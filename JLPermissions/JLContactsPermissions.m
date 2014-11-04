//
//  JLPermissions+Contacts.m
//
//  Created by Joseph Laws on 11/3/14.
//  Copyright (c) 2014 Joe Laws. All rights reserved.
//

#import "JLContactsPermissions.h"

#import "JLPermissionsCore+Internal.h"

@import AddressBook;

@implementation JLContactsPermissions {
  AuthorizationHandler _completion;
}

+ (instancetype)sharedInstance {
  static JLContactsPermissions *_instance = nil;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{ _instance = [[JLContactsPermissions alloc] init]; });

  return _instance;
}

#pragma mark - Contacts

- (BOOL)contactsAuthorized {
  return ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized;
}

- (void)authorizeContacts:(AuthorizationHandler)completion {
  [self authorizeContactsWithTitle:[self defaultTitle:@"Contacts"]
                           message:[self defaultMessage]
                       cancelTitle:[self defaultCancelTitle]
                        grantTitle:[self defaultGrantTitle]
                        completion:completion];
}

- (void)authorizeContactsWithTitle:(NSString *)messageTitle
                           message:(NSString *)message
                       cancelTitle:(NSString *)cancelTitle
                        grantTitle:(NSString *)grantTitle
                        completion:(AuthorizationHandler)completion {
  ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();

  switch (status) {
    case kABAuthorizationStatusAuthorized: {
      if (completion) {
        completion(true, nil);
      }
    } break;
    case kABAuthorizationStatusNotDetermined: {
      _completion = completion;
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:messageTitle
                                                      message:message
                                                     delegate:self
                                            cancelButtonTitle:cancelTitle
                                            otherButtonTitles:grantTitle, nil];
      [alert show];
    } break;
    case kABAuthorizationStatusRestricted:
    case kABAuthorizationStatusDenied: {
      if (completion) {
        completion(false, [self previouslyDeniedError]);
      }
    } break;
  }
}

- (void)displayContactsErrorDialog {
  [self displayErrorDialog:@"Contacts"];
}

- (void)actuallyAuthorize {
  ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();

  switch (status) {
    case kABAuthorizationStatusAuthorized: {
      if (_completion) {
        _completion(true, nil);
      }
    } break;
    case kABAuthorizationStatusNotDetermined: {
      ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
      ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
          if (_completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                  _completion(true, nil);
                } else {
                  NSError *e = (__bridge NSError *)error;
                  _completion(false, [self systemDeniedError:e]);
                }

            });
          }
      });
    } break;
    case kABAuthorizationStatusRestricted:
    case kABAuthorizationStatusDenied: {
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
