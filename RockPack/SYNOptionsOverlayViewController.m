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
    
    
    
    for (UIView* sView in self.view.subviews) {
        
        if([sView isKindOfClass:[UIButton class]]) // sanity check
        {
            [((UIButton*)sView) addTarget:self
                                   action:@selector(optionButtonPressed:)
                         forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    [self.backgroundView addGestureRecognizer:tapGesture];
    
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
                    [appDelegate.masterViewController addOverlayController:accountSettingsVC
                                                                  animated:YES];
                }
                else
                {
                    UIViewController* currentVC = appDelegate.masterViewController.showingViewController;
                    currentVC.navigationController.navigationBarHidden = NO;
                    [currentVC.navigationController pushViewController:accountSettingsVC
                                                                               animated:YES];
                }
                
                
            };
        }
        break;
            
        case OptionButtonTagFriends:
        {
            
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
