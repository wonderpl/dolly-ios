//
//  SYNAccountSettingsFullNameInput.m
//  rockpack
//
//  Created by Michael Michailidis on 20/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "GAI.h"
#import "SYNAccountSettingOtherTableViewCell.h"
#import "SYNAccountSettingsFullNameInput.h"
#import "SYNOAuthNetworkEngine.h"
#import "UIFont+SYNFont.h"

@interface SYNAccountSettingsFullNameInput () <UITextFieldDelegate>

@property (nonatomic) BOOL nameIsPublic;
@property (nonatomic, strong) SYNPaddedUITextField* lastNameInputField;
@property (nonatomic, strong) UITableView* tableView;

@end


@implementation SYNAccountSettingsFullNameInput

#pragma mark - Object lifecycle

- (void) dealloc
{
    // Defensive programming
    self.inputField.delegate = nil;
    self.lastNameInputField.delegate = nil;
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}


#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"accountPropertyChanged"
                                                            label: @"Full name"
                                                            value: nil] build]];
    
    self.view.backgroundColor = [UIColor whiteColor];

    self.inputField.tag =1 ;
    self.inputField.delegate = self;
    
    self.lastNameInputField = [self createInputField];
    self.lastNameInputField.text = self.appDelegate.currentUser.lastName;
    self.lastNameInputField.leftViewMode = UITextFieldViewModeAlways;
    self.lastNameInputField.leftView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"IconFullname.png"]];
    self.lastNameInputField.tag = 2;
    self.lastNameInputField.delegate = self;
    
    [self.scrollView addSubview:self.lastNameInputField];
    
    self.tableView = [[UITableView alloc] initWithFrame: CGRectMake((IS_IPAD ? 1.0 : 0.0),
                                                                    self.lastNameInputField.frame.origin.y + 42.0,
                                                                    (IS_IPAD ? 378.0 : 320.0),
                                                                    126.0) style: UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundView = nil;
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.scrollView addSubview:self.tableView];
    
    
    CGRect saveButtonRect = self.saveButton.frame;
    saveButtonRect.origin.y = self.tableView.frame.origin.y + self.tableView.frame.size.height + 10.0;
    self.saveButton.frame = saveButtonRect;
    
    
    self.errorLabel.center = CGPointMake(self.errorLabel.center.x, self.saveButton.center.y + 60.0);
    self.errorLabel.frame = CGRectIntegral(self.errorLabel.frame);
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* backButtonImage = [UIImage imageNamed: @"ButtonAccountBackDefault.png"];
    UIImage* backButtonHighlightedImage = [UIImage imageNamed: @"ButtonAccountBackHighlighted.png"];
    
    
    [backButton setImage: backButtonImage
                forState: UIControlStateNormal];
    
    [backButton setImage: backButtonHighlightedImage
                forState: UIControlStateHighlighted];
    
    [backButton addTarget:self action:@selector(didTapBackButton:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0.0, 0.0, backButtonImage.size.width, backButtonImage.size.height);
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame: CGRectMake( -(self.contentSizeForViewInPopover.width * 0.5), -15.0, self.contentSizeForViewInPopover.width, 40.0)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor colorWithRed: (28.0/255.0) green: (31.0/255.0) blue: (33.0/255.0) alpha: (1.0)];
    titleLabel.text = NSLocalizedString (@"settings_popover_fullname_title", nil);
    titleLabel.font = [UIFont boldRockpackFontOfSize:18.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.shadowColor = [UIColor whiteColor];
    titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    
    
    UIView * labelContentView = [[UIView alloc]init];
    [labelContentView addSubview:titleLabel];
    
    self.navigationItem.titleView = labelContentView;
    
    self.nameIsPublic = self.appDelegate.currentUser.fullNameIsPublicValue;
    
    
    self.inputField.placeholder = @"First Name";
    self.lastNameInputField.placeholder = @"Last Name";
    
}


#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}


- (NSInteger) tableView: (UITableView *) tableView
  numberOfRowsInSection: (NSInteger) section
{
    return 2;
    
}


- (UITableViewCell *) tableView: (UITableView *) tableView
          cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;
    cell = [[SYNAccountSettingOtherTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                                     reuseIdentifier: CellIdentifier];
        
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.row == 0)
    {
        cell.textLabel.text = NSLocalizedString (@"Public", nil);
        if(self.nameIsPublic)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else
    {
        cell.textLabel.text = NSLocalizedString (@"Private", nil);
        if(!self.nameIsPublic)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    cell.textLabel.font = [UIFont rockpackFontOfSize:16.0];
    
    
    return cell;
}


- (void) saveButtonPressed: (UIButton*) button
{
    [self.lastNameInputField resignFirstResponder];
    [self.inputField resignFirstResponder];
    
    if ([self.inputField.text isEqualToString:self.appDelegate.currentUser.firstName] && // user did not change anything
       [self.lastNameInputField.text isEqualToString:self.appDelegate.currentUser.lastName] &&
        self.nameIsPublic == self.appDelegate.currentUser.fullNameIsPublicValue)
    {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if (![self inputIsValid:self.inputField.text] || ![self inputIsValid:self.lastNameInputField.text])
    {
        self.errorLabel.text = NSLocalizedString (@"You Have Entered Invalid Characters", nil);
        [self.spinner stopAnimating];
        self.saveButton.hidden = NO;
        return;
    }
    
    // must be done in steps as it is a series of API calls, first name first
    
    [self updateField:@"first_name" forValue:self.inputField.text withCompletionHandler:^{
        
        self.appDelegate.currentUser.firstName = self.inputField.text;
        
        // last name second
        
        [self updateField:@"last_name" forValue:self.lastNameInputField.text withCompletionHandler:^{
            
            self.appDelegate.currentUser.lastName = self.lastNameInputField.text;
            
            // in most cases this field won't change so its worth a quick check to avoid the API call if possible
            
            if(self.nameIsPublic != self.appDelegate.currentUser.fullNameIsPublicValue)
            {
                
                [self updateField:@"display_fullname" forValue:@(self.nameIsPublic) withCompletionHandler:^{
                    
                    self.appDelegate.currentUser.fullNameIsPublicValue = self.nameIsPublic;
                    
                    [self.appDelegate saveContext: YES];
                    
                    [self.navigationController popViewControllerAnimated: YES];
                    
                }];
            }
            else
            {
                [self.appDelegate saveContext: YES];
                
                [self.navigationController popViewControllerAnimated: YES];
            }
            
            
            
        }];
        
    }];
    
    
}

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    UIView* view = [self.view viewWithTag: textField.tag +1];
    if(view)
    {
        [view becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    return YES;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    self.nameIsPublic = (indexPath.row == 0) ? YES : NO ;
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.tableView reloadData]; // to show the checkmark only
}



@end
