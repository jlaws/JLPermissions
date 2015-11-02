//
//  JLCameraPermission.m
//  JLPermissionsExample
//
//  Created by Joseph Laws on 12/2/14.
//  Copyright (c) 2014 Joe Laws. All rights reserved.
//

#import "JLCameraPermission.h"

@import AVFoundation;

#import "JLPermissionsCore+Internal.h"

@implementation JLCameraPermission {
  AuthorizationHandler _completion;
}

+ (instancetype)sharedInstance {
  static JLCameraPermission *_instance = nil;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{
    _instance = [[JLCameraPermission alloc] init];
  });

  return _instance;
}

#pragma mark - Microphone

- (JLAuthorizationStatus)authorizationStatus {
  if ([AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)]) {
    AVAuthorizationStatus permission =
        [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];

    switch (permission) {
      case AVAuthorizationStatusAuthorized:
        return JLPermissionAuthorized;
      case AVAuthorizationStatusDenied:
      case AVAuthorizationStatusRestricted:
        return JLPermissionDenied;
      case AVAuthorizationStatusNotDetermined:
        return JLPermissionNotDetermined;
    }
  } else {
    // Prior to iOS 8 all apps were authorized.
    return JLPermissionAuthorized;
  }
}

- (void)authorize:(AuthorizationHandler)completion {
  [self authorizeWithTitle:[self defaultTitle:@"Camera"]
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
  if ([AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)]) {
    AVAuthorizationStatus permission =
        [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (permission) {
      case AVAuthorizationStatusAuthorized: {
        if (completion) {
          completion(true, nil);
        }
      } break;
      case AVAuthorizationStatusDenied:
      case AVAuthorizationStatusRestricted: {
        if (completion) {
          completion(false, [self previouslyDeniedError]);
        }
      } break;
      case AVAuthorizationStatusNotDetermined: {
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
    }
  } else {
    // Prior to iOS 8 all apps were authorized.
    if (completion) {
      completion(true, nil);
    }
  }
}

- (JLPermissionType)permissionType {
  return JLPermissionCamera;
}

- (void)actuallyAuthorize {
  [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                           completionHandler:^(BOOL granted) {
                             if (_completion) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                 if (granted) {
                                   _completion(true, nil);
                                 } else {
                                   _completion(false, nil);
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
