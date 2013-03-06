//
//  SYNVideoQueueCell.m
//  rockpack
//
//  Created by Nick Banks on 19/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "MKNetworkKit.h"
#import "SYNVideoQueueCell.h"
#import "UIImageView+ImageProcessing.h"

@implementation SYNVideoQueueCell



#pragma mark - Asynchronous image loading support

- (void) setVideoImageViewImage: (NSString*) imageURLString
{
    [self.imageView setAsynchronousImageFromURL: [NSURL URLWithString: imageURLString]
                               placeHolderImage: nil];
}

@end
