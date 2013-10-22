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
#import "UIColor+SYNColor.h"
#import "VideoInstance.h"
#import "Video.h"
#import "UIImage+Tint.h"

@interface SYNAggregateVideoCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UILabel *likeLabel;

@end

static NSString* kVideoItemCellIndetifier = @"SYNAggregateVideoItemCell";


@implementation SYNAggregateVideoCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.mainTitleLabel.font = [UIFont regularCustomFontOfSize: self.mainTitleLabel.font.pointSize];
    self.likeLabel.font = [UIFont lightCustomFontOfSize: self.likeLabel.font.pointSize];
    self.likesNumberLabel.font = [UIFont regularCustomFontOfSize: self.likesNumberLabel.font.pointSize];
    
    
    [self.collectionView registerNib:[UINib nibWithNibName:kVideoItemCellIndetifier bundle:nil]
          forCellWithReuseIdentifier:kVideoItemCellIndetifier];
    
    [self.collectionView reloadData];
    
    NSLog(@"%@", NSStringFromCGRect(self.frame));
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
}


- (void) setSupplementaryMessageWithDictionary: (NSDictionary *) messageDictionary
{
    NSNumber *likesNumber = messageDictionary[@"star_count"] ? messageDictionary[@"star_count"] : @(0);
    NSString *likesString = [NSString stringWithFormat: @"%i likes", likesNumber.integerValue];
    
    NSAttributedString *likesAttributedString = [[NSAttributedString alloc] initWithString: [NSString stringWithFormat: @"%@ ", likesString]
                                                                                attributes: self.boldTextAttributes];
    
    if (likesNumber.integerValue == 0)
    {
        if (IS_IPAD)
        {
            self.likesNumberLabel.text = @"0";
            self.likeLabel.hidden = YES;
        }
        else
        {
            self.likeLabel.attributedText = likesAttributedString;
        }
        
        return;
    }
    
    SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    
    NSArray *users = messageDictionary[@"starrers"] ? messageDictionary[@"starrers"] : @[];
    
    // initial setup
    NSMutableAttributedString *attributedCompleteString = [[NSMutableAttributedString alloc] init];
    
    if (!IS_IPAD && users.count > 3)
    {
        [attributedCompleteString appendAttributedString: likesAttributedString];
    }
    else
    {
        self.likesNumberLabel.text = [NSString stringWithFormat: @"%i", likesNumber.integerValue];
    }
    
    if (users.count > 1 && users.count < 4 && IS_IPAD)
    {
        [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: @"including "
                                                                                          attributes: self.lightTextAttributes]];
    }
    
    self.likeButton.selected = NO;
    
    if (users.count > 0)
    {
        ChannelOwner *co;
        NSString *name;
        
        for (int i = 0; i < users.count; i++)
        {
            co = (ChannelOwner *) users[i];
            
            if (!co)
            {
                continue;
            }
            
            if ([co.uniqueId isEqualToString: appDelegate.currentUser.uniqueId])
            {
                name = @"You";
                self.likeButton.selected = YES;
            }
            else
            {
                name = co.displayName;
            }
            
            [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: name
                                                                                              attributes: self.boldTextAttributes]];
            
            if ((users.count - i) == 2) // the one before last
            {
                [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: @" & "
                                                                                                  attributes: self.boldTextAttributes]];
            }
            else if ((users.count - i) > 2)
            {
                [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: @", "
                                                                                                  attributes: self.boldTextAttributes]];
            }
        }
    }
    
    self.likeLabel.attributedText = attributedCompleteString;
}


- (void) prepareForReuse
{
    [super prepareForReuse];
    
}




- (void) showVideo: (UITapGestureRecognizer *) recognizer
{
    [self.viewControllerDelegate touchedAggregateCell];
}


#pragma mark - UICollectionView DataSource


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


@end
