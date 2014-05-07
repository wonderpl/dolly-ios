//
//  SYNNavigationManager.h
//  rockpack
//
//  Created by Michael Michailidis on 17/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

@import Foundation;

@class SYNMasterViewController, SYNContainerViewController, SYNSideNavigatorViewController;

@interface SYNNavigationManager : NSObject

@property (nonatomic, weak) SYNMasterViewController* masterController;
@property (nonatomic, weak) SYNContainerViewController* containerController;
@property (nonatomic, weak) SYNSideNavigatorViewController* sideNavigationController;

-(void)navigateToPage:(NSInteger)index;
-(void)navigateToPageByName:(NSString*)pageName;

- (void)switchToFeed;

+(id)manager;

@end
