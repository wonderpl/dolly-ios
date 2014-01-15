//
//  SYNiPhoneLoginAnimator.h
//  dolly
//
//  Created by Sherman Lo on 13/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYNiPhoneLoginAnimator : NSObject <UIViewControllerAnimatedTransitioning>

+ (instancetype)animatorForPresentation:(BOOL)presenting;

@end
