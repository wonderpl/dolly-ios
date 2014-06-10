//
//  SYNVideoThumbnailDownloader.m
//  dolly
//
//  Created by Sherman Lo on 2/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNVideoThumbnailDownloader.h"
#import "Video.h"
#import "UIImage+Blur.h"
#import <SDWebImagePrefetcher.h>
#import <SDImageCache.h>
#import <SDWebImageManager.h>

@interface SYNVideoThumbnailDownloader () <SDWebImagePrefetcherDelegate>

@property (nonatomic, strong) SDWebImagePrefetcher *prefetcher;
@property (nonatomic, strong) SDImageCache *imageCache;
@property (nonatomic, strong) NSOperationQueue *processingQueue;

@end

@implementation SYNVideoThumbnailDownloader

+ (instancetype)sharedDownloader {
	static dispatch_once_t onceToken;
	static SYNVideoThumbnailDownloader *downloader;
	dispatch_once(&onceToken, ^{
		downloader = [[SYNVideoThumbnailDownloader alloc] init];
        downloader.imageCache.maxCacheSize = 1024000;
        downloader.imageCache.maxCacheAge = 60;
	});
	return downloader;
}

- (void)fetchThumbnailImagesForVideos:(NSArray *)videos {
	NSArray *thumbnailURLStrings = [videos valueForKey:@"thumbnailURL"];
	NSArray *thumbnailURLs = [self creatURLsArrayFromURLStrings:thumbnailURLStrings];
	[self.prefetcher prefetchURLs:thumbnailURLs
						 progress:^(NSUInteger finishedCount, NSUInteger completedCount) {
							 
						 } completed:^(NSUInteger finishedCount, NSUInteger skippedCount) {
							 
						 }];
}

- (void)fetchThumbnailImageForVideo:(Video *)video completion:(VideoThumbnailImageCompletionBlock)completion {
	NSURL *thumbnailURL = [NSURL URLWithString:video.thumbnailURL];
	NSString *imageCacheKey = [thumbnailURL absoluteString];
	
	[[SDWebImageManager sharedManager] downloadWithURL:thumbnailURL
											   options:0
											  progress:^(NSInteger receivedSize, NSInteger expectedSize) {
												  
											  } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
												  
												  NSString *blurredImageCacheKey = [NSString stringWithFormat:@"blurred+%@", imageCacheKey];
												  
												  NSOperation *operation = [self blurOperationForImage:image cacheKey:blurredImageCacheKey completion:^(UIImage *image) {
													  completion(image);
												  }];
												  operation.queuePriority = NSOperationQueuePriorityHigh;
												  
												  [self.processingQueue addOperation:operation];
											  }];
}

- (void)blurredImageForVideoInstance:(Video *)video completion:(VideoThumbnailImageCompletionBlock)completion {
	
	NSURL *thumbnailURL = [NSURL URLWithString:video.thumbnailURL];
	NSString *imageCacheKey = [thumbnailURL absoluteString];
	
	NSString *blurredImageCacheKey = [NSString stringWithFormat:@"blurred+%@", imageCacheKey];
	UIImage *blurredImage = [self.imageCache imageFromMemoryCacheForKey:blurredImageCacheKey];
	
	if (blurredImage) {
		completion(blurredImage);
		return;
	}
	
	[self fetchThumbnailImageForVideo:video completion:completion];
}

- (NSOperation *)blurOperationForImage:(UIImage *)image cacheKey:(NSString *)cacheKey completion:(VideoThumbnailImageCompletionBlock)completion {
	return [NSBlockOperation blockOperationWithBlock:^{
		
		UIImage *blurredImage = [UIImage blurredImageFromImage:image];
		[self.imageCache storeImage:blurredImage forKey:cacheKey toDisk:NO];
		if (completion) {
			dispatch_async(dispatch_get_main_queue(), ^{
				completion(blurredImage);
			});
		}
	}];
}

- (void)imagePrefetcher:(SDWebImagePrefetcher *)imagePrefetcher didPrefetchURL:(NSURL *)imageURL finishedCount:(NSUInteger)finishedCount totalCount:(NSUInteger)totalCount {
	
	NSString *imageCacheKey = [imageURL absoluteString];
	
	UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:imageCacheKey];
	NSString *blurredImageCacheKey = [NSString stringWithFormat:@"blurred+%@", imageCacheKey];

	NSOperation *operation = [self blurOperationForImage:image cacheKey:blurredImageCacheKey completion:nil];
	[self.processingQueue addOperation:operation];
}

- (SDWebImagePrefetcher *)prefetcher {
	if (!_prefetcher) {
		SDWebImagePrefetcher *prefetcher = [[SDWebImagePrefetcher alloc] init];
		prefetcher.delegate = self;
		
		self.prefetcher = prefetcher;
	}
	return _prefetcher;
}

- (SDImageCache *)imageCache {
	if (!_imageCache) {
		SDImageCache *imageCache = [[SDImageCache alloc] initWithNamespace:@"VideoThumbnails"];
		
		self.imageCache = imageCache;
	}
	return _imageCache;
}

- (NSOperationQueue *)processingQueue {
	if (!_processingQueue) {
		NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
		operationQueue.maxConcurrentOperationCount = 1;
		
		self.processingQueue = operationQueue;
	}
	
	return _processingQueue;
}

- (NSArray *)creatURLsArrayFromURLStrings:(NSArray *)urlStrings {
	NSMutableArray *urls = [NSMutableArray array];
	for (NSString *urlString in urlStrings) {
		[urls addObject:[NSURL URLWithString:urlString]];
	}
	return urls;
}

@end
