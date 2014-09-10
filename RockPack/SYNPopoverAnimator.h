//
//  SYNPopoverAnimator.h
//  dolly
//
//  Created by Sherman Lo on 12/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYNPopoverAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign, readonly) BOOL presenting;

+ (instancetype)animatorForPresentation:(BOOL)presenting;
- (instancetype)initForPresentation:(BOOL)presenting;

@end
