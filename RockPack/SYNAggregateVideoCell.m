//
//  SYNAggregateVideoCell.m
//  rockpack
//
//  Created by Michael Michailidis on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "ChannelOwner.h"
#import "SYNAggregateVideoCell.h"
#import "SYNAppDelegate.h"
#import "SYNTouchGestureRecognizer.h"
#import "SYNAggregateVideoItemCell.h"
#import "SYNDeviceManager.h"
#import "UIColor+SYNColor.h"
#import "VideoInstance.h"
#import "Video.h"
#import "UIImage+Tint.h"


@interface SYNAggregateVideoCell () <UIGestureRecognizerDelegate>

@property (nonatomic, readonly) CGFloat scrollViewMargin;

@end

static NSString* kVideoItemCellIndetifier = @"SYNAggregateVideoItemCell";


@implementation SYNAggregateVideoCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.mainTitleLabel.font = [UIFont regularCustomFontOfSize: self.mainTitleLabel.font.pointSize];
    self.likesNumberLabel.font = [UIFont regularCustomFontOfSize: self.likesNumberLabel.font.pointSize];
    
    
    [self.collectionView registerNib:[UINib nibWithNibName:kVideoItemCellIndetifier bundle:nil]
          forCellWithReuseIdentifier:kVideoItemCellIndetifier];
    
    [self.collectionView reloadData];
    
    self.collectionView.clipsToBounds = NO;
}


- (void) setViewControllerDelegate: (UIViewController *) viewControllerDelegate
{
    [super setViewControllerDelegate: (id < SYNAggregateCellDelegate >)viewControllerDelegate];

    [self.likeButton addTarget: self.viewControllerDelegate
                         action: @selector(likeButtonPressed:)
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


-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize viewSize = self.frame.size;
    CGFloat middleOfView = roundf(viewSize.width * 0.5f); // to avoid pixelation
    
    // user thumbnail
    self.userThumbnailImageView.center = CGPointMake(middleOfView, self.userThumbnailImageView.center.y);
    self.userThumbnailButton.center = CGPointMake(middleOfView, self.userThumbnailImageView.center.y);
    
    // bottom controls
    self.bottomControlsView.center = CGPointMake(middleOfView, self.bottomControlsView.center.y);
    
    
    
    
    // == Collection View == //
    
    CGRect collectionFrame = self.collectionView.frame;
    
    // the idea is to put a margin so as to show the next video cell while adding an inset of the same value
    collectionFrame.size = CGSizeMake(self.sizeForItemAtDefaultPath.width + self.scrollViewMargin, self.sizeForItemAtDefaultPath.height);
    
    
    self.collectionView.frame = collectionFrame;
    
    // now set the bounds
    
    self.collectionView.contentSize = CGSizeMake(collectionFrame.size.width, collectionFrame.size.width * (float)self.collectionData.count);
    
    UIEdgeInsets scrollViewInsets = self.collectionView.contentInset;
    scrollViewInsets.left = self.scrollViewMargin;
    //self.collectionView.contentInset = scrollViewInsets;
    
    // finally center it
    self.collectionView.center = CGPointMake(middleOfView, self.collectionView.center.y);
    
    
}




- (void) prepareForReuse
{
    [super prepareForReuse];
    
    self.collectionData = @[];
    
    [self.collectionView reloadData];
    
}


- (void) showVideo: (UITapGestureRecognizer *) recognizer
{
    [self.viewControllerDelegate touchedAggregateCell];
}


#pragma mark - UICollectionView DataSource

// utility method (overriding abstract class)
-(CGSize)sizeForItemAtDefaultPath
{
    return [self collectionView:self.collectionView
                         layout:self.collectionView.collectionViewLayout
         sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
}


- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout*) collectionViewLayout
   sizeForItemAtIndexPath: (NSIndexPath *) indexPath
{
    CGSize correctSize = CGSizeZero;
    if(IS_IPHONE)
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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return self.collectionData.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    SYNAggregateVideoItemCell* itemCell = [collectionView dequeueReusableCellWithReuseIdentifier: kVideoItemCellIndetifier
                                                                                    forIndexPath: indexPath];
    
    VideoInstance* videoInstance = self.collectionData[indexPath.item];
    
    
    [itemCell.imageView setImageWithURL: [NSURL URLWithString: videoInstance.thumbnailURL] // calls vi.video.thumbnailURL
                       placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                                options: SDWebImageRetryFailed];
    
    return itemCell;
    
    
}

-(CGFloat)scrollViewMargin
{
    return 40.0f;
}



@end
