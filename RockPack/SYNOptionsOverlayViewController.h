//
//  SYNOptionsOverlayViewController.h
//  dolly
//
//  Created by Michael Michailidis on 13/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNPopoverable.h"
#import "SYNProfileDelegate.h"

@interface SYNOptionsOverlayViewController : UIViewController <SYNPopoverable>


@property (weak, nonatomic) id<SYNProfileDelegate> delegate;

-(void)removeFromScreen;

@end
