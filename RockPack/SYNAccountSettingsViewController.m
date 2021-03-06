//
//  SYNAccountSettingsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 18/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//


#import "AppConstants.h"
#import "NSString+Utils.h"
#import "SYNAccountSettingTableViewCell.h"
#import "SYNAccountSettingOtherTableViewCell.h"
#import "SYNAccountSettingsDOB.h"
#import "SYNAccountSettingsEmail.h"
#import "SYNAccountSettingsFullNameInput.h"
#import "SYNAccountSettingsGender.h"
#import "SYNAccountSettingsLocation.h"
#import "SYNAccountSettingsViewController.h"
#import "SYNAccountSettingsPassword.h"
#import "SYNAccountSettingBasicController.h"
#import "SYNAccountSettingsUsername.h"
#import "SYNMasterViewController.h"
#import "SYNAppDelegate.h"
#import "UIFont+SYNFont.h"
#import "User.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+SYNColor.h"
#import "SYNTrackingManager.h"

@interface SYNAccountSettingsViewController ()

@property (nonatomic, strong) UIPopoverController* dobPopover;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;
@property (nonatomic, weak) UITableViewCell* dobTableViewCell;


@property (nonatomic, weak) User* user;
@property (nonatomic, strong) IBOutlet UITableView* tableView;

@end


@implementation SYNAccountSettingsViewController

@synthesize appDelegate, user;

#pragma mark - Object lifecycle


-(void)finishingPresentation
{
    self.dobPopover.delegate = nil;
}


-(void)startingPresentation
{
    
}

#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    user = appDelegate.currentUser;
    
    self.title = NSLocalizedString (@"settings_popover_title" , nil);
    
    self.tableView.scrollEnabled = IS_IPHONE;
    self.tableView.scrollsToTop = NO;
}

- (void) viewWillAppear: (BOOL) animated {
    [super viewWillAppear: animated];
    
    [self.tableView reloadData];
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[SYNTrackingManager sharedManager] trackAccountSettingsScreenView];
}


#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 2;
}


- (NSInteger) tableView: (UITableView *) tableView
  numberOfRowsInSection: (NSInteger) section
{
    if (section == 0)
    {
        // first section
        return 6;
    }
    else
    {
        // Change Passwork
        return 1;
    }
    
}


