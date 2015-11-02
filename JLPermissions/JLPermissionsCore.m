//
//  JLPermissionCore.m
//
//  Created by Joseph Laws on 11/3/14.
//  Copyright (c) 2014 Joe Laws. All rights reserved.
//

#import "JLPermissionsCore.h"

#import <DBPrivacyHelper/DBPrivateHelperController.h>

@implementation JLPermissionsCore

- (instancetype)init {
  self = [super init];
  if (self) {
    [self setExtraAlertEnabled:YES];
  }
  return self;
}

- (NSString *)defaultTitle:(NSString *)authorizationType {
  return [NSString
      stringWithFormat:@"\"%@\" Would Like to Access Your %@", [self appName], authorizationType];
}

- (NSString *)defaultMessage {
  return nil;
}

- (NSString *)defaultCancelTitle {
  return @"Don't Allow";
}

- (NSString *)defaultGrantTitle {
  return @"Ok";
}

- (NSString *)appName {
  return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

- (UIViewController *)reenableViewController {
  DBPrivacyType privacyType;
  switch ([self permissionType]) {
    case JLPermissionCalendar:
      privacyType = DBPrivacyTypeCalendars;
      break;
    case JLPermissionCamera:
      privacyType = DBPrivacyTypeCamera;
      break;
    case JLPermissionContacts:
      privacyType = DBPrivacyTypeContacts;
      break;
    case JLPermissionFacebook:
      privacyType = DBPrivacyTypeFacebook;
      break;
    case JLPermissionHealth:
      privacyType = DBPrivacyTypeHealth;
      break;
    case JLPermissionLocation:
      privacyType = DBPrivacyTypeLocation;
      break;
    case JLPermissionMicrophone:
      privacyType = DBPrivacyTypeMicrophone;
      break;
    case JLPermissionNotification:
      privacyType = DBPrivacyTypeNotifications;
      break;
    case JLPermissionPhotos:
      privacyType = DBPrivacyTypePhoto;
      break;
    case JLPermissionReminders:
      privacyType = DBPrivacyTypeReminders;
      break;
    case JLPermissionTwitter:
      privacyType = DBPrivacyTypeTwitter;
      break;
  }
  DBPrivateHelperController *vc = [DBPrivateHelperController helperForType:privacyType];
  vc.snapshot = [self snapshot];
  vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  return vc;
}

- (UIImage *)snapshot {
  id<UIApplicationDelegate> appDelegate = [[UIApplication sharedApplication] delegate];

  UIGraphicsBeginImageContextWithOptions(appDelegate.window.bounds.size, NO,
                                         appDelegate.window.screen.scale);

  [appDelegate.window drawViewHierarchyInRect:appDelegate.window.bounds afterScreenUpdates:NO];

  UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();

  UIGraphicsEndImageContext();

  return snapshotImage;
}

- (void)displayReenableAlert {
  NSString *message = [NSString stringWithFormat:@"Please go to Settings -> Privacy -> "
                                                 @"%@ to re-enable %@'s access.",
                                                 [self permissionName], [self appName]];
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                  message:message
                                                 delegate:nil
                                        cancelButtonTitle:@"Ok"
                                        otherButtonTitles:nil];
  dispatch_async(dispatch_get_main_queue(), ^{
    [alert show];
  });
}

- (NSString *)permissionName {
  switch ([self permissionType]) {
    case JLPermissionCalendar:
      return @"Calendar";
    case JLPermissionCamera:
      return @"Camera";
    case JLPermissionContacts:
      return @"Contacts";
    case JLPermissionFacebook:
      return @"Facebook";
    case JLPermissionHealth:
      return @"Health";
    case JLPermissionLocation:
      return @"Location";
    case JLPermissionMicrophone:
      return @"Microphone";
    case JLPermissionNotification:
      return @"Notification";
    case JLPermissionPhotos:
      return @"Photos";
    case JLPermissionReminders:
      return @"Reminders";
    case JLPermissionTwitter:
      return @"Twitter";
  }
}

- (NSError *)userDeniedError {
  return [NSError errorWithDomain:@"UserDenied" code:JLPermissionUserDenied userInfo:nil];
}

- (NSError *)previouslyDeniedError {
  return [NSError errorWithDomain:@"SystemDenied" code:JLPermissionSystemDenied userInfo:nil];
}

- (NSError *)systemDeniedError:(NSError *)error {
  return [NSError errorWithDomain:@"SystemDenied"
                             code:JLPermissionSystemDenied
                         userInfo:[error userInfo]];
}

- (void)displayAppSystemSettings {
  if (IS_IOS_8 && &UIApplicationOpenSettingsURLString != NULL) {
    NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [[UIApplication sharedApplication] openURL:appSettings];
  }
}

#pragma mark - Abstract methods

- (JLPermissionType)permissionType {
  @throw [NSException
      exceptionWithName:NSInternalInconsistencyException
                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
                                                   NSStringFromSelector(_cmd)]
               userInfo:nil];
}

- (JLAuthorizationStatus)authorizationStatus {
  @throw [NSException
      exceptionWithName:NSInternalInconsistencyException
                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
                                                   NSStringFromSelector(_cmd)]
               userInfo:nil];
}

- (void)actuallyAuthorize {
  @throw [NSException
      exceptionWithName:NSInternalInconsistencyException
                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
                                                   NSStringFromSelector(_cmd)]
               userInfo:nil];
}

- (void)canceledAuthorization:(NSError *)error {
  @throw [NSException
      exceptionWithName:NSInternalInconsistencyException
                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
                                                   NSStringFromSelector(_cmd)]
               userInfo:nil];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  BOOL canceled = (buttonIndex == alertView.cancelButtonIndex);
  dispatch_async(dispatch_get_main_queue(), ^{
    if (canceled) {
      NSError *error =
          [NSError errorWithDomain:@"UserDenied" code:JLPermissionUserDenied userInfo:nil];
      [self canceledAuthorization:error];
    } else {
      [self actuallyAuthorize];
    }
  });
}

@end
