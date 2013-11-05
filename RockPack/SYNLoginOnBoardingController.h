//
//  SYNLoginOnBoardingController.h
//  rockpack
//
//  Created by Michael Michailidis on 21/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

@import UIKit;

@protocol UIScrollViewDelegate;

@interface SYNLoginOnBoardingController : UIViewController

@property (nonatomic, readonly) UIPageControl* pageControl;
@property (nonatomic, readonly) UIScrollView* scrollView;

- (id) initWithDelegate: (id <UIScrollViewDelegate>) delegate;

@end
