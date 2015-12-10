//
//  JLPermissionCore.h
//
//  Created by Joseph Laws on 11/3/14.
//  Copyright (c) 2014 Joe Laws. All rights reserved.
//

@import Foundation;
@import UIKit;

typedef NS_ENUM(NSInteger, JLAuthorizationErrorCode) {
  JLPermissionUserDenied = 42,
  JLPermissionSystemDenied
};

typedef NS_ENUM(NSInteger, JLAuthorizationStatus) {
  JLPermissionNotDetermined = 0,
  JLPermissionDenied,
  JLPermissionAuthorized
};

typedef NS_ENUM(NSInteger, JLPermissionType) {
  JLPermissionCalendar = 0,
  JLPermissionCamera,
  JLPermissionContacts,
  JLPermissionFacebook,
  JLPermissionHealth,
  JLPermissionLocation,
  JLPermissionMicrophone,
  JLPermissionNotification,
  JLPermissionPhotos,
  JLPermissionReminders,
  JLPermissionTwitter,
};

NS_ASSUME_NONNULL_BEGIN
typedef void (^AuthorizationHandler)(BOOL granted, NSError *__nullable error);
typedef void (^NotificationAuthorizationHandler)(NSString *__nullable deviceID,
                                                 NSError *__nullable error);

@interface JLPermissionsCore : NSObject<UIAlertViewDelegate>

/**
 * A Boolean property that indicates whether the extra alert view will be shown
 * before the library actually requests permissions to the system.
 */
@property(nonatomic, getter=isExtraAlertEnabled) BOOL extraAlertEnabled;

/**
 * @return whether or not user has granted access to the calendar
 */
- (JLAuthorizationStatus)authorizationStatus;

/**
 * Displays a dialog telling the user how to re-enable the permission in
 * the Settings application
 */
- (void)displayReenableAlert;

/**
 * A view controller telling the user how to re-enable the permission in
 * the Settings application or nil if one doesnt exist.
 */
- (UIViewController *__nullable)reenableViewController;

/**
 * The type of permission.
 */
- (JLPermissionType)permissionType;

/**
 * Opens the application system settings dialog if running on iOS 8.
 */
- (void)displayAppSystemSettings;

@end
NS_ASSUME_NONNULL_END
