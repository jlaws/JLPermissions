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

@end

@implementation JLViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  NSLog(@"%@", [JLPermissions sharedInstance].appName);
}

- (void)updateStatusLabels {
  self.addressBookLabel.text =
      [[JLPermissions sharedInstance] addressBookAuthorized] ? @"Enabled"
                                                             : @"Disabled";
}

- (IBAction)pushNotifications:(id)sender {
}

- (IBAction)addressBook:(id)sender {
}

- (IBAction)photoLibrary:(id)sender {
}

@end
