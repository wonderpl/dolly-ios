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

typedef void(^TriggerActionOnCompleteBlock)(void);
typedef enum {
    
    OptionButtonTagSettings = 1,
    OptionButtonTagFriends = 2,
    OptionButtonTagAbout = 3,
    OptionButtonTagFeedback = 4,
    OptionButtonTagRate = 5,
    OptionButtonTagBlog = 6,
    OptionButtonTagHelp = 7,
    OptionButtonTagLogout = 8

} OptionButtonTag;


@interface SYNOptionsOverlayViewController ()

@property (nonatomic, copy) TriggerActionOnCompleteBlock completeBlock;
@property (nonatomic, strong) IBOutlet UIView* backgroundView;

@end




@implementation SYNOptionsOverlayViewController




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
                              @"Logout"];
    
    
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
            
        }
        break;
            
        case OptionButtonTagFeedback:
        {
            
        }
        break;
            
        case OptionButtonTagRate:
        {
            
        }
        break;
            
        case OptionButtonTagBlog:
        {
            
        }
        break;
            
        case OptionButtonTagHelp:
        {
            
        }
        break;
            
        case OptionButtonTagLogout:
        {
            [appDelegate logout];
        }
        break;
            
    }
    
    [self removeFromScreen];
       
}

-(void)removeFromScreen
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
    
    self.view.frame = [[SYNDeviceManager sharedInstance] currentScreenRect];
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
