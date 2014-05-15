//
//  SYNIPadFeedLayout.h
//  dolly
//
//  Created by Sherman Lo on 23/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYNPagingModel;

@interface SYNIPadFeedLayout : UICollectionViewLayout

// This is set by the view controller so that we can position the collection view properly
// when the iPad is rotated
@property (nonatomic, assign) CGFloat blockLocation;

@property (nonatomic, strong) SYNPagingModel *model;

@end
