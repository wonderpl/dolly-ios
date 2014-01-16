//
//  SYNExistingChannelCell.m
//  dolly
//
//  Created by Michael Michailidis on 08/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAddToChannelCell.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+SYNColor.h"

@implementation SYNAddToChannelCell


-(void)awakeFromNib
{
    [super awakeFromNib];
    
    // hold the text color at the start so as to resuse
    defaultTitleColor = self.titleLabel.textColor;
    
    // on iPad the cell looks like a box
    if(IS_IPAD)
    {
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.layer.borderWidth = 1.0f;
    }
    else
    {
        UIView* separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.frame.size.height - 1.0f, self.frame.size.width, 1.0f)];
        separatorView.backgroundColor = [UIColor dollyTabColorSelectedBackground];
        [self addSubview:separatorView];
    }
    
    
    self.titleLabel.font = [UIFont lightCustomFontOfSize:self.titleLabel.font.pointSize];
    
    
}

-(void)setSelected:(BOOL)selected
{
    _selected = selected;
	
    if (selected) {
		[UIView animateWithDuration:0.2 animations:^{
			self.titleLabel.textColor = [UIColor whiteColor];
			self.backgroundColor = [UIColor colorWithRed: (182.0f/255.0f)
												   green: (202.0f/255.0f)
													blue: (178.0f/255.0f)
												   alpha: 1.0f];
		}];
    } else {
		[UIView animateWithDuration:0.2 animations:^{
			self.titleLabel.textColor = defaultTitleColor;
			self.backgroundColor = [UIColor whiteColor];
		}];
    }
    
}
-(BOOL)isSelected
{
    return _selected;
}
@end
