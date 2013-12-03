//
//  SYNOnBoardingFooter.m
//  dolly
//
//  Created by Michael Michailidis on 03/12/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNOnBoardingFooter.h"
#import "UIFont+SYNFont.h"

@implementation SYNOnBoardingFooter

-(void)awakeFromNib
{
    
    self.skipButton.titleLabel.font = [UIFont regularCustomFontOfSize:self.skipButton.titleLabel.font.pointSize];
    
    self.skipButton.layer.borderWidth = 1.0;
    self.skipButton.layer.borderColor = [UIColor colorWithRed:(188.0f/255.0f) green:(186.0f/255.0f) blue:(212.0f/255.0f) alpha:1.0f].CGColor;
    self.skipButton.layer.cornerRadius = 8.0f;
    
}


@end
