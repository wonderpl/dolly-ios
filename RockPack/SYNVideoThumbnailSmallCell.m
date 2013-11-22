//
//  SYNVideoThumbnailSmallCell.m
//  rockpack
//
//  Created by Nick Banks on 30/01/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNVideoThumbnailSmallCell.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
#import "AppConstants.h"
@import QuartzCore;

#define kNextPrevVideoCellAlpha 0.8f
#define kCurrentVideoCellAlpha 1.0f

@interface SYNVideoThumbnailSmallCell ()

@property (nonatomic, strong) IBOutlet UIView *mainView;

@end


@implementation SYNVideoThumbnailSmallCell

+ (UINib *)nib {
	return [UINib nibWithNibName:NSStringFromClass(self) bundle:nil];
}

- (void) awakeFromNib
{
    [super awakeFromNib];

    self.titleLabel.font = [UIFont regularCustomFontOfSize: self.titleLabel.font.pointSize];
    
    self.colourImageView.image = nil;
    self.mainView.alpha = kNextPrevVideoCellAlpha;
}

#pragma mark - Asynchronous image loading support

- (void)setImageWithURL:(NSString *)urlString {
	[self.colourImageView setImageWithURL:[NSURL URLWithString:urlString]];
}

// If this cell is going to be re-used, then clear the image and cancel any outstanding operations
- (void) prepareForReuse {
    // Cancel any ongoing requests
    [self.colourImageView cancelCurrentImageLoad];
    
    self.colourImageView.alpha = 0.0f;
    
    self.colourImageView.image = nil;
    
    self.mainView.alpha = kNextPrevVideoCellAlpha;
}

@end
