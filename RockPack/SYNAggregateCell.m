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
}


- (void) setCoverImagesAndTitlesWithArray: (NSArray *) imageString
{
    // to be implemented in subclass
    AssertOrLog(@"Not meant to be called, as should be overridden in derived class");
}


- (void) setTitleMessageWithDictionary: (NSDictionary *) messageDictionary
{
    // to be implemented in subclass
    AssertOrLog(@"Not meant to be called, as should be overridden in derived class");
}


- (void) setViewControllerDelegate: (id<SYNAggregateCellDelegate>) viewControllerDelegate
{
    _viewControllerDelegate = viewControllerDelegate;
    
    [self.userThumbnailButton addTarget: self.viewControllerDelegate
                                 action: @selector(profileButtonTapped:)
                       forControlEvents: UIControlEventTouchUpInside];
}


- (void) setSupplementaryMessageWithDictionary: (NSDictionary *) messageDictionary
{
    // to be implemented in subclass
    AssertOrLog(@"Not meant to be called, as should be overridden in derived class");
}


@end
