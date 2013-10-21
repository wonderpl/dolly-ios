//
//  SYNAggregateChannelCell.m
//  rockpack
//
//  Created by Michael Michailidis on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "SYNAggregateChannelCell.h"
#import "SYNTouchGestureRecognizer.h"
#import "Channel.h"
#import "SYNAggregateChannelItemCell.h"
#import "UIImage+Tint.h"

@interface SYNAggregateChannelCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UIView *buttonContainerView;
@property (nonatomic, strong) UIView *labelsContainerView;

@end

static NSString* kChannelItemCellIndetifier = @"SYNAggregateChannelItemCell";


@implementation SYNAggregateChannelCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    
    [self.collectionView registerNib:[UINib nibWithNibName:kChannelItemCellIndetifier bundle:nil]
          forCellWithReuseIdentifier:kChannelItemCellIndetifier];
    
    [self.collectionView reloadData];
    
}


- (void) prepareForReuse
{
    [super prepareForReuse];
    
    
}





- (void) setViewControllerDelegate: (id<SYNAggregateCellDelegate>) viewControllerDelegate
{
    [super setViewControllerDelegate: viewControllerDelegate];
    
    
    
    
}


- (void) setTitleMessageWithDictionary: (NSDictionary *) messageDictionary
{
    NSString *channelOwnerName = messageDictionary[@"display_name"] ? messageDictionary[@"display_name"] : @"User";
    
    NSNumber *itemCountNumber = messageDictionary[@"item_count"] ? messageDictionary[@"item_count"] : @1;
    NSString *actionString = [NSString stringWithFormat: @"%i pack%@", itemCountNumber.integerValue, itemCountNumber.integerValue > 1 ? @"s": @""];
    
    // craete the attributed string //
    NSMutableAttributedString *attributedCompleteString = [[NSMutableAttributedString alloc] init];
    
    [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: channelOwnerName
                                                                                      attributes: self.boldTextAttributes]];
    
    [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: @" created "
                                                                                      attributes: self.lightTextAttributes]];
    
    [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: actionString
                                                                                      attributes: self.lightTextAttributes]];
    
    self.messageLabel.attributedText = attributedCompleteString;
}




- (void) showChannel: (UITapGestureRecognizer *) recognizer
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
    
    
    SYNAggregateChannelItemCell* itemCell = [collectionView dequeueReusableCellWithReuseIdentifier: kChannelItemCellIndetifier
                                                                                    forIndexPath: indexPath];
    
    Channel* channel = (Channel*)self.collectionData[indexPath.item];
    
    itemCell.titleLabel.text = channel.title;
    
    return itemCell;
    
    
}

@end
