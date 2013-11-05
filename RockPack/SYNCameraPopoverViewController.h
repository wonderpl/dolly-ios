//
//  SYNCameraPopoverViewController.h
//  rockpack
//
//  Created by Nick Banks on 11/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import UIKit;

@protocol SYNCameraPopoverViewControllerDelegate;

@interface SYNCameraPopoverViewController : UIViewController

@property (nonatomic, weak) id<SYNCameraPopoverViewControllerDelegate> delegate;

@end

@protocol SYNCameraPopoverViewControllerDelegate <NSObject>

- (void) userTouchedTakePhotoButton;
- (void) userTouchedChooseExistingPhotoButton;

@end
