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
