//
//  SYNOnBoardingFooter.h
//  dolly
//
//  Created by Michael Michailidis on 03/12/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SYNOnboardingFooterDelegate <NSObject>

- (void)continueButtonPressed:(UIButton *)button;

@end

@interface SYNOnBoardingFooter : UICollectionReusableView

@property (nonatomic, weak) id<SYNOnboardingFooterDelegate> delegate;

@end
