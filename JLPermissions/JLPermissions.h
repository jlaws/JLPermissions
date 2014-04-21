//
//  JLPermissions.h
//  Joseph Laws
//
//  Created by Joseph Laws on 4/19/14.
//  Copyright (c) 2014 Joe Laws. All rights reserved.
//

@import Foundation;

typedef NS_ENUM(NSInteger, JLAuthorizationStatus) {
  kJLPermissionNotDetermined = 0,
  kJLPermissionDenied,
  kJLPermissionAuthorized
};

typedef void (^AuthorizationBlock)(bool granted, NSError *error);

@interface JLPermissions : NSObject

+ (instancetype)sharedInstance;

- (BOOL)contactsAuthorized;
- (void)authorizeContacts:(AuthorizationBlock)completionHandler;
- (void)authorizeContactsWithTitle:(NSString *)messageTitle
                           message:(NSString *)message
                       cancelTitle:(NSString *)cancelTitle
                        grantTitle:(NSString *)grantTitle
                 completionHandler:(AuthorizationBlock)completionHandler;

- (BOOL)calendarAuthorized;
- (void)authorizeCalendar:(AuthorizationBlock)completionHandler;
- (void)authorizeCalendarWithTitle:(NSString *)messageTitle
                           message:(NSString *)message
                       cancelTitle:(NSString *)cancelTitle
                        grantTitle:(NSString *)grantTitle
                 completionHandler:(AuthorizationBlock)completionHandler;

- (BOOL)photosAuthorized;
- (void)authorizePhotos:(AuthorizationBlock)completionHandler;
- (void)authorizePhotosWithTitle:(NSString *)messageTitle
                         message:(NSString *)message
                     cancelTitle:(NSString *)cancelTitle
                      grantTitle:(NSString *)grantTitle
               completionHandler:(AuthorizationBlock)completionHandler;

- (BOOL)remindersAuthorized;
- (void)authorizeReminders:(AuthorizationBlock)completionHandler;
- (void)authorizeRemindersWithTitle:(NSString *)messageTitle
                            message:(NSString *)message
                        cancelTitle:(NSString *)cancelTitle
                         grantTitle:(NSString *)grantTitle
                  completionHandler:(AuthorizationBlock)completionHandler;

- (BOOL)notificationsAuthorized;
- (void)authorizeNotifications:(AuthorizationBlock)completionHandler;
- (void)authorizeNotificationsWithTitle:(NSString *)messageTitle
                                message:(NSString *)message
                            cancelTitle:(NSString *)cancelTitle
                             grantTitle:(NSString *)grantTitle
                      completionHandler:(AuthorizationBlock)completionHandler;

- (NSString *)parseDeviceID:(NSData *)deviceToken;

@end
