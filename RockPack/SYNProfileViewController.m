//
//  SYNProfileViewController.m
//  dolly
//
//  Created by Cong Le on 10/03/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNProfileViewController.h"
#import "SYNActivityManager.h"
#import "UIFont+SYNFont.h"
#import "UINavigationBar+Appearance.h"
#import "SYNProfileEditViewController.h"
#import "SYNOptionsOverlayViewController.h"
#import "SYNMasterViewController.h"
#import "SYNDeviceManager.h"
#import "SYNTrackingManager.h"
#import "SYNProfileHeader.h"
#import "SYNSocialButton.h"
#import "SYNProfileVideoViewController.h"
#import "SYNProfileChannelViewController.h"
#import "SYNProfileSubscriptionViewController.h"

static const CGFloat TransitionDuration = 0.5f;

@interface SYNProfileViewController () <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning, SYNProfileNavigationBarDelegate>

@property (nonatomic, strong) SYNProfileSubscriptionViewController *subscriptionCollectionViewController;
@property (strong, nonatomic) SYNProfileVideoViewController *videoCollectionViewController;
@property (strong, nonatomic) SYNProfileChannelViewController *channelCollectionViewController;
@property (strong, nonatomic) IBOutlet UIView *channelContainer;
@property (strong, nonatomic) IBOutlet UIView *videosContainer;
@property (strong, nonatomic) IBOutlet UIView *followingContainer;
@property (strong, nonatomic) IBOutlet UINavigationItem *titleView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (assign, nonatomic) BOOL isUserProfile;

@end

@implementation SYNProfileViewController

+ (UINavigationController *)navigationControllerWithChannelOwner:(ChannelOwner*) channelOwner {
	NSString *filename = IS_IPAD ? @"Profile_IPad" : @"Profile_IPhone";
    
    UINavigationController *navigationController = [[UIStoryboard storyboardWithName:filename bundle:nil] instantiateInitialViewController];
	SYNProfileViewController *profileVC = ((SYNProfileViewController*)navigationController.topViewController);
	profileVC.channelOwner = channelOwner;
    
	return navigationController;
}

+ (UIViewController *)viewControllerWithChannelOwner:(ChannelOwner*) channelOwner {
	NSString *filename = IS_IPAD ? @"Profile_IPad" : @"Profile_IPhone";
	
    SYNProfileViewController *profileVC = [[UIStoryboard storyboardWithName:filename bundle:nil] instantiateViewControllerWithIdentifier:@"SYNProfileViewController"];
	profileVC.channelOwner = channelOwner;
	
    return profileVC;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	[self.videoCollectionViewController coverPhotoAnimation];
    [self.channelCollectionViewController coverPhotoAnimation];
    
    if (self.isUserProfile) {
        self.followingContainer.hidden = YES;
        self.videosContainer.hidden = YES;
        self.channelContainer.hidden = NO;
    } else {
        self.videosContainer.hidden = NO;
        self.channelContainer.hidden = YES;
        self.followingContainer.hidden = YES;
    }
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[SYNActivityManager.sharedInstance updateActivityForCurrentUserWithReset:NO];
	if (self.isUserProfile) {
		[[SYNTrackingManager sharedManager] trackOwnProfileScreenView];
    } else {
		[[SYNTrackingManager sharedManager] trackOtherUserProfileScreenView];
	}
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.navigationController.navigationBar setBackgroundTransparent:YES];
    [self.navigationBar setBarTintColor:[UIColor whiteColor]];
	self.navigationBar.hidden = YES;
	[self updateProfileData];
	self.navigationItem.title = @"";
}

- (void) viewDidDisappear:(BOOL)animated {
    self.navigationBar.hidden = NO;
}

