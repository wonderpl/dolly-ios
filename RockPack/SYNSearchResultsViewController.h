//
//  SYNSearchResultsViewController.h
//  dolly
//
//  Created by Michael Michailidis on 21/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAbstractViewController.h"
#import "SYNSocialActionsDelegate.h"
#import "SYNVideoCellDelegate.h"

typedef enum {
    SearchResultsShowingVideos = 0,
    SearchResultsShowingUsers
} SearchResultsShowing;

@interface SYNSearchResultsViewController : SYNAbstractViewController <SYNSocialActionsDelegate, SYNVideoCellDelegate>

@property (nonatomic, strong) IBOutlet UIButton* videosTabButton;
@property (nonatomic, strong) IBOutlet UIButton* usersTabButton;

@property (nonatomic, strong) IBOutlet UICollectionView* videosCollectionView;
@property (nonatomic, strong) IBOutlet UICollectionView* usersCollectionView;

@property (nonatomic, readonly) SearchResultsShowing searchResultsShowing;

- (void) searchForTerm: (NSString *) newSearchTerm ;
- (void) searchForGenre: (NSString *) genreId;


@end
