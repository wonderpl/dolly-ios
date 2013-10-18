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
}


- (void) prepareForReuse
{
    [super prepareForReuse];
    
    if (self.buttonContainerView)
    {
        [self.buttonContainerView removeFromSuperview];
        self.buttonContainerView = nil;
    }
    
    if (self.labelsContainerView)
    {
        [self.labelsContainerView removeFromSuperview];
        self.labelsContainerView = nil;
    }
    
    self.mainTitleLabel.hidden = NO;
}


- (void) setCoverImagesAndTitlesWithArray: (NSArray *) array
{
    
}


- (void) setViewControllerDelegate: (id<SYNAggregateCellDelegate>) viewControllerDelegate
{
    [super setViewControllerDelegate: viewControllerDelegate];
    
    if (self.buttonContainerView)
    {
        for (UIImageView *simulatedButtonView in self.buttonContainerView.subviews)
        {
            // Tap for showing video
            UITapGestureRecognizer *buttonTap = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                                        action: @selector(showChannel:)];
            buttonTap.delegate = self;
            [simulatedButtonView addGestureRecognizer: buttonTap];
            
            // Touch for highlighting cells when the user touches them (like UIButton)
            SYNTouchGestureRecognizer *buttonTouch = [[SYNTouchGestureRecognizer alloc] initWithTarget: self
                                                                                                action: @selector(showGlossLowlight:)];
            
            buttonTouch.delegate = self;
            [simulatedButtonView addGestureRecognizer: buttonTouch];
        }
    }
    
    [self.userThumbnailButton addTarget: self.viewControllerDelegate
                                 action: @selector(profileButtonTapped:)
                       forControlEvents: UIControlEventTouchUpInside];
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
    
    return 1;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    SYNAggregateChannelItemCell* itemCell = [collectionView dequeueReusableCellWithReuseIdentifier: kChannelItemCellIndetifier
                                                                                    forIndexPath: indexPath];
    
    
    return itemCell;
    
    
}

@end
