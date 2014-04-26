//
//  JLPermissions.m
//  Joseph Laws
//
//  Created by Joseph Laws on 4/19/14.
//  Copyright (c) 2014 Joe Laws. All rights reserved.
//

#import "JLPermissions.h"
@import AddressBook;
@import EventKit;
@import EventKitUI;
@import AssetsLibrary;
@import CoreLocation;

@interface JLPermissions ()<UIAlertViewDelegate, CLLocationManagerDelegate>

@property(nonatomic, strong) AuthorizationBlock contactsCompletionHandler;
@property(nonatomic, strong) AuthorizationBlock calendarCompletionHandler;
@property(nonatomic, strong) AuthorizationBlock photosCompletionHandler;
@property(nonatomic, strong) AuthorizationBlock remindersCompletionHandler;
@property(nonatomic, strong) AuthorizationBlock locationsCompletionHandler;
@property(nonatomic, strong) NotificationAuthorizationBlock notificationsCompletionHandler;

@property(nonatomic, strong) CLLocationManager *locationManager;
@end

typedef NS_ENUM(NSInteger, JLAuthorizationStatus) {
  kJLPermissionNotDetermined = 0,
  kJLPermissionDenied,
  kJLPermissionAuthorized
};

typedef NS_ENUM(NSInteger, JLAuthorizationTags) {
  kContactsTag = 100,
  kPhotosTag,
  kNotificationsTag,
  kCalendarTag,
  kRemindersTag,
  kLocationsTag
};

