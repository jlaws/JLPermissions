//
//  JLPermissionsCore+Internal.h
//
//  Created by Joseph Laws on 11/3/14.
//  Copyright (c) 2014 Joe Laws. All rights reserved.
//

@interface JLPermissionsCore (Internal)

- (NSString *)appName;
- (NSString *)defaultTitle:(NSString *)authorizationType;
- (NSString *)defaultMessage;
- (NSString *)defaultCancelTitle;
- (NSString *)defaultGrantTitle;
- (void)displayErrorDialog:(NSString *)authorizationType;
- (NSError *)previouslyDeniedError;
- (NSError *)systemDeniedError:(NSError *)error;

/**
 * This should be overridden by subclasses.
 */
- (void)actuallyAuthorize;

/**
 * This should be overridden by subclasses.
 */
- (void)canceledAuthorization:(NSError *)error;

@end
