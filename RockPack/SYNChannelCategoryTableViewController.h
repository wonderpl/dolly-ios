//
//  SYNChannelCategoryTableViewController.h
//  rockpack
//
//  Created by Mats Trovik on 23/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import UIKit;
#import "SYNTabViewDelegate.h"

#define kCategoryNameKey  @ "CategoryName"
#define kSubCategoriesKey @ "SubCategory"

@class SYNChannelCategoryTableViewController;
@class Genre;

@protocol SYNChannelCategoryTableViewDelegate <NSObject>

@optional
/**
 Callback method triggered when the user selects a category header
 @param tableController the controller that the user interacted with
 @param genre the core data object for the selected category.
 */
- (void) categoryTableController: (SYNChannelCategoryTableViewController *) tableController didSelectCategory: (Genre *) category;


/**
 Callback method triggered when the user selects a sub category cell
 
 Alternatively, if a confirm button was added through a xib, pressing it will fire this callback.
 @param tableController the controller that the user interacted with
 @param subCategory the core data object for the selected sub category.
 
 */
- (void) categoryTableController: (SYNChannelCategoryTableViewController *) tableController didSelectSubCategory: (SubGenre *) subCategory;

/**
 fires when the user selects the "All categories" header.
 
 Alternatively, if a closebutton was added through a nib, pressing it will fire this callback.
 @param tableController the controller that the user interacted with
 */
- (void) categoryTableControllerDeselectedAll: (SYNChannelCategoryTableViewController *) tableController;


@end

@interface SYNChannelCategoryTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<SYNChannelCategoryTableViewDelegate> categoryTableControllerDelegate;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
/**
 toggles the showing of an "All categories" cell or an "Other" category cell at the top of the list
 
 set to YES by default
 */
@property (nonatomic, assign) BOOL showAllCategoriesHeader;

/**
 the genre representing the "Other" category. Set when the view is loaded. nil if not available.
 */
@property (nonatomic, strong) Genre *otherGenre;

/**
 Pre-select a category based on its ID
 @param selectedCategoryId the category ID. passing nil will select the "Other" button
 */
- (void) setSelectedCategoryForId: (NSString *) selectedCategoryId;




@end
