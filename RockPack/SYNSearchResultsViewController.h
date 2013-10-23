//
//  SYNSearchResultsViewController.h
//  dolly
//
//  Created by Michael Michailidis on 21/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAbstractViewController.h"

@interface SYNSearchResultsViewController : SYNAbstractViewController

@property (nonatomic, strong) IBOutlet UIButton* videosTabButton;
@property (nonatomic, strong) IBOutlet UIButton* usersTabButton;

@property (nonatomic, strong) IBOutlet UICollectionView* videosCollectionView;
@property (nonatomic, strong) IBOutlet UICollectionView* usersCollectionView;

@end
