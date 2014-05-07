//
//  SYNRotatingPopoverController.m
//  dolly
//
//  Created by Sherman Lo on 8/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNRotatingPopoverController.h"

@interface SYNRotatingPopoverController () <UIPopoverControllerDelegate>

@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) UIButton *button;


@end

@implementation SYNRotatingPopoverController

- (instancetype)initWithContentViewController:(UIViewController *)viewController {
	if (self = [super init]) {
		self.popoverController = [[UIPopoverController alloc] initWithContentViewController:viewController];
		self.popoverController.delegate = self;
	}
	return self;
}

- (void)presentPopoverFromButton:(UIButton *)button
						  inView:(UIView *)view
		permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
						animated:(BOOL)animated {
	CGRect buttonFrame = [view convertRect:button.frame fromView:button.superview];

	[self.popoverController presentPopoverFromRect:buttonFrame
											inView:view
						  permittedArrowDirections:arrowDirections
										  animated:animated];

	self.view = view;
	self.button = button;
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverController:(UIPopoverController *)popoverController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView *__autoreleasing *)view {
	CGRect buttonRect = [self.view convertRect:self.button.bounds fromView:self.button];

	*rect = buttonRect;
}


- (void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
}

@end
