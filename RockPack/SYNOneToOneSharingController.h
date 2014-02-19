//
//  SYNOneToOneSharingController.h
//  rockpack
//
//  Created by Michael Michailidis on 28/08/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

@import UIKit;

@interface SYNOneToOneSharingController : UIViewController

@property (nonatomic, readonly) UISearchBar* searchBar;

- (id) initWithInfo: (NSMutableDictionary *) mutableInfoDictionary;

- (NSString *)shareType;

@end
