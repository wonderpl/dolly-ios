//
//  SYNModalSubscribersController.m
//  rockpack
//
//  Created by Michael Michailidis on 09/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNModalSubscribersController.h"
#import "SYNAppDelegate.h"
#import "UIFont+SYNFont.h"
#import "SYNMasterViewController.h"

@interface SYNModalSubscribersController ()

@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) IBOutlet UIView *containerView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIButton *backButton;

@end


@implementation SYNModalSubscribersController


- (id) initWithContentViewController: (UIViewController *) viewController
{
    if (self = [super initWithNibName: NSStringFromClass([self class])
                               bundle: [NSBundle mainBundle]])
    {
        self.viewController = viewController;
    }
    
    return self;
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.font = [UIFont lightCustomFontOfSize: self.titleLabel.font.pointSize];
    
    CGRect containerViewFrame = self.containerView.frame;
    self.viewController.view.frame = containerViewFrame;
    
    [self.containerView addSubview: self.viewController.view];
    
}


- (IBAction) backButtonPressed: (id) sender
{
	[appDelegate.masterViewController removeOverlayControllerAnimated:YES];
}

@end
