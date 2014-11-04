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

@implementation JLFacebookPermission {
  AuthorizationHandler _completion;
}

+ (instancetype)sharedInstance {
  static JLFacebookPermission *_instance = nil;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{ _instance = [[JLFacebookPermission alloc] init]; });

  return _instance;
}

#pragma mark - Facebook

- (BOOL)facebookAuthorized {
  ACAccountStore *store = [ACAccountStore new];
  ACAccountType *accountType =
      [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
  return [accountType accessGranted];
}

- (void)authorizeFacebook:(AuthorizationHandler)completion {
  NSString *title =
      [NSString stringWithFormat:@"\"%@\" Would Like Access to Facebook Accounts", [self appName]];
  [self authorizeFacebookWithTitle:title
                           message:[self defaultMessage]
                       cancelTitle:[self defaultCancelTitle]
                        grantTitle:[self defaultGrantTitle]
                        completion:completion];
}

- (void)authorizeFacebookWithTitle:(NSString *)messageTitle
                           message:(NSString *)message
                       cancelTitle:(NSString *)cancelTitle
                        grantTitle:(NSString *)grantTitle
                        completion:(AuthorizationHandler)completion {
  BOOL authorized = [self facebookAuthorized];
  bool previouslyAsked =
      [[NSUserDefaults standardUserDefaults] boolForKey:kJLAskedForFacebookPermission];
  if (authorized) {
    if (completion) {
      completion(true, nil);
    }
  } else if (!previouslyAsked) {
    _completion = completion;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:messageTitle
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:cancelTitle
                                          otherButtonTitles:grantTitle, nil];
    [alert show];
  } else {
    _completion = completion;
    [self actuallyAuthorize];
  }
}

- (void)displayFacebookErrorDialog {
  [self displayErrorDialog:@"Facebook"];
}

- (void)actuallyAuthorize {
  bool previouslyAsked =
      [[NSUserDefaults standardUserDefaults] boolForKey:kJLAskedForFacebookPermission];
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kJLAskedForFacebookPermission];
  [[NSUserDefaults standardUserDefaults] synchronize];

  ACAccountStore *accountStore = [ACAccountStore new];
  ACAccountType *accountType =
      [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
  NSDictionary *options = @{
    @"ACFacebookAppIdKey" : @"123456789",
    @"ACFacebookPermissionsKey" : @[ @"publish_stream" ],
    @"ACFacebookAudienceKey" : ACFacebookAudienceEveryone
  };
  [accountStore requestAccessToAccountsWithType:accountType
                                        options:options
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
