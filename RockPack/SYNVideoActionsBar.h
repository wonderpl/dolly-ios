//
//  SYNVideoButtonBar.h
//  dolly
//
//  Created by Sherman Lo on 16/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYNVideoActionsBar;

@protocol SYNVideoActionsBarDelegate <NSObject>

- (void)videoActionsBar:(SYNVideoActionsBar *)bar favouritesButtonPressed:(UIButton *)button;
- (void)videoActionsBar:(SYNVideoActionsBar *)bar addToChannelButtonPressed:(UIButton *)button;
- (void)videoActionsBar:(SYNVideoActionsBar *)bar shareButtonPressed:(UIButton *)button;

@optional
- (void)videoActionsBar:(SYNVideoActionsBar *)bar annotationButtonPressed:(UIButton *)button;

@end

@interface SYNVideoActionsBar : UIView

@property (nonatomic, weak) id<SYNVideoActionsBarDelegate> delegate;

@property (nonatomic, weak, readonly) UIButton *shopButton;
@property (nonatomic, weak, readonly) UIButton *favouriteButton;

+ (instancetype)bar;

@end
