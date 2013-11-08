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

    self.stringButtonsArray = [[NSMutableArray alloc] initWithCapacity: STANDARD_BUTTON_CAPACITY];
    
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
    _collectionData = collectionData;
    
    if (!_collectionData)
    {
        return;
    }
    
    [self.collectionView reloadData];
}


- (void) setDelegate: (id<SYNSocialActionsDelegate>) delegate
{
    _delegate = delegate;
    
    // Both the avatar button and its label re-direct to the profile page
    [self.userThumbnailButton addTarget: _delegate
                                 action: @selector(profileButtonTapped:)
                       forControlEvents: UIControlEventTouchUpInside];
    
    [self.actionButton addTarget: self.delegate
                          action: @selector(profileButtonTapped:)
                forControlEvents: UIControlEventTouchUpInside];
}


- (void) setSupplementaryMessageWithDictionary: (NSDictionary *) messageDictionary
{
    // to be implemented in subclass
    AssertOrLog(@"Not meant to be called, as should be overridden in derived class");
}


#pragma mark - UICollectionView DataSource

// they all have 1 section

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (ChannelOwner *) channelOwner
{
    return nil; // implement in subclass
}


- (CGSize) correctSize
{
    return CGSizeZero; // override in subclass
}


- (NSString *) description
{
    return [NSString stringWithFormat: @"AggregateCell of type %@", [self isKindOfClass: [SYNAggregateCell class]] ? @"Video": @"Channel"];
}



@end
