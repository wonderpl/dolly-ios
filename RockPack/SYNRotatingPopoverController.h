//
//  SYNRotatingPopoverController.h
//  dolly
//
//  Created by Sherman Lo on 8/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYNSocialButton.h"

@interface SYNRotatingPopoverController : NSObject

- (instancetype)initWithContentViewController:(UIViewController *)viewController;

- (void)presentPopoverFromButton:(UIButton *)button
						  inView:(UIView *)view
		permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
						animated:(BOOL)animated;

@end
