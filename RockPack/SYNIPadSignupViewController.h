//
//  SYNIPadSignupViewController.h
//  dolly
//
//  Created by Sherman Lo on 15/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNSignupViewController.h"

@class SYNTextFieldLogin;

@interface SYNIPadSignupViewController : SYNSignupViewController

@property (nonatomic, strong, readonly) SYNTextFieldLogin *emailTextField;
@property (nonatomic, strong, readonly) UISegmentedControl *genderSegmentedControl;

@property (nonatomic, strong, readonly) UIButton *registerButton;
@property (nonatomic, strong, readonly) UIButton *uploadPhotoButton;

@end
