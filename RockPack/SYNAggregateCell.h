//
//  SYNAggregateCell.h
//  rockpack
//
//  Created by Michael Michailidis on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
#import <UIKit/UIKit.h>

@protocol SYNAggregateCellDelegate <NSObject>

- (void) touchedAggregateCell;

@end

@interface SYNAggregateCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIButton *userThumbnailButton;
@property (nonatomic, strong) IBOutlet UIImageView *userThumbnailImageView;
@property (nonatomic, strong) IBOutlet UILabel *mainTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) IBOutlet UIView *imageContainer;
@property (nonatomic, strong) NSDictionary *boldTextAttributes;
@property (nonatomic, strong) NSDictionary *lightTextAttributes;
@property (nonatomic, strong) NSMutableArray *stringButtonsArray;
@property (nonatomic, weak) id<SYNAggregateCellDelegate> viewControllerDelegate;

- (void) setCoverImagesAndTitlesWithArray: (NSArray *) imageString;
- (void) setTitleMessageWithDictionary: (NSDictionary *) messageDictionary;
- (void) setSupplementaryMessageWithDictionary: (NSDictionary *) messageDictionary;

@end