- (UITableViewCell *) tableView: (UITableView *) tableView
          cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0)
    {
        static NSString *CellIdentifier = @"Section0Cell";
        cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
        
        if(!cell)
        {
            cell = [[SYNAccountSettingTableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                                         reuseIdentifier: CellIdentifier];
        }
        
        switch (indexPath.row)
        {
            // First and Last Name
            case 0:
                
                cell.imageView.image = [UIImage imageNamed: @"IconFullname.png"];
                cell.textLabel.text = [user.fullName length] ? user.fullName : NSLocalizedString(@"full_name", nil);
                cell.detailTextLabel.text = user.fullNameIsPublicValue ? NSLocalizedString (@"Public" , nil) : NSLocalizedString (@"Private" , nil);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                break;
                
            // Username
            case 1:
                cell.imageView.image = [UIImage imageNamed: @"IconUsername.png"];
                cell.textLabel.text = user.username;
                cell.detailTextLabel.text = NSLocalizedString (@"Public", nil);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            // Email
            case 2:
                if ([user.emailAddress isEqualToString:@""])
                {
                    cell.textLabel.text = @"Email Address";
                }
                else
                {
                    cell.textLabel.text = user.emailAddress;
                }
                cell.imageView.image = [UIImage imageNamed: @"IconEmail.png"];
                cell.detailTextLabel.text = NSLocalizedString (@"Email - Private", nil);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            // Locale
            // We only support these 2 locales currently. 
            case 3:
                if ([user.locale isEqualToString:@"en-gb"])
                {
                    cell.textLabel.text = NSLocalizedString (@"United Kingdom", nil);
                }
                else
                {
                    cell.textLabel.text = NSLocalizedString (@"United States", nil);
                }
                
                cell.detailTextLabel.text = @"Location";
                cell.imageView.image = [UIImage imageNamed: @"IconLocation.png"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            // Gender
            case 4:
                if (user.genderValue == GenderUndecided)
                {
                    cell.textLabel.text = NSLocalizedString (@"Gender", nil);
                }
                else
                {
                    cell.textLabel.text = [user.gender isEqual: @(GenderMale)] ? @"Male" : @"Female";
                }
                
                cell.detailTextLabel.text = NSLocalizedString (@"Gender - Private", nil);
                cell.imageView.image = [UIImage imageNamed :@"IconGender.png"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            // DOB
            case 5:
                if (!user.dateOfBirth)
                    cell.textLabel.text = NSLocalizedString (@"Date of Birth", nil);
                else
                    cell.textLabel.text = [self getDOBPlainString:user.dateOfBirth];
                
                self.dobTableViewCell = cell;
                cell.detailTextLabel.text = NSLocalizedString (@"D.O.B Private", nil);
                cell.imageView.image = [UIImage imageNamed: @"IconBirthday.png"];
                break;
                
        }
        
        cell.textLabel.font = [UIFont lightCustomFontOfSize: 16.0];
        cell.detailTextLabel.font = [UIFont lightCustomFontOfSize: 12.0];
        cell.textLabel.backgroundColor = [UIColor clearColor];
    }
    else
    {
        static NSString *CellIdentifier = @"OtherSectionCell";
        cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
        
        if (!cell)
        {
            cell = [[SYNAccountSettingOtherTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                                         reuseIdentifier: CellIdentifier];
        }
        
        cell.textLabel.text = NSLocalizedString (@"Change Password", nil);
        cell.textLabel.font = [UIFont lightCustomFontOfSize:16.0];
        cell.textLabel.center = CGPointMake(0, 0);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void) tableView: (UITableView *) tableView
         didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    if (indexPath.section == 0)
    {
        switch (indexPath.row)
        {
                
            case 0:
                [self.navigationController pushViewController: [[SYNAccountSettingsFullNameInput alloc] initWithUserFieldType:UserFieldTypeFullName]
                                                     animated: YES];
                break;
                
            case 1:
                [self.navigationController pushViewController: [[SYNAccountSettingsUsername alloc] initWithUserFieldType:UserFieldTypeUsername]
                                                     animated: YES];
                
                break;
                
            case 2:
                [self.navigationController pushViewController: [[SYNAccountSettingsEmail alloc] initWithUserFieldType:UserFieldTypeEmail]
                                                     animated: YES];
                break;
                
            case 3:
                [self.navigationController pushViewController: [[SYNAccountSettingsLocation alloc] init]
                                                     animated: YES];
                break;
            
            case 4:
                [self.navigationController pushViewController: [[SYNAccountSettingsGender alloc] init]
                                                     animated: YES];
                break;
                
            case 5:
            {
                SYNAccountSettingsDOB* dobController = [[SYNAccountSettingsDOB alloc] init];
                
                [dobController.datePicker addTarget: self
                                             action: @selector(datePickerValueChanged:)
                                   forControlEvents: UIControlEventValueChanged];
                
                NSDate* date = [NSDate date];
                
                if (appDelegate.currentUser.dateOfBirth)
                {
                    date = appDelegate.currentUser.dateOfBirth;
                }
                
                [dobController.datePicker setDate:date];
                
                if (IS_IPAD)
                {
                    if(self.dobPopover)
                        return;

                    // wrap into a nav controller so as to display the title
                    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController: dobController];
                    
                    
                    self.dobPopover = [[UIPopoverController alloc] initWithContentViewController: navigationController];
                    self.dobPopover.popoverContentSize = dobController.datePicker.frame.size;
                    self.dobPopover.delegate = self;
                    
                    
                    [self.dobPopover presentPopoverFromRect: self.dobTableViewCell.frame
                                                     inView: self.tableView
                                   permittedArrowDirections: UIPopoverArrowDirectionDown
                                                   animated: YES];
                }
                else
                {
                    [self.navigationController pushViewController: dobController
                                                         animated: YES];
                }
            }
            break;
                
            default:
                break;  
        }
    }
    else
    {
        [self.navigationController pushViewController: [[SYNAccountSettingsPassword alloc] init] animated: YES];
    }
    
    [self.tableView deselectRowAtIndexPath: indexPath
                                  animated: YES];
}




#pragma mark - DOB 


- (void) datePickerValueChanged: (UIDatePicker*) datePicker
{
	[[SYNTrackingManager sharedManager] trackAccountPropertyChanged:@"Date of birth"];
	
    NSString* dateString = [self getDOBFormattedString:datePicker.date];
    
    UIActivityIndicatorView* dobLoader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [dobLoader setColor:[UIColor dollyActivityIndicator]];
    self.dobTableViewCell.accessoryView = dobLoader;
    
    [dobLoader startAnimating];
    
    [self.appDelegate.oAuthNetworkEngine changeUserField: @"date_of_birth"
                                                 forUser: self.appDelegate.currentUser
                                            withNewValue: dateString
                                       completionHandler: ^ (NSDictionary * dictionary){
                                           user.dateOfBirth = datePicker.date;
                                           self.dobTableViewCell.textLabel.text = [self getDOBPlainString: user.dateOfBirth];
                                           [dobLoader stopAnimating];
                                           [dobLoader removeFromSuperview];
										   [[SYNTrackingManager sharedManager] setAgeDimensionFromBirthDate:datePicker.date];
                                       }
                                            errorHandler: ^(NSDictionary* errorInfo) {
                                                NSString *errorMessage = [errorInfo[@"message"][0] stringByReplacingOccurrencesOfString:@"Rockpack" withString:@"Wonder PL"];
                                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Opps" message:errorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                                [alert show];
                                                [dobLoader stopAnimating];
                                                [dobLoader removeFromSuperview];
                                            }];
	
}


-(NSString*)getDOBPlainString:(NSDate*)date
{
    if(!date) return nil;
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    return [dateFormatter stringFromDate:date];
}

-(NSString*) getDOBFormattedString:(NSDate*)date
{
    if(!date) return nil;
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    
    return [dateFormatter stringFromDate:date];
}

- (void) popoverControllerDidDismissPopover: (UIPopoverController *) popoverController
{
    if (popoverController == self.dobPopover)
    {
        self.dobPopover = nil;
    }
}

@end
