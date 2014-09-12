//
//  SYNOptionsOverlayViewController.m
//  dolly
//
//  Created by Michael Michailidis on 13/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNOptionsOverlayViewController.h"
#import "SYNAppDelegate.h"
#import "SYNMasterViewController.h"
#import "SYNAccountSettingsViewController.h"
#import "SYNDeviceManager.h"
#import "SYNFriendsViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNAboutViewController.h"
#import "SYNFeedbackViewController.h"
#import "Appirater.h"
#import "SYNWebViewController.h"
#import "SYNContainerViewController.h"
#import "SYNTrackingManager.h"

typedef void(^TriggerActionOnCompleteBlock)(void);
typedef enum {
    
    OptionButtonTagSettings = 1,
    OptionButtonTagFriends = 2,
    OptionButtonTagAbout = 3,
    OptionButtonTagFeedback = 4,
    OptionButtonTagRate = 5,
    OptionButtonTagBlog = 6,
    OptionButtonTagHelp = 7,
    OptionButtonTagLogout = 8,
    OptionButtonTagHints = 9,
    OptionButtonTagEdit = 10

} OptionButtonTag;


@interface SYNOptionsOverlayViewController ()

@property (nonatomic, copy) TriggerActionOnCompleteBlock completeBlock;
@property (nonatomic, strong) IBOutlet UIView* backgroundView;

@end




@implementation SYNOptionsOverlayViewController


-(void)startingPresentation
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // start by a blank name as the tags are 1 indexed (don't ask why... mainly superstition)
    NSArray* labelStrings = @[@"",
                              @"Settings",
                              @"Friends",
                              @"About",
                              @"Feedback",
                              @"Rate",
                              @"Blog",
                              @"Help",
                              @"Logout",
                              @"Hints",
                              @"Edit my profile"];
    
    
    for (UIView* sView in self.view.subviews)
    {
        
        if([sView isKindOfClass:[UIButton class]]) // sanity check
        {
            
            NSString* poperName = labelStrings[sView.tag];
            
            UILabel* l = [self createLabelForOptionButtonWithName:poperName];
            
            l.center = CGPointMake(30.0f, 75.0f);
            
            [sView addSubview:l];
            
            [((UIButton*)sView) addTarget:self
                                   action:@selector(optionButtonPressed:)
                         forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    [self.backgroundView addGestureRecognizer:tapGesture];
    
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[SYNTrackingManager sharedManager] trackProfileOverlayScreenView];
}

-(UILabel*)createLabelForOptionButtonWithName:(NSString*)name
{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont lightCustomFontOfSize:14.0f];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = name;
    [label sizeToFit];
    return label;
}

-(void)backgroundTapped:(UITapGestureRecognizer*)tapGesture
{
    [self removeFromScreen];
}

