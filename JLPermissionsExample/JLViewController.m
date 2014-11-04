//
//  JLViewController.m
//  JLPermissionsExample
//
//  Created by Joseph Laws on 4/19/14.
//  Copyright (c) 2014 Joe Laws. All rights reserved.
//

#import "JLViewController.h"

#import "JLCalendarPermission.h"
#import "JLContactsPermission.h"
#import "JLFacebookPermission.h"
#import "JLHealthPermission.h"
#import "JLLocationPermission.h"
#import "JLMicrophonePermission.h"
#import "JLNotificationPermission.h"
#import "JLPhotosPermission.h"
#import "JLRemindersPermission.h"
#import "JLTwitterPermission.h"

@interface JLViewController ()

@property(strong, nonatomic) IBOutlet UILabel *pushNotificationLabel;
@property(strong, nonatomic) IBOutlet UILabel *addressBookLabel;
@property(strong, nonatomic) IBOutlet UILabel *photoLibraryLabel;
@property(strong, nonatomic) IBOutlet UILabel *calendarLabel;
@property(strong, nonatomic) IBOutlet UILabel *remindersLabel;
@property(strong, nonatomic) IBOutlet UILabel *locationsLabel;
@property(strong, nonatomic) IBOutlet UILabel *twitterLabel;
@property(strong, nonatomic) IBOutlet UILabel *facebookLabel;
@property(strong, nonatomic) IBOutlet UILabel *microphoneLabel;
@property(strong, nonatomic) IBOutlet UILabel *healthLabel;

@end

@implementation JLViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  NSLog(@"viewDidLoad");
  [self updateStatusLabels];
}

- (void)updateStatusLabels {
  self.calendarLabel.text =
      [self authorizationText:[[JLCalendarPermission sharedInstance] calendarAuthorized]];
  self.pushNotificationLabel.text =
      [self authorizationText:[[JLNotificationPermission sharedInstance] notificationsAuthorized]];
  self.addressBookLabel.text =
      [self authorizationText:[[JLContactsPermission sharedInstance] contactsAuthorized]];
  self.photoLibraryLabel.text =
      [self authorizationText:[[JLPhotosPermission sharedInstance] photosAuthorized]];
  self.remindersLabel.text =
      [self authorizationText:[[JLRemindersPermission sharedInstance] remindersAuthorized]];
  self.locationsLabel.text =
      [self authorizationText:[[JLLocationPermission sharedInstance] locationsAuthorized]];
  self.twitterLabel.text =
      [self authorizationText:[[JLTwitterPermission sharedInstance] twitterAuthorized]];
  self.facebookLabel.text =
      [self authorizationText:[[JLFacebookPermission sharedInstance] facebookAuthorized]];
  self.microphoneLabel.text =
      [self authorizationText:[[JLMicrophonePermission sharedInstance] microphoneAuthorized]];
  self.healthLabel.text =
      [self authorizationText:[[JLHealthPermission sharedInstance] healthAuthorized]];
}

- (NSString *)authorizationText:(BOOL)enabled {
  return (enabled) ? @"Enabled" : @"Disabled";
}

- (IBAction)pushNotifications:(id)sender {
  [[JLNotificationPermission sharedInstance]
      authorizeNotifications:^(NSString *deviceID, NSError *error) {
          NSLog(@"pushNotifications returned %@ with error %@", deviceID, error);
          [self updateStatusLabels];
      }];
}

- (IBAction)contacts:(id)sender {
  [[JLContactsPermission sharedInstance] authorizeContacts:^(bool granted, NSError *error) {
      NSLog(@"contacts returned %@ with error %@", @(granted), error);
      [self updateStatusLabels];
  }];
}

- (IBAction)photoLibrary:(id)sender {
  [[JLPhotosPermission sharedInstance] authorizePhotos:^(bool granted, NSError *error) {
      NSLog(@"photoLibrary returned %@ with error %@", @(granted), error);
      [self updateStatusLabels];
  }];
}

- (IBAction)calendar:(id)sender {
  [[JLCalendarPermission sharedInstance] authorizeCalendar:^(bool granted, NSError *error) {
      NSLog(@"calendar returned %@ with error %@", @(granted), error);
      [self updateStatusLabels];
  }];
}

- (IBAction)reminders:(id)sender {
  [[JLRemindersPermission sharedInstance] authorizeReminders:^(bool granted, NSError *error) {
      NSLog(@"reminders returned %@ with error %@", @(granted), error);
      [self updateStatusLabels];
  }];
}
- (IBAction)microphone:(id)sender {
  [[JLMicrophonePermission sharedInstance] authorizeMicrophone:^(bool granted, NSError *error) {
      NSLog(@"microphone returned %@ with error %@", @(granted), error);
      [self updateStatusLabels];
  }];
}
- (IBAction)health:(id)sender {
  [[JLHealthPermission sharedInstance] authorizeHealth:^(bool granted, NSError *error) {
      NSLog(@"health returned %@ with error %@", @(granted), error);
      [self updateStatusLabels];
  }];
}

- (IBAction)locations:(id)sender {
  [[JLLocationPermission sharedInstance] authorizeLocations:^(bool granted, NSError *error) {
      NSLog(@"locations returned %@ with error %@", @(granted), error);
      [self updateStatusLabels];
  }];
}

- (IBAction)twitter:(id)sender {
  [[JLTwitterPermission sharedInstance] authorizeTwitter:^(bool granted, NSError *error) {
      NSLog(@"twitter returned %@ with error %@", @(granted), error);
      [self updateStatusLabels];
  }];
}

- (IBAction)facebook:(id)sender {
  [[JLFacebookPermission sharedInstance] authorizeFacebook:^(bool granted, NSError *error) {
      NSLog(@"facebook returned %@ with error %@", @(granted), error);
      [self updateStatusLabels];
  }];
}

@end
