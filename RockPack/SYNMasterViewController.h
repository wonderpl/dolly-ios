//
//  SYNTopBarViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//


#import "SYNAppDelegate.h"
#import "SYNNetworkMessageView.h"
#import "SYNVideoViewerViewController.h"
@import UIKit;

typedef void (^VideoOverlayDismissBlock)(void);



@interface SYNMasterViewController : UIViewController <UIPopoverControllerDelegate,
                                                       UIGestureRecognizerDelegate,
                                                       UINavigationControllerDelegate>

{
    SYNAppDelegate* appDelegate;
}




@property (nonatomic, strong) SYNAbstractViewController* originViewController;
@property (strong, nonatomic) Reachability *reachability;
@property (nonatomic, readonly) SYNVideoViewerViewController *videoViewerViewController;

@property (nonatomic, strong) IBOutlet UIView* errorContainerView;

@property (nonatomic, strong) IBOutlet UIView* tabsView;

@property (nonatomic, strong) IBOutlet UIButton* closeSearchButton;
@property (nonatomic, strong) IBOutlet UIView* videoOverlayView;
@property (nonatomic, strong) IBOutlet UIButton* sideNavigationButton;

@property (nonatomic, readonly) NSArray* tabs;

@property (nonatomic, readonly) BOOL hasCreatedPopularGenre;


@property (nonatomic, readonly) SYNAbstractViewController* showingViewController;

- (id) initWithContainerViewController: (UIViewController*) root;

- (void) presentNotificationWithMessage : (NSString*) message andType:(NotificationMessageType)type;

- (void) addVideoOverlayToViewController: (SYNAbstractViewController *) originViewController
                  withVideoInstanceArray: (NSArray*) videoInstanceArray
                        andSelectedIndex: (int) selectedIndex fromCenter:(CGPoint)centerPoint;

- (void) removeVideoOverlayController;

// Overlay
-(void) addExistingCollectionsOverlayControllerForVideoInstance:(VideoInstance *)videoInstance;


-(void) addOverlayController: (UIViewController*) abstractViewController animated:(BOOL)animated;


-(void) removeOverlayControllerAnimated:(BOOL)animated;

-(void)displayNotificationsLoaded:(NSInteger)notificationsCount;

// on-boarding


@end