- (void) viewWillDisappear:(BOOL)animated {
    if (IS_IPHONE) {
        [self.navigationController.navigationBar setBackgroundTransparent:NO];
    }
}
#pragma mark - segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"channelSegue"]) {
        SYNProfileChannelViewController * channelCollectionViewController =[segue destinationViewController];
        channelCollectionViewController.channelOwner = self.channelOwner;
        channelCollectionViewController.isUserProfile = self.isUserProfile;
		channelCollectionViewController.delegate = self;
        self.channelCollectionViewController = channelCollectionViewController;
    } else if ([segueName isEqualToString: @"videoSegue"]){
        SYNProfileVideoViewController * videoCollectionViewController =[segue destinationViewController];
        videoCollectionViewController.channelOwner = self.channelOwner;
        videoCollectionViewController.isUserProfile = self.isUserProfile;
		videoCollectionViewController.delegate = self;
        self.videoCollectionViewController = videoCollectionViewController;
    
    }  else if ([segueName isEqualToString: @"subscriptionSegue"]){
        SYNProfileSubscriptionViewController * subscriptionCollectionViewController =[segue destinationViewController];
        subscriptionCollectionViewController.channelOwner = self.channelOwner;
        subscriptionCollectionViewController.isUserProfile = self.isUserProfile;
		subscriptionCollectionViewController.delegate = self;
        self.subscriptionCollectionViewController = subscriptionCollectionViewController;
    }

}

- (void) setChannelOwner: (ChannelOwner *) user {
    
    if (!appDelegate) {
        appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    }
    
     // if no user has been passed, set to nil and then return
    if (!user) {
        return;
    }
    
    BOOL channelOwnerIsUser = (BOOL)[user.uniqueId isEqualToString: appDelegate.currentUser.uniqueId];
    // is a User has been passsed dont copy him OR his channels as there can be only one.
    if (!channelOwnerIsUser && user.uniqueId) {
        IgnoringObjects flags = kIgnoreChannelOwnerObject | kIgnoreVideoInstanceObjects; // these flags are passed to the Channels
        
        _channelOwner = [ChannelOwner instanceFromChannelOwner: user
                                                     andViewId: self.viewId
                                     usingManagedObjectContext: user.managedObjectContext
                                           ignoringObjectTypes: flags];
        
        if (_channelOwner) {
            [_channelOwner.managedObjectContext save: nil];
        }
        
    } else {
        _channelOwner = user;
    }
	
    // if a user has been passed or found, monitor
    if (_channelOwner) {
        self.isUserProfile = channelOwnerIsUser;
        NSManagedObjectID *channelOwnerObjectId = _channelOwner.objectID;
        NSManagedObjectContext *channelOwnerObjectMOC = _channelOwner.managedObjectContext;
        
        __weak SYNProfileViewController *weakSelf = self;
        
        [appDelegate.oAuthNetworkEngine userDataForUser: ((User *) self.channelOwner)
                                           onCompletion: ^(id dictionary) {
                                               
                                               NSError *error = nil;
                                               ChannelOwner * channelOwnerFromId = (ChannelOwner *)[channelOwnerObjectMOC existingObjectWithID: channelOwnerObjectId
                                                                                                                                         error: &error];
                                               if (channelOwnerFromId) {
                                                   [channelOwnerFromId setAttributesFromDictionary: dictionary
                                                                               ignoringObjectTypes: kIgnoreVideoInstanceObjects | kIgnoreChannelOwnerObject];
                                                   _channelOwner = channelOwnerFromId;
                                                   [weakSelf reloadCollectionViews];
                                               } else {
                                                   DebugLog (@"Channel disappeared from underneath us");
                                               }
                                           } onError: nil];
    }
    
    self.channelOwner.subscribedByUserValue = [SYNActivityManager.sharedInstance isSubscribedToUserId:self.channelOwner.uniqueId];
}


