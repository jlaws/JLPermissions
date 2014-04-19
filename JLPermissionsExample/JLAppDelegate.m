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

  NSString *deviceID =
      [[JLPermissions sharedInstance] parseDeviceID:deviceToken];

  NSLog(@"Received deviceID %@", deviceID);
}

- (void)application:(UIApplication *)application
    didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
}

@end
