//
//  UIViewController+PresentNotification.h
//  dolly
//
//  Created by Cong on 08/05/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNNetworkMessageView.h"

@interface UIViewController (PresentNotification)

- (void) presentNotificationWithMessage : (NSString*) message andType:(NotificationMessageType)type;


@end
