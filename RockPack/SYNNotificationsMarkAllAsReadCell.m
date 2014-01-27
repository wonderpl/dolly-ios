//
//  SYNNotificationsMarkAllAsReadCell.m
//  dolly
//
//  Created by Michael Michailidis on 27/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNNotificationsMarkAllAsReadCell.h"
#import "UIFont+SYNFont.h"
#import "UIColor+SYNColor.h"

@implementation SYNNotificationsMarkAllAsReadCell

-(void)awakeFromNib{
    
    self.readButton.layer.borderWidth = 1.0f;
    self.readButton.layer.cornerRadius = 15.0f;
    self.readButton.titleLabel.textColor = [UIColor dollyMoodColor];
    
    self.readButton.layer.borderColor = [UIColor colorWithRed:(188.0f/255.0f) green:(186.0f/255.0f) blue:(212.0f/255.0f) alpha:1.0f].CGColor;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

- (void) layoutSubviews
{
    [super layoutSubviews];
}


@end
