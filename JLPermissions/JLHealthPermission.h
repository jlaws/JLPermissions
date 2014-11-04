//
//  JLHealthPermissions.h
//
//  Created by Joseph Laws on 11/3/14.
//  Copyright (c) 2014 Joe Laws. All rights reserved.
//

#import "JLPermissionsCore.h"

@interface JLHealthPermission : JLPermissionsCore

+ (instancetype)sharedInstance;

/**
 *  @return whether or not user has granted access to health information
 */
- (BOOL)healthAuthorized;
/**
 *  Uses the default dialog which is identical to the system permission dialog
 *
 *  @param completion the block that will be executed on the main thread
 *when access is granted or denied.  May be called immediately if access was
 *previously established
 */
- (void)authorizeHealth:(AuthorizationHandler)completion;
/**
 *  This is identical to the call other call, however it allows you to specify
 *your own custom text for the dialog window rather than using the standard
 *system dialog
 *
 *  @param messageTitle      custom alert message title
 *  @param message           custom alert message
 *  @param cancelTitle       custom cancel button message
 *  @param grantTitle        custom grant button message
 *  @param completion the block that will be executed on the main thread
 *when access is granted or denied.  May be called immediately if access was
 *previously established
 */
- (void)authorizeHealthWithTitle:(NSString *)messageTitle
                         message:(NSString *)message
                     cancelTitle:(NSString *)cancelTitle
                      grantTitle:(NSString *)grantTitle
                      completion:(AuthorizationHandler)completion;
/**
 *  Displays a dialog telling the user how to re-enable health permission in
 * the Settings application
 */
- (void)displayHealthErrorDialog;

@end
