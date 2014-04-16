//
//  SYNSocialFollowButton.m
//  dolly
//
//  Created by Michael Michailidis on 04/12/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSocialFollowButton.h"
#import "UIColor+SYNColor.h"
#import "UIFont+SYNFont.h"

@interface SYNSocialFollowButton ()

@end

@implementation SYNSocialFollowButton

-(void)awakeFromNib {
    [super awakeFromNib];
    self.layer.borderWidth = 1.0f;


}

-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if(selected) {
        self.layer.borderColor = [self.selectedBorderColor CGColor];
        [self setTitle:NSLocalizedString(@"unfollow", nil)];
		self.titleLabel.font = self.selectedFont;
		[self setTitleColor: self.selectedColor
				   forState: UIControlStateSelected];
    } else {
        self.layer.borderColor = [self.defaultBorderColor CGColor];
        [self setTitle:NSLocalizedString(@"follow", nil)];
		self.titleLabel.font = self.defaultFont;
		[self setTitleColor: self.defaultColor
				   forState: UIControlStateNormal];
    }
}

- (UIColor*)selectedColor {
	return [UIColor colorWithRed:(146.0f/255.0f)
                           green:(143.0f/255.0f)
                            blue:(183.0f/255.0f)
                           alpha:1.0f];
}

- (UIColor*)defaultColor {
	return [UIColor dollyMoodColor];
}

- (UIColor*)selectedBorderColor {
	return [UIColor colorWithRed:(146.0f/255.0f)
                           green:(143.0f/255.0f)
                            blue:(183.0f/255.0f)
                           alpha:1.0f];
}

- (UIColor*)defaultBorderColor {
	return [UIColor colorWithRed:(146.0f/255.0f)
                           green:(143.0f/255.0f)
                            blue:(183.0f/255.0f)
                           alpha:1.0f];
}



- (UIFont*)selectedFont {
	return [UIFont lightCustomFontOfSize:11.0f];
}

- (UIFont*)defaultFont {
	return [UIFont lightCustomFontOfSize:13.0f];
}


@end
