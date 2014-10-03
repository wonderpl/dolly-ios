//
//  SYNNotificationsViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

/*
 SYNActivityViewController
 
 Activity shows user notifications. The thing of note here is the web service call is made in 2 only places
 
 applicationWillEnterForeground and viewWillAppear
 
 There are limitations here, a good solution would be to make a timed request every x minutes as this is not called enough.
*/

#import "SYNAbstractViewController.h"
@import UIKit;

@interface SYNActivityViewController : SYNAbstractViewController

@end
