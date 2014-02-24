//
//  SYNCommentingViewController.h
//  dolly
//
//  Created by Michael Michailidis on 06/12/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNAbstractViewController.h"
#import "VideoInstance.h"
#import "SYNSocialCommentButton.h"

@interface SYNCommentingViewController : SYNAbstractViewController

- (instancetype)initWithVideoInstance:(VideoInstance *)videoInstance withButton:(SYNSocialCommentButton*) socialButton;

@end
