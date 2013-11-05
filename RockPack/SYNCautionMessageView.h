//
//  SYNCautionMessageView.h
//  rockpack
//
//  Created by Michael Michailidis on 25/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCaution.h"
@import UIKit;

@interface SYNCautionMessageView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIButton *skipButton;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) SYNCaution *caution;

- (id) initWithCaution: (SYNCaution *) caution;
+ (id) withCaution: (SYNCaution *) caution;

- (void) presentInView: (UIView *) container;

@end
