//
//  SYNSearchResultsVideoCell.m
//  dolly
//
//  Created by Michael Michailidis on 23/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//


#import "SYNSearchResultsVideoCell.h"
#import "SYNSocialAddButton.h"
#import "SYNSocialButton.h"
#import "UIFont+SYNFont.h"
#import <UIImageView+WebCache.h>

@interface SYNSearchResultsVideoCell ()

@property (strong, nonatomic) IBOutlet SYNSocialButton *likeSocialButton;
@property (strong, nonatomic) IBOutlet SYNSocialAddButton *addSocialButton;
@property (strong, nonatomic) IBOutlet SYNSocialButton *shareSocialButton;

@end

@implementation SYNSearchResultsVideoCell

- (void) awakeFromNib
{
    self.titleLabel.font = [UIFont lightCustomFontOfSize: self.titleLabel.font.pointSize];
    
    [self.likeSocialButton setTitle: NSLocalizedString(@"like", @"Label for follow button on SYNAggregateChannelItemCell")
                           andCount: 0];
    
    // no title for the add button
    self.shareSocialButton.title = NSLocalizedString(@"share", @"Label for share button on SYNAggregateChannelItemCell");
}


#pragma mark - Setting Data

- (void) setVideoInstance: (VideoInstance *) videoInstance
{
    _videoInstance = videoInstance;
    
    if (!_videoInstance)
    {
        return;
    }
    
    // Methods like sizeWithFont failed so first shrink and then get the correct height
    CGRect titleLabelFrame = self.titleLabel.frame;
    self.titleLabel.text = _videoInstance.title;
    [self.titleLabel sizeToFit];
    titleLabelFrame.size.height = self.titleLabel.frame.size.height;
    self.titleLabel.frame = titleLabelFrame;
    
    
    // set social buttons
    
    self.likeSocialButton.dataItemLinked = _videoInstance;
    self.addSocialButton.dataItemLinked = _videoInstance;
    self.shareSocialButton.dataItemLinked = _videoInstance;
    
    
    [self.iconImageView setImageWithURL: [NSURL URLWithString: _videoInstance.thumbnailURL]
                       placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                                options: SDWebImageRetryFailed];
}


- (IBAction) likeControlPressed: (id) sender
{
    [self.delegate likeControlPressed: sender];
}


- (IBAction) addControlPressed: (id) sender
{
    [self.delegate addControlPressed: sender];
}


- (IBAction) shareControlPressed: (id) sender
{
    [self.delegate shareControlPressed: sender];
}

@end