- (void) singleChannelOwnerCheck: (ChannelOwner*) user {
    
    NSFetchRequest *channelOwnerFetchRequest = [NSFetchRequest fetchRequestWithEntityName:[ChannelOwner entityName]];
    
    channelOwnerFetchRequest.includesSubentities = NO;
    
    [channelOwnerFetchRequest setPredicate: [NSPredicate predicateWithFormat: @"uniqueId == %@ AND viewId == %@", user.uniqueId, self.viewId]];
    
    NSError *error = nil;
    NSArray *matchingChannelOwnerEntries = [user.managedObjectContext
                                            executeFetchRequest: channelOwnerFetchRequest
                                            error: &error];
    
    if (matchingChannelOwnerEntries.count > 0) {
        _channelOwner = (ChannelOwner *) matchingChannelOwnerEntries[0];
        _channelOwner.markedForDeletionValue = NO;
        
        // housekeeping, there can be only one!
        if (matchingChannelOwnerEntries.count > 1) {
            for (int i = 1; i < matchingChannelOwnerEntries.count; i++) {
                [user.managedObjectContext
                 deleteObject: (matchingChannelOwnerEntries[i])];
            }
        }
    } else {
        IgnoringObjects flags = kIgnoreChannelOwnerObject | kIgnoreVideoInstanceObjects; // these flags are passed to the Channels
        
        _channelOwner = [ChannelOwner instanceFromChannelOwner: user
                                                     andViewId: self.viewId
                                     usingManagedObjectContext: user.managedObjectContext
                                           ignoringObjectTypes: flags];
        
        if (_channelOwner) {
            [_channelOwner.managedObjectContext save: &error];
            
            if (error) {
                _channelOwner = nil; // further error code
            }
        }
    }
}


# pragma mark SYNProfileDelegate

- (void) collectionsTabTapped {

    
    if (self.isUserProfile) {
        self.channelCollectionViewController.headerView.secondTab.selected = NO;
        self.channelCollectionViewController.headerView.firstTab.selected = YES;

    } else {
        self.channelCollectionViewController.headerView.secondTab.selected = YES;
        self.channelCollectionViewController.headerView.firstTab.selected = NO;

    }
    
	
	if (self.isChannelsCollectionViewShowing) {
		return;
	}

    CGPoint offSet;
    
    if (self.isUserProfile) {
        offSet = self.subscriptionCollectionViewController.cv.contentOffset;
    } else {
        offSet = self.videoCollectionViewController.cv.contentOffset;
    }
    
	[self alignOffSet:offSet];
    [self.videoCollectionViewController coverPhotoAnimation];
    [self.channelCollectionViewController coverPhotoAnimation];
    [self.channelCollectionViewController.headerView layoutIfNeeded];
    [self.videoCollectionViewController.headerView layoutIfNeeded];

//    if (IS_IPHONE) {
//		int headerSize = self.isUserProfile ? 523 : 523;
//		
//		CGRect toFrame = self.view.frame;
//		toFrame.origin.x = 0;
//				
//		CGRect fromFrame = self.view.frame;
//		fromFrame.origin.x = 320;
//
//		self.channelCollectionViewController.view.frame = CGRectMake(-320, 0, 320, headerSize);
//		self.channelCollectionViewController.headerView.frame = CGRectMake(320, 0, 320, headerSize);
//		
//		[self transitionFromViewController:self.subscriptionCollectionViewController toViewController:self.channelCollectionViewController duration:0.35 options:UIViewAnimationCurveEaseInOut animations:^{
//			
//			[self.view bringSubviewToFront:self.followingContainer];
//
//			self.channelCollectionViewController.view.frame = toFrame;
//			self.subscriptionCollectionViewController.view.frame = fromFrame;
//			self.subscriptionCollectionViewController.headerView.frame = CGRectMake(-320, 0, 320, headerSize);
//			self.channelCollectionViewController.headerView.frame = CGRectMake(0, 0, 320, headerSize);
//						
//		} completion:nil];
//		
//	} else {
		self.channelContainer.hidden = NO;
		self.videosContainer.hidden = YES;
	    self.followingContainer.hidden = YES;
//	}

	[self.channelCollectionViewController.model reloadInitialPage];
}


