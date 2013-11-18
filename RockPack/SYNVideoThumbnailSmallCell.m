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
#import "UIImage+Monochrome.h"
#import "AppConstants.h"
@import QuartzCore;

#define kNextPrevVideoCellAlpha 0.8f
#define kCurrentVideoCellAlpha 1.0f

@interface SYNVideoThumbnailSmallCell ()

@property (nonatomic, assign) int uniqueCount;
@property (nonatomic, strong) IBOutlet UIView *mainView;
@property (nonatomic, strong) IBOutlet UIImageView *selectedGlossImageView;
@property (nonatomic, strong) IBOutlet UIImageView *defaultGlossImageView;

@end


@implementation SYNVideoThumbnailSmallCell

@synthesize colour = _colour;

- (void) awakeFromNib
{
    [super awakeFromNib];

    self.titleLabel.font = [UIFont regularCustomFontOfSize: self.titleLabel.font.pointSize];
    
    self.colourImageView.image = nil;
    self.monochromeImageView.image = nil;
    self.mainView.alpha = kNextPrevVideoCellAlpha;
    self.colour = NO;
}

#pragma mark - Asynchronous image loading support


- (void) setImageWithURL: (NSString *) urlString
{   
    __weak typeof(self) weakSelf = self;
    
    int currentCount = ++self.uniqueCount;
    
    [self.colourImageView setImageWithURL: [NSURL URLWithString: urlString]
                         placeholderImage: nil
                                  options: SDWebImageRetryFailed | SDWebImageMonochromeVersion
                                 progress: nil
                                completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                    if (weakSelf.uniqueCount == currentCount)
                                    {
                                        // Now set out monchrome view as well
                                        weakSelf.monochromeImageView.image = image.monochromeImage;
                                        
                                        if (cacheType != SDImageCacheTypeMemoryMonochrome)
                                        {
                                            [UIView animateWithDuration: 0.35f
                                                                  delay: 0.0f
                                                                options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                                                             animations: ^{
                                                                 weakSelf.colourImageView.alpha = kCurrentVideoCellAlpha;
                                                                 weakSelf.monochromeImageView.alpha = kCurrentVideoCellAlpha;
                                                             }
                                                             completion: nil];
                                        }
                                        else
                                        {
                                            weakSelf.colourImageView.alpha = kCurrentVideoCellAlpha;
                                            weakSelf.monochromeImageView.alpha = kCurrentVideoCellAlpha;
                                        }
                                    }
                                    else
                                    {
                                        weakSelf.colourImageView.image = nil;
                                    }

                                }];
}


- (void) displayThumbnail: (BOOL) isColour
{
    if (isColour)
    {
        self.colourImageView.hidden =  FALSE;
        self.monochromeImageView.hidden = TRUE;
        self.selectedGlossImageView.hidden = FALSE;
        self.defaultGlossImageView.hidden = TRUE;
        self.mainView.alpha = kCurrentVideoCellAlpha;
    }
    else
    {
        self.colourImageView.hidden =  TRUE;
        self.monochromeImageView.hidden = FALSE;
        self.mainView.alpha = kNextPrevVideoCellAlpha;
        self.selectedGlossImageView.hidden = TRUE;
        self.defaultGlossImageView.hidden = FALSE;
    }
}


- (void) setColour: (BOOL) colour
{
    [self displayThumbnail: colour];
    _colour = colour;
}


// If this cell is going to be re-used, then clear the image and cancel any outstanding operations
- (void) prepareForReuse
{
    // Cancel any ongoing requests
    [self.colourImageView cancelCurrentImageLoad];
    
//    [self.colourImageView.layer removeAllAnimations];
//    [self.monochromeImageView.layer removeAllAnimations];
    
    self.colourImageView.alpha = 0.0f;
    self.monochromeImageView.alpha = 0.0f;
    
    self.colourImageView.image = nil;
    self.monochromeImageView.image = nil;
    
    self.mainView.alpha = kNextPrevVideoCellAlpha;
    self.colour = NO;
}

#pragma mark - Monochrome support

+ (dispatch_queue_t) sharedImageProcessingQueue
{
    static dispatch_once_t pred;
    static dispatch_queue_t imageProcessingQueue;
    
    dispatch_once(&pred, ^
                  {
                      imageProcessingQueue = dispatch_queue_create("com.rockpack.imageprocessing", DISPATCH_QUEUE_SERIAL);
                  });
    
    return imageProcessingQueue;
}


+ (CIFilter *) sharedFilter
{
    static dispatch_once_t pred;
    static CIFilter *filter;
    
    dispatch_once(&pred, ^
                  {
                      filter = [CIFilter filterWithName: @"CIColorMonochrome"
                                          keysAndValues: @"inputIntensity", @1.0f,
                                @"inputColor", [[CIColor alloc] initWithColor: [UIColor whiteColor]],
                                nil];
                  });
    
    return filter;
}

@end
