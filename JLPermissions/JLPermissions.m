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
@import AssetsLibrary;
@import CoreLocation;
@import Accounts;
@import AVFoundation;
@import HealthKit;

@interface JLPermissions () <UIAlertViewDelegate, CLLocationManagerDelegate>

@property(nonatomic, strong) AuthorizationBlock contactsCompletionHandler;
@property(nonatomic, strong) AuthorizationBlock calendarCompletionHandler;
@property(nonatomic, strong) AuthorizationBlock photosCompletionHandler;
@property(nonatomic, strong) AuthorizationBlock remindersCompletionHandler;
@property(nonatomic, strong) AuthorizationBlock microphoneCompletionHandler;
@property(nonatomic, strong) AuthorizationBlock healthCompletionHandler;
@property(nonatomic, strong) AuthorizationBlock locationsCompletionHandler;
@property(nonatomic, strong) AuthorizationBlock twitterCompletionHandler;
@property(nonatomic, strong) AuthorizationBlock facebookCompletionHandler;
@property(nonatomic, strong)
    NotificationAuthorizationBlock notificationsCompletionHandler;

@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) NSSet *healthReadTypes;
@property(nonatomic, strong) NSSet *healthWriteTypes;

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
  kMicrophoneTag,
  kHealthTag,
  kTwitterTag,
  kFacebookTag,
  kLocationsTag
};

#define kJLDeviceToken @"JLDeviceToken"
#define kJLAskedForNotificationPermission @"JLAskedForNotificationPermission"
#define kJLAskedForTwitterPermission @"JLAskedForTwitterPermission"
#define kJLAskedForFacebookPermission @"JLAskedForFacebookPermission"

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
      completionHandler(false, [self previouslyDeniedError]);
    } break;
  }
}

- (void)displayContactsErrorDialog {
  [self displayErrorDialog:@"Contacts"];
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
      completionHandler(false, [self previouslyDeniedError]);
    } break;
  }
}

- (void)displayCalendarErrorDialog {
  [self displayErrorDialog:@"Calendars"];
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
      completionHandler(false, [self previouslyDeniedError]);
    } break;
  }
}

- (void)displayPhotoErrorDialog {
  [self displayErrorDialog:@"Photos"];
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

      completionHandler(false, [self previouslyDeniedError]);
    } break;
  }
}

- (void)displayRemindersErrorDialog {
  [self displayErrorDialog:@"Reminders"];
}

#pragma mark - Microphone

- (BOOL)microphoneAuthorized {
  AVAudioSession *audioSession = [AVAudioSession sharedInstance];
  if ([audioSession respondsToSelector:@selector(recordPermission)]) {
    AVAudioSessionRecordPermission permission =
        [[AVAudioSession sharedInstance] recordPermission];
    switch (permission) {
      case AVAudioSessionRecordPermissionGranted:
        return YES;
      case AVAudioSessionRecordPermissionDenied:
      case AVAudioSessionRecordPermissionUndetermined:
        return NO;
    }
  } else {
    return NO;
  }
}

- (void)authorizeMicrophone:(AuthorizationBlock)completionHandler {
  [self authorizeMicrophoneWithTitle:[self defaultTitle:@"Microphone"]
                             message:[self defaultMessage]
                         cancelTitle:[self defaultCancelTitle]
                          grantTitle:[self defaultGrantTitle]
                   completionHandler:completionHandler];
}

- (void)authorizeMicrophoneWithTitle:(NSString *)messageTitle
                             message:(NSString *)message
                         cancelTitle:(NSString *)cancelTitle
                          grantTitle:(NSString *)grantTitle
                   completionHandler:(AuthorizationBlock)completionHandler {
  AVAudioSession *audioSession = [AVAudioSession sharedInstance];
  if ([audioSession respondsToSelector:@selector(recordPermission)]) {
    completionHandler(false, [self previouslyDeniedError]);
    return;
  }
  AVAudioSessionRecordPermission permission = [audioSession recordPermission];
  switch (permission) {
    case AVAudioSessionRecordPermissionGranted: {
      completionHandler(true, nil);
    } break;
    case AVAudioSessionRecordPermissionDenied: {
      completionHandler(false, [self previouslyDeniedError]);
    } break;
    case AVAudioSessionRecordPermissionUndetermined: {
      self.microphoneCompletionHandler = completionHandler;
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:messageTitle
                                                      message:message
                                                     delegate:self
                                            cancelButtonTitle:cancelTitle
                                            otherButtonTitles:grantTitle, nil];
      alert.tag = kMicrophoneTag;
      [alert show];
    } break;
  }
}

