//
//  SYNTermsViewController.m
//  dolly
//
//  Created by Sherman Lo on 27/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNTermsViewController.h"
#import "AppConstants.h"
#import "SYNWebViewController.h"

@interface SYNTermsViewController ()

@end

@implementation SYNTermsViewController

- (IBAction)termsAndConditionsButtonPressed:(UIButton *)button {
	NSURL *url = [NSURL URLWithString:kURLTermsAndConditions];
	UIViewController *webViewController = [SYNWebViewController webViewControllerForURL:url];
	[self presentViewController:webViewController animated:YES completion:nil];
}

- (IBAction)privacyPolicyButtonPressed:(UIButton *)button {
	NSURL *url = [NSURL URLWithString:kURLPrivacy];
	UIViewController *webViewController = [SYNWebViewController webViewControllerForURL:url];
	[self presentViewController:webViewController animated:YES completion:nil];
}

@end
