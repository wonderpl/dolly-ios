//
//  SYNiPadLoginToForgotPasswordAnimator.h
//  dolly
//
//  Created by Sherman Lo on 15/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYNiPadLoginToForgotPasswordAnimator : NSObject <UIViewControllerAnimatedTransitioning>

+ (instancetype)animatorForPresentation:(BOOL)presenting;

@end