- (void)displayMicrophoneErrorDialog {
  [self displayErrorDialog:@"Microphone"];
}

#pragma mark - Health

- (BOOL)healthAuthorized {
  HKHealthStore *healthStore = [[HKHealthStore alloc] init];
  NSMutableSet *allTypes = [NSMutableSet set];
  if (self.healthReadTypes.count) {
    [allTypes unionSet:self.healthReadTypes];
  }

  if (self.healthWriteTypes.count) {
    [allTypes unionSet:self.healthWriteTypes];
  }

  BOOL hasAuthorized = NO;
  for (HKObjectType *sampleType in allTypes) {
    HKAuthorizationStatus status =
        [healthStore authorizationStatusForType:sampleType];
    switch (status) {
      case HKAuthorizationStatusSharingDenied:
      case HKAuthorizationStatusNotDetermined:
        return NO;
      case HKAuthorizationStatusSharingAuthorized: {
        hasAuthorized = YES;
      }
    }
  }
  return hasAuthorized;
}

- (void)authorizeHealth:(AuthorizationBlock)completionHandler {
  [self authorizeHealthWithTitle:[self defaultTitle:@"Health"]
                         message:[self defaultMessage]
                     cancelTitle:[self defaultCancelTitle]
                      grantTitle:[self defaultGrantTitle]
               completionHandler:completionHandler];
}

- (void)authorizeHealthWithTitle:(NSString *)messageTitle
                         message:(NSString *)message
                     cancelTitle:(NSString *)cancelTitle
                      grantTitle:(NSString *)grantTitle
               completionHandler:(AuthorizationBlock)completionHandler {
  NSMutableSet *allTypes = [[NSMutableSet alloc] init];
  if (self.healthReadTypes.count) {
    [allTypes unionSet:self.healthReadTypes];
  }

  if (self.healthWriteTypes.count) {
    [allTypes unionSet:self.healthWriteTypes];
  }

  HKHealthStore *healthStore = [[HKHealthStore alloc] init];
  for (HKObjectType *healthType in allTypes) {
    HKAuthorizationStatus status =
        [healthStore authorizationStatusForType:healthType];
    switch (status) {
      case HKAuthorizationStatusNotDetermined: {
        self.healthCompletionHandler = completionHandler;
        UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle:messageTitle
                                       message:message
                                      delegate:self
                             cancelButtonTitle:cancelTitle
                             otherButtonTitles:grantTitle, nil];
        alert.tag = kHealthTag;
        [alert show];
      } break;
      case HKAuthorizationStatusSharingAuthorized: {
        completionHandler(true, nil);
      } break;
      case HKAuthorizationStatusSharingDenied: {
        completionHandler(false, [self previouslyDeniedError]);
      } break;
    }
  }
}

- (void)displayHealthErrorDialog {
  [self displayErrorDialog:@"Health"];
}

#pragma mark - Locations

- (BOOL)locationsAuthorized {
  return [CLLocationManager authorizationStatus] ==
         kCLAuthorizationStatusAuthorizedAlways;
}

