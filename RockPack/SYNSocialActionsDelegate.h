//
//  SYNSocialActionsDelegate.h
//  dolly
//
//  Created by Michael Michailidis on 28/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SYNSocialActionsDelegate <NSObject>

-(void)followControlPressed:(id)control;
-(void)shareControlPressed:(id)control;
-(void)likeControlPressed:(id)control;
-(void)addControlPressed:(id)control;

@end
