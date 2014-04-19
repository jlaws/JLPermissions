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

@end

#define kAddressBookTag 100
#define kPhotoLibraryTag 101
#define kPushNotificationTag 102

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

- (BOOL)addressBookAuthorized {
  return ABAddressBookGetAuthorizationStatus() ==
         kABAuthorizationStatusAuthorized;
}
- (void)authorizeAddressBook:(AuthorizationBlock)block {

  ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();

  switch (status) {
    case kABAuthorizationStatusAuthorized: {
      block(true, nil);
    } break;
    case kABAuthorizationStatusNotDetermined: {
      ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
      ABAddressBookRequestAccessWithCompletion(
          addressBook, ^(bool granted, CFErrorRef error) {
              if (granted) {
                block(true, nil);
              } else {
                block(false, (__bridge NSError *)error);
              }
          });
    } break;
    case kABAuthorizationStatusDenied: {
      block(false, [NSError errorWithDomain:@"Denied"
                                       code:kABAuthorizationStatusDenied
                                   userInfo:nil]);
    } break;
    case kABAuthorizationStatusRestricted: {
      block(false, [NSError errorWithDomain:@"Restricted"
                                       code:kABAuthorizationStatusRestricted
                                   userInfo:nil]);
    } break;
    default: {
      block(false, [NSError errorWithDomain:@"Unknown"
                                       code:kABAuthorizationStatusNotDetermined
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
}

@end