- (void)authorizeLocations:(AuthorizationBlock)completionHandler {
  NSString *title = [NSString
      stringWithFormat:@"\"%@\" Would Like to Use Your Current Location",
                       [self appName]];
  [self authorizeLocationsWithTitle:title
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
  CLAuthorizationStatus authorizationStatus =
      [CLLocationManager authorizationStatus];
  switch (authorizationStatus) {
    case kCLAuthorizationStatusAuthorizedAlways:
    case kCLAuthorizationStatusAuthorizedWhenInUse: {
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
      completionHandler(false, [self previouslyDeniedError]);
    } break;
  }
}

- (void)displayLocationsErrorDialog {
  [self displayErrorDialog:@"Location"];
}

#pragma mark - Twitter

- (BOOL)twitterAuthorized {
  ACAccountStore *store = [ACAccountStore new];
  ACAccountType *accountType = [store
      accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
  return [accountType accessGranted];
}

- (void)authorizeTwitter:(AuthorizationBlock)completionHandler {
  NSString *title = [NSString
      stringWithFormat:@"\"%@\" Would Like Access to Twitter Accounts",
                       [self appName]];
  [self authorizeTwitterWithTitle:title
                          message:[self defaultMessage]
                      cancelTitle:[self defaultCancelTitle]
                       grantTitle:[self defaultGrantTitle]
                completionHandler:completionHandler];
}

- (void)authorizeTwitterWithTitle:(NSString *)messageTitle
                          message:(NSString *)message
                      cancelTitle:(NSString *)cancelTitle
                       grantTitle:(NSString *)grantTitle
                completionHandler:(AuthorizationBlock)completionHandler {
  BOOL authorized = [self twitterAuthorized];

  bool previouslyAsked = [[NSUserDefaults standardUserDefaults]
      boolForKey:kJLAskedForTwitterPermission];

  if (authorized) {
    completionHandler(true, nil);
  } else if (!previouslyAsked) {
    self.twitterCompletionHandler = completionHandler;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:messageTitle
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:cancelTitle
                                          otherButtonTitles:grantTitle, nil];
    alert.tag = kTwitterTag;
    [alert show];
  } else {
    self.twitterCompletionHandler = completionHandler;
    [self actuallyAuthorizeTwitter];
  }
}

- (void)displayTwitterErrorDialog {
  [self displayErrorDialog:@"Twitter"];
}

#pragma mark - Facebook

- (BOOL)facebookAuthorized {
  ACAccountStore *store = [ACAccountStore new];
  ACAccountType *accountType = [store
      accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
  return [accountType accessGranted];
}

- (void)authorizeFacebook:(AuthorizationBlock)completionHandler {
  NSString *title = [NSString
      stringWithFormat:@"\"%@\" Would Like Access to Facebook Accounts",
                       [self appName]];
  [self authorizeFacebookWithTitle:title
                           message:[self defaultMessage]
                       cancelTitle:[self defaultCancelTitle]
                        grantTitle:[self defaultGrantTitle]
                 completionHandler:completionHandler];
}

- (void)authorizeFacebookWithTitle:(NSString *)messageTitle
                           message:(NSString *)message
                       cancelTitle:(NSString *)cancelTitle
                        grantTitle:(NSString *)grantTitle
                 completionHandler:(AuthorizationBlock)completionHandler {
  BOOL authorized = [self facebookAuthorized];
  bool previouslyAsked = [[NSUserDefaults standardUserDefaults]
      boolForKey:kJLAskedForFacebookPermission];
  if (authorized) {
    completionHandler(true, nil);
  } else if (!previouslyAsked) {
    self.facebookCompletionHandler = completionHandler;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:messageTitle
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:cancelTitle
                                          otherButtonTitles:grantTitle, nil];
    alert.tag = kFacebookTag;
    [alert show];
  } else {
    self.facebookCompletionHandler = completionHandler;
    [self actuallyAuthorizeFacebook];
  }
}

- (void)displayFacebookErrorDialog {
  [self displayErrorDialog:@"Facebook"];
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

  BOOL notificationsOn = NO;
  if ([[UIApplication sharedApplication]
          respondsToSelector:@selector(currentUserNotificationSettings)]) {
    notificationsOn =
        ([[UIApplication sharedApplication] currentUserNotificationSettings]
             .types != UIUserNotificationTypeNone);
  } else {
    notificationsOn =
        ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] !=
         UIRemoteNotificationTypeNone);
  }
  if (existingID) {
    completionHandler(existingID, nil);
  } else if (notificationsOn) {
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
    completionHandler(false, [self previouslyDeniedError]);
  }
}

- (void)displayNotificationsErrorDialog {
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
      self.notificationsCompletionHandler(nil, [self systemDeniedError:error]);
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
        [self canceledDialog:alertView.tag];
      } else {
        [self approvedDialog:alertView.tag];
      }
  });
}

#pragma mark - Helpers

