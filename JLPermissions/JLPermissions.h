//
//  JLPermissions.h
//  Joseph Laws
//
//  Created by Joseph Laws on 4/19/14.
//  Copyright (c) 2014 Joe Laws. All rights reserved.
//

@import Foundation;

typedef void (^AuthorizationBlock)(bool granted, NSError *error);
typedef void (^NotificationAuthorizationBlock)(NSString *deviceID,
                                               NSError *error);

@interface JLPermissions : NSObject

+ (instancetype)sharedInstance;

/**
 *  @return whether or not user has granted access to the address book
 */
- (BOOL)contactsAuthorized;
/**
 *  Uses the default dialog which is identical to the system permission dialog
 *
 *  @param completionHandler the block that will be executed on the main thread
 *when access is granted or denied.  May be called immediately if access was
 *previously established
 */
- (void)authorizeContacts:(AuthorizationBlock)completionHandler;
/**
 *  This is identical to the call other call, however it allows you to specify
 *your own custom text for the dialog window rather than using the standard
 *system dialog
 *
 *  @param messageTitle      custom alert message title
 *  @param message           custom alert message
 *  @param cancelTitle       custom cancel button message
 *  @param grantTitle        custom grant button message
 *  @param completionHandler the block that will be executed on the main thread
 *when access is granted or denied.  May be called immediately if access was
 *previously established
 */
- (void)authorizeContactsWithTitle:(NSString *)messageTitle
                           message:(NSString *)message
                       cancelTitle:(NSString *)cancelTitle
                        grantTitle:(NSString *)grantTitle
                 completionHandler:(AuthorizationBlock)completionHandler;
/**
 *  Displays a dialog telling the user how to re-enable contacts permission in
 * the Settings application
 */
- (void)displayContactsErrorDialog;

/**
 *  @return whether or not user has granted access to the calendar
 */
- (BOOL)calendarAuthorized;
/**
 *  Uses the default dialog which is identical to the system permission dialog
 *
 *  @param completionHandler the block that will be executed on the main thread
 *when access is granted or denied.  May be called immediately if access was
 *previously established
 */
- (void)authorizeCalendar:(AuthorizationBlock)completionHandler;
/**
 *  This is identical to the call other call, however it allows you to specify
 *your own custom text for the dialog window rather than using the standard
 *system dialog
 *
 *  @param messageTitle      custom alert message title
 *  @param message           custom alert message
 *  @param cancelTitle       custom cancel button message
 *  @param grantTitle        custom grant button message
 *  @param completionHandler the block that will be executed on the main thread
 *when access is granted or denied.  May be called immediately if access was
 *previously established
 */
- (void)authorizeCalendarWithTitle:(NSString *)messageTitle
                           message:(NSString *)message
                       cancelTitle:(NSString *)cancelTitle
                        grantTitle:(NSString *)grantTitle
                 completionHandler:(AuthorizationBlock)completionHandler;
/**
 *  Displays a dialog telling the user how to re-enable calendar permission in
 * the Settings application
 */
- (void)displayCalendarErrorDialog;

/**
 *  @return whether or not user has granted access to the photo library
 */
- (BOOL)photosAuthorized;
/**
 *  Uses the default dialog which is identical to the system permission dialog
 *
 *  @param completionHandler the block that will be executed on the main thread
 *when access is granted or denied.  May be called immediately if access was
 *previously established
 */
- (void)authorizePhotos:(AuthorizationBlock)completionHandler;
/**
 *  This is identical to the call other call, however it allows you to specify
 *your own custom text for the dialog window rather than using the standard
 *system dialog
 *
 *  @param messageTitle      custom alert message title
 *  @param message           custom alert message
 *  @param cancelTitle       custom cancel button message
 *  @param grantTitle        custom grant button message
 *  @param completionHandler the block that will be executed on the main thread
 *when access is granted or denied.  May be called immediately if access was
 *previously established
 */
- (void)authorizePhotosWithTitle:(NSString *)messageTitle
                         message:(NSString *)message
                     cancelTitle:(NSString *)cancelTitle
                      grantTitle:(NSString *)grantTitle
               completionHandler:(AuthorizationBlock)completionHandler;
/**
 *  Displays a dialog telling the user how to re-enable photo permission in
 * the Settings application
 */
- (void)displayPhotoErrorDialog;

/**
 *  @return whether or not user has granted access to reminders
 */
- (BOOL)remindersAuthorized;
/**
 *  Uses the default dialog which is identical to the system permission dialog
 *
 *  @param completionHandler the block that will be executed on the main thread
 *when access is granted or denied.  May be called immediately if access was
 *previously established
 */
