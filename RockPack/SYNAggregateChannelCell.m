//
//  SYNAggregateChannelCell.m
//  rockpack
//
//  Created by Michael Michailidis on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "SYNAggregateChannelCell.h"
#import "SYNAggregateChannelItemCell.h"
#import "SYNTouchGestureRecognizer.h"
#import "UIImage+Tint.h"

@interface SYNAggregateChannelCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UIView *buttonContainerView;
@property (nonatomic, strong) UIView *labelsContainerView;

@end

static NSString *kChannelItemCellIndetifier = @"SYNAggregateChannelItemCell";


@implementation SYNAggregateChannelCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [self.collectionView registerNib: [UINib nibWithNibName: kChannelItemCellIndetifier bundle: nil]
          forCellWithReuseIdentifier: kChannelItemCellIndetifier];
    
    [self.collectionView reloadData];
}


- (void) prepareForReuse
{
    [super prepareForReuse];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGSize viewSize = self.frame.size;
    CGFloat middleOfView = roundf(viewSize.width * 0.5f); // to avoid pixelation
    
    
    
    
    // user thumbnail
    self.userThumbnailImageView.center = CGPointMake(middleOfView, self.userThumbnailImageView.center.y);
    self.userThumbnailButton.center = CGPointMake(middleOfView, self.userThumbnailImageView.center.y);
    
    self.actionMessageLabel.center =CGPointMake(middleOfView, self.actionMessageLabel.center.y);
    self.collectionView.center =CGPointMake(middleOfView, self.collectionView.center.y);
}


// NOTE: will be called back from the inner cell and the message should be passed to the feed controller acting as THIS cell's delegate

- (void) followControlPressed: (id) control
{
    [self.delegate performSelector: @selector(followControlPressed:)
                        withObject: self];
}


- (void) shareControlPressed: (id) control
{
    [self.delegate performSelector: @selector(shareControlPressed:)
                        withObject: self];
}

- (void) setCollectionData:(NSArray *)collectionData
{
    [super setCollectionData:collectionData];
    
    if(collectionData.count <= 0)
        return;
    
    Channel* firstChannel = collectionData[0];
    // create string
    
    NSString *nameString = firstChannel.channelOwner.displayName; // ex 'Dolly Proxima'
    NSString *actionString = [NSString stringWithFormat:@" created %@ collection%@", _collectionData.count > 1 ? [NSString stringWithFormat:@"%i", _collectionData.count] : @"a new", _collectionData.count > 1 ? @"s" : @""];
    
    
    NSMutableAttributedString *attributedCompleteString = [[NSMutableAttributedString alloc] init];
    
    [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: nameString
                                                                                      attributes: self.darkTextAttributes]];
    
    [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: actionString
                                                                                      attributes: self.lightTextAttributes]];
    
    self.actionMessageLabel.attributedText = attributedCompleteString;
    
}


#pragma mark - UICollectionView DataSource


- (NSInteger) collectionView: (UICollectionView *) collectionView numberOfItemsInSection: (NSInteger) section
{
    return self.collectionData.count;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNAggregateChannelItemCell *itemCell = [collectionView dequeueReusableCellWithReuseIdentifier: kChannelItemCellIndetifier
                                                                                      forIndexPath: indexPath];
    
    Channel *channel = (Channel *) self.collectionData[indexPath.item];
    
    itemCell.titleLabel.text = channel.title;
    
    itemCell.followersLabel.text = [NSString stringWithFormat:@"%lli followers", channel.subscribersCountValue];
    itemCell.videosLabel.text = [NSString stringWithFormat:@"%i videos", channel.videoInstances.count];
    
    itemCell.timeAgoComponents = channel.timeAgo;
    
    itemCell.delegate = self;
    
    return itemCell;
}

#pragma mark - Data Retrieval

- (ChannelOwner *) channelOwner
{
    Channel *heuristic = self.channelShowing;
    
    if (!heuristic)
    {
        return nil;
    }
    
    return heuristic.channelOwner;
}


- (Channel *) channelShowing
{
    if (self.collectionData.count == 0)
    {
        return nil;
    }
    
    return (Channel *) self.collectionData[0];
}




@end
