//
//  SYNAutocompleteViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 15/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SYNSearchBoxView.h"

@interface SYNSearchBoxViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate>

@property (nonatomic, readonly) SYNSearchBoxView* searchBoxView;
@property (nonatomic, weak, readonly) UITextField* searchTextField;

- (void) clear;
-(void)presentSearchCategoriesIPhone;
-(void)dismissSearchCategoriesIPhone;
@end
