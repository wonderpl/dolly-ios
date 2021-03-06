//
//  SYNOneToOneFriendCell.m
//  rockpack
//
//  Created by Michael Michailidis on 04/09/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNOneToOneFriendCell.h"
#import "UIFont+SYNFont.h"

@implementation SYNOneToOneFriendCell

- (id) initWithStyle: (UITableViewCellStyle) style
     reuseIdentifier: (NSString *) reuseIdentifier
{
    self = [super initWithStyle: style
                reuseIdentifier: reuseIdentifier];
    
    if (self)
    {
        self.textLabel.font = [UIFont regularCustomFontOfSize: 13.0f];
        
        self.textLabel.textColor = [UIColor colorWithRed: (40.0f / 255.0f)
                                                   green: (45.0f / 255.0f)
                                                    blue: (51.0f / 255.0f)
                                                   alpha: 1.0f];
        
        self.detailTextLabel.font = [UIFont lightCustomFontOfSize: 12.0f];
        
        self.detailTextLabel.textColor = [UIColor colorWithRed: (170.0f / 255.0f)
                                                         green: (170.0f / 255.0f)
                                                          blue: (170.0f / 255.0f)
                                                         alpha: 1.0f];
        
        
        
        CGRect svFrame = CGRectMake(0.0, 0.0f, 0.0f, 0.5f);
        self.customSeparatorView = [[UIView alloc] initWithFrame: svFrame];
        self.customSeparatorView.backgroundColor = [UIColor colorWithRed: (232.0f / 255.0f)
                                                                   green: (232.0f / 255.0f)
                                                                    blue: (232.0f / 255.0f)
                                                                   alpha: 1.0f];
        
        
        [self addSubview: self.customSeparatorView];
    }
    
    return self;
}


- (void) layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(10.0f, 10.0f, 30.0f, 30.0f);
    
    if(!self.special)
        self.textLabel.frame = CGRectMake(50.0f, 10.0f, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
    else // if it is the last cell then we need to push down the textLabel;
        self.textLabel.frame = CGRectMake(50.0f, 20.0f, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
    
    self.imageView.layer.cornerRadius = self.imageView.frame.size.width * 0.5f;
    self.imageView.clipsToBounds = YES;
    
    self.detailTextLabel.frame = CGRectMake(50.0f, 28.0f, self.detailTextLabel.frame.size.width, self.detailTextLabel.frame.size.height);
    
    self.customSeparatorView.frame = CGRectMake(0.0f, self.frame.size.height - 2.0f, self.frame.size.width, 2.0f);
    
}


- (void) setSelected: (BOOL) selected animated: (BOOL) animated
{
    [super setSelected: selected
              animated: animated];
}


@end
