//
//  JLPermissions.m
//  Joseph Laws
//
//  Created by Joseph Laws on 4/19/14.
//  Copyright (c) 2014 Joe Laws. All rights reserved.
//

#import "JLPermissions.h"

@import Accounts;
@import AVFoundation;
@import CoreLocation;
@import EventKit;
@import HealthKit;

typedef NS_ENUM(NSInteger, JLAuthorizationStatus) {
  kJLPermissionNotDetermined = 0,
  kJLPermissionDenied,
  kJLPermissionAuthorized
};

@interface JLPermissions () <UIAlertViewDelegate, CLLocationManagerDelegate>

@property(nonatomic, strong) AuthorizationHandler photoscompletion;
@property(nonatomic, strong) AuthorizationHandler reminderscompletion;
@property(nonatomic, strong) AuthorizationHandler microphonecompletion;
@property(nonatomic, strong) AuthorizationHandler healthcompletion;
@property(nonatomic, strong) AuthorizationHandler locationscompletion;
@property(nonatomic, strong) AuthorizationHandler twittercompletion;
@property(nonatomic, strong) AuthorizationHandler facebookcompletion;
@property(nonatomic, strong) NotificationAuthorizationHandler notificationscompletion;

@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) NSSet *healthReadTypes;
@property(nonatomic, strong) NSSet *healthWriteTypes;

@end

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

#pragma mark - Reminders

- (BOOL)remindersAuthorized {
  return [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder] ==
         EKAuthorizationStatusAuthorized;
}

- (void)authorizeReminders:(AuthorizationHandler)completion {
  [self authorizeRemindersWithTitle:[self defaultTitle:@"Reminders"]
                            message:[self defaultMessage]
                        cancelTitle:[self defaultCancelTitle]
                         grantTitle:[self defaultGrantTitle]
                         completion:completion];
}

