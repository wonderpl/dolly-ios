//
//  SYNCameraPopoverViewController.h
//  rockpack
//
//  Created by Nick Banks on 11/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import UIKit;
#import "UIColor+SYNColor.h"
#import "UIFont+SYNFont.h"

@protocol SYNCameraPopoverViewControllerDelegate;

@interface SYNCameraPopoverViewController : UIViewController

@property (nonatomic, weak) id<SYNCameraPopoverViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (strong, nonatomic) IBOutlet UIButton *chooseExistingPhotoButton;

@end

@protocol SYNCameraPopoverViewControllerDelegate <NSObject>

- (void) userTouchedTakePhotoButton;
- (void) userTouchedChooseExistingPhotoButton;

@end
