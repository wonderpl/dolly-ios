//
//  SYNVideoThumbnailDownloader.h
//  dolly
//
//  Created by Sherman Lo on 2/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^VideoThumbnailImageCompletionBlock)(UIImage *image);

@class Video;

@interface SYNVideoThumbnailDownloader : NSObject

+ (instancetype)sharedDownloader;

- (void)fetchThumbnailImagesForVideos:(NSArray *)videos;

- (void)blurredImageForVideoInstance:(Video *)video completion:(VideoThumbnailImageCompletionBlock)completion;

@end
