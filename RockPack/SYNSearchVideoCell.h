//
//  SYNSearchVideoCell.h
//  dolly
//
//  Created by Cong Le on 01/05/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNVideoInfoCell.h"

@class VideoInstance;

@interface SYNSearchVideoCell : UICollectionViewCell <SYNVideoInfoCell>


@property (nonatomic, strong) VideoInstance *videoInstance;

@end