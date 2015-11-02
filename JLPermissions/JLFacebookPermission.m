//
//  JLFacebookPermissions.m
//
//  Created by Joseph Laws on 11/3/14.
//  Copyright (c) 2014 Joe Laws. All rights reserved.
//

#import "JLFacebookPermission.h"

@import Accounts;

#import "JLPermissionsCore+Internal.h"

#define kJLAskedForFacebookPermission @"JLAskedForFacebookPermission"

@interface JLFacebookPermission ()

@end

@implementation JLFacebookPermission {
  AuthorizationHandler _completion;
}

+ (instancetype)sharedInstance {
  static JLFacebookPermission *_instance = nil;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{
    _instance = [[JLFacebookPermission alloc] init];
    _instance.accountOptions = @{
      @"ACFacebookAppIdKey" : @"REPLACE_ME",
      @"ACFacebookPermissionsKey" : @[ @"publish_stream" ],
      @"ACFacebookAudienceKey" : ACFacebookAudienceEveryone
    };
  });

  return _instance;
}

#pragma mark - Facebook

- (JLAuthorizationStatus)authorizationStatus {
  ACAccountStore *store = [ACAccountStore new];
  ACAccountType *accountType =
      [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
  bool previouslyAsked =
      [[NSUserDefaults standardUserDefaults] boolForKey:kJLAskedForFacebookPermission];
  if ([accountType accessGranted]) {
    return JLPermissionAuthorized;
  } else if (previouslyAsked) {
    return JLPermissionDenied;
  } else {
    return JLPermissionNotDetermined;
  }
}

- (void)authorize:(AuthorizationHandler)completion {
  NSString *title =
      [NSString stringWithFormat:@"\"%@\" Would Like Access to Facebook Accounts", [self appName]];
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
  BOOL authorized = [self authorizationStatus] == JLPermissionAuthorized;
  bool previouslyAsked =
      [[NSUserDefaults standardUserDefaults] boolForKey:kJLAskedForFacebookPermission];
  if (authorized) {
    if (completion) {
      completion(true, nil);
    }
  } else if (!previouslyAsked) {
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
  } else {
    _completion = completion;
    [self actuallyAuthorize];
  }
}

- (JLPermissionType)permissionType {
  return JLPermissionFacebook;
}

- (void)actuallyAuthorize {
  bool previouslyAsked =
      [[NSUserDefaults standardUserDefaults] boolForKey:kJLAskedForFacebookPermission];
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kJLAskedForFacebookPermission];
  [[NSUserDefaults standardUserDefaults] synchronize];

  ACAccountStore *accountStore = [ACAccountStore new];
  ACAccountType *accountType =
      [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];

  [accountStore requestAccessToAccountsWithType:accountType
                                        options:self.accountOptions
                                     completion:^(BOOL granted, NSError *error) {
                                       if (_completion) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                           if (granted) {
                                             _completion(true, nil);
                                           } else if (!previouslyAsked) {
                                             _completion(false, [self systemDeniedError:error]);
                                           } else {
                                             _completion(false, [self previouslyDeniedError]);
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
