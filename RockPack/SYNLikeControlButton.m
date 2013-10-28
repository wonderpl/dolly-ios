//
//  SYNLikeControlButton.m
//  dolly
//
//  Created by Michael Michailidis on 25/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNLikeControlButton.h"

@implementation SYNLikeControlButton

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        
        numberLabel = [[UILabel alloc] init];
        numberLabel.textColor = button.titleLabel.textColor;
        numberLabel.font = button.titleLabel.font;
        
    }
    return self;
}

#pragma mark - Set Number of Likes

-(NSInteger)numberOfLikes
{
    return [numberLabel.text integerValue];
}
-(void)setNumberOfLikes:(NSInteger)numberOfLikes
{
    numberLabel.text = [NSString stringWithFormat:@"%i", numberOfLikes];
}

@end
