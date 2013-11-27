//
//  SYNNotificationsMarkAllAsReadCell.m
//  dolly
//
//  Created by Michael Michailidis on 27/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNNotificationsMarkAllAsReadCell.h"
#import "UIFont+SYNFont.h"

@implementation SYNNotificationsMarkAllAsReadCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.textLabel.text = NSLocalizedString(@"notification_mark_all_as_read", nil);
        self.textLabel.font = [UIFont lightCustomFontOfSize:25.0f];
        self.textLabel.textColor = [UIColor blackColor];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
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
