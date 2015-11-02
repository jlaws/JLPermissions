//
//  JLPhotosPermissions.m
//
//  Created by Joseph Laws on 11/3/14.
//  Copyright (c) 2014 Joe Laws. All rights reserved.
//

#import "JLPhotosPermission.h"

#import "JLPermissionsCore+Internal.h"

@import AssetsLibrary;

@implementation JLPhotosPermission {
  AuthorizationHandler _completion;
}

+ (instancetype)sharedInstance {
  static JLPhotosPermission *_instance = nil;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{
    _instance = [[JLPhotosPermission alloc] init];
  });

  return _instance;
}

#pragma mark - Photos

- (JLAuthorizationStatus)authorizationStatus {
  ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
  switch (status) {
    case ALAuthorizationStatusAuthorized:
      return JLPermissionAuthorized;
    case ALAuthorizationStatusNotDetermined:
      return JLPermissionNotDetermined;
    case ALAuthorizationStatusRestricted:
    case ALAuthorizationStatusDenied:
      return JLPermissionDenied;
  }
}

- (void)authorize:(AuthorizationHandler)completion {
  [self authorizeWithTitle:[self defaultTitle:@"Photos"]
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
  ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
  switch (status) {
    case ALAuthorizationStatusAuthorized:
      if (completion) {
        completion(true, nil);
      }
      break;
    case ALAuthorizationStatusNotDetermined: {
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
    case ALAuthorizationStatusRestricted:
    case ALAuthorizationStatusDenied: {
      if (completion) {
        completion(false, [self previouslyDeniedError]);
      }
    } break;
  }
}

- (JLPermissionType)permissionType {
  return JLPermissionPhotos;
}

- (void)actuallyAuthorize {
  ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
  switch (status) {
    case ALAuthorizationStatusAuthorized:
      if (_completion) {
        _completion(true, nil);
      }
      break;
    case ALAuthorizationStatusNotDetermined: {
      ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];

      [library enumerateGroupsWithTypes:ALAssetsGroupAll
          usingBlock:^(ALAssetsGroup *assetGroup, BOOL *stop) {
            if (*stop) {
              if (_completion) {
                _completion(true, nil);
              }
            } else {
              *stop = YES;
            }
          }
          failureBlock:^(NSError *error) {
            if (_completion) {
              _completion(false, [self systemDeniedError:error]);
            }
          }];
    } break;
    case ALAuthorizationStatusRestricted:
    case ALAuthorizationStatusDenied: {
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
