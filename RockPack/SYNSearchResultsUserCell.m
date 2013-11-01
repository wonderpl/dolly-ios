//
//  SYNSearchResultsUserCell.m
//  dolly
//
//  Created by Michael Michailidis on 23/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchResultsUserCell.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"

@implementation SYNSearchResultsUserCell

-(void) awakeFromNib
{
    
    self.userNameLabel.font = [UIFont lightCustomFontOfSize:self.userNameLabel.font.pointSize];
    
    // == Round off the image == //
    self.userThumbnailImageView.layer.cornerRadius = self.userThumbnailImageView.frame.size.height * 0.5f;
    self.userThumbnailImageView.clipsToBounds = YES;
}

#pragma mark - Set Data

- (void) setChannelOwner:(ChannelOwner *)channelOwner
{
    _channelOwner = channelOwner;
    if(!_channelOwner)
        return;
    
    self.followButton.dataItemLinked = _channelOwner;
    
    [self.userThumbnailImageView setImageWithURL: [NSURL URLWithString: _channelOwner.thumbnailURL]
                                placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                                         options: SDWebImageRetryFailed];
    
    self.userNameLabel.text = _channelOwner.displayName;
}

- (IBAction) followControlPressed: (id) sender
{
    [self.delegate shareControlPressed: sender];
}

@end
