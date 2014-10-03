//
//  SYNSearchViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 15/10/2013.
//  Copyright (c) 2013 Wonder PL Ltd. All rights reserved.
//

/* SYNDiscoverViewController
 
 The IPad discover screen has a container view controller called SYNSearchResultsViewController.
 
 SYNPagingModel
 Paging model to store fetched lists.
 To use create a model and implementing loadItemsForRange and viewForSupplementaryElementOfKind in the paging collection.
 
 if ([self.model hasMoreItems]) {
	self.footerView.showsLoading = YES;
	[self.model loadNextPage];
 }
 
 Example in SYNProfileChannelViewController.

 */

#import "SYNAbstractViewController.h"

@interface SYNDiscoverViewController : SYNAbstractViewController

@end