- (void) alignOffSet: (CGPoint) offset {
    [self.subscriptionCollectionViewController.cv setContentOffset:offset];
	[self.videoCollectionViewController.cv setContentOffset:offset];
    [self.channelCollectionViewController.cv setContentOffset:offset];
    
    [self.videoCollectionViewController coverPhotoAnimation];
    [self.channelCollectionViewController coverPhotoAnimation];
    [self.subscriptionCollectionViewController coverPhotoAnimation];
    
    [self.videoCollectionViewController.headerView layoutIfNeeded];
    [self.channelCollectionViewController.headerView layoutIfNeeded];
    [self.subscriptionCollectionViewController.headerView layoutIfNeeded];

}

- (void) followingsTabTapped {
    
	if (!self.followingContainer.hidden) {
		return;
	}
	
    
    if (self.isUserProfile) {
		self.subscriptionCollectionViewController.headerView.firstTab.selected = NO;
		self.subscriptionCollectionViewController.headerView.secondTab.selected = YES;
    } else {
        self.videoCollectionViewController.headerView.firstTab.selected = YES;
        self.videoCollectionViewController.headerView.secondTab.selected = NO;
    }

    [self.channelCollectionViewController hideDescriptionCurrentlyShowing];
    
	if ([self.channelOwner.uniqueId isEqualToString:appDelegate.currentUser.uniqueId]) {
		[[SYNTrackingManager sharedManager] trackOwnProfileFollowingScreenView];
	} else {
		[[SYNTrackingManager sharedManager] trackOtherUserCollectionFollowingScreenView];
	}

    CGPoint offSet = self.channelCollectionViewController.cv.contentOffset;

    
    
	[self alignOffSet:offSet];
    
    
	
//	if (IS_IPHONE) {
//		CGRect toFrame = self.view.frame;
//		toFrame.origin.x = 0;
//		
//		CGRect fromFrame = self.view.frame;
//		fromFrame.origin.x = -320;
//		
//		
//		int headerSize = self.isUserProfile ? 523 : 523;
//		
//		self.videoCollectionViewController.view.frame = CGRectMake(320, 0, 320, headerSize);
//		self.videoCollectionViewController.headerView.frame = CGRectMake(-320, 0, 320, headerSize);
//				
//		[self transitionFromViewController:self.channelCollectionViewController toViewController:self.videoCollectionViewController duration:0.35 options:UIViewAnimationCurveEaseInOut animations:^{
//			[self.view bringSubviewToFront:self.channelContainer];
//
//			self.videoCollectionViewController.view.frame = toFrame;
//			self.videoCollectionViewController.headerView.frame = CGRectMake(0, 0, 320, headerSize);
//			
//			
//			self.channelCollectionViewController.view.frame = fromFrame;
//			self.channelCollectionViewController.headerView.frame = CGRectMake(320, 0, 320, headerSize);
//			
//		} completion:nil];
//
//	} else {
		self.videosContainer.hidden = YES;
		self.channelContainer.hidden = YES;
        self.followingContainer.hidden = NO;
//	}
	
//	[self.subscriptionCollectionViewController.model reloadInitialPage];
}


- (void) videosTabTapped {
    
	if (!self.videosContainer.hidden) {
		return;
	}
	
    
    if (self.isUserProfile) {
        
    } else {
        self.videoCollectionViewController.headerView.firstTab.selected = YES;
        self.videoCollectionViewController.headerView.secondTab.selected = NO;
    }
    
    [[SYNTrackingManager sharedManager] trackOtherUserCollectionVideoScreenView];
    
    CGPoint offSet = self.channelCollectionViewController.cv.contentOffset;

    
    
	[self alignOffSet:offSet];
    
    [self.videoCollectionViewController coverPhotoAnimation];
    [self.channelCollectionViewController coverPhotoAnimation];
    [self.videoCollectionViewController.headerView layoutIfNeeded];
    [self.channelCollectionViewController.headerView layoutIfNeeded];
    
	
    //	if (IS_IPHONE) {
    //		CGRect toFrame = self.view.frame;
    //		toFrame.origin.x = 0;
    //
    //		CGRect fromFrame = self.view.frame;
    //		fromFrame.origin.x = -320;
    //
    //
    //		int headerSize = self.isUserProfile ? 523 : 523;
    //
    //		self.videoCollectionViewController.view.frame = CGRectMake(320, 0, 320, headerSize);
    //		self.videoCollectionViewController.headerView.frame = CGRectMake(-320, 0, 320, headerSize);
    //
    //		[self transitionFromViewController:self.channelCollectionViewController toViewController:self.videoCollectionViewController duration:0.35 options:UIViewAnimationCurveEaseInOut animations:^{
    //			[self.view bringSubviewToFront:self.channelContainer];
    //
    //			self.videoCollectionViewController.view.frame = toFrame;
    //			self.videoCollectionViewController.headerView.frame = CGRectMake(0, 0, 320, headerSize);
    //
    //
    //			self.channelCollectionViewController.view.frame = fromFrame;
    //			self.channelCollectionViewController.headerView.frame = CGRectMake(320, 0, 320, headerSize);
    //
    //		} completion:nil];
    //
    //	} else {
    self.videosContainer.hidden = NO;
    self.channelContainer.hidden = YES;
    //	}
	
    //	[self.subscriptionCollectionViewController.model reloadInitialPage];
}


