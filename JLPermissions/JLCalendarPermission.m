//
//  JLCalendarPermissions.m
//
//  Created by Joseph Laws on 11/3/14.
//  Copyright (c) 2014 Joe Laws. All rights reserved.
//

#import "JLCalendarPermission.h"

@import EventKit;

#import "JLPermissionsCore+Internal.h"

@implementation JLCalendarPermission {
  AuthorizationHandler _completion;
}

+ (instancetype)sharedInstance {
  static JLCalendarPermission *_instance = nil;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{
    _instance = [[JLCalendarPermission alloc] init];
  });

  return _instance;
}

#pragma mark - Calendar

- (JLAuthorizationStatus)authorizationStatus {
  EKAuthorizationStatus authorizationStatus =
      [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
  switch (authorizationStatus) {
    case EKAuthorizationStatusAuthorized:
      return JLPermissionAuthorized;
    case EKAuthorizationStatusNotDetermined:
      return JLPermissionNotDetermined;
    case EKAuthorizationStatusRestricted:
    case EKAuthorizationStatusDenied:
      return JLPermissionDenied;
  }
}

- (void)authorize:(AuthorizationHandler)completion {
  [self authorizeWithTitle:[self defaultTitle:@"Calendar"]
                   message:[self defaultMessage]
               cancelTitle:[self defaultCancelTitle]
                grantTitle:[self defaultGrantTitle]
                completion:completion];
}

- (void)authorizeWithTitle:(NSString *)messageTitle
                   message:(NSString *)message
               cancelTitle:(NSString *)cancelTitle
                grantTitle:(NSString *)grantTitle
                completion:(AuthorizationHandler)completion {
  EKAuthorizationStatus authorizationStatus =
      [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];

  switch (authorizationStatus) {
    case EKAuthorizationStatusAuthorized: {
      if (completion) {
        completion(true, nil);
      }
    } break;
    case EKAuthorizationStatusNotDetermined: {
      _completion = completion;
      if (self.isExtraAlertEnabled) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:messageTitle
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:cancelTitle
                                              otherButtonTitles:grantTitle, nil];
        dispatch_async(dispatch_get_main_queue(), ^{
          [alert show];
        });
      } else {
        [self actuallyAuthorize];
      }
    } break;
    case EKAuthorizationStatusRestricted:
    case EKAuthorizationStatusDenied: {
      if (completion) {
        completion(false, [self previouslyDeniedError]);
      }
    } break;
  }
}

- (JLPermissionType)permissionType {
  return JLPermissionCalendar;
}

- (void)actuallyAuthorize {
  EKAuthorizationStatus authorizationStatus =
      [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];

  switch (authorizationStatus) {
    case EKAuthorizationStatusAuthorized: {
      if (_completion) {
        _completion(true, nil);
      }
    } break;
    case EKAuthorizationStatusNotDetermined: {
      EKEventStore *eventStore = [[EKEventStore alloc] init];
      [eventStore requestAccessToEntityType:EKEntityTypeEvent
                                 completion:^(BOOL granted, NSError *error) {
                                   if (_completion) {
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                       if (granted) {
                                         _completion(true, nil);
                                       } else {
                                         _completion(false, [self systemDeniedError:error]);
                                       }
                                     });
                                   }
                                 }];
    } break;
    case EKAuthorizationStatusRestricted:
    case EKAuthorizationStatusDenied: {
      if (_completion) {
        _completion(false, [self previouslyDeniedError]);
      }
    } break;
  }
}

- (void)canceledAuthorization:(NSError *)error {
  if (_completion) {
    _completion(false, error);
  }
}

@end
