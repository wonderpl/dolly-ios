//
//  SYNIPhoneSignupDetailsViewController.h
//  dolly
//
//  Created by Sherman Lo on 14/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNSignupViewController.h"

@interface SYNIPhoneSignupDetailsViewController : SYNSignupViewController

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *username;

@property (nonatomic, strong) UIImage *avatarImage;

@end