- (void)editButtonTapped {
    
    SYNProfileEditViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SYNProfileEditViewController"];
	
	viewController.modalPresentationStyle = UIModalPresentationCustom;
	viewController.transitioningDelegate = self;
    viewController.delegate = self;
    
    viewController.descriptionString = self.channelOwner.channelOwnerDescription;

	[UIView animateWithDuration:0.3 animations:^{
		if (!IS_IPHONE_5 && IS_IPHONE) {
			[self setCollectionViewContentOffset:CGPointMake(0, 0) animated:NO];
		} else {
			[self setCollectionViewContentOffset:CGPointMake(0, 0) animated:NO];
		}

	} completion:^(BOOL finished) {
		[self presentViewController:viewController animated:YES completion:nil];
	}];
}

- (void) moreButtonTapped {
    
    SYNOptionsOverlayViewController* optionsVC = [[SYNOptionsOverlayViewController alloc] init];
    CGRect vFrame = optionsVC.view.frame;
    vFrame.size = [[SYNDeviceManager sharedInstance] currentScreenSize];
    optionsVC.view.frame = vFrame;
    optionsVC.view.alpha = 0.0f;
	optionsVC.delegate = self;
    
    [appDelegate.masterViewController addChildViewController:optionsVC];
    [appDelegate.masterViewController.view addSubview:optionsVC.view];
    
    [UIView animateWithDuration:0.3 animations:^{
        optionsVC.view.alpha = 1.0f;
    }];
}

- (void) followUserButtonTapped:(SYNSocialButton*)sender {
    
    [self followControlPressed:sender withChannelOwner:self.channelOwner completion:^{
        [self reloadCollectionViews];
    }];
}

#pragma mark - SYNProfileEditDelegate

- (void) setCollectionViewContentOffset:(CGPoint)contentOffset animated:(BOOL) animated{
    [self.channelCollectionViewController.cv setContentOffset:contentOffset animated:animated];
    [self.videoCollectionViewController.cv setContentOffset:contentOffset animated:animated];
    [self.subscriptionCollectionViewController.cv setContentOffset:contentOffset animated:animated];
}

//TODO: only update the showing header

- (void) updateCoverImage: (NSString*) urlString {
	[[SYNTrackingManager sharedManager] trackCoverPhotoUpload];
    self.channelOwner.coverPhotoURL = urlString;
    [self.channelCollectionViewController.headerView setCoverphotoImage:urlString];
	[self.videoCollectionViewController.headerView setCoverphotoImage:urlString];
	[self.subscriptionCollectionViewController.headerView setCoverphotoImage:urlString];
}

- (void) updateAvatarImage: (NSString*) urlString {
	[[SYNTrackingManager sharedManager] trackAvatarUploadFromScreen:[self trackingScreenName]];
    [self.channelCollectionViewController.headerView setProfileImage:urlString];
	[self.subscriptionCollectionViewController.headerView setProfileImage:urlString];
	[self.videoCollectionViewController.headerView setProfileImage:urlString];
}