- (void)authorizeRemindersWithTitle:(NSString *)messageTitle
                            message:(NSString *)message
                        cancelTitle:(NSString *)cancelTitle
                         grantTitle:(NSString *)grantTitle
                         completion:(AuthorizationHandler)completion {
  EKAuthorizationStatus authorizationStatus =
      [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];

  switch (authorizationStatus) {
    case EKAuthorizationStatusAuthorized: {
      completion(true, nil);
    } break;
    case EKAuthorizationStatusNotDetermined: {
      self.reminderscompletion = completion;
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:messageTitle
                                                      message:message
                                                     delegate:self
                                            cancelButtonTitle:cancelTitle
                                            otherButtonTitles:grantTitle, nil];
      alert.tag = JLReminders;
      [alert show];
    } break;
    case EKAuthorizationStatusRestricted:
    case EKAuthorizationStatusDenied: {
      [self displayErrorDialog:@"Reminders"];

      completion(false, [self previouslyDeniedError]);
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
    AVAudioSessionRecordPermission permission = [[AVAudioSession sharedInstance] recordPermission];
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

- (void)authorizeMicrophone:(AuthorizationHandler)completion {
  [self authorizeMicrophoneWithTitle:[self defaultTitle:@"Microphone"]
                             message:[self defaultMessage]
                         cancelTitle:[self defaultCancelTitle]
                          grantTitle:[self defaultGrantTitle]
                          completion:completion];
}

- (void)authorizeMicrophoneWithTitle:(NSString *)messageTitle
                             message:(NSString *)message
                         cancelTitle:(NSString *)cancelTitle
                          grantTitle:(NSString *)grantTitle
                          completion:(AuthorizationHandler)completion {
  AVAudioSession *audioSession = [AVAudioSession sharedInstance];
  if (![audioSession respondsToSelector:@selector(recordPermission)]) {
    completion(false, [self previouslyDeniedError]);
    return;
  }
  AVAudioSessionRecordPermission permission = [audioSession recordPermission];
  switch (permission) {
    case AVAudioSessionRecordPermissionGranted: {
      completion(true, nil);
    } break;
    case AVAudioSessionRecordPermissionDenied: {
      completion(false, [self previouslyDeniedError]);
    } break;
    case AVAudioSessionRecordPermissionUndetermined: {
      self.microphonecompletion = completion;
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:messageTitle
                                                      message:message
                                                     delegate:self
                                            cancelButtonTitle:cancelTitle
                                            otherButtonTitles:grantTitle, nil];
      alert.tag = JLMicrophone;
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
    HKAuthorizationStatus status = [healthStore authorizationStatusForType:sampleType];
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

- (void)authorizeHealth:(AuthorizationHandler)completion {
  [self authorizeHealthWithTitle:[self defaultTitle:@"Health"]
                         message:[self defaultMessage]
                     cancelTitle:[self defaultCancelTitle]
                      grantTitle:[self defaultGrantTitle]
                      completion:completion];
}

- (void)authorizeHealthWithTitle:(NSString *)messageTitle
                         message:(NSString *)message
                     cancelTitle:(NSString *)cancelTitle
                      grantTitle:(NSString *)grantTitle
                      completion:(AuthorizationHandler)completion {
  NSMutableSet *allTypes = [[NSMutableSet alloc] init];
  if (self.healthReadTypes.count) {
    [allTypes unionSet:self.healthReadTypes];
  }

  if (self.healthWriteTypes.count) {
    [allTypes unionSet:self.healthWriteTypes];
  }

  HKHealthStore *healthStore = [[HKHealthStore alloc] init];
  for (HKObjectType *healthType in allTypes) {
    HKAuthorizationStatus status = [healthStore authorizationStatusForType:healthType];
    switch (status) {
      case HKAuthorizationStatusNotDetermined: {
        self.healthcompletion = completion;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:messageTitle
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:cancelTitle
                                              otherButtonTitles:grantTitle, nil];
        alert.tag = JLHealth;
        [alert show];
      } break;
      case HKAuthorizationStatusSharingAuthorized: {
        completion(true, nil);
      } break;
      case HKAuthorizationStatusSharingDenied: {
        completion(false, [self previouslyDeniedError]);
      } break;
    }
  }
}

- (void)displayHealthErrorDialog {
  [self displayErrorDialog:@"Health"];
}

#pragma mark - Locations

- (BOOL)locationsAuthorized {
  return [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways;
}

- (void)authorizeLocations:(AuthorizationHandler)completion {
  NSString *title =
      [NSString stringWithFormat:@"\"%@\" Would Like to Use Your Current Location", [self appName]];
  [self authorizeLocationsWithTitle:title
                            message:[self defaultMessage]
                        cancelTitle:[self defaultCancelTitle]
                         grantTitle:[self defaultGrantTitle]
                         completion:completion];
}

- (void)authorizeLocationsWithTitle:(NSString *)messageTitle
                            message:(NSString *)message
                        cancelTitle:(NSString *)cancelTitle
                         grantTitle:(NSString *)grantTitle
                         completion:(AuthorizationHandler)completion {
  CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
  switch (authorizationStatus) {
    case kCLAuthorizationStatusAuthorizedAlways:
    case kCLAuthorizationStatusAuthorizedWhenInUse: {
      completion(true, nil);
    } break;
    case kCLAuthorizationStatusNotDetermined: {
      self.locationscompletion = completion;
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:messageTitle
                                                      message:message
                                                     delegate:self
                                            cancelButtonTitle:cancelTitle
                                            otherButtonTitles:grantTitle, nil];
      alert.tag = JLLocations;
      [alert show];
    } break;
    case kCLAuthorizationStatusDenied:
    case kCLAuthorizationStatusRestricted: {
      completion(false, [self previouslyDeniedError]);
    } break;
  }
}

- (void)displayLocationsErrorDialog {
  [self displayErrorDialog:@"Location"];
}

#pragma mark - Twitter

- (BOOL)twitterAuthorized {
  ACAccountStore *store = [ACAccountStore new];
  ACAccountType *accountType =
      [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
  return [accountType accessGranted];
}

- (void)authorizeTwitter:(AuthorizationHandler)completion {
  NSString *title =
      [NSString stringWithFormat:@"\"%@\" Would Like Access to Twitter Accounts", [self appName]];
  [self authorizeTwitterWithTitle:title
                          message:[self defaultMessage]
                      cancelTitle:[self defaultCancelTitle]
                       grantTitle:[self defaultGrantTitle]
                       completion:completion];
}

- (void)authorizeTwitterWithTitle:(NSString *)messageTitle
                          message:(NSString *)message
                      cancelTitle:(NSString *)cancelTitle
                       grantTitle:(NSString *)grantTitle
                       completion:(AuthorizationHandler)completion {
  BOOL authorized = [self twitterAuthorized];

  bool previouslyAsked =
      [[NSUserDefaults standardUserDefaults] boolForKey:kJLAskedForTwitterPermission];

  if (authorized) {
    completion(true, nil);
  } else if (!previouslyAsked) {
    self.twittercompletion = completion;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:messageTitle
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:cancelTitle
                                          otherButtonTitles:grantTitle, nil];
    alert.tag = JLTwitter;
    [alert show];
  } else {
    self.twittercompletion = completion;
    [self actuallyAuthorizeTwitter];
  }
}

- (void)displayTwitterErrorDialog {
  [self displayErrorDialog:@"Twitter"];
}

#pragma mark - Facebook

- (BOOL)facebookAuthorized {
  ACAccountStore *store = [ACAccountStore new];
  ACAccountType *accountType =
      [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
  return [accountType accessGranted];
}

- (void)authorizeFacebook:(AuthorizationHandler)completion {
  NSString *title =
      [NSString stringWithFormat:@"\"%@\" Would Like Access to Facebook Accounts", [self appName]];
  [self authorizeFacebookWithTitle:title
                           message:[self defaultMessage]
                       cancelTitle:[self defaultCancelTitle]
                        grantTitle:[self defaultGrantTitle]
                        completion:completion];
}

- (void)authorizeFacebookWithTitle:(NSString *)messageTitle
                           message:(NSString *)message
                       cancelTitle:(NSString *)cancelTitle
                        grantTitle:(NSString *)grantTitle
                        completion:(AuthorizationHandler)completion {
  BOOL authorized = [self facebookAuthorized];
  bool previouslyAsked =
      [[NSUserDefaults standardUserDefaults] boolForKey:kJLAskedForFacebookPermission];
  if (authorized) {
    completion(true, nil);
  } else if (!previouslyAsked) {
    self.facebookcompletion = completion;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:messageTitle
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:cancelTitle
                                          otherButtonTitles:grantTitle, nil];
    alert.tag = JLFacebook;
    [alert show];
  } else {
    self.facebookcompletion = completion;
    [self actuallyAuthorizeFacebook];
  }
}

- (void)displayFacebookErrorDialog {
  [self displayErrorDialog:@"Facebook"];
}

#pragma mark - Notifications

- (BOOL)notificationsAuthorized {
  return [[NSUserDefaults standardUserDefaults] objectForKey:kJLDeviceToken] != nil;
}

- (void)authorizeNotifications:(NotificationAuthorizationHandler)completion {
  NSString *messageTitle =
      [NSString stringWithFormat:@"\"%@\" Would Like to Access Your Notifications", [self appName]];
  [self authorizeNotificationsWithTitle:messageTitle
                                message:[self defaultMessage]
                            cancelTitle:[self defaultCancelTitle]
                             grantTitle:[self defaultGrantTitle]
                             completion:completion];
}

- (void)authorizeNotificationsWithTitle:(NSString *)messageTitle
                                message:(NSString *)message
                            cancelTitle:(NSString *)cancelTitle
                             grantTitle:(NSString *)grantTitle
                             completion:(NotificationAuthorizationHandler)completion {
  self.notificationscompletion = completion;

  bool previouslyAsked =
      [[NSUserDefaults standardUserDefaults] boolForKey:kJLAskedForNotificationPermission];

  NSString *existingID = [[NSUserDefaults standardUserDefaults] objectForKey:kJLDeviceToken];

  BOOL notificationsOn = NO;
  if ([[UIApplication sharedApplication]
          respondsToSelector:@selector(currentUserNotificationSettings)]) {
    notificationsOn = ([[UIApplication sharedApplication] currentUserNotificationSettings].types !=
                       UIUserNotificationTypeNone);
  } else {
    notificationsOn = ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] !=
                       UIRemoteNotificationTypeNone);
  }
  if (existingID) {
    completion(existingID, nil);
  } else if (notificationsOn) {
    [self actuallyAuthorizeNotifications];
  } else if (!previouslyAsked) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:messageTitle
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:cancelTitle
                                          otherButtonTitles:grantTitle, nil];
    alert.tag = JLNotifications;
    [alert show];
  } else {
    completion(false, [self previouslyDeniedError]);
  }
}

