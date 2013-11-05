//
//  SYNNotificationsViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNAbstractViewController.h"
@import UIKit;

@interface SYNActivityViewController : SYNAbstractViewController

@property (nonatomic, strong) NSArray* notifications;
@property (nonatomic, readonly) NSInteger unreadNotificationsCount;

-(void)parseNotificationsFromDictionary:(NSDictionary*)response;

@end