#define kJLDeviceToken @"JLDeviceToken"
#define kJLAskedForNotificationPermission @"JLAskedForNotificationPermission"

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
  [self authorizeContactsWithTitle:[self defaultTitle:@"Contacts"]
                           message:[self defaultMessage]
                       cancelTitle:[self defaultCancelTitle]
                        grantTitle:[self defaultGrantTitle]
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

      completionHandler(false, [NSError errorWithDomain:@"PreviouslyDenied"
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
  [self authorizeCalendarWithTitle:[self defaultTitle:@"Calendar"]
                           message:[self defaultMessage]
                       cancelTitle:[self defaultCancelTitle]
                        grantTitle:[self defaultGrantTitle]
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

      completionHandler(false, [NSError errorWithDomain:@"PreviouslyDenied"
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
  [self authorizePhotosWithTitle:[self defaultTitle:@"Photos"]
                         message:[self defaultMessage]
                     cancelTitle:[self defaultCancelTitle]
                      grantTitle:[self defaultGrantTitle]
               completionHandler:completionHandler];
}

- (void)authorizePhotosWithTitle:(NSString *)messageTitle
                         message:(NSString *)message
                     cancelTitle:(NSString *)cancelTitle
                      grantTitle:(NSString *)grantTitle
               completionHandler:(AuthorizationBlock)completionHandler {
  ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
  switch (status) {
    case ALAuthorizationStatusAuthorized:
      completionHandler(true, nil);
      break;
    case ALAuthorizationStatusNotDetermined: {
      self.photosCompletionHandler = completionHandler;
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:messageTitle
                                                      message:message
                                                     delegate:self
                                            cancelButtonTitle:cancelTitle
                                            otherButtonTitles:grantTitle, nil];
      alert.tag = kPhotosTag;
      [alert show];
    } break;
    case ALAuthorizationStatusRestricted:
    case ALAuthorizationStatusDenied: {
      [self displayErrorDialog:@"Photos"];

      completionHandler(false, [NSError errorWithDomain:@"PreviouslyDenied"
                                                   code:kJLPermissionDenied
                                               userInfo:nil]);
    } break;
  }
}

#pragma mark - Reminders

- (BOOL)remindersAuthorized {
  return [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder] ==
         EKAuthorizationStatusAuthorized;
}

- (void)authorizeReminders:(AuthorizationBlock)completionHandler {
  [self authorizeRemindersWithTitle:[self defaultTitle:@"Reminders"]
                            message:[self defaultMessage]
                        cancelTitle:[self defaultCancelTitle]
                         grantTitle:[self defaultGrantTitle]
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

      completionHandler(false, [NSError errorWithDomain:@"PreviouslyDenied"
                                                   code:kJLPermissionDenied
                                               userInfo:nil]);
    } break;
  }
}

#pragma mark - Locations

- (BOOL)locationsAuthorized {
    return [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized;
}

- (void)authorizeLocations:(AuthorizationBlock)completionHandler {
    [self authorizeLocationsWithTitle:[self defaultTitle:@"Locations"]
                              message:[self defaultMessage]
                          cancelTitle:[self defaultCancelTitle]
                           grantTitle:[self defaultGrantTitle]
                    completionHandler:completionHandler];
}

- (void)authorizeLocationsWithTitle:(NSString *)messageTitle
                            message:(NSString *)message
                        cancelTitle:(NSString *)cancelTitle
                         grantTitle:(NSString *)grantTitle
                  completionHandler:(AuthorizationBlock)completionHandler {

    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    switch (authorizationStatus) {
        case kCLAuthorizationStatusAuthorized: {
            completionHandler(true, nil);
        } break;
        case kCLAuthorizationStatusNotDetermined: {
            self.locationsCompletionHandler = completionHandler;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:messageTitle
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:cancelTitle
                                                  otherButtonTitles:grantTitle, nil];
            alert.tag = kLocationsTag;
            [alert show];
        } break;
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted: {
            [self displayErrorDialog:@"Locations"];

            completionHandler(false, [NSError errorWithDomain:@"PreviouslyDenied"
                                                         code:kJLPermissionDenied
                                                     userInfo:nil]);
        } break;
    }
}

#pragma mark - Notifications

- (BOOL)notificationsAuthorized {
  return [[NSUserDefaults standardUserDefaults] objectForKey:kJLDeviceToken] !=
         nil;
}

- (void)authorizeNotifications:
            (NotificationAuthorizationBlock)completionHandler {
  NSString *messageTitle = [NSString
      stringWithFormat:@"\"%@\" Would Like to Access Your Notifications",
                       [self appName]];
  [self authorizeNotificationsWithTitle:messageTitle
                                message:[self defaultMessage]
                            cancelTitle:[self defaultCancelTitle]
                             grantTitle:[self defaultGrantTitle]
                      completionHandler:completionHandler];
}

- (void)authorizeNotificationsWithTitle:(NSString *)messageTitle
                                message:(NSString *)message
                            cancelTitle:(NSString *)cancelTitle
                             grantTitle:(NSString *)grantTitle
                      completionHandler:
                          (NotificationAuthorizationBlock)completionHandler {
  self.notificationsCompletionHandler = completionHandler;

  bool previouslyAsked = [[NSUserDefaults standardUserDefaults]
      boolForKey:kJLAskedForNotificationPermission];

  NSString *existingID =
      [[NSUserDefaults standardUserDefaults] objectForKey:kJLDeviceToken];

  if (existingID) {
    completionHandler(existingID, nil);
  } else if ([[UIApplication
                     sharedApplication] enabledRemoteNotificationTypes] !=
             UIRemoteNotificationTypeNone) {
    [self actuallyAuthorizeNotifications];
  } else if (!previouslyAsked) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:messageTitle
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:cancelTitle
                                          otherButtonTitles:grantTitle, nil];
    alert.tag = kNotificationsTag;
    [alert show];
  } else {
    NSString *message = [NSString
        stringWithFormat:@"Please go to Settings -> Notification Center -> "
                         @"%@ to re-enable push notifications.",
                         [self appName]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
    completionHandler(false, [NSError errorWithDomain:@"PreviouslyDenied"
                                                 code:kJLPermissionDenied
                                             userInfo:nil]);
  }
}

- (void)unauthorizeNotifications {
  [[UIApplication sharedApplication] unregisterForRemoteNotifications];
  [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kJLDeviceToken];
  [[NSUserDefaults standardUserDefaults]
      setBool:false
       forKey:kJLAskedForNotificationPermission];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)notificationResult:(NSData *)deviceToken error:(NSError *)error {
  if (deviceToken) {
    NSString *deviceID =
        [[JLPermissions sharedInstance] parseDeviceID:deviceToken];

    [[NSUserDefaults standardUserDefaults] setObject:deviceID
                                              forKey:kJLDeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];

    if (self.notificationsCompletionHandler) {
      self.notificationsCompletionHandler(deviceID, nil);
    }
  } else {
    if (self.notificationsCompletionHandler) {
      NSError *e = [NSError errorWithDomain:@"UserDenied"
                                       code:kJLPermissionDenied
                                   userInfo:error.userInfo];

      self.notificationsCompletionHandler(nil, e);
    }
  }
}

- (NSString *)deviceID {
  return [[NSUserDefaults standardUserDefaults] objectForKey:kJLDeviceToken];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  BOOL canceled = (buttonIndex == alertView.cancelButtonIndex);
  dispatch_async(dispatch_get_main_queue(), ^{
      if (canceled) {
        NSError *error = [NSError errorWithDomain:@"UserDenied"
                                             code:kJLPermissionDenied
                                         userInfo:nil];
        switch (alertView.tag) {
          case kContactsTag:
            self.contactsCompletionHandler(false, error);
            break;
          case kPhotosTag:
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
          case kLocationsTag:
            self.locationsCompletionHandler(false, error);
            break;
        }
      } else {
        switch (alertView.tag) {
          case kContactsTag:
            [self actuallyAuthorizeContacts];
            break;
          case kPhotosTag:
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
          case kLocationsTag:
            [self actuallyAuthorizeLocations];
            break;
        }
      }
  });
}

#pragma mark - Helpers

- (NSString *)defaultTitle:(NSString *)authorizationType {
  return [NSString stringWithFormat:@"\"%@\" Would Like to Access Your %@",
                                    [self appName], authorizationType];
}

- (NSString *)defaultMessage {
  return nil;
}

- (NSString *)defaultCancelTitle {
  return @"Don't Allow";
}

- (NSString *)defaultGrantTitle {
  return @"Ok";
}

- (NSString *)appName {
  return
      [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

- (NSString *)parseDeviceID:(NSData *)deviceToken {
  NSString *token = [deviceToken description];
  return [[self regex]
      stringByReplacingMatchesInString:token
                               options:0
                                 range:NSMakeRange(0, [token length])
                          withTemplate:@""];
}

- (NSRegularExpression *)regex {
  NSError *error;
  NSRegularExpression *exp = [NSRegularExpression
      regularExpressionWithPattern:@"[<> ]"
                           options:NSRegularExpressionCaseInsensitive
                             error:&error];

  if (!exp) {
    NSLog(@"Failed to instantiate the regex parser due to %@", error);
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
                        false, [NSError errorWithDomain:@"SystemDenied"
                                                   code:kJLPermissionDenied
                                               userInfo:e.userInfo]);
                  }
              });
          });
    } break;
    case kABAuthorizationStatusRestricted:
    case kABAuthorizationStatusDenied: {
      [self displayErrorDialog:@"Contacts"];
      self.contactsCompletionHandler(
          false, [NSError errorWithDomain:@"PreviouslyDenied"
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
                                           errorWithDomain:@"SystemDenied"
                                                      code:kJLPermissionDenied
                                                  userInfo:error.userInfo]);
                                 }
                             });
                         }];
    } break;
    case EKAuthorizationStatusRestricted:
    case EKAuthorizationStatusDenied: {
      [self displayErrorDialog:@"Calendars"];
      self.calendarCompletionHandler(
          false, [NSError errorWithDomain:@"PreviouslyDenied"
                                     code:kJLPermissionDenied
                                 userInfo:nil]);
    } break;
  }
}

