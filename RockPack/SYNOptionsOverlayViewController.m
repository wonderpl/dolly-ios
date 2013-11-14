//
//  SYNOptionsOverlayViewController.m
//  dolly
//
//  Created by Michael Michailidis on 13/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNOptionsOverlayViewController.h"
#import "SYNAppDelegate.h"

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
    SYNAppDelegate* appDelegate;
}


@end

@implementation SYNOptionsOverlayViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
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
    
    switch (buttonPressed.tag)
    {
        case OptionButtonTagSettings:
            
            break;
            
        case OptionButtonTagFriends:
            
            break;
            
        case OptionButtonTagAbout:
            
            break;
            
        case OptionButtonTagFeedback:
            
            break;
            
        case OptionButtonTagRate:
            
            break;
            
        case OptionButtonTagBlog:
            
            break;
            
        case OptionButtonTagHelp:
            
            break;
            
        case OptionButtonTagLogout:
            [appDelegate logout];
            break;
            
    }
}

@end
