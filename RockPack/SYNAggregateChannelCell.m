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

@property (nonatomic, strong) IBOutlet UILabel* userNameLabel;

@end

static NSString *kChannelItemCellIndetifier = @"SYNAggregateChannelItemCell";


@implementation SYNAggregateChannelCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [self.collectionView registerNib: [UINib nibWithNibName: kChannelItemCellIndetifier bundle: nil]
          forCellWithReuseIdentifier: kChannelItemCellIndetifier];
    
    self.actionMessageLabel.font = [UIFont lightCustomFontOfSize:self.actionMessageLabel.font.pointSize];
    
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
    
    self.actionMessageLabel.center = CGPointMake(middleOfView, self.actionMessageLabel.center.y);
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
    
    if(IS_IPAD)
    {
        NSMutableAttributedString *attributedCompleteString = [[NSMutableAttributedString alloc] init];
        
        [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: nameString
                                                                                          attributes: self.strongTextAttributes]];
        
        [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: @" "
                                                                                          attributes: self.strongTextAttributes]];
        
        [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: actionString
                                                                                          attributes: self.lightTextAttributes]];
        
        self.actionMessageLabel.attributedText = attributedCompleteString;
    }
    else
    {
        self.userNameLabel.text = nameString;
        self.actionMessageLabel.text =  actionString;
    }
    
    
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