- (void)authorizeReminders:(AuthorizationBlock)completionHandler;
/**
 *  This is identical to the call other call, however it allows you to specify
 *your own custom text for the dialog window rather than using the standard
 *system dialog
 *
 *  @param messageTitle      custom alert message title
 *  @param message           custom alert message
 *  @param cancelTitle       custom cancel button message
 *  @param grantTitle        custom grant button message
 *  @param completionHandler the block that will be executed on the main thread
 *when access is granted or denied.  May be called immediately if access was
 *previously established
 */
- (void)authorizeRemindersWithTitle:(NSString *)messageTitle
                            message:(NSString *)message
                        cancelTitle:(NSString *)cancelTitle
                         grantTitle:(NSString *)grantTitle
                  completionHandler:(AuthorizationBlock)completionHandler;
/**
 *  Displays a dialog telling the user how to re-enable reminders permission in
 * the Settings application
 */
- (void)displayRemindersErrorDialog;

/**
 *  @return whether or not user has granted access to health information
 */
- (BOOL)healthAuthorized;
/**
 *  Uses the default dialog which is identical to the system permission dialog
 *
 *  @param completionHandler the block that will be executed on the main thread
 *when access is granted or denied.  May be called immediately if access was
 *previously established
 */
- (void)authorizeHealth:(AuthorizationBlock)completionHandler;
/**
 *  This is identical to the call other call, however it allows you to specify
 *your own custom text for the dialog window rather than using the standard
 *system dialog
 *
 *  @param messageTitle      custom alert message title
 *  @param message           custom alert message
 *  @param cancelTitle       custom cancel button message
 *  @param grantTitle        custom grant button message
 *  @param completionHandler the block that will be executed on the main thread
 *when access is granted or denied.  May be called immediately if access was
 *previously established
 */
- (void)authorizeHealthWithTitle:(NSString *)messageTitle
                         message:(NSString *)message
                     cancelTitle:(NSString *)cancelTitle
                      grantTitle:(NSString *)grantTitle
               completionHandler:(AuthorizationBlock)completionHandler;
/**
 *  Displays a dialog telling the user how to re-enable health permission in
 * the Settings application
 */
- (void)displayHealthErrorDialog;

/**
 *  @return whether or not user has granted access to locations
 */
- (BOOL)locationsAuthorized;
/**
 *  Uses the default dialog which is identical to the system permission dialog
 *
 *  @param completionHandler the block that will be executed on the main thread
 *when access is granted or denied.  May be called immediately if access was
 *previously established
 */
- (void)authorizeLocations:(AuthorizationBlock)completionHandler;
/**
 *  This is identical to the call other call, however it allows you to specify
 *your own custom text for the dialog window rather than using the standard
 *system dialog
 *
 *  @param messageTitle      custom alert message title
 *  @param message           custom alert message
 *  @param cancelTitle       custom cancel button message
 *  @param grantTitle        custom grant button message
 *  @param completionHandler the block that will be executed on the main thread
 *when access is granted or denied.  May be called immediately if access was
 *previously established
 */
- (void)authorizeLocationsWithTitle:(NSString *)messageTitle
                            message:(NSString *)message
                        cancelTitle:(NSString *)cancelTitle
                         grantTitle:(NSString *)grantTitle
                  completionHandler:(AuthorizationBlock)completionHandler;
/**
 *  Displays a dialog telling the user how to re-enable locations permission in
 * the Settings application
 */
- (void)displayLocationsErrorDialog;

/**
 *  @return whether or not user has granted access to Twitter
 */
- (BOOL)twitterAuthorized;
/**
 *  Uses the default dialog which is identical to the system permission dialog
 *
 *  @param completionHandler the block that will be executed on the main thread
 *when access is granted or denied.  May be called immediately if access was
 *previously established
 */
- (void)authorizeTwitter:(AuthorizationBlock)completionHandler;
/**
 *  This is identical to the call other call, however it allows you to specify
 *your own custom text for the dialog window rather than using the standard
 *system dialog
 *
 *  @param messageTitle      custom alert message title
 *  @param message           custom alert message
 *  @param cancelTitle       custom cancel button message
 *  @param grantTitle        custom grant button message
 *  @param completionHandler the block that will be executed on the main thread
 *when access is granted or denied.  May be called immediately if access was
 *previously established
 */
- (void)authorizeTwitterWithTitle:(NSString *)messageTitle
                          message:(NSString *)message
                      cancelTitle:(NSString *)cancelTitle
                       grantTitle:(NSString *)grantTitle
                completionHandler:(AuthorizationBlock)completionHandler;
/**
 *  Displays a dialog telling the user how to re-enable twitter permission in
 * the Settings application
 */
- (void)displayTwitterErrorDialog;

/**
 *  @return whether or not user has granted access to Facebook
 */
