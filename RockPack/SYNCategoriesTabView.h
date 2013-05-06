//
//  SYNCategoriesTabView.h
//  rockpack
//
//  Created by Michael Michailidis on 12/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNTabViewDelegate.h"
#import "SYNTabView.h"

@interface SYNCategoriesTabView : SYNTabView

- (id) initWithSize: (CGFloat) totalWidth
      andHomeButton: (BOOL) useHomeButton;

- (void) hideSecondaryTabs;

@end