- (void) updateUserDescription: (NSString*) descriptionString {
    [self.subscriptionCollectionViewController.headerView setDescriptionText:descriptionString];
    [self.channelCollectionViewController.headerView setDescriptionText:descriptionString];
    [self.videoCollectionViewController.headerView setDescriptionText:descriptionString];
}



#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>) animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>) animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return TransitionDuration;
}

- (void) animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *container = transitionContext.containerView;
	
	SYNProfileViewController *fromVC = (SYNProfileViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    SYNProfileEditViewController *toVC = (SYNProfileEditViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    
	if (toVC.isBeingPresented) {
        toView.frame = fromView.frame;
		
        [container addSubview:toView];
        [UIView animateWithDuration:0.5 animations:^{
            toView.alpha = 1.0f;
            fromView.alpha = 0.2f;

        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            toVC.view.alpha = 1.0f;
            fromView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
            [fromView removeFromSuperview];
        }];
    }
}

#pragma mark - reload container collection views

- (void) reloadCollectionViews {
    [self.channelCollectionViewController.cv.collectionViewLayout invalidateLayout];
    [self.subscriptionCollectionViewController.cv.collectionViewLayout invalidateLayout];
	[self.videoCollectionViewController.cv.collectionViewLayout invalidateLayout];
    
	[self.channelCollectionViewController.cv reloadData];
    [self.subscriptionCollectionViewController.cv reloadData];
	[self.videoCollectionViewController.cv reloadData];
}

- (NSString *)trackingScreenName {
	return @"Profile";
}

#pragma mark - SYNProfileNavigationBarDelegate

- (void) hideNavigationBar {
    //	self.navigationBar.hidden = YES;
}

- (void) showNavigationBar {
//	self.navigationBar.hidden = NO;
}


- (void) updateProfileData {
    
    if (self.isUserProfile) {
        if (self.isChannelsCollectionViewShowing) {
            [appDelegate.oAuthNetworkEngine userDataForUser: ((User *) self.channelOwner)
                                               onCompletion: ^(id dictionary) {
                                                   
                                                   if (self.channelOwner)
                                                   {
                                                       [self.channelOwner setAttributesFromDictionary: dictionary
                                                                                  ignoringObjectTypes: kIgnoreNothing];
                                                   }
                                                   
                                                   [self.subscriptionCollectionViewController.model loadNextPageWithCompletionHandler:^(BOOL success, BOOL hasChanged) {
                                                       [self.subscriptionCollectionViewController.headerView setSegmentedControllerText];
                                                       if (success) {
                                                           [self.subscriptionCollectionViewController.cv reloadData];
                                                           [self.channelCollectionViewController.cv reloadData];
                                                       }
                                                   }];
                                               } onError: nil];
        } else {
            
            [self.subscriptionCollectionViewController.model loadNextPageWithCompletionHandler:^(BOOL success, BOOL hasChanged) {
                [self.subscriptionCollectionViewController.cv reloadData];
               	[self.channelCollectionViewController.cv reloadData];
            }];
        }
    
    } else {
        if ([self isVideosCollectionViewShowing]) {
            [self.videoCollectionViewController.model loadNextPageWithCompletionHandler:^(BOOL success, BOOL hasChanged) {
                if (success) {
                    [self.videoCollectionViewController.cv reloadData];
                    [self.channelCollectionViewController.cv reloadData];
                }
            }];
        } else {
            [self.subscriptionCollectionViewController.model loadNextPageWithCompletionHandler:^(BOOL success, BOOL hasChanged) {
                [self.subscriptionCollectionViewController.cv reloadData];
               	[self.videoCollectionViewController.cv reloadData];
            }];
        }
    }
}




- (BOOL) isUserProfile {
    return [self.channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId];
}

- (BOOL) isChannelsCollectionViewShowing {
    return !self.channelContainer.hidden;
}

- (BOOL) isVideosCollectionViewShowing {
    return !self.videosContainer.hidden;
}

- (BOOL) isFollowingsCollectionViewShowing {
    return !self.followingContainer.hidden;
}

@end
