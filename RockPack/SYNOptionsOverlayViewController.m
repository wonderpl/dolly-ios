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
#import "SYNAccountSettingsMainTableViewController.h"


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
{
    
}

@property (nonatomic, copy) TriggerActionOnCompleteBlock completeBlock;
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
    
}

-(void)optionButtonPressed:(UIButton*)buttonPressed
{
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    __weak SYNOptionsOverlayViewController* wself = self;
    switch (buttonPressed.tag)
    {
        case OptionButtonTagSettings:
        {
            self.completeBlock = ^{
                
                SYNAccountSettingsMainTableViewController* accountSettingsVC = [[SYNAccountSettingsMainTableViewController alloc] init];
                
                if(IS_IPAD)
                    [appDelegate.masterViewController addOverlayController:accountSettingsVC animated:YES];
                else
                    [wself.parentViewController.navigationController pushViewController:accountSettingsVC animated:YES];
                
                
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
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        
        
    }];
    
}

-(void)dealloc
{
    self.completeBlock = nil;
}

@end