- (void)canceledDialog:(NSInteger)tag {
  NSError *error = [NSError errorWithDomain:@"UserDenied"
                                       code:kJLPermissionDenied
                                   userInfo:nil];
  switch (tag) {
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
    case kMicrophoneTag:
      self.microphoneCompletionHandler(false, error);
      break;
    case kHealthTag:
      self.healthCompletionHandler(false, error);
      break;
    case kLocationsTag:
      self.locationsCompletionHandler(false, error);
      break;
    case kTwitterTag:
      self.twitterCompletionHandler(false, error);
      break;
    case kFacebookTag:
      self.facebookCompletionHandler(false, error);
      break;
  }
}

- (void)approvedDialog:(NSInteger)tag {
  switch (tag) {
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
    case kMicrophoneTag:
      [self actuallyAuthorizeMicrophone];
      break;
    case kHealthTag:
      [self actuallyAuthorizeHealth];
      break;
    case kLocationsTag:
      [self actuallyAuthorizeLocations];
      break;
    case kTwitterTag:
      [self actuallyAuthorizeTwitter];
      break;
    case kFacebookTag:
      [self actuallyAuthorizeFacebook];
      break;
  }
}

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

- (NSError *)previouslyDeniedError {
  return [NSError errorWithDomain:@"PreviouslyDenied"
                             code:kJLPermissionDenied
                         userInfo:nil];
}

- (NSError *)systemDeniedError:(NSError *)error {
  return [NSError errorWithDomain:@"SystemDenied"
                             code:kJLPermissionDenied
                         userInfo:[error userInfo]];
}

#pragma mark - System Authorization

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
                    self.contactsCompletionHandler(false,
                                                   [self systemDeniedError:e]);
                  }
              });
          });
    } break;
    case kABAuthorizationStatusRestricted:
    case kABAuthorizationStatusDenied: {
      self.contactsCompletionHandler(false, [self previouslyDeniedError]);
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
      [eventStore requestAccessToEntityType:EKEntityTypeEvent
                                 completion:^(BOOL granted, NSError *error) {
                                     dispatch_async(dispatch_get_main_queue(),
                                                    ^{
                                         if (granted) {
                                           self.calendarCompletionHandler(true,
                                                                          nil);
                                         } else {
                                           self.calendarCompletionHandler(
                                               false,
                                               [self systemDeniedError:error]);
                                         }
                                     });
                                 }];
    } break;
    case EKAuthorizationStatusRestricted:
    case EKAuthorizationStatusDenied: {
      self.calendarCompletionHandler(false, [self previouslyDeniedError]);
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
              self.photosCompletionHandler(false,
                                           [self systemDeniedError:error]);
          }];
    } break;
    case ALAuthorizationStatusRestricted:
    case ALAuthorizationStatusDenied: {
      self.photosCompletionHandler(false, [self previouslyDeniedError]);
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
      [eventStore requestAccessToEntityType:EKEntityTypeReminder
                                 completion:^(BOOL granted, NSError *error) {
                                     dispatch_async(dispatch_get_main_queue(),
                                                    ^{
                                         if (granted) {
                                           self.remindersCompletionHandler(true,
                                                                           nil);
                                         } else {
                                           self.remindersCompletionHandler(
                                               false,
                                               [self systemDeniedError:error]);
                                         }
                                     });
                                 }];
    } break;
    case EKAuthorizationStatusRestricted:
    case EKAuthorizationStatusDenied: {
      self.remindersCompletionHandler(false, [self previouslyDeniedError]);
    } break;
  }
}

- (void)actuallyAuthorizeMicrophone {
  AVAudioSession *session = [[AVAudioSession alloc] init];
  NSError *error;
  [session setCategory:@"AVAudioSessionCategoryPlayAndRecord" error:&error];
  [session requestRecordPermission:^(BOOL granted) {
      if (granted) {
        self.microphoneCompletionHandler(true, nil);
      } else {
        self.microphoneCompletionHandler(false, nil);
      }
  }];
}

- (void)actuallyAuthorizeHealth {
  HKHealthStore *healthStore = [[HKHealthStore alloc] init];
  [healthStore
      requestAuthorizationToShareTypes:self.healthWriteTypes
                             readTypes:self.healthReadTypes
                            completion:^(BOOL success, NSError *error) {
                                if (success) {
                                  self.healthCompletionHandler(true, nil);
                                } else {
                                  self.healthCompletionHandler(false, error);
                                }

                            }];
}