-(void)optionButtonPressed:(UIButton*)buttonPressed
{
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	UIViewController *parentViewController = self.parentViewController;
    
    switch (buttonPressed.tag)
    {
        case OptionButtonTagSettings:
        {
            self.completeBlock = ^{
                
                SYNAccountSettingsViewController* accountSettingsVC = [[SYNAccountSettingsViewController alloc] init];
                
                if(IS_IPAD)
                {
                    UINavigationController* wrapper =
                    [[UINavigationController alloc] initWithRootViewController:accountSettingsVC];
                    
                    wrapper.view.frame = accountSettingsVC.view.frame;
                    
                    [appDelegate.masterViewController addOverlayController:wrapper
                                                                  animated:YES];
                }
                else
                {
                    UIViewController* currentVC = appDelegate.masterViewController.showingViewController;
                    currentVC.navigationController.navigationBarHidden = NO;
                    [currentVC.navigationController pushViewController: accountSettingsVC
                                                              animated: YES];
                }
                
                
            };
        }
        break;
            
        case OptionButtonTagFriends:
        {
            self.completeBlock = ^{
              
                
                SYNFriendsViewController* friendsVC = [[SYNFriendsViewController alloc] initWithViewId:kFriendsViewId];
                
                UIViewController* currentVC = appDelegate.masterViewController.showingViewController;
                
                currentVC.navigationController.navigationBarHidden = NO;
                [currentVC.navigationController pushViewController: friendsVC
                                                          animated: YES];
                
            };
        }
        break;
            
        case OptionButtonTagAbout:
        {
            self.completeBlock = ^{
                
                
                SYNAboutViewController* aboutVC = [[SYNAboutViewController alloc] init];
                
                if(IS_IPAD)
                {
                    UINavigationController* wrapper =
                    [[UINavigationController alloc] initWithRootViewController:aboutVC];
                    
                    wrapper.view.frame = aboutVC.view.frame;
                    
                    [appDelegate.masterViewController addOverlayController:wrapper
                                                                  animated:YES];
                }
                else
                {
                    UIViewController* currentVC = appDelegate.masterViewController.showingViewController;
                    currentVC.navigationController.navigationBarHidden = NO;
                    [currentVC.navigationController pushViewController: aboutVC
                                                              animated: YES];
                }
                
            };
        }
        break;
            
        case OptionButtonTagFeedback:
        {
            self.completeBlock = ^{
                
                
                SYNFeedbackViewController* aboutVC = [[SYNFeedbackViewController alloc] init];
                
                if(IS_IPAD)
                {
                    UINavigationController* wrapper =
                    [[UINavigationController alloc] initWithRootViewController:aboutVC];
                    
                    wrapper.view.frame = aboutVC.view.frame;
                    
                    [appDelegate.masterViewController addOverlayController:wrapper
                                                                  animated:YES];
                }
                else
                {
                    UIViewController* currentVC = appDelegate.masterViewController.showingViewController;
                    currentVC.navigationController.navigationBarHidden = NO;
                    [currentVC.navigationController pushViewController: aboutVC
                                                              animated: YES];
                }
                
            };
        }
        break;
            
        case OptionButtonTagRate:
        {
             self.completeBlock = ^{
				 
				 [[SYNTrackingManager sharedManager] trackRateScreenView];
				 
				 NSString *URLString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", APP_ID];
				 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString]];
                 
                 [Appirater userDidSignificantEvent: YES];
				 
             };
        }
        break;
            
        case OptionButtonTagBlog:
        {
			NSURL *URL = [NSURL URLWithString:@"http://blog.wonderpl.com/"];
			UIViewController *viewController = [SYNWebViewController webViewControllerForURL:URL withTrackingName:@"Blog"];
			[parentViewController presentViewController:viewController animated:YES completion:nil];
        }
        break;
            
        case OptionButtonTagHelp:
        {
			NSURL *URL = [NSURL URLWithString:@"http://wonderpl.com/help"];
			UIViewController *viewController = [SYNWebViewController webViewControllerForURL:URL withTrackingName:@"Help"];
			[parentViewController presentViewController:viewController animated:YES completion:nil];
        }
        break;
            
        case OptionButtonTagLogout:
        {
            [appDelegate logout];
        }
        break;
            
        case OptionButtonTagHints:
        {
            NSURL *URL = [NSURL URLWithString:@"http://wonderpl.com/hints"];
            UIViewController *viewController = [SYNWebViewController webViewControllerForURL:URL withTrackingName:@"Hints"];
            [parentViewController presentViewController:viewController animated:YES completion:nil];
        }
        break;
  
        case OptionButtonTagEdit:
        {
            [self removeFromScreen];
			
			__weak SYNOptionsOverlayViewController *wself = self;
			self.completeBlock = ^{
				[wself.delegate editButtonTapped];
			};
        }
            
    }
    
    [self removeFromScreen];
}

- (void) removeFromScreen
{
    [UIView animateWithDuration:0.3f animations:^{
        
        self.view.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        
        
        // trigger the nessesary action on fade out
        if(self.completeBlock)
            self.completeBlock();
        
        
        // then remove since removing before the block call will release the instance
        //[self.view removeFromSuperview];
        [self removeFromParentViewController];
        
        
    }];
    
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    self.view.frame = [[UIScreen mainScreen] bounds];
}

-(void)finishingPresentation
{
    if(self.completeBlock)
        self.completeBlock();
}

-(void)dealloc
{
    self.completeBlock = nil;
}

@end
