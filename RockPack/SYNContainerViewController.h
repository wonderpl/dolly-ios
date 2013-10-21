//
//  SYNBottomTabViewController.h
//  RockPack
//
//  Created by Nick Banks on 13/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNAbstractViewController.h"
#import <UIKit/UIKit.h>


@interface SYNContainerViewController : UIViewController

@property (nonatomic) CGPoint currentPageOffset;

@property (nonatomic, readonly) NSInteger currentPage;
@property (nonatomic, readonly) SYNAbstractViewController *currentViewController;
@property (nonatomic, readonly) NSArray* viewControllers;


-(void)navigateToPage:(NSInteger)index;
-(void)navigateToPageByName:(NSString*)pageName;

-(SYNAbstractViewController*)viewControllerByPageName: (NSString *) pageName;
-(NSInteger)indexOfControllerByName: (NSString*) pageName;





@end
