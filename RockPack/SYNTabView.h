//
//  SYNTabView.h
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import UIKit;
#import "SYNTabViewDelegate.h"

@interface SYNTabView : UIView <SYNTabViewDelegate>

@property (nonatomic, weak) id<SYNTabViewDelegate> tapDelegate;

- (id) initWithSize: (CGFloat) totalWidth;
- (void) createCategoriesTab: (NSArray*) categories;
- (void) createSubcategoriesTab: (NSArray*) subcategories;
- (void) setSelectedWithId: (NSString*) selectedId;

/**
	triggers a re-layout of the tab view to suit the selected orientation.
 
    Override in subclass with implementation
	@param orientation orientation to adapt to.
 */

- (void) refreshViewForOrientation: (UIInterfaceOrientation) orientation;


@end