- (BOOL)facebookAuthorized;
/**
 *  Uses the default dialog which is identical to the system permission dialog
 *
 *  @param completionHandler the block that will be executed on the main thread
 *when access is granted or denied.  May be called immediately if access was
 *previously established
 */
- (void)authorizeFacebook:(AuthorizationBlock)completionHandler;
/**
 *  This is identical to the call other call, however it allows you to specify
 *your own custom text for the dialog window rather than using the standard
 *system dialog
 *
 *  @param messageTitle      custom alert message title
 *  @param message           custom alert message
 *  @param cancelTitle       custom cancel button message
 *  @param grantTitle        custom grant button message
 *  @param completionHandler the block that will be executed on the main thread
 *when access is granted or denied.  May be called immediately if access was
 *previously established
 */
- (void)authorizeFacebookWithTitle:(NSString *)messageTitle
                           message:(NSString *)message
                       cancelTitle:(NSString *)cancelTitle
                        grantTitle:(NSString *)grantTitle
                 completionHandler:(AuthorizationBlock)completionHandler;
/**
 *  Displays a dialog telling the user how to re-enable facebook permission in
 * the Settings application
 */
- (void)displayFacebookErrorDialog;

/**
 *  @return whether or not user has granted access to microphone
 */
- (BOOL)microphoneAuthorized;
/**
 *  Uses the default dialog which is identical to the system permission dialog
 *
 *  @param completionHandler the block that will be executed on the main thread
 *when access is granted or denied.  May be called immediately if access was
 *previously established
 */
- (void)authorizeMicrophone:(AuthorizationBlock)completionHandler;
/**
 *  This is identical to the call other call, however it allows you to specify
 *your own custom text for the dialog window rather than using the standard
 *system dialog
 *
 *  @param messageTitle      custom alert message title
 *  @param message           custom alert message
 *  @param cancelTitle       custom cancel button message
 *  @param grantTitle        custom grant button message
 *  @param completionHandler the block that will be executed on the main thread
 *when access is granted or denied.  May be called immediately if access was
 *previously established
 */
- (void)authorizeMicrophoneWithTitle:(NSString *)messageTitle
                             message:(NSString *)message
                         cancelTitle:(NSString *)cancelTitle
                          grantTitle:(NSString *)grantTitle
                   completionHandler:(AuthorizationBlock)completionHandler;
/**
 *  Displays a dialog telling the user how to re-enable microphone permission
 * in the Settings application
 */
- (void)displayMicrophoneErrorDialog;

/**
 *  @return whether or not user has granted access to push notifications
 */
- (BOOL)notificationsAuthorized;
/**
 *  Uses the default dialog which is identical to the system permission dialog
 *
 *  @param completionHandler the block that will be executed on the main thread
 *when access is granted or denied.  May be called immediately if access was
 *previously established
 */
- (void)authorizeNotifications:
        (NotificationAuthorizationBlock)completionHandler;
/**
 *  This is identical to the call other call, however it allows you to specify
 *your own custom text for the dialog window rather than using the standard
 *system dialog
 *
 *  @param messageTitle      custom alert message title
 *  @param message           custom alert message
 *  @param cancelTitle       custom cancel button message
 *  @param grantTitle        custom grant button message
 *  @param completionHandler the block that will be executed on the main thread
 *when access is granted or denied.  May be called immediately if access was
 *previously established
 */
- (void)authorizeNotificationsWithTitle:(NSString *)messageTitle
                                message:(NSString *)message
                            cancelTitle:(NSString *)cancelTitle
                             grantTitle:(NSString *)grantTitle
                      completionHandler:
                          (NotificationAuthorizationBlock)completionHandler;

/**
 *  Displays a dialog telling the user how to re-enable notification permission
 * in the Settings application
 */
- (void)displayNotificationsErrorDialog;
/**
 *  Removes the apps push notification authorization at the system level and
 * clears the cached deviceID.
 */
- (void)unauthorizeNotifications;
/**
 *  This callback must be called in the AppDelegate or else your push
 *notification handler may not be called
 *
 *- (void)application:(UIApplication *)application
 *didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
 *   [[JLPermissions sharedInstance] notificationResult:deviceToken error:nil];
 *}
 *
 *- (void)application:(UIApplication *)application
 *didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 *   [[JLPermissions sharedInstance] notificationResult:nil error:error];
 *}
 *
 *  @param deviceToken the deviceToken from
 *didRegisterForRemoteNotificationsWithDeviceToken
 *  @param error       the error from
 *didFailToRegisterForRemoteNotificationsWithError
 */
- (void)notificationResult:(NSData *)deviceToken error:(NSError *)error;
/**
 *  The device ID that was previously obtained during an authorizeNotifications
 *call
 *
 *  @return the deviceID with <,>, and spaces removed
 */
- (NSString *)deviceID;

@end
