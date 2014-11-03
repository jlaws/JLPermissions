//
//  JLPermissionCore.m
//
//  Created by Joseph Laws on 11/3/14.
//  Copyright (c) 2014 Joe Laws. All rights reserved.
//

#import "JLPermissionsCore.h"

@implementation JLPermissionsCore

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

- (void)displayErrorDialog:(NSString *)authorizationType {
  NSString *message = [NSString stringWithFormat:@"Please go to Settings -> Privacy -> "
                                                 @"%@ to re-enable %@'s access.",
                                                 authorizationType, [self appName]];
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                  message:message
                                                 delegate:nil
                                        cancelButtonTitle:@"Ok"
                                        otherButtonTitles:nil];
  [alert show];
}

- (NSError *)previouslyDeniedError {
  return [NSError errorWithDomain:@"PreviouslyDenied" code:JLPermissionDenied userInfo:nil];
}

- (NSError *)systemDeniedError:(NSError *)error {
  return
      [NSError errorWithDomain:@"SystemDenied" code:JLPermissionDenied userInfo:[error userInfo]];
}

- (void)actuallyAuthorize {
}

- (void)canceledAuthorization:(NSError *)error {
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  BOOL canceled = (buttonIndex == alertView.cancelButtonIndex);
  dispatch_async(dispatch_get_main_queue(), ^{
      if (canceled) {
        NSError *error =
            [NSError errorWithDomain:@"UserDenied" code:JLPermissionDenied userInfo:nil];
        [self canceledAuthorization:error];
      } else {
        [self actuallyAuthorize];
      }
  });
}

@end
