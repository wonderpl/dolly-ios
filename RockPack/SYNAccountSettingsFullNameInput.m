//
//  SYNAccountSettingsFullNameInput.m
//  rockpack
//
//  Created by Michael Michailidis on 20/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNAccountSettingOtherTableViewCell.h"
#import "SYNAccountSettingsFullNameInput.h"
#import "SYNOAuthNetworkEngine.h"
#import "UIFont+SYNFont.h"
#import "SYNTrackingManager.h"

@interface SYNAccountSettingsFullNameInput () <UITextFieldDelegate>

@property (nonatomic) BOOL nameIsPublic;
@property (nonatomic, strong) SYNPaddedUITextField* lastNameInputField;
@property (nonatomic, strong) UITableView* tableView;

@end


@implementation SYNAccountSettingsFullNameInput



#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.nameIsPublic = self.appDelegate.currentUser.fullNameIsPublicValue;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.inputField.placeholder = @"First Name";
    
    self.lastNameInputField = [self createInputField];
    self.lastNameInputField.text = self.appDelegate.currentUser.lastName;
    self.lastNameInputField.leftViewMode = UITextFieldViewModeAlways;
    self.lastNameInputField.leftView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"IconFullname.png"]];
    self.lastNameInputField.tag = 2;
    self.lastNameInputField.delegate = self;
    
    [self.view addSubview:self.lastNameInputField];
    
    
    self.lastNameInputField.placeholder = @"Last Name";
    
    CGRect tableViewFrame = CGRectMake(0.0,
                                       self.lastNameInputField.frame.origin.y + 22.0,
                                       self.view.frame.size.width,
                                       138.0);
    
    
    self.tableView = [[UITableView alloc] initWithFrame:tableViewFrame style: UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundView = nil;
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:self.tableView];
    
    
    CGRect saveButtonRect = self.saveButton.frame;
    saveButtonRect.origin.y = self.tableView.frame.origin.y + self.tableView.frame.size.height + 10.0;
    self.saveButton.frame = saveButtonRect;
    
    
    self.errorLabel.center = CGPointMake(self.errorLabel.center.x, self.saveButton.center.y + 60.0);
    self.errorLabel.frame = CGRectIntegral(self.errorLabel.frame);
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.lastNameInputField.delegate = nil;
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
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
    
    cell.textLabel.font = [UIFont lightCustomFontOfSize:16.0];
    
    
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
	
	[[SYNTrackingManager sharedManager] trackAccountPropertyChanged:@"Full name"];
    
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
