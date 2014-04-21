//
//  JLAppDelegate.m
//  JLPermissionsExample
//
//  Created by Joseph Laws on 4/19/14.
//  Copyright (c) 2014 Joe Laws. All rights reserved.
//

#import "JLAppDelegate.h"
#import "JLPermissions.h"

@implementation JLAppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  return YES;
}

#pragma mark - UIRemoteNotifications

- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken %@",
        [deviceToken description]);

  [[JLPermissions sharedInstance] notificationResult:deviceToken error:nil];
}

- (void)application:(UIApplication *)application
    didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
  NSLog(@"didFailToRegisterForRemoteNotificationsWithError %@", error);

  [[JLPermissions sharedInstance] notificationResult:nil error:error];
}

@end
