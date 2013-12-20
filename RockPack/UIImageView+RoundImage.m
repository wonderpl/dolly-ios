//
//  UIImageView+RoundImage.m
//  dolly
//
//  Created by Cong on 20/12/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "UIImageView+RoundImage.h"

@implementation UIImageView (RoundImage)

-(void) roundImage
{
	self.layer.cornerRadius = CGRectGetWidth(self.frame) / 2.0;
	self.layer.masksToBounds = YES;
}

@end
