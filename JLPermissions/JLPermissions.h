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

@property(strong, nonatomic) NSString *appName;

+ (instancetype)sharedInstance;

- (BOOL)contactsAuthorized;
- (void)authorizeContacts:(AuthorizationBlock)completionHandler;
- (void)authorizeContactsWithTitle:(NSString *)messageTitle
                           message:(NSString *)message
                       cancelTitle:(NSString *)cancelTitle
                        grantTitle:(NSString *)grantTitle
                 completionHandler:(AuthorizationBlock)completionHandler;

- (NSString *)parseDeviceID:(NSData *)deviceToken;

@end