- (void)displayNotificationsErrorDialog {
  NSString *message = [NSString stringWithFormat:@"Please go to Settings -> Notification Center -> "
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
  [[NSUserDefaults standardUserDefaults] setBool:false forKey:kJLAskedForNotificationPermission];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)notificationResult:(NSData *)deviceToken error:(NSError *)error {
  if (deviceToken) {
    NSString *deviceID = [[JLPermissions sharedInstance] parseDeviceID:deviceToken];

    [[NSUserDefaults standardUserDefaults] setObject:deviceID forKey:kJLDeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];

    if (self.notificationscompletion) {
      self.notificationscompletion(deviceID, nil);
    }
  } else {
    if (self.notificationscompletion) {
      self.notificationscompletion(nil, [self systemDeniedError:error]);
    }
  }
}

- (NSString *)deviceID {
  return [[NSUserDefaults standardUserDefaults] objectForKey:kJLDeviceToken];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
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
}

- (void)approvedDialog:(NSInteger)tag {
}

- (NSString *)parseDeviceID:(NSData *)deviceToken {
  NSString *token = [deviceToken description];
  return [[self regex] stringByReplacingMatchesInString:token
                                                options:0
                                                  range:NSMakeRange(0, [token length])
                                           withTemplate:@""];
}

- (NSRegularExpression *)regex {
  NSError *error;
  NSRegularExpression *exp =
      [NSRegularExpression regularExpressionWithPattern:@"[<> ]"
                                                options:NSRegularExpressionCaseInsensitive
                                                  error:&error];

  if (!exp) {
    NSLog(@"Failed to instantiate the regex parser due to %@", error);
  }

  return exp;
}

- (NSString *)defaultTitle:(NSString *)authorizationType {
  return [NSString
      stringWithFormat:@"\"%@\" Would Like to Access Your %@", [self appName], authorizationType];
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
  return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

- (void)displayErrorDialog:(NSString *)authorizationType {
  NSString *message = [NSString stringWithFormat:@"Please go to Settings -> Privacy -> "
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
  return [NSError errorWithDomain:@"PreviouslyDenied" code:kJLPermissionDenied userInfo:nil];
}

- (NSError *)systemDeniedError:(NSError *)error {
  return
      [NSError errorWithDomain:@"SystemDenied" code:kJLPermissionDenied userInfo:[error userInfo]];
}

#pragma mark - System Authorization

- (void)actuallyAuthorizeReminders {
  EKAuthorizationStatus authorizationStatus =
      [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];

  switch (authorizationStatus) {
    case EKAuthorizationStatusAuthorized: {
      self.reminderscompletion(true, nil);
    } break;
    case EKAuthorizationStatusNotDetermined: {
      EKEventStore *eventStore = [[EKEventStore alloc] init];
      [eventStore requestAccessToEntityType:EKEntityTypeReminder
                                 completion:^(BOOL granted, NSError *error) {
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         if (granted) {
                                           self.reminderscompletion(true, nil);
                                         } else {
                                           self.reminderscompletion(false,
                                                                    [self systemDeniedError:error]);
                                         }
                                     });
                                 }];
    } break;
    case EKAuthorizationStatusRestricted:
    case EKAuthorizationStatusDenied: {
      self.reminderscompletion(false, [self previouslyDeniedError]);
    } break;
  }
}

- (void)actuallyAuthorizeMicrophone {
  AVAudioSession *session = [[AVAudioSession alloc] init];
  NSError *error;
  [session setCategory:@"AVAudioSessionCategoryPlayAndRecord" error:&error];
  [session requestRecordPermission:^(BOOL granted) {
      if (granted) {
        self.microphonecompletion(true, nil);
      } else {
        self.microphonecompletion(false, nil);
      }
  }];
}

- (void)actuallyAuthorizeHealth {
  HKHealthStore *healthStore = [[HKHealthStore alloc] init];
  [healthStore requestAuthorizationToShareTypes:self.healthWriteTypes
                                      readTypes:self.healthReadTypes
                                     completion:^(BOOL success, NSError *error) {
                                         if (success) {
                                           self.healthcompletion(true, nil);
                                         } else {
                                           self.healthcompletion(false, error);
                                         }

                                     }];
}

- (void)actuallyAuthorizeLocations {
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self;

  if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 &&
      [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
    BOOL hasAlwaysKey =
        [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"] !=
        nil;
    BOOL hasWhenInUseKey =
        [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"] !=
        nil;
    if (hasAlwaysKey) {
      [self.locationManager requestAlwaysAuthorization];
    } else if (hasWhenInUseKey) {
      [self.locationManager requestWhenInUseAuthorization];
    } else {
      // At least one of the keys NSLocationAlwaysUsageDescription or
      // NSLocationWhenInUseUsageDescription MUST be present in the Info.plist
      // file to use location services on iOS 8+.
      NSAssert(hasAlwaysKey || hasWhenInUseKey,
               @"To use location services in iOS 8+, your Info.plist must "
               @"provide a value for either " @"NSLocationWhenInUseUsageDescription or "
               @"NSLocationAlwaysUsageDescription.");
    }
  } else {
    [self.locationManager startUpdatingLocation];
  }
}

- (void)actuallyAuthorizeTwitter {
  bool previouslyAsked =
      [[NSUserDefaults standardUserDefaults] boolForKey:kJLAskedForTwitterPermission];
  [[NSUserDefaults standardUserDefaults] setBool:true forKey:kJLAskedForTwitterPermission];
  [[NSUserDefaults standardUserDefaults] synchronize];

  ACAccountStore *accountStore = [ACAccountStore new];
  ACAccountType *accountType =
      [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

  [accountStore requestAccessToAccountsWithType:accountType
                                        options:nil
                                     completion:^(BOOL granted, NSError *error) {

                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             if (granted) {
                                               self.twittercompletion(true, nil);
                                             } else if (!previouslyAsked) {
                                               self.twittercompletion(
                                                   false, [self systemDeniedError:error]);
                                             } else {
                                               self.twittercompletion(false,
                                                                      [self previouslyDeniedError]);
                                             }
                                         });
                                     }];
}

- (void)actuallyAuthorizeFacebook {
  bool previouslyAsked =
      [[NSUserDefaults standardUserDefaults] boolForKey:kJLAskedForFacebookPermission];
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kJLAskedForFacebookPermission];
  [[NSUserDefaults standardUserDefaults] synchronize];

  ACAccountStore *accountStore = [ACAccountStore new];
  ACAccountType *accountType =
      [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
  NSDictionary *options = @{
    @"ACFacebookAppIdKey" : @"123456789",
    @"ACFacebookPermissionsKey" : @[ @"publish_stream" ],
    @"ACFacebookAudienceKey" : ACFacebookAudienceEveryone
  };
  [accountStore requestAccessToAccountsWithType:accountType
                                        options:options
                                     completion:^(BOOL granted, NSError *error) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             if (granted) {
                                               self.facebookcompletion(true, nil);
                                             } else if (!previouslyAsked) {
                                               self.facebookcompletion(
                                                   false, [self systemDeniedError:error]);
                                             } else {
                                               self.facebookcompletion(
                                                   false, [self previouslyDeniedError]);
                                             }
                                         });
                                     }];
}

- (void)actuallyAuthorizeNotifications {
  [[NSUserDefaults standardUserDefaults] setBool:true forKey:kJLAskedForNotificationPermission];
  [[NSUserDefaults standardUserDefaults] synchronize];

  if ([[UIApplication sharedApplication]
          respondsToSelector:@selector(registerUserNotificationSettings:)]) {
    UIUserNotificationSettings *settings = [UIUserNotificationSettings
        settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge |
                          UIUserNotificationTypeSound)
              categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
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
      self.locationscompletion(true, nil);
      break;
    }
    case kCLAuthorizationStatusDenied:
    case kCLAuthorizationStatusRestricted: {
      [self.locationManager stopUpdatingLocation];
      self.locationManager = nil;
      self.locationscompletion(false, [self systemDeniedError:nil]);
      break;
    }
  }
}

@end
