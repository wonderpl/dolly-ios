//
//  SYNAggregateVideoCell.m
//  rockpack
//
//  Created by Michael Michailidis on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "ChannelOwner.h"
#import "SYNAggregateFlowLayout.h"
#import "SYNAggregateVideoCell.h"
#import "SYNAggregateVideoItemCell.h"
#import "SYNAppDelegate.h"
#import "SYNDeviceManager.h"
#import "SYNSocialControlFactory.h"
#import "SYNTouchGestureRecognizer.h"
#import "UIColor+SYNColor.h"
#import "UIImage+Tint.h"
#import "Video.h"
#import "VideoInstance.h"


@interface SYNAggregateVideoCell () <UIGestureRecognizerDelegate>

@end

static NSString* kVideoItemCellIndentifier = @"SYNAggregateVideoItemCell";


@implementation SYNAggregateVideoCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.font = [UIFont regularCustomFontOfSize: self.titleLabel.font.pointSize];
    
    
    
    // == Create Buttons == //
    
    CGPoint middlePoint = CGPointMake(self.bottomControlsView.frame.size.width * 0.5f, self.bottomControlsView.frame.size.height * 0.5);
    
    likeControl = [[SYNSocialControlFactory defaultFactory] createControlForType:SocialControlTypeDefault
                                                                        forTitle:@"like"
                                                                     andPosition:CGPointMake(middlePoint.x - 60.0f, middlePoint.y)];
    
    [self.bottomControlsView addSubview:likeControl];
    
    addControl = [[SYNSocialControlFactory defaultFactory] createControlForType:SocialControlTypeAdd
                                                                       forTitle:nil
                                                                    andPosition:CGPointMake(middlePoint.x, middlePoint.y)];
    
    [self.bottomControlsView addSubview:addControl];
    
    shareControl = [[SYNSocialControlFactory defaultFactory] createControlForType:SocialControlTypeDefault
                                                                         forTitle:@"share"
                                                                      andPosition:CGPointMake(middlePoint.x + 60.0f, middlePoint.y)];
    
    [self.bottomControlsView addSubview:shareControl];
    
    
    [self.collectionView registerNib: [UINib nibWithNibName: kVideoItemCellIndentifier bundle: nil]
          forCellWithReuseIdentifier: kVideoItemCellIndentifier];
    
    SYNAggregateFlowLayout *aggregateFlowLayout = [[SYNAggregateFlowLayout alloc] init];
    
    self.collectionView.collectionViewLayout = aggregateFlowLayout;
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    [self.collectionView reloadData];
}


- (void) prepareForReuse
{
    [super prepareForReuse];
    
    self.collectionData = @[];

    [self.collectionView reloadData];
}


- (void) setDelegate: (id<SYNSocialActionsDelegate>) delegate
{
    [super setDelegate: delegate];

    [likeControl addTarget: self.delegate
                    action: @selector(likeControlPressed:)
          forControlEvents: UIControlEventTouchUpInside];
    
    [addControl addTarget: self.delegate
                   action: @selector(addControlPressed:)
         forControlEvents: UIControlEventTouchUpInside];
    
    [shareControl addTarget: self.delegate
                     action: @selector(shareControlPressed:)
           forControlEvents: UIControlEventTouchUpInside];
}


- (void) setTitleMessageWithDictionary: (NSDictionary *) messageDictionary
{
    NSString *channelOwnerName = messageDictionary[@"display_name"] ? messageDictionary[@"display_name"] : @"User";
    
    NSNumber *itemCountNumber = messageDictionary[@"item_count"] ? messageDictionary[@"item_count"] : @1;
    NSString *actionString = [NSString stringWithFormat: @"%i video%@", itemCountNumber.integerValue, itemCountNumber.integerValue > 1 ? @"s": @""];
    
    NSString *channelNameString = messageDictionary[@"channel_name"] ? messageDictionary[@"channel_name"] : @"his channel";
    
    // create the attributed string //
    NSMutableAttributedString *attributedCompleteString = [[NSMutableAttributedString alloc] init];
    
    
    [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: channelOwnerName
                                                                                      attributes: self.boldTextAttributes]];
    
    
    [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: @" added "
                                                                                      attributes: self.lightTextAttributes]];
    
    [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: actionString
                                                                                      attributes: self.lightTextAttributes]];
    
    [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: @" to "
                                                                                      attributes: self.lightTextAttributes]];
    
    [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: channelNameString
                                                                                      attributes: self.boldTextAttributes]];
    
    self.messageLabel.attributedText = attributedCompleteString;
    self.messageLabel.center = CGPointMake(self.messageLabel.center.x, self.userThumbnailImageView.center.y + 2.0f);
    self.messageLabel.frame = CGRectIntegral(self.messageLabel.frame);

}


- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGSize viewSize = self.frame.size;
    CGFloat middleOfView = roundf(viewSize.width * 0.5f); // to avoid pixelation
    
    CGRect bgViewFrame = self.backgroundView.frame;
    
    if(IS_IPHONE)
    {
        bgViewFrame.size.width = 320.0f;
        
    }
    else
    {
        bgViewFrame.size.width = 400.0f;
    }
    
    self.backgroundView.frame = bgViewFrame;
    self.backgroundView.center = CGPointMake(middleOfView, self.backgroundView.center.y);
    
    // user thumbnail
    self.userThumbnailImageView.center = CGPointMake(middleOfView, self.userThumbnailImageView.center.y);
    self.userThumbnailButton.center = CGPointMake(middleOfView, self.userThumbnailImageView.center.y);
    
    // bottom controls
    self.bottomControlsView.center = CGPointMake(middleOfView, self.bottomControlsView.center.y);
}


#pragma mark - UICollectionView DataSource

// utility method (overriding abstract class)
- (CGSize) sizeForItemAtDefaultPath
{
    // TODO: Might be a good idea to cache this, as this might be (relatively) computationally expensive
    return [self collectionView: self.collectionView
                         layout: self.collectionView.collectionViewLayout
         sizeForItemAtIndexPath: [NSIndexPath indexPathForItem: 0 inSection: 0]];
}


- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout*) collectionViewLayout
   sizeForItemAtIndexPath: (NSIndexPath *) indexPath
{
    CGSize correctSize = CGSizeZero;
    
    if (IS_IPHONE)
    {
        correctSize.width = 248.0f;
        correctSize.height = 139.0f;
    }
    else
    {
        correctSize.width = 288.0f;
        correctSize.height = 139.0f;
    }
    
    return correctSize;
    
}


- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger) section
{
    
    return self.collectionData.count;
    
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNAggregateVideoItemCell* itemCell = [collectionView dequeueReusableCellWithReuseIdentifier: kVideoItemCellIndentifier
                                                                                    forIndexPath: indexPath];
    
    VideoInstance* videoInstance = self.collectionData[indexPath.item];
    
    [itemCell.imageView setImageWithURL: [NSURL URLWithString: videoInstance.thumbnailURL] // calls vi.video.thumbnailURL
                       placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                                options: SDWebImageRetryFailed];
    
    return itemCell;
}

- (ChannelOwner*) channelOwner
{
    VideoInstance* heuristic = self.videoInstanceShowing;
    if(!heuristic)
        return nil;
    
    return heuristic.channel.channelOwner;
}

- (VideoInstance*) videoInstanceShowing
{
    if(self.collectionData.count == 0)
        return nil;
    
    // TODO: Figure out the correct video instance according to scroll offset
    
    return (VideoInstance*)self.collectionData[0];
}


@end
