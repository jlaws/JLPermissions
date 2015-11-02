//
//  JLHealthPermissions.m
//
//  Created by Joseph Laws on 11/3/14.
//  Copyright (c) 2014 Joe Laws. All rights reserved.
//

#import "JLHealthPermission.h"

@import HealthKit;

#import "JLPermissionsCore+Internal.h"

@implementation JLHealthPermission {
  AuthorizationHandler _completion;
}

+ (instancetype)sharedInstance {
  static JLHealthPermission *_instance = nil;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{
    _instance = [[JLHealthPermission alloc] init];
  });

  return _instance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _readTypes = [NSMutableSet set];
    _writeTypes = [NSMutableSet set];
  }
  return self;
}

#pragma mark - Health

- (JLAuthorizationStatus)authorizationStatus {
  HKHealthStore *healthStore = [[HKHealthStore alloc] init];
  NSMutableSet *allTypes = [NSMutableSet set];
  [allTypes unionSet:_readTypes];
  [allTypes unionSet:_writeTypes];

  for (HKObjectType *sampleType in allTypes) {
    HKAuthorizationStatus status = [healthStore authorizationStatusForType:sampleType];
    switch (status) {
      case HKAuthorizationStatusSharingDenied:
        return JLPermissionDenied;
      case HKAuthorizationStatusSharingAuthorized:
        return JLPermissionAuthorized;
      case HKAuthorizationStatusNotDetermined:
        break;
    }
  }
  return JLPermissionNotDetermined;
}

- (void)authorize:(AuthorizationHandler)completion {
  [self authorizeWithTitle:[self defaultTitle:@"Health"]
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
  NSMutableSet *allTypes = [NSMutableSet set];
  [allTypes unionSet:_readTypes];
  [allTypes unionSet:_writeTypes];

  HKHealthStore *healthStore = [[HKHealthStore alloc] init];
  for (HKObjectType *healthType in allTypes) {
    HKAuthorizationStatus status = [healthStore authorizationStatusForType:healthType];
    switch (status) {
      case HKAuthorizationStatusNotDetermined: {
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
      case HKAuthorizationStatusSharingAuthorized: {
        if (completion) {
          completion(true, nil);
        }
      } break;
      case HKAuthorizationStatusSharingDenied: {
        if (completion) {
          completion(false, [self previouslyDeniedError]);
        }
      } break;
    }
  }
}

- (JLPermissionType)permissionType {
  return JLPermissionHealth;
}

- (void)actuallyAuthorize {
  HKHealthStore *healthStore = [[HKHealthStore alloc] init];
  [healthStore requestAuthorizationToShareTypes:_writeTypes
                                      readTypes:_readTypes
                                     completion:^(BOOL success, NSError *error) {
                                       if (_completion) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                           if (success) {
                                             _completion(true, nil);
                                           } else {
                                             _completion(false, error);
                                           }
                                         });
                                       }
                                     }];
}

- (void)canceledAuthorization:(NSError *)error {
  if (_completion) {
    _completion(false, error);
  }
}
@end
