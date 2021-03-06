//
//  SYNTopBarViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//


#import "SYNAppDelegate.h"
#import "SYNNetworkMessageView.h"
#import "SYNAbstractViewController.h"
#import "SYNPopoverable.h"
#import "SYNActivityTabButton.h"

@import UIKit;

typedef void (^VideoOverlayDismissBlock)(void);



@interface SYNMasterViewController : UIViewController
{
    SYNAppDelegate* appDelegate;
}


@property (nonatomic, strong) SYNAbstractViewController* originViewController;
@property (strong, nonatomic) Reachability *reachability;

@property (nonatomic, strong) IBOutlet UIView* errorContainerView;

@property (nonatomic, strong) IBOutlet UIView* tabsView;

@property (nonatomic, readonly) NSArray* tabs;

@property (nonatomic, strong, readonly) SYNActivityTabButton *activityTab;

@property (nonatomic, readonly) SYNAbstractViewController* showingViewController;

@property (nonatomic, readonly) SYNAbstractViewController* rootViewController;

@property (nonatomic, readonly) NSArray* viewControllers;

- (id) initWithContainerViewController: (UIViewController*) root;

- (void) presentNotificationWithMessage : (NSString*) message andType:(NotificationMessageType)type;

// == Adding an Overlay == //

-(void) addExistingCollectionsOverlayControllerForVideoInstance:(VideoInstance *)videoInstance;

- (void) addOverlayController:(UIViewController*)overlayViewController animated:(BOOL)animated;

// ======================= //

-(void) removeOverlayControllerAnimated:(BOOL)animated;

// on-boarding


@end
