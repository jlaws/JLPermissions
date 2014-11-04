//
//  JLPermissionCore.h
//
//  Created by Joseph Laws on 11/3/14.
//  Copyright (c) 2014 Joe Laws. All rights reserved.
//

@import Foundation;
@import UIKit;

typedef NS_ENUM(NSInteger, JLAuthorizationStatus) {
  JLPermissionNotDetermined = 0,
  JLPermissionDenied,
  JLPermissionAuthorized
};

typedef void (^AuthorizationHandler)(bool granted, NSError *error);
typedef void (^NotificationAuthorizationHandler)(NSString *deviceID, NSError *error);

@interface JLPermissionsCore : NSObject<UIAlertViewDelegate>

@end
