//
//  SYNCoverThumbnailCell.m
//  rockpack
//
//  Created by Nick Banks on 25/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "AppConstants.h"
#import "SYNCoverThumbnailCell.h"
#import <UIImageView+WebCache.h>
@import QuartzCore;

@interface SYNCoverThumbnailCell ()

@property (nonatomic, strong) IBOutlet UIImageView *selectedOverlayImageView;

@end


@implementation SYNCoverThumbnailCell


- (void) awakeFromNib
{
    [super awakeFromNib];
}


#pragma mark - Selection

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
    [self.coverImageView.layer removeAllAnimations];
    [self.coverImageView setImageWithURL: nil];
    self.selectedOverlayImageView.alpha = 0.0f;
}

@end
