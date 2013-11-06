//
//  SYNCollectionVideoCell.m
//  dolly
//
//  Created by Michael Michailidis on 06/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCollectionVideoCell.h"
#import "UIFont+SYNFont.h"
#import "Video.h"
#import "UIImageView+WebCache.h"

@implementation SYNCollectionVideoCell 


- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.font = [UIFont lightCustomFontOfSize:self.titleLabel.font.pointSize];
}

#pragma mark - Social Callbacks



- (IBAction) likeControlPressed: (SYNSocialButton *) socialButton
{
    [self.delegate likeControlPressed: socialButton];
}


- (IBAction) addControlPressed: (SYNSocialButton *) socialButton
{
   
    [self.delegate addControlPressed: socialButton];
}

- (IBAction) shareControlPressed: (SYNSocialButton *) socialButton
{
    [self.delegate shareControlPressed: socialButton];
}

#pragma mark - Set Video Instance

- (void) setVideoInstance: (VideoInstance *) videoInstance
{
    _videoInstance = videoInstance;
    
    self.shareControl.dataItemLinked = _videoInstance;
    self.addControl.dataItemLinked = _videoInstance;
    self.likeControl.dataItemLinked = _videoInstance;
    
    if (!_videoInstance)
    {
        return;
    }
    
    [self.imageView setImageWithURL: [NSURL URLWithString: videoInstance.thumbnailURL]
                   placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                            options: SDWebImageRetryFailed];
    
    
    
    self.likeControl.selected = videoInstance.starredByUserValue;
    
    [self.likeControl setTitle: NSLocalizedString(@"like", @"Label for follow button on SYNAggregateVideoItemCell")
                      andCount: videoInstance.video.starCountValue];
    
    self.titleLabel.text = videoInstance.title;
}

@end
