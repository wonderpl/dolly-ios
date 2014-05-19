//
//  UIViewController+PresentNotification.m
//  dolly
//
//  Created by Cong on 08/05/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "UIViewController+PresentNotification.h"
#import "SYNDeviceManager.h"

@implementation UIViewController (PresentNotification)

- (void) presentNotificationWithMessage : (NSString*) message andType:(NotificationMessageType)type {
    
    
    SYNNetworkMessageView *networkMessageView = [[SYNNetworkMessageView alloc] initWithMessageType:type];
    
    
    [networkMessageView setText: message];
	
	[self.view addSubview: networkMessageView];

    CGRect newFrame = networkMessageView.frame;
    newFrame.origin.y = [SYNDeviceManager.sharedInstance currentScreenHeight] - newFrame.size.height;
    
    if (IS_IPHONE) {
        newFrame.origin.y-=newFrame.size.height-2;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        networkMessageView.frame = newFrame;
        
    } completion:^(BOOL finished) {
       
        if (type == NotificationMessageTypeSuccess)
        {
            [UIView animateWithDuration: 0.3f
                                  delay: 2.0f
                                options: UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState
                             animations: ^{
                                 
                                 CGRect messgaeViewFrame = networkMessageView.frame;
                                 messgaeViewFrame.origin.y = [SYNDeviceManager.sharedInstance currentScreenHeight]; // push to the bottom
                                 networkMessageView.frame = messgaeViewFrame;
                                 
                             }
                             completion: ^(BOOL finished) {
                                 [networkMessageView removeFromSuperview];
                             }];
        }

    }];
}




@end
