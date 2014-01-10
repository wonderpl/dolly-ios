//
//  SYNVideoCellDelegate.h
//  dolly
//
//  Created by Sherman Lo on 9/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SYNVideoCellDelegate <NSObject>

- (void)profileButtonPressedForCell:(UICollectionViewCell *)cell;
- (void)channelButtonPressedForCell:(UICollectionViewCell *)cell;

@end
