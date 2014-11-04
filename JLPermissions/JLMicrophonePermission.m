//
//  JLMicrophonePermission.m
//
//  Created by Joseph Laws on 11/3/14.
//  Copyright (c) 2014 Joe Laws. All rights reserved.
//

#import "JLMicrophonePermission.h"

@import AVFoundation;

#import "JLPermissionsCore+Internal.h"

@implementation JLMicrophonePermission {
  AuthorizationHandler _completion;
}

+ (instancetype)sharedInstance {
  static JLMicrophonePermission *_instance = nil;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{ _instance = [[JLMicrophonePermission alloc] init]; });

  return _instance;
}

#pragma mark - Microphone

- (BOOL)microphoneAuthorized {
  AVAudioSession *audioSession = [AVAudioSession sharedInstance];
  if ([audioSession respondsToSelector:@selector(recordPermission)]) {
    AVAudioSessionRecordPermission permission = [[AVAudioSession sharedInstance] recordPermission];
    switch (permission) {
      case AVAudioSessionRecordPermissionGranted:
        return YES;
      case AVAudioSessionRecordPermissionDenied:
      case AVAudioSessionRecordPermissionUndetermined:
        return NO;
    }
  } else {
    return NO;
  }
}

- (void)authorizeMicrophone:(AuthorizationHandler)completion {
  [self authorizeMicrophoneWithTitle:[self defaultTitle:@"Microphone"]
                             message:[self defaultMessage]
                         cancelTitle:[self defaultCancelTitle]
                          grantTitle:[self defaultGrantTitle]
                          completion:completion];
}

- (void)authorizeMicrophoneWithTitle:(NSString *)messageTitle
                             message:(NSString *)message
                         cancelTitle:(NSString *)cancelTitle
                          grantTitle:(NSString *)grantTitle
                          completion:(AuthorizationHandler)completion {
  AVAudioSession *audioSession = [AVAudioSession sharedInstance];
  if (![audioSession respondsToSelector:@selector(recordPermission)]) {
    [audioSession requestRecordPermission:^(BOOL granted) {
        if (completion) {
          dispatch_async(dispatch_get_main_queue(), ^{
              if (granted) {
                completion(granted, nil);
              } else {
                completion(false, nil);
              }
          });
        }
    }];
    return;
  }
  AVAudioSessionRecordPermission permission = [audioSession recordPermission];
  switch (permission) {
    case AVAudioSessionRecordPermissionGranted: {
      if (completion) {
        completion(true, nil);
      }
    } break;
    case AVAudioSessionRecordPermissionDenied: {
      if (completion) {
        completion(false, [self previouslyDeniedError]);
      }
    } break;
    case AVAudioSessionRecordPermissionUndetermined: {
      _completion = completion;
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:messageTitle
                                                      message:message
                                                     delegate:self
                                            cancelButtonTitle:cancelTitle
                                            otherButtonTitles:grantTitle, nil];
      [alert show];
    } break;
  }
}

- (void)displayMicrophoneErrorDialog {
  [self displayErrorDialog:@"Microphone"];
}

- (void)actuallyAuthorize {
  AVAudioSession *session = [[AVAudioSession alloc] init];
  NSError *error;
  [session setCategory:@"AVAudioSessionCategoryPlayAndRecord" error:&error];
  [session requestRecordPermission:^(BOOL granted) {
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
