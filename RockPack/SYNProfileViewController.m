//
//  SYNProfileViewController.m
//  dolly
//
//  Created by Cong Le on 10/03/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNProfileViewController.h"
#import "SYNProfileSubscriptionViewController.h"
#import <UIImageView+WebCache.h>
#import <UIButton+WebCache.h>
#import "SYNProfileChannelViewController.h"
#import "SYNActivityManager.h"
#import "UIFont+SYNFont.h"
#import "UINavigationBar+Appearance.h"
#import "SYNProfileEditViewController.h"
#import "SYNOptionsOverlayViewController.h"
#import "SYNMasterViewController.h"
#import "SYNDeviceManager.h"
#import "SYNTrackingManager.h"
#import "SYNProfileHeader.h"

#define TRANSITION_DURATION 1.0
#define ALPHA_IN_EDIT 0.2f

static const CGFloat TransitionDuration = 1.0f;

@interface SYNProfileViewController () <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

@property (nonatomic, strong) SYNProfileSubscriptionViewController *subscriptionCollectionViewController;
@property (nonatomic, strong) SYNProfileChannelViewController *channelCollectionViewController;
@property (nonatomic, strong) IBOutlet UIView *channelContainer;
@property (nonatomic, strong) IBOutlet UIView *followingContainer;
@property (nonatomic, strong) UIAlertView *followAllAlertView;
@property (nonatomic, strong) SYNSocialButton *followAllButton;
@property (nonatomic) BOOL isUserProfile;
@property (nonatomic) BOOL creatingChannel;

@end

@implementation SYNProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    self.followingContainer.hidden = YES;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
	[self.navigationController.navigationBar setBackgroundTransparent:YES];
    
    self.navigationItem.title = @"";
    
    
//    
    NSManagedObjectID *channelOwnerObjectId = self.channelOwner.objectID;
    NSManagedObjectContext *channelOwnerObjectMOC = self.channelOwner.managedObjectContext;

    [appDelegate.oAuthNetworkEngine userDataForUser: ((User *) self.channelOwner)
                                       onCompletion: ^(id dictionary) {
                                           NSError *error = nil;
                                           ChannelOwner * channelOwnerFromId = (ChannelOwner *)[channelOwnerObjectMOC existingObjectWithID: channelOwnerObjectId error: &error];
                                           
                                           if (channelOwnerFromId)
                                           {
                                               [channelOwnerFromId setAttributesFromDictionary: dictionary
                                                                           ignoringObjectTypes: kIgnoreNothing];
                                               [self reloadCollectionViews];
                                           }
                                       } onError: nil];
    
    
    if (self.followingContainer.hidden == NO) {
        [self.subscriptionCollectionViewController.model reset];
        [self.subscriptionCollectionViewController.model loadFirstPage];
    }
    [self reloadCollectionViews];
}

#pragma mark - segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"channelSegue"]) {
        SYNProfileChannelViewController * channelCollectionViewController =[segue destinationViewController];
        channelCollectionViewController.channelOwner = self.channelOwner;
        channelCollectionViewController.isUserProfile = self.isUserProfile;

        self.channelCollectionViewController = channelCollectionViewController;
    } else if ([segueName isEqualToString: @"subscriptionSegue"]){
        SYNProfileSubscriptionViewController * subscriptionCollectionViewController =[segue destinationViewController];
        subscriptionCollectionViewController.channelOwner = self.channelOwner;
        subscriptionCollectionViewController.isUserProfile = self.isUserProfile;
        
        //TODO: Change modeType to BOOL

        self.subscriptionCollectionViewController = subscriptionCollectionViewController;
    }
}

#pragma mark - setChannelOwner

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
        
        [self singleChannelOwnerCheck:user];
        // The ChannelOwner is the User!
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


-(void) stopScrollView: (UIScrollView*) scrollview {
    CGPoint offset = scrollview.contentOffset;
    offset.x -= 1.0;
    offset.y -= 1.0;
    [scrollview setContentOffset:offset animated:NO];
    offset.x += 1.0;
    offset.y += 1.0;
    [scrollview setContentOffset:offset animated:NO];
}

# pragma mark profile delegate methods


//make a real segmented controller
- (void) collectionsTabTapped {
    if (!self.channelContainer.hidden) {
        return;
    }
    
    CGPoint offSet = self.subscriptionCollectionViewController.cv.contentOffset;
    
    [self.subscriptionCollectionViewController.cv setContentOffset:offSet];
    [self.channelCollectionViewController.cv setContentOffset:offSet];

    [self.subscriptionCollectionViewController coverPhotoAnimation];
    [self.channelCollectionViewController coverPhotoAnimation];
    [self.channelCollectionViewController.headerView layoutIfNeeded];
    [self.subscriptionCollectionViewController.headerView layoutIfNeeded];

    self.channelContainer.hidden = NO;
    self.followingContainer.hidden = YES;
    

    [self.channelCollectionViewController.model reset];
    [self.channelCollectionViewController.model loadFirstPage];
    [self.channelCollectionViewController.headerView.segmentedController setSelectedSegmentIndex:0];

}