- (void)actuallyAuthorizePhotos {
  ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
  switch (status) {
    case ALAuthorizationStatusAuthorized:
      self.photosCompletionHandler(true, nil);
      break;
    case ALAuthorizationStatusNotDetermined: {
      ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];

      [library enumerateGroupsWithTypes:ALAssetsGroupAll
          usingBlock:^(ALAssetsGroup *assetGroup, BOOL *stop) {
              if (*stop) {
                self.photosCompletionHandler(true, nil);
              } else {
                *stop = YES;
              }
          }
          failureBlock:^(NSError *error) {
              self.photosCompletionHandler(
                  false, [NSError errorWithDomain:@"SystemDenied"
                                             code:kJLPermissionDenied
                                         userInfo:error.userInfo]);
          }];
    } break;
    case ALAuthorizationStatusRestricted:
    case ALAuthorizationStatusDenied: {
      [self displayErrorDialog:@"Photos"];

      self.photosCompletionHandler(false,
                                   [NSError errorWithDomain:@"PreviouslyDenied"
                                                       code:kJLPermissionDenied
                                                   userInfo:nil]);
    } break;
  }
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
                                           errorWithDomain:@"SystemDenied"
                                                      code:kJLPermissionDenied
                                                  userInfo:error.userInfo]);
                                 }
                             });
                         }];
    } break;
    case EKAuthorizationStatusRestricted:
    case EKAuthorizationStatusDenied: {
      [self displayErrorDialog:@"Reminders"];
      self.remindersCompletionHandler(
          false, [NSError errorWithDomain:@"PreviouslyDenied"
                                     code:kJLPermissionDenied
                                 userInfo:nil]);
    } break;
  }
}

- (void)actuallyAuthorizeLocations {

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusAuthorized: {
            self.locationsCompletionHandler(true, nil);
            
            [self.locationManager stopUpdatingLocation];
            self.locationManager = nil;
            break;
        }

        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted: {
            [self displayErrorDialog:@"Locations"];

            NSError *error = [NSError errorWithDomain:@"PreviouslyDenied" code:kJLPermissionDenied userInfo:nil];
            self.locationsCompletionHandler(false, error);
            
            [self.locationManager stopUpdatingLocation];
            self.locationManager = nil;
            break;
        }

        default:
            break;
    }
}

- (void)actuallyAuthorizeNotifications {
  [[NSUserDefaults standardUserDefaults]
      setBool:true
       forKey:kJLAskedForNotificationPermission];
  [[NSUserDefaults standardUserDefaults] synchronize];

  [[UIApplication sharedApplication]
      registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert |
                                          UIRemoteNotificationTypeBadge |
                                          UIRemoteNotificationTypeSound)];
}

@end