- (void)actuallyAuthorizeLocations {
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self;
  [self.locationManager startUpdatingLocation];
}

- (void)actuallyAuthorizeTwitter {
  bool previouslyAsked = [[NSUserDefaults standardUserDefaults]
      boolForKey:kJLAskedForTwitterPermission];
  [[NSUserDefaults standardUserDefaults] setBool:true
                                          forKey:kJLAskedForTwitterPermission];
  [[NSUserDefaults standardUserDefaults] synchronize];

  ACAccountStore *accountStore = [ACAccountStore new];
  ACAccountType *accountType = [accountStore
      accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

  [accountStore
      requestAccessToAccountsWithType:accountType
                              options:nil
                           completion:^(BOOL granted, NSError *error) {

                               dispatch_async(dispatch_get_main_queue(), ^{
                                   if (granted) {
                                     self.twitterCompletionHandler(true, nil);
                                   } else if (!previouslyAsked) {
                                     self.twitterCompletionHandler(
                                         false, [self systemDeniedError:error]);
                                   } else {
                                     self.twitterCompletionHandler(
                                         false, [self previouslyDeniedError]);
                                   }
                               });
                           }];
}

- (void)actuallyAuthorizeFacebook {
  bool previouslyAsked = [[NSUserDefaults standardUserDefaults]
      boolForKey:kJLAskedForFacebookPermission];
  [[NSUserDefaults standardUserDefaults] setBool:YES
                                          forKey:kJLAskedForFacebookPermission];
  [[NSUserDefaults standardUserDefaults] synchronize];

  ACAccountStore *accountStore = [ACAccountStore new];
  ACAccountType *accountType = [accountStore
      accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
  NSDictionary *options = @{
    @"ACFacebookAppIdKey" : @"123456789",
    @"ACFacebookPermissionsKey" : @[ @"publish_stream" ],
    @"ACFacebookAudienceKey" : ACFacebookAudienceEveryone
  };
  [accountStore
      requestAccessToAccountsWithType:accountType
                              options:options
                           completion:^(BOOL granted, NSError *error) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   if (granted) {
                                     self.facebookCompletionHandler(true, nil);
                                   } else if (!previouslyAsked) {
                                     self.facebookCompletionHandler(
                                         false, [self systemDeniedError:error]);
                                   } else {
                                     self.facebookCompletionHandler(
                                         false, [self previouslyDeniedError]);
                                   }
                               });
                           }];
}

- (void)actuallyAuthorizeNotifications {
  [[NSUserDefaults standardUserDefaults]
      setBool:true
       forKey:kJLAskedForNotificationPermission];
  [[NSUserDefaults standardUserDefaults] synchronize];

  if ([[UIApplication sharedApplication]
          respondsToSelector:@selector(registerUserNotificationSettings:)]) {
    UIUserNotificationSettings *settings = [UIUserNotificationSettings
        settingsForTypes:(UIUserNotificationTypeAlert |
                          UIUserNotificationTypeBadge |
                          UIUserNotificationTypeSound)
              categories:nil];
    [[UIApplication sharedApplication]
        registerUserNotificationSettings:settings];
  } else {
    [[UIApplication sharedApplication]
        registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert |
                                            UIRemoteNotificationTypeBadge |
                                            UIRemoteNotificationTypeSound)];
  }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
    didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  NSLog(@"Status is %@", @(status));

  switch (status) {
    case kCLAuthorizationStatusNotDetermined:
      break;
    case kCLAuthorizationStatusAuthorizedWhenInUse:
    case kCLAuthorizationStatusAuthorizedAlways: {
      [self.locationManager stopUpdatingLocation];
      self.locationManager = nil;
      self.locationsCompletionHandler(true, nil);
      break;
    }
    case kCLAuthorizationStatusDenied:
    case kCLAuthorizationStatusRestricted: {
      [self.locationManager stopUpdatingLocation];
      self.locationManager = nil;
      self.locationsCompletionHandler(false, [self systemDeniedError:nil]);
      break;
    }
  }
}

@end
