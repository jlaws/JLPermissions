//
//  JLViewController.m
//  JLPermissionsExample
//
//  Created by Joseph Laws on 4/19/14.
//  Copyright (c) 2014 Joe Laws. All rights reserved.
//

#import "JLViewController.h"
#import "JLPermissions.h"
#import "DDLog.h"

static const int ddLogLevel = LOG_LEVEL_INFO;

@interface JLViewController ()

@property(strong, nonatomic) IBOutlet UILabel *pushNotificationLabel;
@property(strong, nonatomic) IBOutlet UILabel *addressBookLabel;
@property(strong, nonatomic) IBOutlet UILabel *photoLibraryLabel;
@property(strong, nonatomic) IBOutlet UILabel *calendarLabel;
@property(strong, nonatomic) IBOutlet UILabel *remindersLabel;

@end

@implementation JLViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  DDLogInfo(@"%@", [JLPermissions sharedInstance].appName);
  [self updateStatusLabels];
}

- (void)updateStatusLabels {
  self.addressBookLabel.text = [self
      authorizationText:[[JLPermissions sharedInstance] contactsAuthorized]];
}

- (NSString *)authorizationText:(BOOL)enabled {
  return (enabled) ? @"Enabled" : @"Disabled";
}

- (IBAction)pushNotifications:(id)sender {
}

- (IBAction)contacts:(id)sender {
  [[JLPermissions sharedInstance]
      authorizeContacts:^(bool granted,
                          NSError *error) { [self updateStatusLabels]; }];
}

- (IBAction)photoLibrary:(id)sender {
}
- (IBAction)calendar:(id)sender {
}
- (IBAction)reminders:(id)sender {
}

@end
