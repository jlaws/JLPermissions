//
//  JLViewController.m
//  JLPermissionsExample
//
//  Created by Joseph Laws on 4/19/14.
//  Copyright (c) 2014 Joe Laws. All rights reserved.
//

#import "JLViewController.h"
#import "JLPermissions.h"

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
  self.calendarLabel.text = [self
      authorizationText:[[JLPermissions sharedInstance] calendarAuthorized]];
  self.pushNotificationLabel.text =
      [self authorizationText:
                [[JLPermissions sharedInstance] notificationsAuthorized]];
  self.addressBookLabel.text = [self
      authorizationText:[[JLPermissions sharedInstance] contactsAuthorized]];
  self.photoLibraryLabel.text = [self
      authorizationText:[[JLPermissions sharedInstance] photosAuthorized]];
  self.remindersLabel.text = [self
      authorizationText:[[JLPermissions sharedInstance] remindersAuthorized]];
  self.locationsLabel.text = [self
      authorizationText:[[JLPermissions sharedInstance] locationsAuthorized]];
  self.twitterLabel.text = [self
      authorizationText:[[JLPermissions sharedInstance] twitterAuthorized]];
  self.facebookLabel.text = [self
      authorizationText:[[JLPermissions sharedInstance] facebookAuthorized]];
  self.microphoneLabel.text = [self
      authorizationText:[[JLPermissions sharedInstance] microphoneAuthorized]];
  self.healthLabel.text = [self
      authorizationText:[[JLPermissions sharedInstance] healthAuthorized]];
}

- (NSString *)authorizationText:(BOOL)enabled {
  return (enabled) ? @"Enabled" : @"Disabled";
}

- (IBAction)pushNotifications:(id)sender {
  [[JLPermissions sharedInstance] authorizeNotifications:^(NSString *deviceID,
                                                           NSError *error) {
      NSLog(@"pushNotifications returned %@ with error %@", deviceID, error);
      [self updateStatusLabels];
  }];
}

- (IBAction)contacts:(id)sender {
  [[JLPermissions sharedInstance]
      authorizeContacts:^(bool granted, NSError *error) {
          NSLog(@"contacts returned %@ with error %@", @(granted), error);
          [self updateStatusLabels];
      }];
}

- (IBAction)photoLibrary:(id)sender {
  [[JLPermissions sharedInstance]
      authorizePhotos:^(bool granted, NSError *error) {
          NSLog(@"photoLibrary returned %@ with error %@", @(granted), error);
          [self updateStatusLabels];
      }];
}

- (IBAction)calendar:(id)sender {
  [[JLPermissions sharedInstance]
      authorizeCalendar:^(bool granted, NSError *error) {
          NSLog(@"calendar returned %@ with error %@", @(granted), error);
          [self updateStatusLabels];
      }];
}

- (IBAction)reminders:(id)sender {
  [[JLPermissions sharedInstance]
      authorizeReminders:^(bool granted, NSError *error) {
          NSLog(@"reminders returned %@ with error %@", @(granted), error);
          [self updateStatusLabels];
      }];
}
- (IBAction)microphone:(id)sender {
  [[JLPermissions sharedInstance]
      authorizeMicrophone:^(bool granted, NSError *error) {
          NSLog(@"microphone returned %@ with error %@", @(granted), error);
          [self updateStatusLabels];
      }];
}
- (IBAction)health:(id)sender {
  [[JLPermissions sharedInstance]
      authorizeHealth:^(bool granted, NSError *error) {
          NSLog(@"health returned %@ with error %@", @(granted), error);
          [self updateStatusLabels];
      }];
}

- (IBAction)locations:(id)sender {
  [[JLPermissions sharedInstance]
      authorizeLocations:^(bool granted, NSError *error) {
          NSLog(@"locations returned %@ with error %@", @(granted), error);
          [self updateStatusLabels];
      }];
}

- (IBAction)twitter:(id)sender {
  [[JLPermissions sharedInstance]
      authorizeTwitter:^(bool granted, NSError *error) {
          NSLog(@"twitter returned %@ with error %@", @(granted), error);
          [self updateStatusLabels];
      }];
}

- (IBAction)facebook:(id)sender {
  [[JLPermissions sharedInstance]
      authorizeFacebook:^(bool granted, NSError *error) {
          NSLog(@"facebook returned %@ with error %@", @(granted), error);
          [self updateStatusLabels];
      }];
}

@end
