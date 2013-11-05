//
//  SYNOnBoardingPopoverQueueController.h
//  rockpack
//
//  Created by Michael Michailidis on 12/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNOnBoardingPopoverView.h"
@import UIKit;

@interface SYNOnBoardingPopoverQueueController : UIViewController

- (void) addPopover: (SYNOnBoardingPopoverView *) popoverView;
- (void) present;
+ (id) queueController;

@end
