//
//  SYNCategoriesTabView.h
//  rockpack
//
//  Created by Michael Michailidis on 12/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNTabView.h"
#import "SYNTabViewDelegate.h"
@import UIKit;


@class Genre;

@interface SYNGenreTabView : SYNTabView


- (id) initWithSize: (CGFloat) totalWidth
      andHomeButton: (NSString*) homeButtonString;

- (void) hideSecondaryTabs;
- (void) showSecondaryTabs;

-(void) deselectAll;
-(void)highlightTabWithGenre:(Genre*)genreSelected;

@end
