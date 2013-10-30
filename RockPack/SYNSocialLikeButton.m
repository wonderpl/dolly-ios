//
//  SYNLikeControlButton.m
//  dolly
//
//  Created by Michael Michailidis on 25/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSocialLikeButton.h"

@implementation SYNSocialLikeButton

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    numberLabel = [[UILabel alloc] init];
    numberLabel.textColor = self.titleLabel.textColor;
    numberLabel.font = self.titleLabel.font;
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
