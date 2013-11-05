//
//  SYNOnBoardingPopoverView.h
//  rockpack
//
//  Created by Michael Michailidis on 12/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

@import UIKit;
#import "AppConstants.h"

typedef void (^PopoverAction)(id);

@interface SYNOnBoardingPopoverView : UIView {
    PopoverAction a;
}

+ (id) withMessage: (NSString *) message
          withSize: (CGSize) size
       andFontSize: (CGFloat) fontSize
        pointingTo: (CGRect) pointRect
     withDirection: (PointingDirection) direction;

- (id) initWithMessage: (NSString *) message
              withSize: (CGSize) size
           andFontSize: (CGFloat) fontSize
            pointingTo: (CGRect) pointRect
         withDirection: (PointingDirection) direction;

@property (nonatomic) PointingDirection direction;
@property (nonatomic) CGRect pointRect;
@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) UIImageView *arrow;
@property (nonatomic, copy) PopoverAction action;

@end
