//
//  SYNSocialActionsDelegate.h
//  dolly
//
//  Created by Michael Michailidis on 28/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SYNSocialActionsDelegate <NSObject>

-(void)followControlPressed:(UIControl*)control;
-(void)shareControlPressed:(UIControl*)control;
-(void)likeControlPressed:(UIControl*)control;
-(void)addControlPressed:(UIControl*)control;

@end
