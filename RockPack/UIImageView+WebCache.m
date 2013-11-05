/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageManager.h"
#import "UIImage+Monochrome.h"
#import "UIImageView+WebCache.h"
#import "objc/runtime.h"
@import QuartzCore;

static char operationKey;

@implementation UIImageView (WebCache)

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options
{
    [self setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url completed:(SDWebImageCompletedBlock)completedBlock
{
    [self setImageWithURL:url placeholderImage:nil options:SDWebImageRetryFailed progress:nil completed:completedBlock];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletedBlock)completedBlock
{
    [self setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletedBlock)completedBlock
{
    [self setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}


- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletedBlock)completedBlock
{
    [self cancelCurrentImageLoad];
    
    NSString *key = [SDWebImageManager.sharedManager cacheKeyForURL: url];
    UIImage *image = [SDWebImageManager.sharedManager.imageCache imageFromMemoryCacheForKey: key];
    
    if (image)
    {
        self.image = image;
        
        if (options & SDWebImageMonochromeVersion)
        {
            if (image.monochromeImage != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completedBlock(image, nil, SDImageCacheTypeMemoryMonochrome);
                });
                return;
            }
        }
    }
    else
    {
        self.image = placeholder;
    }

    if (url)
    {
        __weak UIImageView *wself = self;
        id<SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadWithURL: url
                                                                                     options: options
                                                                                    progress: progressBlock
                                                                                   completed:^ (UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
                                             {
                                                 if (options & SDWebImageMonochromeVersion)
                                                 {
                                                     __weak typeof(self) weakSelf = self;
                                                     
                                                     if (weakSelf == nil)
                                                     {
                                                         // If the pointer is nil, then bail
                                                         return;
                                                     }
                                                     
                                                     dispatch_async([UIImageView sharedImageProcessingQueue], ^
                                                                    {
                                                                        // Just do image processing on background thread
                                                                        CIImage *colourImage = [CIImage imageWithCGImage: image.CGImage];
                                                                        
                                                                        // Only update the imput image each time (as opposed to creating the filter again)
                                                                        [[UIImageView sharedFilter] setValue: colourImage
                                                                                                      forKey: kCIInputImageKey];
                                                                        
                                                                        CIImage *monochromeImage = [UIImageView sharedFilter].outputImage;
                                                                        
                                                                        CIContext *context = [CIContext contextWithOptions: nil];
                                                                        
                                                                        CGImageRef imageRef = [context createCGImage: monochromeImage
                                                                                                            fromRect: monochromeImage.extent];
                                                                        
                                                                        
                                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                                            // UIImage is surprisingly thread safe and can be initialised here.
                                                                            UIImage *newMonochromeImage = [UIImage imageWithCGImage: imageRef];
                                                                            CGImageRelease(imageRef);
                                                                            weakSelf.image = image;
                                                                            weakSelf.image.monochromeImage = newMonochromeImage;
                                                                            
                                                                            id<SDWebImageOperation> operation = objc_getAssociatedObject(weakSelf, &operationKey);

                                                                            if (operation)
                                                                            {
                                                                                if (completedBlock && finished)
                                                                                {
                                                                                    completedBlock(image, error, cacheType);
                                                                                }
                                                                            }
                                                                            else
                                                                            {
//                                                                                DebugLog (@"cancelled 1");
                                                                            }
                                                                        });
                                                                        
                                                                    });
                                                 }
                                                 else
                                                 {
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         __strong typeof(self) sself = wself;
                                                         
                                                         if (sself == nil)
                                                         {
                                                             // If the pointer is nil, then bail
                                                             return;
                                                         }
                                                         
                                                         if (image != nil)
                                                         {
                                                             // If we were not returned directly from the cache, then fade up
                                                             if (cacheType == SDImageCacheTypeNone)
                                                             {
                                                                 [UIView transitionWithView: sself.superview
                                                                                   duration: 0.35f
                                                                                    options: UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
                                                                                 animations: ^{
                                                                                     sself.image = image;
                                                                                 }
                                                                                 completion: nil];
                                                             }
                                                             else
                                                             {
                                                                 sself.image = image;
                                                             }
                                                             
                                                             [sself setNeedsLayout];
                                                         }
                                                         
                                                         if (completedBlock && finished)
                                                         {
                                                             completedBlock(image, error, cacheType);
                                                         }
                                                     });
                                                 }
                                             }];
        
        objc_setAssociatedObject(self, &operationKey, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)cancelCurrentImageLoad
{
    // Cancel in progress downloader from queue
    id<SDWebImageOperation> operation = objc_getAssociatedObject(self, &operationKey);
    if (operation)
    {
        [operation cancel];
        objc_setAssociatedObject(self, &operationKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
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
