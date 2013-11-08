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
#import "UIFont+SYNFont.h"

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
    
    self.collectionView.center = CGPointMake(middleOfView, self.collectionView.center.y);
}


- (void) setCollectionData:(NSArray *)collectionData
{
    [super setCollectionData:collectionData];
    
    if(collectionData.count <= 0)
        return;
    
    Channel* firstChannel = collectionData[0];
    
    // create string
    
    NSString *nameString = firstChannel.channelOwner.displayName; // ex 'Dolly Proxima'
    NSString *actionString = [NSString stringWithFormat:@"created %@ collection%@", _collectionData.count > 1 ? [NSString stringWithFormat:@"%i", _collectionData.count] : @"a new", _collectionData.count > 1 ? @"s" : @""];
    
    NSMutableAttributedString *attributedCompleteString = [[NSMutableAttributedString alloc] init];
    NSDictionary *strong = IS_IPHONE ? self.strongCenteredTextAttributes : self.strongTextAttributes;
    NSDictionary *light = IS_IPHONE ? self.lightCenteredTextAttributes : self.lightTextAttributes;
    
    [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: nameString
                                                                                      attributes: strong]];
    if(IS_IPAD)
    {
        [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: @" "
                                                                                          attributes: strong]];
    }
    else
    {
        [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: @"\n"
                                                                                          attributes: strong]];
        
        
    }
    
    [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: actionString
                                                                                      attributes: light]];
    
    self.actionButton.attributedTitle = attributedCompleteString;
    
        self.actionButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
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
    
    // NOTE: All fields are set through the setChannel setter
    itemCell.delegate = self.delegate;
    itemCell.channel = channel;
    
    return itemCell;
}






@end
