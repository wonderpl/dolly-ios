//
//  SYNOnBoardingFooter.m
//  dolly
//
//  Created by Michael Michailidis on 03/12/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNOnBoardingFooter.h"
#import "UIFont+SYNFont.h"
#import "UIColor+SYNColor.h"

@interface SYNOnBoardingFooter ()

@property (strong, nonatomic) IBOutlet UIView *border;

@property (nonatomic, strong) IBOutlet UIButton *continueButton;

@end

@implementation SYNOnBoardingFooter

- (void)awakeFromNib {
	[super awakeFromNib];

	UIColor *color = [UIColor colorWithRed:(188.0f/255.0f) green:(186.0f/255.0f) blue:(212.0f/255.0f) alpha:1.0f];

	self.continueButton.titleLabel.font = [UIFont regularCustomFontOfSize:self.continueButton.titleLabel.font.pointSize];

	self.continueButton.layer.borderWidth = 1.0;
	self.continueButton.layer.borderColor = [color CGColor];
	self.continueButton.layer.cornerRadius = 15.5f;

	[self.border.layer setBorderColor:[color CGColor]];
	[self.border.layer setBorderWidth:1.0f];
}

- (IBAction)continueButtonPressed:(UIButton *)button {
	[self.delegate continueButtonPressed:button];
}

@end
