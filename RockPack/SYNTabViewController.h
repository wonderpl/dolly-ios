//
//  SYNTabViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNGenreTabView.h"
#import "SYNTabView.h"
#import "SYNTabViewDelegate.h"
@import UIKit;

@interface SYNTabViewController : UIViewController <SYNTabViewDelegate>

@property (nonatomic, weak) id <SYNTabViewDelegate> delegate;
@property (nonatomic, readonly) SYNTabView* tabView;

- (void) setSelectedWithId: (NSString*) selectedId;

@end
