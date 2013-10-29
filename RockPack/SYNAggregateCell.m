//
//  SYNAggregateCell.m
//  rockpack
//
//  Created by Michael Michailidis on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAggregateCell.h"
#import "UIColor+SYNColor.h"
#import "UIFont+SYNFont.h"

#import <QuartzCore/QuartzCore.h>

#define STANDARD_BUTTON_CAPACITY 10

@implementation SYNAggregateCell

- (void) awakeFromNib
{
    self.messageLabel.font = [UIFont lightCustomFontOfSize: self.messageLabel.font.pointSize];
    
    self.stringButtonsArray = [[NSMutableArray alloc] initWithCapacity: STANDARD_BUTTON_CAPACITY];
    
    self.lightTextAttributes = @{NSFontAttributeName: [UIFont lightCustomFontOfSize: 13.0f],
                                 NSForegroundColorAttributeName: [UIColor rockpacAggregateTextLight]};
    
    self.boldTextAttributes = @{NSFontAttributeName: [UIFont regularCustomFontOfSize: 13.0f],
                                NSForegroundColorAttributeName: [UIColor rockpacAggregateTextLight]};
    
    // == Round off the image == //
    
    self.userThumbnailImageView.layer.cornerRadius = self.userThumbnailImageView.frame.size.height * 0.5f;
    self.userThumbnailImageView.clipsToBounds = YES;
    
    self.collectionData = @[]; // set to 0
}

-(void)setCollectionData:(NSArray *)collectionData
{
    _collectionData = collectionData;
    [self.collectionView reloadData];
}





- (void) setDelegate: (id<SYNSocialActionsDelegate>) delegate
{
    _delegate = delegate;
    
    [self.userThumbnailButton addTarget: _delegate
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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(ChannelOwner*)channelOwner
{
    return nil; // implement in subclass
}

@end
