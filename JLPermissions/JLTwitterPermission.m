//
//  JLTwitterPermissions.m
//
//  Created by Joseph Laws on 11/3/14.
//  Copyright (c) 2014 Joe Laws. All rights reserved.
//

#import "JLTwitterPermission.h"

@import Accounts;

#import "JLPermissionsCore+Internal.h"

#define kJLAskedForTwitterPermission @"JLAskedForTwitterPermission"

@implementation JLTwitterPermission {
  AuthorizationHandler _completion;
}

+ (instancetype)sharedInstance {
  static JLTwitterPermission *_instance = nil;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{
    _instance = [[JLTwitterPermission alloc] init];
  });

  return _instance;
}

#pragma mark - Twitter

- (JLAuthorizationStatus)authorizationStatus {
  ACAccountStore *store = [ACAccountStore new];
  ACAccountType *accountType =
      [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
  bool previouslyAsked =
      [[NSUserDefaults standardUserDefaults] boolForKey:kJLAskedForTwitterPermission];
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
      [NSString stringWithFormat:@"\"%@\" Would Like Access to Twitter Accounts", [self appName]];
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
  BOOL authorized = [self authorizationStatus];

  bool previouslyAsked =
      [[NSUserDefaults standardUserDefaults] boolForKey:kJLAskedForTwitterPermission];

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
  return JLPermissionTwitter;
}

- (void)actuallyAuthorize {
  bool previouslyAsked =
      [[NSUserDefaults standardUserDefaults] boolForKey:kJLAskedForTwitterPermission];
  [[NSUserDefaults standardUserDefaults] setBool:true forKey:kJLAskedForTwitterPermission];
  [[NSUserDefaults standardUserDefaults] synchronize];

  ACAccountStore *accountStore = [ACAccountStore new];
  ACAccountType *accountType =
      [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

  [accountStore requestAccessToAccountsWithType:accountType
                                        options:nil
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
