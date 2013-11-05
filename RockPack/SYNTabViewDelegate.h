//
//  SYNTabViewDelegate.h
//  rockpack
//
//  Created by Michael Michailidis on 12/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import Foundation;

@class Genre;
@class SubGenre;

@protocol SYNTabViewDelegate <NSObject>

- (void) handleMainTap: (UIView*) tab;
- (void) handleSecondaryTap: (UIView*) tab;

// general
/**
	@deprecated
 */
- (void) handleNewTabSelectionWithId: (NSString*) itemId;

- (void) handleNewTabSelectionWithGenre: (Genre*) name;

- (BOOL) showSubGenres;

@end
