//
//  JLPermissions.m
//  Joseph Laws
//
//  Created by Joseph Laws on 4/19/14.
//  Copyright (c) 2014 Joe Laws. All rights reserved.
//

#import "JLPermissions.h"
#import "DDLog.h"
@import AddressBook;

#undef LOG_LEVEL_DEF
#define LOG_LEVEL_DEF JLPermissionsLogLevel

#ifdef DEBUG
static const int JLPermissionsLogLevel = LOG_LEVEL_INFO;
#else
static const int JLPermissionsLogLevel = LOG_LEVEL_ERROR;
#endif

@interface JLPermissions ()<UIAlertViewDelegate>

@property(nonatomic, strong) NSRegularExpression *regex;
@property(nonatomic, strong) AuthorizationBlock callback;

@end

typedef NS_ENUM(NSInteger, JLAuthorizationTags) {
  kContactsTag = 100,
  kPhotoLibraryTag,
  kPushNotificationTag,
  kCalendarTag,
  kRemindersTag
};

@implementation JLPermissions

+ (instancetype)sharedInstance {
  static JLPermissions *_instance = nil;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{ _instance = [[JLPermissions alloc] init]; });

  return _instance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    self.appName = [[NSBundle mainBundle]
        objectForInfoDictionaryKey:@"CFBundleDisplayName"];

    NSError *error;
    self.regex = [NSRegularExpression
        regularExpressionWithPattern:@"[<> ]"
                             options:NSRegularExpressionCaseInsensitive
                               error:&error];

    if (error) {
      DDLogError(@"Failed to instantiate the regex parser");
      return nil;
    }
  }
  return self;
}

- (BOOL)contactsAuthorized {
  return ABAddressBookGetAuthorizationStatus() ==
         kABAuthorizationStatusAuthorized;
}

- (void)authorizeContacts:(AuthorizationBlock)completionHandler {
  NSString *messageTitle =
      [NSString stringWithFormat:@"\"%@\" Would Like to Access Your Contacts",
                                 self.appName];
  NSString *message = nil;
  NSString *cancelTitle = @"Don't Allow";
  NSString *grantTitle = @"Ok";
  [self authorizeContactsWithTitle:messageTitle
                           message:message
                       cancelTitle:cancelTitle
                        grantTitle:grantTitle
                 completionHandler:completionHandler];
}

- (void)authorizeContactsWithTitle:(NSString *)messageTitle
                           message:(NSString *)message
                       cancelTitle:(NSString *)cancelTitle
                        grantTitle:(NSString *)grantTitle
                 completionHandler:(AuthorizationBlock)completionHandler {

  ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();

  switch (status) {
    case kABAuthorizationStatusAuthorized: {
      completionHandler(true, nil);
    } break;
    case kABAuthorizationStatusNotDetermined: {
      self.callback = completionHandler;
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:messageTitle
                                                      message:message
                                                     delegate:self
                                            cancelButtonTitle:cancelTitle
                                            otherButtonTitles:grantTitle, nil];
      alert.tag = kContactsTag;
      [alert show];
    } break;
    case kABAuthorizationStatusRestricted:
    case kABAuthorizationStatusDenied: {
      [self displayErrorDialog:@"Contacts"];

      completionHandler(false, [NSError errorWithDomain:@"Denied"
                                                   code:kJLPermissionDenied
                                               userInfo:nil]);
    } break;
  }
}

- (NSString *)parseDeviceID:(NSData *)deviceToken {
  NSString *token = [deviceToken description];
  return [self.regex
      stringByReplacingMatchesInString:token
                               options:0
                                 range:NSMakeRange(0, [token length])
                          withTemplate:@""];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  dispatch_async(dispatch_get_main_queue(), ^{
      if (buttonIndex == alertView.cancelButtonIndex) {
        self.callback(false, [NSError errorWithDomain:@"Denied"
                                                 code:kJLPermissionDenied
                                             userInfo:nil]);
      } else {
        switch (alertView.tag) {
          case kContactsTag:
            [self actuallyAuthorizeContacts];
            break;
          case kPhotoLibraryTag:
            break;
          case kPushNotificationTag:
            break;
          case kCalendarTag:
            break;
          case kRemindersTag:
            break;
        }
      }
  });
}

#pragma mark - Helpers

- (void)displayErrorDialog:(NSString *)authorizationType {
  NSString *message =
      [NSString stringWithFormat:@"Please go to Settings -> Privacy -> "
                                 @"%@ to re-enable %@'s access.",
                                 authorizationType, self.appName];
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                  message:message
                                                 delegate:nil
                                        cancelButtonTitle:@"Ok"
                                        otherButtonTitles:nil];
  [alert show];
}

- (void)actuallyAuthorizeContacts {

  ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();

  switch (status) {
    case kABAuthorizationStatusAuthorized: {
      self.callback(true, nil);
    } break;
    case kABAuthorizationStatusNotDetermined: {
      ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
      ABAddressBookRequestAccessWithCompletion(
          addressBook, ^(bool granted, CFErrorRef error) {
              dispatch_async(dispatch_get_main_queue(), ^{
                  if (granted) {
                    self.callback(true, nil);
                  } else {
                    NSError *e = (__bridge NSError *)error;
                    self.callback(false,
                                  [NSError errorWithDomain:e.domain
                                                      code:kJLPermissionDenied
                                                  userInfo:e.userInfo]);
                  }
              });
          });
    } break;
    case kABAuthorizationStatusRestricted:
    case kABAuthorizationStatusDenied: {
      self.callback(false, [NSError errorWithDomain:@"Denied"
                                               code:kJLPermissionDenied
                                           userInfo:nil]);
    } break;
  }
}

@end
