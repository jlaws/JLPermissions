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
@import EventKit;
@import EventKitUI;
@import AssetsLibrary;

#undef LOG_LEVEL_DEF
#define LOG_LEVEL_DEF JLPermissionsLogLevel

#ifdef DEBUG
static const int JLPermissionsLogLevel = LOG_LEVEL_INFO;
#else
static const int JLPermissionsLogLevel = LOG_LEVEL_ERROR;
#endif

@interface JLPermissions ()<UIAlertViewDelegate>

@property(nonatomic, strong) AuthorizationBlock contactsCompletionHandler;
@property(nonatomic, strong) AuthorizationBlock calendarCompletionHandler;
@property(nonatomic, strong) AuthorizationBlock photosCompletionHandler;
@property(nonatomic, strong) AuthorizationBlock remindersCompletionHandler;
@property(nonatomic, strong) AuthorizationBlock notificationsCompletionHandler;

@end

typedef NS_ENUM(NSInteger, JLAuthorizationTags) {
  kContactsTag = 100,
  kPhotoLibraryTag,
  kNotificationsTag,
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

#pragma mark - Contacts

- (BOOL)contactsAuthorized {
  return ABAddressBookGetAuthorizationStatus() ==
         kABAuthorizationStatusAuthorized;
}

- (void)authorizeContacts:(AuthorizationBlock)completionHandler {
  NSString *messageTitle =
      [NSString stringWithFormat:@"\"%@\" Would Like to Access Your Contacts",
                                 [self appName]];
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
      self.contactsCompletionHandler = completionHandler;
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

#pragma mark - Calendar

- (BOOL)calendarAuthorized {
  return [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent] ==
         EKAuthorizationStatusAuthorized;
}

- (void)authorizeCalendar:(AuthorizationBlock)completionHandler {
  NSString *messageTitle =
      [NSString stringWithFormat:@"\"%@\" Would Like to Access Your Calendar",
                                 [self appName]];
  NSString *message = nil;
  NSString *cancelTitle = @"Don't Allow";
  NSString *grantTitle = @"Ok";
  [self authorizeCalendarWithTitle:messageTitle
                           message:message
                       cancelTitle:cancelTitle
                        grantTitle:grantTitle
                 completionHandler:completionHandler];
}

- (void)authorizeCalendarWithTitle:(NSString *)messageTitle
                           message:(NSString *)message
                       cancelTitle:(NSString *)cancelTitle
                        grantTitle:(NSString *)grantTitle
                 completionHandler:(AuthorizationBlock)completionHandler {
  EKAuthorizationStatus authorizationStatus =
      [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];

  switch (authorizationStatus) {
    case EKAuthorizationStatusAuthorized: {
      completionHandler(true, nil);
    } break;
    case EKAuthorizationStatusNotDetermined: {
      self.calendarCompletionHandler = completionHandler;
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:messageTitle
                                                      message:message
                                                     delegate:self
                                            cancelButtonTitle:cancelTitle
                                            otherButtonTitles:grantTitle, nil];
      alert.tag = kCalendarTag;
      [alert show];
    } break;
    case EKAuthorizationStatusRestricted:
    case EKAuthorizationStatusDenied: {
      [self displayErrorDialog:@"Calendars"];

      completionHandler(false, [NSError errorWithDomain:@"Denied"
                                                   code:kJLPermissionDenied
                                               userInfo:nil]);
    } break;
  }
}

#pragma mark - Photos

- (BOOL)photosAuthorized {
  return
      [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized;
}

- (void)authorizePhotos:(AuthorizationBlock)completionHandler {
}
- (void)authorizePhotosWithTitle:(NSString *)messageTitle
                         message:(NSString *)message
                     cancelTitle:(NSString *)cancelTitle
                      grantTitle:(NSString *)grantTitle
               completionHandler:(AuthorizationBlock)completionHandler {
}

#pragma mark - Reminders

- (BOOL)remindersAuthorized {
  return [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder] ==
         EKAuthorizationStatusAuthorized;
}

- (void)authorizeReminders:(AuthorizationBlock)completionHandler {
  NSString *messageTitle =
      [NSString stringWithFormat:@"\"%@\" Would Like to Access Your Reminders",
                                 [self appName]];
  NSString *message = nil;
  NSString *cancelTitle = @"Don't Allow";
  NSString *grantTitle = @"Ok";
  [self authorizeRemindersWithTitle:messageTitle
                            message:message
                        cancelTitle:cancelTitle
                         grantTitle:grantTitle
                  completionHandler:completionHandler];
}

- (void)authorizeRemindersWithTitle:(NSString *)messageTitle
                            message:(NSString *)message
                        cancelTitle:(NSString *)cancelTitle
                         grantTitle:(NSString *)grantTitle
                  completionHandler:(AuthorizationBlock)completionHandler {
  EKAuthorizationStatus authorizationStatus =
      [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];

  switch (authorizationStatus) {
    case EKAuthorizationStatusAuthorized: {
      completionHandler(true, nil);
    } break;
    case EKAuthorizationStatusNotDetermined: {
      self.remindersCompletionHandler = completionHandler;
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:messageTitle
                                                      message:message
                                                     delegate:self
                                            cancelButtonTitle:cancelTitle
                                            otherButtonTitles:grantTitle, nil];
      alert.tag = kRemindersTag;
      [alert show];
    } break;
    case EKAuthorizationStatusRestricted:
    case EKAuthorizationStatusDenied: {
      [self displayErrorDialog:@"Reminders"];

      completionHandler(false, [NSError errorWithDomain:@"Denied"
                                                   code:kJLPermissionDenied
                                               userInfo:nil]);
    } break;
  }
}

#pragma mark - Notifications

- (BOOL)notificationsAuthorized {
  return [[UIApplication sharedApplication] enabledRemoteNotificationTypes] !=
         UIRemoteNotificationTypeNone;
}

- (void)authorizeNotifications:(AuthorizationBlock)completionHandler {
}

- (void)authorizeNotificationsWithTitle:(NSString *)messageTitle
                                message:(NSString *)message
                            cancelTitle:(NSString *)cancelTitle
                             grantTitle:(NSString *)grantTitle
                      completionHandler:(AuthorizationBlock)completionHandler {
}

- (NSString *)parseDeviceID:(NSData *)deviceToken {
  NSString *token = [deviceToken description];
  return [[self regex]
      stringByReplacingMatchesInString:token
                               options:0
                                 range:NSMakeRange(0, [token length])
                          withTemplate:@""];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  BOOL canceled = (buttonIndex == alertView.cancelButtonIndex);
  dispatch_async(dispatch_get_main_queue(), ^{
      if (canceled) {
        NSError *error = [NSError errorWithDomain:@"Denied"
                                             code:kJLPermissionDenied
                                         userInfo:nil];
        switch (alertView.tag) {
          case kContactsTag:
            self.contactsCompletionHandler(false, error);
            break;
          case kPhotoLibraryTag:
            self.photosCompletionHandler(false, error);
            break;
          case kNotificationsTag:
            self.notificationsCompletionHandler(false, error);
            break;
          case kCalendarTag:
            self.calendarCompletionHandler(false, error);
            break;
          case kRemindersTag:
            self.remindersCompletionHandler(false, error);
            break;
        }
      } else {
        switch (alertView.tag) {
          case kContactsTag:
            [self actuallyAuthorizeContacts];
            break;
          case kPhotoLibraryTag:
            [self actuallyAuthorizePhotos];
            break;
          case kNotificationsTag:
            [self actuallyAuthorizeNotifications];
            break;
          case kCalendarTag:
            [self actuallyAuthorizeCalendar];
            break;
          case kRemindersTag:
            [self actuallyAuthorizeReminders];
            break;
        }
      }
  });
}

#pragma mark - Helpers

- (NSString *)appName {
  return
      [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

- (NSRegularExpression *)regex {
  NSError *error;
  NSRegularExpression *exp = [NSRegularExpression
      regularExpressionWithPattern:@"[<> ]"
                           options:NSRegularExpressionCaseInsensitive
                             error:&error];

  if (!exp) {
    DDLogError(@"Failed to instantiate the regex parser due to %@", error);
  }

  return exp;
}

- (void)displayErrorDialog:(NSString *)authorizationType {
  NSString *message =
      [NSString stringWithFormat:@"Please go to Settings -> Privacy -> "
                                 @"%@ to re-enable %@'s access.",
                                 authorizationType, [self appName]];
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
      self.contactsCompletionHandler(true, nil);
    } break;
    case kABAuthorizationStatusNotDetermined: {
      ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
      ABAddressBookRequestAccessWithCompletion(
          addressBook, ^(bool granted, CFErrorRef error) {
              dispatch_async(dispatch_get_main_queue(), ^{
                  if (granted) {
                    self.contactsCompletionHandler(true, nil);
                  } else {
                    NSError *e = (__bridge NSError *)error;
                    self.contactsCompletionHandler(
                        false, [NSError errorWithDomain:e.domain
                                                   code:kJLPermissionDenied
                                               userInfo:e.userInfo]);
                  }
              });
          });
    } break;
    case kABAuthorizationStatusRestricted:
    case kABAuthorizationStatusDenied: {
      self.contactsCompletionHandler(
          false, [NSError errorWithDomain:@"Denied"
                                     code:kJLPermissionDenied
                                 userInfo:nil]);
    } break;
  }
}

- (void)actuallyAuthorizeCalendar {
  EKAuthorizationStatus authorizationStatus =
      [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];

  switch (authorizationStatus) {
    case EKAuthorizationStatusAuthorized: {
      self.calendarCompletionHandler(true, nil);
    } break;
    case EKAuthorizationStatusNotDetermined: {
      EKEventStore *eventStore = [[EKEventStore alloc] init];
      [eventStore
          requestAccessToEntityType:EKEntityTypeEvent
                         completion:^(BOOL granted, NSError *error) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 if (granted) {
                                   self.calendarCompletionHandler(true, nil);
                                 } else {
                                   self.calendarCompletionHandler(
                                       false,
                                       [NSError
                                           errorWithDomain:error.domain
                                                      code:kJLPermissionDenied
                                                  userInfo:error.userInfo]);
                                 }
                             });
                         }];
    } break;
    case EKAuthorizationStatusRestricted:
    case EKAuthorizationStatusDenied: {
      self.calendarCompletionHandler(
          false, [NSError errorWithDomain:@"Denied"
                                     code:kJLPermissionDenied
                                 userInfo:nil]);
    } break;
  }
}

- (void)actuallyAuthorizePhotos {
}

- (void)actuallyAuthorizeReminders {
  EKAuthorizationStatus authorizationStatus =
      [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];

  switch (authorizationStatus) {
    case EKAuthorizationStatusAuthorized: {
      self.remindersCompletionHandler(true, nil);
    } break;
    case EKAuthorizationStatusNotDetermined: {
      EKEventStore *eventStore = [[EKEventStore alloc] init];
      [eventStore
          requestAccessToEntityType:EKEntityTypeReminder
                         completion:^(BOOL granted, NSError *error) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 if (granted) {
                                   self.remindersCompletionHandler(true, nil);
                                 } else {
                                   self.remindersCompletionHandler(
                                       false,
                                       [NSError
                                           errorWithDomain:error.domain
                                                      code:kJLPermissionDenied
                                                  userInfo:error.userInfo]);
                                 }
                             });
                         }];
    } break;
    case EKAuthorizationStatusRestricted:
    case EKAuthorizationStatusDenied: {
      self.remindersCompletionHandler(
          false, [NSError errorWithDomain:@"Denied"
                                     code:kJLPermissionDenied
                                 userInfo:nil]);
    } break;
  }
}

- (void)actuallyAuthorizeNotifications {
}

@end
