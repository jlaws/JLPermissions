# JLPermissions

[![Version](http://cocoapod-badges.herokuapp.com/v/JLPermissions/badge.png)](http://cocoadocs.org/docsets/JLPermissions)
[![Platform](http://cocoapod-badges.herokuapp.com/p/JLPermissions/badge.png)](http://cocoadocs.org/docsets/JLPermissions)

JLPermissions is a pre-permissions utility that lets developers ask users on their own dialog for calendar, contacts, photos, reminders, and push notificaion access, before making the system-based request. 

## Requirements

iOS 7.0

## Installation

JLPermissions is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "JLPermissions"

## Usage

To run the example project; clone the repo, and run `pod install`, then open JLPermissionsExample.xcworkspace.

The method for asking for each type of permission (other than push notifications) is virtually identical.  Here is the the API:

```objective-c

typedef void (^AuthorizationBlock)(bool granted, NSError *error);
typedef void (^NotificationAuthorizationBlock)(NSString *deviceID,
                                               NSError *error);

@interface JLPermissions : NSObject

+ (instancetype)sharedInstance;

- (BOOL)contactsAuthorized;
- (void)authorizeContacts:(AuthorizationBlock)completionHandler;
- (void)authorizeContactsWithTitle:(NSString *)messageTitle
                           message:(NSString *)message
                       cancelTitle:(NSString *)cancelTitle
                        grantTitle:(NSString *)grantTitle
                 completionHandler:(AuthorizationBlock)completionHandler;

- (BOOL)calendarAuthorized;
- (void)authorizeCalendar:(AuthorizationBlock)completionHandler;
- (void)authorizeCalendarWithTitle:(NSString *)messageTitle
                           message:(NSString *)message
                       cancelTitle:(NSString *)cancelTitle
                        grantTitle:(NSString *)grantTitle
                 completionHandler:(AuthorizationBlock)completionHandler;

- (BOOL)photosAuthorized;
- (void)authorizePhotos:(AuthorizationBlock)completionHandler;
- (void)authorizePhotosWithTitle:(NSString *)messageTitle
                         message:(NSString *)message
                     cancelTitle:(NSString *)cancelTitle
                      grantTitle:(NSString *)grantTitle
               completionHandler:(AuthorizationBlock)completionHandler;

- (BOOL)remindersAuthorized;
- (void)authorizeReminders:(AuthorizationBlock)completionHandler;
- (void)authorizeRemindersWithTitle:(NSString *)messageTitle
                            message:(NSString *)message
                        cancelTitle:(NSString *)cancelTitle
                         grantTitle:(NSString *)grantTitle
                  completionHandler:(AuthorizationBlock)completionHandler;

- (BOOL)notificationsAuthorized;
- (void)authorizeNotifications:
        (NotificationAuthorizationBlock)completionHandler;
- (void)authorizeNotificationsWithTitle:(NSString *)messageTitle
                                message:(NSString *)message
                            cancelTitle:(NSString *)cancelTitle
                             grantTitle:(NSString *)grantTitle
                      completionHandler:
                          (NotificationAuthorizationBlock)completionHandler;
- (void)unauthorizeNotifications;
- (void)notificationResult:(NSData *)deviceToken error:(NSError *)error;
- (NSString *)deviceID;

@end
```

## Author

- [Joe Laws]

## Projects

Here is a list of iPhone apps utilizing this library:

- [Seer Reminders] - [Seer Homepage]

## License

JLAddressBook is available under the MIT license. See the LICENSE file for more info.

[Joe Laws]:https://angel.co/joe-laws
[Seer Reminders]:https://itunes.apple.com/us/app/seer-reminders/id721450216?ls=1&mt=8
[Seer Homepage]:http://getseer.com

