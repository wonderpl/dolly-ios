//
//  SYNChanneCoverImageCell.m
//  rockpack
//
//  Created by Mats Trovik on 08/05/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "AppConstants.h"
#import "SYNChannelCoverImageCell.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>


@interface SYNChannelCoverImageCell ()

@property (nonatomic, retain) NSURL* latestAssetUrl;
@property (nonatomic, strong) IBOutlet UIImageView *selectedOverlayImageView;
@property (nonatomic, strong) UIImage* placeholderImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end


@implementation SYNChannelCoverImageCell

- (void) layoutSubviews
{
    [super layoutSubviews];
    self.titleLabel.font = [UIFont regularCustomFontOfSize: self.titleLabel.font.pointSize];
    self.placeholderImage = [UIImage imageNamed: @"PlaceholderChannelCover.png"];
}


- (void) setTitleText: (NSString*) titleText
{
    CGRect oldFrame = self.titleLabel.frame;
    self.titleLabel.text = [titleText uppercaseString];
    [self.titleLabel sizeToFit];
    CGRect newFrame = self.titleLabel.frame;
    newFrame.size.width = oldFrame.size.width;
    newFrame.origin.y = oldFrame.origin.y + oldFrame.size.height - newFrame.size.height;
    self.titleLabel.frame = newFrame;
}


- (void) setimageFromAsset: (ALAsset*) asset;
{
    self.channelCoverImageView.image = self.placeholderImage;
    
    if (asset)
    {
        self.latestAssetUrl = [asset valueForProperty:ALAssetPropertyAssetURL];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __block NSURL* url = [asset valueForProperty: ALAssetPropertyAssetURL];
            __block UIImage* resultImage = [UIImage imageWithCGImage: asset.thumbnail];
            dispatch_async(dispatch_get_main_queue(), ^{
                if([url isEqual:self.latestAssetUrl])
                {
                    self.channelCoverImageView.image = resultImage;
                }
            });
        });
    }
}

-(void)selectWithoutAnimation
{
    [super setSelected:YES];
    self.selectedOverlayImageView.alpha = 1.0f;
}

-(void)deselectWithoutAnimation
{
    [super setSelected:NO];
    self.selectedOverlayImageView.alpha = 0.0f;
}

- (void) setSelected: (BOOL) selected
{
    [super setSelected: selected];
    
    if (selected)
    {
        // Guard against multiple repeated selections
        if (self.selectedOverlayImageView.alpha == 0.0f)
        {
            [UIView animateWithDuration: kChannelEditModeAnimationDuration
                             animations: ^{
                                 self.selectedOverlayImageView.alpha = 1.0f;
                             }
                             completion: nil];
        }
    }
    else
    {
        if (self.selectedOverlayImageView.alpha == 1.0f)
        {
            [UIView animateWithDuration: kChannelEditModeAnimationDuration
                             animations: ^{
                                 self.selectedOverlayImageView.alpha = 0.0f;
                             }
                             completion: nil];
        }
    }
}

// If this cell is going to be re-used, then clear the image and cancel any outstanding operations
- (void) prepareForReuse
{
    // We need to clean up any asynchronous image uploads
    [self.channelCoverImageView.layer removeAllAnimations];
    [self.channelCoverImageView setImageWithURL: nil];
    self.selectedOverlayImageView.alpha = 0.0f;
}

@end
