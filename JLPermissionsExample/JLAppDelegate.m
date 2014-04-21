//
//  JLAppDelegate.m
//  JLPermissionsExample
//
//  Created by Joseph Laws on 4/19/14.
//  Copyright (c) 2014 Joe Laws. All rights reserved.
//

#import "JLAppDelegate.h"
#import "JLPermissions.h"
#import "DDLog.h"

static const int ddLogLevel = LOG_LEVEL_INFO;

@implementation JLAppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  return YES;
}

#pragma mark - UIRemoteNotifications

- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  DDLogInfo(@"didRegisterForRemoteNotificationsWithDeviceToken %@",
            [deviceToken description]);

  NSString *deviceID =
      [[JLPermissions sharedInstance] parseDeviceID:deviceToken];
}

- (void)application:(UIApplication *)application
    didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
  DDLogError(@"didFailToRegisterForRemoteNotificationsWithError %@", error);
}

@end
