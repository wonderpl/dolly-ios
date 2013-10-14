//
//  SYNTopBarViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//


#import "SYNAccountSettingsMainTableViewController.h"
#import "SYNAccountSettingsPopoverBackgroundView.h"
#import "SYNAppDelegate.h"
#import "SYNContainerViewController.h"

#import "SYNVideoViewerViewController.h"
#import <UIKit/UIKit.h>

typedef void (^VideoOverlayDismissBlock)(void);

typedef enum NotificationMessageType : NSInteger {
    NotificationMessageTypeError = 0,
    NotificationMessageTypeSuccess = 1
} NotificationMessageType;

@interface SYNMasterViewController : UIViewController <UIPopoverControllerDelegate,
                                                       UIGestureRecognizerDelegate,
                                                       UINavigationControllerDelegate>

{
    SYNAppDelegate* appDelegate;
    CGFloat originalAddButtonX;
}


@property (nonatomic, strong) IBOutlet UIView* containerView;
@property (nonatomic, readonly) SYNContainerViewController* containerViewController;
@property (nonatomic, strong) SYNAbstractViewController* originViewController;
@property (strong, nonatomic) Reachability *reachability;
@property (nonatomic, readonly) BOOL hasSearchBarOn;
@property (nonatomic, readonly) BOOL isInSearchMode;
@property (nonatomic, readonly) SYNVideoViewerViewController *videoViewerViewController;

@property (nonatomic, strong) IBOutlet UIView* errorContainerView;

@property (nonatomic, strong) IBOutlet UIButton* searchButton;

@property (nonatomic, strong) IBOutlet UIView* darkOverlayView;
@property (nonatomic, strong) IBOutlet UIButton* closeSearchButton;
@property (nonatomic, strong) IBOutlet UIView* overlayView;
@property (nonatomic, strong) IBOutlet UIButton* sideNavigationButton;


@property (nonatomic, weak, readonly) SYNAbstractViewController* showingBaseViewController;
@property (nonatomic, weak, readonly) SYNAbstractViewController* showingViewController;

- (id) initWithContainerViewController: (UIViewController*) root;

- (void) addVideoOverlayToViewController: (SYNAbstractViewController *) originViewController
                  withVideoInstanceArray: (NSArray*) videoInstanceArray
                        andSelectedIndex: (int) selectedIndex fromCenter:(CGPoint)centerPoint;

- (void) removeVideoOverlayController;
- (void) showSideNavigation;
-(void) clearSearchBoxController;

-(void) headerButtonIsActive: (BOOL)isActive;

@end
