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
@property (nonatomic, strong) UIImage* placeholderImage;
@end

@implementation SYNChannelCoverImageCell

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.titleLabel.font = [UIFont boldRockpackFontOfSize:self.titleLabel.font.pointSize];
    self.placeholderImage = [UIImage imageNamed:@"PlaceholderChannelCover.png"];
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

-(void)setimageFromAsset:(ALAsset*)asset;
{
    self.channelCoverImageView.image = self.placeholderImage;
    if(asset)
    {
        self.latestAssetUrl = [asset valueForProperty:ALAssetPropertyAssetURL];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __block NSURL* url = [asset valueForProperty:ALAssetPropertyAssetURL];
            __block UIImage* resultImage = [UIImage imageWithCGImage:asset.thumbnail];
            dispatch_async(dispatch_get_main_queue(), ^{
                if([url isEqual:self.latestAssetUrl])
                {
                    self.channelCoverImageView.image = resultImage;
                }
            });
        });
    }
}

@end
