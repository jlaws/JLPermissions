//
//  JLPermissions.h
//  Joseph Laws
//
//  Created by Joseph Laws on 4/19/14.
//  Copyright (c) 2014 Joe Laws. All rights reserved.
//

@import Foundation;

typedef void (^AuthorizationBlock)(bool granted, NSError *error);

@interface JLPermissions : NSObject

@property(strong, nonatomic) NSString *appName;

+ (instancetype)sharedInstance;

- (BOOL)addressBookAuthorized;

- (void)authorizeAddressBook:(AuthorizationBlock)block;

- (NSString *)parseDeviceID:(NSData *)deviceToken;

@end
