//
//  SYNTopBarViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "GAITrackedViewController.h"
#import "SYNAppDelegate.h"
#import "SYNContainerViewController.h"

#import "SYNAccountSettingsMainTableViewController.h"
#import "SYNAccountSettingsPopoverBackgroundView.h"
#import <UIKit/UIKit.h>


typedef void (^VideoOverlayDismissBlock)(void);

@interface SYNMasterViewController : GAITrackedViewController <UIPopoverControllerDelegate,
                                                                UIGestureRecognizerDelegate>

{
    SYNAppDelegate* appDelegate;
    CGFloat originalAddButtonX;
}


@property (nonatomic, strong) IBOutlet UIView* containerView;
@property (nonatomic, strong) SYNContainerViewController* containerViewController;
@property (nonatomic, strong) UIViewController* originViewController;
@property (strong, nonatomic) Reachability *reachability;
@property (nonatomic, readonly) BOOL isInSearchMode;


@property (nonatomic, weak, readonly) SYNAbstractViewController* showingViewController;

- (id) initWithContainerViewController: (UIViewController*) root;

- (void) addVideoOverlayToViewController: (UIViewController *) originViewController
                  withVideoInstanceArray: (NSArray*) videoInstanceArray
                        andSelectedIndex: (int) selectedIndex;

- (void) removeVideoOverlayController;



@end
