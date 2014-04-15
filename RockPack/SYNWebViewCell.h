//
//  SYNWebViewCell.h
//  dolly
//
//  Created by Sherman Lo on 10/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYNWebViewCell;

@protocol SYNWebViewCellDelegate <NSObject>

- (void)webViewCellContentLoaded:(SYNWebViewCell *)cell;

@end

@interface SYNWebViewCell : UICollectionViewCell

@property (nonatomic, copy) NSString *contentHTML;

@property (nonatomic, weak) id<SYNWebViewCellDelegate> delegate;

- (CGFloat)contentHeight;

@end
