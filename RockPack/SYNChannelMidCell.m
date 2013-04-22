//
//  SYNChannelMidCell.m
//  rockpack
//
//  Created by Michael Michailidis on 17/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNChannelMidCell.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+ImageProcessing.h"

@implementation SYNChannelMidCell



- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.font = [UIFont boldRockpackFontOfSize: 14.0f];
    
    self.selected = NO;
    
}

- (void) setChannelImageViewImage: (NSString*) imageURLString
{
    [self.imageView setAsynchronousImageFromURL: [NSURL URLWithString: imageURLString]
                               placeHolderImage: nil];
}

- (void) setChannelTitle: (NSString*) titleString
{
    
    CGRect titleFrame = self.titleLabel.frame;
    
    CGSize expectedSize = [titleString sizeWithFont:self.titleLabel.font
                                  constrainedToSize:CGSizeMake(titleFrame.size.width, 500.0)
                                      lineBreakMode:self.titleLabel.lineBreakMode];
    
    titleFrame.size.height = expectedSize.height;
    titleFrame.origin.y = self.imageView.frame.size.height - titleFrame.size.height - 4.0;
    
    self.titleLabel.frame = titleFrame;
    
    
    self.titleLabel.text = titleString;
    
}

-(void)setSelected:(BOOL)value
{
    
    if(value)
    {
        self.panelSelectedImageView.hidden = YES;
    }
    else
    {
        self.panelSelectedImageView.hidden = NO;
    }
}

@end
