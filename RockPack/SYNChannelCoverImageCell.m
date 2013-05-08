//
//  SYNChanneCoverImageCell.m
//  rockpack
//
//  Created by Mats Trovik on 08/05/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNChannelCoverImageCell.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIFont+SYNFont.h"


@interface SYNChannelCoverImageCell ()
@property (nonatomic, retain)NSURL* latestAssetUrl;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation SYNChannelCoverImageCell

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.titleLabel.font = [UIFont boldRockpackFontOfSize:self.titleLabel.font.pointSize];
}

-(void)configureWithUrlAsset:(AVURLAsset*)asset fromLibrary:(ALAssetsLibrary*)library
{
    self.latestAssetUrl = [asset URL];
    [library assetForURL:[asset URL] resultBlock:^(ALAsset *resultAsset) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __block UIImage* newImage = [UIImage imageWithCGImage:resultAsset.thumbnail];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[asset URL] isEqual:self.latestAssetUrl])
                {
                    self.channelCoverImageView.image = newImage;
                }
            });
        });
    } failureBlock:^(NSError *error) {
        self.channelCoverImageView.image = nil;
    }];
}

-(void)setTitleText:(NSString*)titleText
{
    CGRect oldFrame = self.titleLabel.frame;
    self.titleLabel.text = [titleText uppercaseString];
    [self.titleLabel sizeToFit];
    CGRect newFrame = self.titleLabel.frame;
    newFrame.size.width = oldFrame.size.width;
    newFrame.origin.y = oldFrame.origin.y + oldFrame.size.height - newFrame.size.height;
    self.titleLabel.frame = newFrame;
}

@end
