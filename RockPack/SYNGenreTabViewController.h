//
//  SYNCategoriesBarViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 19/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import UIKit;

#import "SYNTabViewController.h"

@class Genre;
@interface SYNGenreTabViewController : SYNTabViewController 

/**
	The default "OTHER" option for the GenreTabViewController. Set when the view is loaded. nil if "OTHER" is not an option.
 */
@property (nonatomic, strong) Genre* otherGenre;


- (id) initWithHomeButton: (NSString*) homeButtomString;

-(void) deselectAll;
-(Genre*)selectAndReturnGenreForIndexPath:(NSIndexPath*)indexPath andSubcategories:(BOOL)subcats;
-(NSIndexPath*)findIndexPathForGenreId:(NSString*)genreId;

@end
