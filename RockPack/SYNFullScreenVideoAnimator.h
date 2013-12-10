//
//  SYNFullScreenVideoAnimator.h
//  dolly
//
//  Created by Sherman Lo on 20/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYNFullScreenVideoAnimator : NSObject <UIViewControllerAnimatedTransitioning>

+ (instancetype)animatorForPresentation:(BOOL)presenting;

@end
