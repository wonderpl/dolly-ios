//
//  SYNLoginViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 11/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//


#import "GKImagePicker.h"
#import "SYNAppDelegate.h"
#import "SYNLoginBaseViewController.h"
#import "SYNOAuth2Credential.h"
@import UIKit;


@interface SYNLoginViewController : SYNLoginBaseViewController

@property (nonatomic) BOOL facebookLoginIsInProcess;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* activityIndicator;

@property (nonatomic, strong) IBOutlet UIButton* passwordForgottenButton;

@property (nonatomic, strong) UIImage* avatarImage;

-(void)showAutologinWithCredentials:(SYNOAuth2Credential*)credentials;




@end
