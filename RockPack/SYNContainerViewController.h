//
//  SYNBottomTabViewController.h
//  RockPack
//
//  Created by Nick Banks on 13/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

/* 
 SYNContainerViewController
 Container initilises all the navigation controllers i.e feed, profile, activity etc..
 */
 
@import UIKit;

@interface SYNContainerViewController : UIViewController

@property (nonatomic, readonly) UINavigationController *currentViewController;
@property (nonatomic, readonly) NSArray* viewControllers;

-(void)navigateToPage:(NSInteger)index;

-(NSInteger)indexOfControllerByName: (NSString*) pageName;

@end
