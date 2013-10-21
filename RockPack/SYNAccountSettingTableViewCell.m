//
//  SYNAccountSettingTableViewCell.m
//  rockpack
//
//  Created by Michael Michailidis on 18/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNAccountSettingTableViewCell.h"
#import "UIFont+SYNFont.h"
#import "SYNDeviceManager.h"

@interface SYNAccountSettingTableViewCell ()

@end


@implementation SYNAccountSettingTableViewCell
@synthesize timeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 20.0)];
        self.timeLabel.font = [UIFont lightCustomFontOfSize:12.0];
        self.timeLabel.textAlignment = NSTextAlignmentLeft;
        self.timeLabel.textColor = [UIColor grayColor];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.timeLabel];
    }
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    if (selected)
    {
        self.backgroundColor = [UIColor colorWithWhite:(247.0/255.0) alpha:(1.0)];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    
    else
    {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if(highlighted)
    {        
        self.backgroundColor = [UIColor clearColor];

    }
    else
    {
        self.backgroundColor = [UIColor colorWithWhite:(247.0/255.0) alpha:(1.0)];
        self.textLabel.backgroundColor = [UIColor clearColor];
    }
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    if (IS_IPAD)
    {
        CGRect tableCellFrame = self.textLabel.frame;
        tableCellFrame.size.width += 30.0;
        tableCellFrame.origin.y = 8.0;
        tableCellFrame.origin.x = self.imageView.frame.size.width + 11;
        self.textLabel.frame = tableCellFrame;
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.detailTextLabel.frame = CGRectMake(self.textLabel.frame.origin.x, 23, 300, 20);
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        self.imageView.frame = CGRectMake( 0, 7, self.imageView.image.size.width, self.imageView.image.size.height);
    }
    
    else
    {
        CGRect tableCellFrame = self.textLabel.frame;
        tableCellFrame.size.width += 30.0;
        tableCellFrame.origin.y = 8.0;
        tableCellFrame.origin.x = self.imageView.frame.size.width + 12;
        self.textLabel.frame = tableCellFrame;
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.detailTextLabel.frame = CGRectMake(self.textLabel.frame.origin.x, 23, 200, 20);
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        self.imageView.frame = CGRectMake( 0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
    }

    
}

@end
