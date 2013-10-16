//
//  SYNFriendsViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 22/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNAbstractViewController.h"

@interface SYNFriendsViewController : SYNAbstractViewController <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView* friendsCollectionView;
@property (nonatomic, strong) IBOutlet UILabel* preLoginLabel;
@property (nonatomic, strong) IBOutlet UIButton* facebookLoginButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* activityIndicator;
@property (nonatomic, strong) IBOutlet UITextField* searchField;

@property (nonatomic, strong) IBOutlet UIButton* onFacebookButton;
@property (nonatomic, strong) IBOutlet UIButton* onRockpackButton;

@property (nonatomic, strong) IBOutlet UILabel* followInviteLabel;

-(IBAction)facebookLoginPressed:(id)sender;

-(void)addSearchBarToView:(UIView*)view;

@end
