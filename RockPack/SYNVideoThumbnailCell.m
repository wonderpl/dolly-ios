//
//  SYNVideoThumbnailCell.m
//  rockpack
//
//  Created by Nick Banks on 30/01/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNVideoThumbnailCell.h"
#import "UIFont+SYNFont.h"
#import "CIFilter+Monochrome.h"
#import <UIImageView+WebCache.h>
#import <SDWebImageManager.h>

@interface SYNVideoThumbnailCell ()

@property (nonatomic, strong) IBOutlet UIImageView *colourImageView;
@property (nonatomic, strong) IBOutlet UIImageView *monochromeImageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) id<SDWebImageOperation> downloadOperation;
@property (nonatomic, strong) NSOperation *monochromeOperation;

@end


@implementation SYNVideoThumbnailCell

#pragma mark - Public

- (void)setImageWithURL:(NSString *)urlString {
	NSURL *url = [NSURL URLWithString:urlString];
	
	SDWebImageManager *imageManager = [SDWebImageManager sharedManager];
	
	NSOperationQueue *operationQueue = [[self class] monochromeOperationQueue];
	
	UIImageView *colourImageView = self.colourImageView;
	UIImageView *monochromeImageView = self.monochromeImageView;
	
	// Make a unique cache key for monochromed images
	NSString *cacheKey = [NSString stringWithFormat:@"monochrome+%@", [url absoluteString]];
	UIImage *cachedImage = [imageManager.imageCache imageFromMemoryCacheForKey:cacheKey];
	if (cachedImage) {
		monochromeImageView.image = cachedImage;
		[colourImageView setImageWithURL:url];
	} else {
		__weak typeof(self) wself = self;
		self.downloadOperation = [imageManager downloadWithURL:url
													   options:0
													  progress:nil
													 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
														 __strong typeof(self) sself = wself;
														 
														 colourImageView.image = image;
														 
														 NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
															 CIFilter *filter = [CIFilter monochromeFilter];

															 // We don't have it cached so we want to monochrome it
															 [filter setValue:[CIImage imageWithCGImage:[image CGImage]] forKey:kCIInputImageKey];
															 
															 UIImage *monochromeImage = [UIImage imageWithCIImage:[filter outputImage]];
															 dispatch_async(dispatch_get_main_queue(), ^{
																 monochromeImageView.image = monochromeImage;
															 });
															 
															 // Now cache it in memory
															 [imageManager.imageCache storeImage:monochromeImage forKey:cacheKey toDisk:NO];
														 }];
														 
														 sself.monochromeOperation = operation;
														 [operationQueue addOperation:operation];
													 }];
	}
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
	
	if (selected) {
		self.colourImageView.hidden = NO;
		self.monochromeImageView.hidden = YES;
	} else {
		self.colourImageView.hidden = YES;
		self.monochromeImageView.hidden = NO;
	}
}

#pragma mark - Overridden

- (void)awakeFromNib {
	[super awakeFromNib];
	
	self.titleLabel.font = [UIFont regularCustomFontOfSize:self.titleLabel.font.pointSize];
	
	self.colourImageView.hidden = YES;
	self.monochromeImageView.hidden = NO;
}

- (void)prepareForReuse {
	[super prepareForReuse];
	
	self.colourImageView.image = nil;
	self.monochromeImageView.image = nil;
	
	self.colourImageView.hidden = YES;
	self.monochromeImageView.hidden = NO;
	
	[self.downloadOperation cancel];
	[self.monochromeOperation cancel];
}

#pragma mark - Private class

+ (NSOperationQueue *)monochromeOperationQueue {
	static dispatch_once_t onceToken;
	static NSOperationQueue *operationQueue;
	dispatch_once(&onceToken, ^{
		operationQueue = [[NSOperationQueue alloc] init];
		[operationQueue setMaxConcurrentOperationCount:5];
	});
	return operationQueue;
}

@end
