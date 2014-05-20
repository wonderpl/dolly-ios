//
//  SYNiPadLoginViewController.h
//  dolly
//
//  Created by Sherman Lo on 15/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYNTextFieldLogin;

@interface SYNiPadLoginViewController : UIViewController

@property (nonatomic, strong, readonly) UIButton *facebookButton;
@property (nonatomic, strong, readonly) SYNTextFieldLogin *emailUsernameTextField;
@property (nonatomic, strong, readonly) SYNTextFieldLogin *passwordTextField;
@property (nonatomic, strong, readonly) UIButton *loginButton;
@property (nonatomic, strong, readonly) UIButton *forgotPasswordButton;

@end
