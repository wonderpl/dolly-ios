//
//  SYNBottomTabViewController.h
//  RockPack
//
//  Created by Nick Banks on 13/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNAbstractViewController.h"
@import UIKit;




@interface SYNContainerViewController : UIViewController

@property (nonatomic) CGPoint currentPageOffset;

@property (nonatomic, readonly) NSInteger currentPage;
@property (nonatomic, readonly) UINavigationController *currentViewController;
@property (nonatomic, readonly) NSArray* viewControllers;
@property (nonatomic, assign) BOOL isTransitioning;


-(void)navigateToPage:(NSInteger)index;

-(NSInteger)indexOfControllerByName: (NSString*) pageName;

@end