- (void) followingsTabTapped {
    
    
    if (!self.followingContainer.hidden) {
        return;
    }

    CGPoint offSet = self.channelCollectionViewController.cv.contentOffset;
    
    [self.subscriptionCollectionViewController.cv setContentOffset:offSet];
    [self.channelCollectionViewController.cv setContentOffset:offSet];

    [self.subscriptionCollectionViewController coverPhotoAnimation];
    [self.channelCollectionViewController coverPhotoAnimation];
    [self.subscriptionCollectionViewController.headerView layoutIfNeeded];
    [self.channelCollectionViewController.headerView layoutIfNeeded];
    
    self.channelContainer.hidden = YES;
    self.followingContainer.hidden = NO;
    
    [self.subscriptionCollectionViewController.model reset];
    [self.subscriptionCollectionViewController.model loadFirstPage];    

}

- (void) editButtonTapped {
    
    SYNProfileEditViewController *viewController = [[UIStoryboard storyboardWithName:IS_IPHONE ? @"Profile_IPhone":@"Profile_IPad"  bundle:nil] instantiateViewControllerWithIdentifier:@"SYNProfileEditViewController"];
    
	viewController.modalPresentationStyle = UIModalPresentationCustom;
	viewController.transitioningDelegate = self;
    viewController.delegate = self;
    
    viewController.descriptionString = self.channelOwner.channelOwnerDescription;

    if (!IS_IPHONE_5 && IS_IPHONE) {
        [self setCollectionViewContentOffset:CGPointMake(0, 110) animated:YES];
    } else {
        [self setCollectionViewContentOffset:CGPointMake(0, 0) animated:YES];
    }

	double delayInSeconds = 0.2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[self presentViewController:viewController animated:YES completion:nil];
		
	});
}

- (void) moreButtonTapped {
    
    SYNOptionsOverlayViewController* optionsVC = [[SYNOptionsOverlayViewController alloc] init];
    CGRect vFrame = optionsVC.view.frame;
    vFrame.size = [[SYNDeviceManager sharedInstance] currentScreenSize];
    optionsVC.view.frame = vFrame;
    optionsVC.view.alpha = 0.0f;
    
    [appDelegate.masterViewController addChildViewController:optionsVC];
    [appDelegate.masterViewController.view addSubview:optionsVC.view];
    
    [UIView animateWithDuration:0.3 animations:^{
        optionsVC.view.alpha = 1.0f;
    }];
}

- (void)followUserButtonTapped:(SYNSocialFollowButton*)sender {
    
    self.followAllAlertView = [[UIAlertView alloc]initWithTitle:@"Follow All?" message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"No", @"No to alert view") otherButtonTitles:NSLocalizedString(@"Yes", @"Yes to alert view"), nil];
    self.followAllButton = sender;
    [self.followAllAlertView show];
}

- (void) resetCollectionViewOffset {
    
    CGPoint newOffset = CGPointZero;
    
    if (IS_IPHONE && !IS_IPHONE_5) {
        newOffset = CGPointMake(0, 100);
    }
    
    if (self.channelContainer.hidden == NO  ) {
        [self.channelCollectionViewController.cv setContentOffset:newOffset animated:YES];
    } else {
        [self.subscriptionCollectionViewController.cv setContentOffset:newOffset animated:YES];
    }
}

- (UIView*) showingContainerView {
    if (self.channelContainer.hidden == NO  ) {
        return self.channelContainer;
    } else {
        return self.followingContainer;
    }
}

#pragma mark - Profile edit delegates

- (void) setCollectionViewContentOffset:(CGPoint)contentOffset animated:(BOOL) animated{
    [self.channelCollectionViewController.cv setContentOffset:contentOffset animated:animated];
    [self.subscriptionCollectionViewController.cv setContentOffset:contentOffset animated:animated];
}

- (void) updateCoverImage: (NSString*) urlString {
    self.channelOwner.coverPhotoURL = urlString;
    
    [self.channelCollectionViewController.headerView setCoverphotoImage:urlString];
    [self.subscriptionCollectionViewController.headerView setCoverphotoImage:urlString];
}

- (void) updateAvatarImage: (NSString*) urlString {
    [self.channelCollectionViewController.headerView setProfileImage:urlString];
    [self.subscriptionCollectionViewController.headerView setProfileImage:urlString];
}

- (void) updateUserDescription: (NSString*) descriptionString {
    
    [self.subscriptionCollectionViewController.headerView setDescriptionText:descriptionString];
    [self.channelCollectionViewController.headerView setDescriptionText:descriptionString];
}

#pragma mark - Alertview delegates

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	[[SYNTrackingManager sharedManager] trackUserCollectionsFollowFromScreenName:[self trackingScreenName]];
    
    //#warning change to server call
    if (alertView == self.followAllAlertView && buttonIndex == 1) {
        self.channelOwner.subscribedByUserValue = [SYNActivityManager.sharedInstance isSubscribedToUserId:self.channelOwner.uniqueId];
        self.followAllButton.dataItemLinked = self.channelOwner;
        [self followControlPressed:self.followAllButton];
    }
}


#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return TransitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
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
            fromView.alpha = 0.6f;

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
    [self.subscriptionCollectionViewController.cv.collectionViewLayout invalidateLayout];
    [self.channelCollectionViewController.cv.collectionViewLayout invalidateLayout];
    
    [self.subscriptionCollectionViewController.cv reloadData];
    [self.channelCollectionViewController.cv reloadData];
}


@end
