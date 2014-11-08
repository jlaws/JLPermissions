# JLPermissions

[![Version](http://cocoapod-badges.herokuapp.com/v/JLPermissions/badge.png)](http://cocoadocs.org/docsets/JLPermissions)
[![Platform](http://cocoapod-badges.herokuapp.com/p/JLPermissions/badge.png)](http://cocoadocs.org/docsets/JLPermissions)

## Requirements

iOS 7.0+

## Installation

JLPermissions is available through [CocoaPods](http://cocoapods.org), to install it simply add the following line to your Podfile:

    pod "JLPermissions/Calendar"
    pod "JLPermissions/Contacts"
    pod "JLPermissions/Facebook"
    pod "JLPermissions/Health"
    pod "JLPermissions/Location"
    pod "JLPermissions/Microphone"
    pod "JLPermissions/Notification"
    pod "JLPermissions/Photos"
    pod "JLPermissions/Reminders"
    pod "JLPermissions/Twitter" 

Only add the pod for the permissions you plan on using.  Apple rejects apps that include Healthkit API's but do not use them.

## Usage

To run the example project; clone the repo, and run `pod install`, then open JLPermissionsExample.xcworkspace.

The method for asking for each type of permission (other than push notifications) is virtually identical.  Here are some examples:

```objective-c

typedef NS_ENUM(NSInteger, JLAuthorizationStatus) {
  JLPermissionNotDetermined = 0,
  JLPermissionDenied,
  JLPermissionAuthorized
};

typedef void (^AuthorizationHandler)(bool granted, NSError *error);

- (JLAuthorizationStatus)authorizationStatus;
- (void)authorize:(AuthorizationHandler)completion;
- (void)authorizeWithTitle:(NSString *)messageTitle
                   message:(NSString *)message
               cancelTitle:(NSString *)cancelTitle
                grantTitle:(NSString *)grantTitle
                completion:(AuthorizationHandler)completion;
- (void)displayErrorDialog;

```

## Author

- [Joe Laws]

## Projects

Here is a list of iPhone apps utilizing this library (let me know if you want your app added):

- [Faysee] - [Faysee Homepage]

## License

JLAddressBook is available under the MIT license. See the LICENSE file for more info.

[Joe Laws]:https://angel.co/joe-laws
[Faysee]:https://itunes.apple.com/us/app/seer-reminders/id721450216?ls=1&mt=8
[Faysee Homepage]:http://faysee.com

