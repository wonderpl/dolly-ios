//
//  SYNSocialActionsDelegate.h
//  dolly
//
//  Created by Michael Michailidis on 28/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYNSocialControl.h"

@protocol SYNSocialActionsDelegate <NSObject>

-(void)followControlPressed:(SYNSocialControl*)socialControl;
-(void)shareControlPressed:(SYNSocialControl*)socialControl;
-(void)likeControlPressed:(SYNSocialControl*)socialControl;
-(void)addControlPressed:(SYNSocialControl*)socialControl;

@end
