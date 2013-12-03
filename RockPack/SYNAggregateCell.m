//
//  SYNAggregateCell.m
//  rockpack
//
//  Created by Michael Michailidis on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAggregateCell.h"
#import "SYNAggregateChannelCell.h"
#import "SYNAggregateVideoCell.h"
#import "UIColor+SYNColor.h"
#import "UIFont+SYNFont.h"
@import QuartzCore;

#define STANDARD_BUTTON_CAPACITY 10


@implementation SYNAggregateCell

- (void) awakeFromNib
{
    // Customise fonts
    self.actionButton.titleLabel.font = [UIFont lightCustomFontOfSize: self.actionButton.titleLabel.font.pointSize];
	
    // == Attributes == //
    
    NSMutableParagraphStyle *paragrapStyle = [[NSMutableParagraphStyle alloc] init];
    paragrapStyle.alignment = NSTextAlignmentCenter;
                                 
    self.strongTextAttributes = @{NSForegroundColorAttributeName: [UIColor dollyTextMediumGray]};
    self.lightTextAttributes = @{NSForegroundColorAttributeName: [UIColor dollyTextLightGray]};
    
    self.strongCenteredTextAttributes = @{NSForegroundColorAttributeName: [UIColor dollyTextMediumGray],
                                          NSParagraphStyleAttributeName: paragrapStyle};
    
    self.lightCenteredTextAttributes = @{NSForegroundColorAttributeName: [UIColor dollyTextLightGray],
                                         NSParagraphStyleAttributeName: paragrapStyle};
    
    self.collectionData = @[]; // set to 0
}


- (void) setCollectionData: (NSArray *) collectionData
{
    if (!collectionData)
    {
        return;
    }
    else
    {
        _collectionData = collectionData;
    }
    
    [self.collectionView reloadData];
}


- (void) setDelegate: (id<SYNSocialActionsDelegate>) delegate
{
    if(_delegate)
    {
        [self.userThumbnailButton removeTarget: _delegate
                                        action: @selector(profileButtonTapped:)
                              forControlEvents: UIControlEventTouchUpInside];
    }
    
    _delegate = delegate;
    
    if(!_delegate)
        return;
    
    [self.userThumbnailButton addTarget: _delegate
                                 action: @selector(profileButtonTapped:)
                       forControlEvents: UIControlEventTouchUpInside];
    
    [self.actionButton addTarget: _delegate
                          action: @selector(profileButtonTapped:)
                forControlEvents: UIControlEventTouchUpInside];
}


#pragma mark - UICollectionView DataSource

// they all have 1 section

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    AssertOrLog(@"Abstract Method Called");
    return 0;
}

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    AssertOrLog(@"Abstract Method Called");
    return 0;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AssertOrLog(@"Abstract Method Called");
    return nil;
}

- (void) followControlPressed: (SYNSocialButton *) socialButton
{
    AssertOrLog(@"Abstract Method Called");
}

- (void) shareControlPressed: (SYNSocialButton *) socialButton
{
    AssertOrLog(@"Abstract Method Called");
}

- (void) likeControlPressed: (SYNSocialButton *) socialButton
{
    AssertOrLog(@"Abstract Method Called");
}
- (void) addControlPressed: (SYNSocialButton *) socialButton
{
    AssertOrLog(@"Abstract Method Called");
}


- (ChannelOwner *) channelOwner
{
    return nil; // implement in subclass
}


- (NSString *) description
{
    return [NSString stringWithFormat: @"AggregateCell of type %@", [self isKindOfClass: [SYNAggregateCell class]] ? @"Video": @"Channel"];
}



@end
