//
//  JLLocationPermissions.m
//
//  Created by Joseph Laws on 11/3/14.
//  Copyright (c) 2014 Joe Laws. All rights reserved.
//

#import "JLLocationPermission.h"

@import CoreLocation;

#import "JLPermissionsCore+Internal.h"

@interface JLLocationPermission ()<CLLocationManagerDelegate>

@end

@implementation JLLocationPermission {
  AuthorizationHandler _completion;
  CLLocationManager *_locationManager;
}

+ (instancetype)sharedInstance {
  static JLLocationPermission *_instance = nil;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{
    _instance = [[JLLocationPermission alloc] init];
  });

  return _instance;
}

#pragma mark - Locations

- (JLAuthorizationStatus)authorizationStatus {
  CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
  switch (authorizationStatus) {
    case kCLAuthorizationStatusAuthorizedAlways:
    case kCLAuthorizationStatusAuthorizedWhenInUse:
      return JLPermissionAuthorized;
    case kCLAuthorizationStatusNotDetermined:
      return JLPermissionNotDetermined;
    case kCLAuthorizationStatusDenied:
    case kCLAuthorizationStatusRestricted:
      return JLPermissionDenied;
  }
}

- (void)authorize:(AuthorizationHandler)completion {
  NSString *title =
      [NSString stringWithFormat:@"\"%@\" Would Like to Use Your Current Location", [self appName]];
  [self authorizeWithTitle:title
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
  CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
  switch (authorizationStatus) {
    case kCLAuthorizationStatusAuthorizedAlways:
    case kCLAuthorizationStatusAuthorizedWhenInUse: {
      if (completion) {
        completion(true, nil);
      }
    } break;
    case kCLAuthorizationStatusNotDetermined: {
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
    case kCLAuthorizationStatusDenied:
    case kCLAuthorizationStatusRestricted: {
      if (completion) {
        completion(false, [self previouslyDeniedError]);
      }
    } break;
  }
}

- (JLPermissionType)permissionType {
  return JLPermissionLocation;
}

- (void)actuallyAuthorize {
  _locationManager = [[CLLocationManager alloc] init];
  _locationManager.delegate = self;

  if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 &&
      [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
    BOOL hasAlwaysKey = [[NSBundle mainBundle]
                            objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"] != nil;
    BOOL hasWhenInUseKey =
        [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"] !=
        nil;
    if (hasAlwaysKey) {
      [_locationManager requestAlwaysAuthorization];
    } else if (hasWhenInUseKey) {
      [_locationManager requestWhenInUseAuthorization];
    } else {
      // At least one of the keys NSLocationAlwaysUsageDescription or
      // NSLocationWhenInUseUsageDescription MUST be present in the Info.plist
      // file to use location services on iOS 8+.
      NSAssert(hasAlwaysKey || hasWhenInUseKey,
               @"To use location services in iOS 8+, your Info.plist must "
               @"provide a value for either "
               @"NSLocationWhenInUseUsageDescription or "
               @"NSLocationAlwaysUsageDescription.");
    }
  } else {
    [_locationManager startUpdatingLocation];
  }
}

- (void)canceledAuthorization:(NSError *)error {
  if (_completion) {
    _completion(false, error);
  }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
    didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  NSLog(@"Status is %@", @(status));

  switch (status) {
    case kCLAuthorizationStatusNotDetermined:
      break;
    case kCLAuthorizationStatusAuthorizedWhenInUse:
    case kCLAuthorizationStatusAuthorizedAlways: {
      [_locationManager stopUpdatingLocation];
      _locationManager = nil;
      if (_completion) {
        _completion(true, nil);
      }
      break;
    }
    case kCLAuthorizationStatusDenied:
    case kCLAuthorizationStatusRestricted: {
      [_locationManager stopUpdatingLocation];
      _locationManager = nil;
      if (_completion) {
        _completion(false, [self systemDeniedError:nil]);
      }
      break;
    }
  }
}

@end
