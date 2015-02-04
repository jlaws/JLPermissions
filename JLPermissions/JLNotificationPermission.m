//
//  JLNotificationPermissions.m
//
//  Created by Joseph Laws on 11/3/14.
//  Copyright (c) 2014 Joe Laws. All rights reserved.
//

#import "JLNotificationPermission.h"

#import "JLPermissionsCore+Internal.h"

#define kJLDeviceToken @"JLDeviceToken"
#define kJLAskedForNotificationPermission @"JLAskedForNotificationPermission"

@implementation JLNotificationPermission {
  NotificationAuthorizationHandler _completion;
}

+ (instancetype)sharedInstance {
  static JLNotificationPermission *_instance = nil;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{
    _instance = [[JLNotificationPermission alloc] init];
  });

  return _instance;
}

#pragma mark - Notifications

- (JLAuthorizationStatus)authorizationStatus {
  BOOL previouslyAsked =
      [[NSUserDefaults standardUserDefaults] boolForKey:kJLAskedForNotificationPermission];
  NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:kJLDeviceToken];
  if (token) {
    return JLPermissionAuthorized;
  } else if (previouslyAsked) {
    return JLPermissionDenied;
  } else {
    return JLPermissionNotDetermined;
  }
}

- (void)authorize:(NotificationAuthorizationHandler)completion {
  NSString *messageTitle =
      [NSString stringWithFormat:@"\"%@\" Would Like to Send You Notifications", [self appName]];
  NSString *message =
      [NSString stringWithFormat:@"Notifications may include alerts, sounds, and icon badges. "
                @"These can be configured in settings."];
  [self authorizeWithTitle:messageTitle
                   message:message
               cancelTitle:[self defaultCancelTitle]
                grantTitle:[self defaultGrantTitle]
                completion:completion];
}

- (void)authorizeWithTitle:(NSString *)messageTitle
                   message:(NSString *)message
               cancelTitle:(NSString *)cancelTitle
                grantTitle:(NSString *)grantTitle
                completion:(NotificationAuthorizationHandler)completion {
    
    UIUserNotificationSettings *settings = nil;
    if ([[UIApplication sharedApplication]
         respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        settings = [UIUserNotificationSettings
                    settingsForTypes:(UIUserNotificationTypeAlert
                                      | UIUserNotificationTypeBadge
                                      | UIUserNotificationTypeSound) categories:nil];
    }
    
    [self authorizeWithTitle:messageTitle message:message cancelTitle:cancelTitle grantTitle:grantTitle settings:settings completion:completion];
}

- (void)authorizeWithTitle:(NSString *)messageTitle
                   message:(NSString *)message
               cancelTitle:(NSString *)cancelTitle
                grantTitle:(NSString *)grantTitle
                  settings:(UIUserNotificationSettings *)settings
                completion:(NotificationAuthorizationHandler)completion {
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
        if (completion) {
            completion(existingID, nil);
        }
    } else if (notificationsOn) {
        _completion = completion;
        [self actuallyAuthorize:settings];
    } else if (!previouslyAsked) {
        _completion = completion;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:messageTitle
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:cancelTitle
                                              otherButtonTitles:grantTitle, nil];
        [alert show];
    } else {
        if (completion) {
            completion(false, [self previouslyDeniedError]);
        }
    }

}

- (void)displayErrorDialog {
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

- (void)unauthorize {
  [[UIApplication sharedApplication] unregisterForRemoteNotifications];
  [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kJLDeviceToken];
  [[NSUserDefaults standardUserDefaults] setBool:false forKey:kJLAskedForNotificationPermission];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)notificationResult:(NSData *)deviceToken error:(NSError *)error {
  if (deviceToken) {
    NSString *deviceID = [self parseDeviceID:deviceToken];

    [[NSUserDefaults standardUserDefaults] setObject:deviceID forKey:kJLDeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];

    if (_completion) {
      _completion(deviceID, nil);
    }
  } else {
    if (_completion) {
      _completion(nil, [self systemDeniedError:error]);
    }
  }
}

- (NSString *)deviceID {
  return [[NSUserDefaults standardUserDefaults] objectForKey:kJLDeviceToken];
}

- (void)actuallyAuthorize:(UIUserNotificationSettings *)settings {
  [[NSUserDefaults standardUserDefaults] setBool:true forKey:kJLAskedForNotificationPermission];
  [[NSUserDefaults standardUserDefaults] synchronize];

  if ([[UIApplication sharedApplication]
          respondsToSelector:@selector(registerUserNotificationSettings:)] && settings) {
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
  } else {
    [[UIApplication sharedApplication]
        registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert |
                                            UIRemoteNotificationTypeBadge |
                                            UIRemoteNotificationTypeSound)];
  }
}

- (void)canceledAuthorization:(NSError *)error {
  if (_completion) {
    _completion(false, error);
  }
}

#pragma mark - Helpers

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

@end
