//
//  SYNAccountSettingsGender.m
//  rockpack
//
//  Created by Michael Michailidis on 18/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "AppConstants.h"
#import "GAI.h"
#import "SYNAccountSettingsGender.h"
#import "SYNAppDelegate.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNAccountSettingOtherTableViewCell.h"
#import "UIFont+SYNFont.h"

@interface SYNAccountSettingsGender ()

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UIActivityIndicatorView* spinner;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;

@end


@implementation SYNAccountSettingsGender


#pragma mark - Object lifecycle

- (id) init
{
    if ((self = [super init]))
    {        
        self.contentSizeForViewInPopover = CGSizeMake(380, 476);
        
        self.appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        self.tableView = [[UITableView alloc] initWithFrame: CGRectMake((IS_IPAD ? 1.0 : 0.0), 0.0, (IS_IPAD ? 378 : 320.0), 200.0) style: UITableViewStyleGrouped];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.opaque = NO;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundView = nil;
        self.tableView.scrollEnabled = NO;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        self.appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
        CGRect spinnerFrame = self.spinner.frame;
        spinnerFrame.origin.y = self.tableView.frame.origin.y + self.tableView.frame.size.height + 20.0;
        spinnerFrame.origin.x = self.tableView.frame.size.width * 0.5 - spinnerFrame.size.width * 0.5;
        self.spinner.frame = CGRectIntegral(spinnerFrame);
        [self.view addSubview: self.spinner];
    }
    
    return self;
}


- (void) dealloc
{
    // Defensive programming
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
                                                            label: @"Gender"
                                                            value: nil] build]];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier: @"Cell"];
    
    UIButton *backButton = [UIButton buttonWithType: UIButtonTypeCustom];
    UIImage* backButtonImage = [UIImage imageNamed: @"ButtonAccountBackDefault.png"];
    UIImage* backButtonHighlightedImage = [UIImage imageNamed: @"ButtonAccountBackHighlighted.png"];

    
    [backButton setImage: backButtonImage
                forState: UIControlStateNormal];
    
    [backButton setImage: backButtonHighlightedImage
                forState: UIControlStateHighlighted];
    
    [backButton addTarget: self
                   action: @selector(didTapBackButton:)
         forControlEvents: UIControlEventTouchUpInside];
    
    backButton.frame = CGRectMake(0.0, 0.0, backButtonImage.size.width, backButtonImage.size.height);
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView: backButton];
    
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame: CGRectMake( -(self.contentSizeForViewInPopover.width * 0.5), -15.0, self.contentSizeForViewInPopover.width, 40.0)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor colorWithRed: (28.0/255.0) green: (31.0/255.0) blue: (33.0/255.0) alpha: (1.0)];
    titleLabel.text = NSLocalizedString (@"settings_popover_gender_title", nil);
    titleLabel.font = [UIFont boldRockpackFontOfSize:18.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.shadowColor = [UIColor whiteColor];
    titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    
    
    UIView * labelContentView = [[UIView alloc]init];
    [labelContentView addSubview:titleLabel];
    
    self.navigationItem.titleView = labelContentView;
}


- (void) didTapBackButton: (id) sender
{
    if (self.navigationController.viewControllers.count > 1)
    {
        [self.navigationController popViewControllerAnimated: YES];
    }
}


#pragma mark - TableView DataSource/Delegate

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
    
    
    if (indexPath.row == 0)
    {
        if (self.appDelegate.currentUser.genderValue == GenderMale)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
        
        cell.textLabel.text = NSLocalizedString (@"Male", nil);
    }
    else if (indexPath.row == 1)
    {
        if (self.appDelegate.currentUser.genderValue == GenderFemale)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
        
        cell.textLabel.text = NSLocalizedString (@"Female", nil);
    }
    
    cell.textLabel.font = [UIFont rockpackFontOfSize:16.0];
    
    return cell;
}


#pragma mark - Table view delegate

- (void) tableView: (UITableView *) tableView
         didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath: indexPath];
    if(cell.accessoryType == UITableViewCellAccessoryCheckmark) // if it is already selected, return.
        return;
    
    
    [[self.tableView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ((UITableViewCell*)obj).accessoryType = UITableViewCellAccessoryNone;
    }];
    
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [self changeUserGenderForValue:( indexPath.row == 0 ? @"m" : @"f")];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    [self.spinner startAnimating];
    
}


- (void) changeUserGenderForValue: (NSString*) newGender
{
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [self.appDelegate.oAuthNetworkEngine changeUserField: @"gender"
                                                 forUser: self.appDelegate.currentUser
                                            withNewValue: newGender
                                       completionHandler: ^ (NSDictionary * dictionary){
                                           if([newGender isEqualToString: @"m"])
                                           {
                                               self.appDelegate.currentUser.gender = @(GenderMale);

                                               [tracker set: [GAIFields customDimensionForIndex: kGADimensionGender]
                                                      value: @"male"];
                                           }
                                           else if([newGender isEqualToString: @"f"])
                                           {
                                               self.appDelegate.currentUser.gender = @(GenderFemale);
                                               
                                               [tracker set: [GAIFields customDimensionForIndex: kGADimensionGender]
                                                      value: @"female"];
                                           }
                                           else
                                           {
                                               self.appDelegate.currentUser.gender = @(GenderUndecided);
                                               
                                               [tracker set: [GAIFields customDimensionForIndex: kGADimensionGender]
                                                      value: @"unknown"];
                                           }
                                           
                                           [self.appDelegate saveContext: YES];
                                           
                                           [self.spinner stopAnimating];
                                           
                                           [self.navigationController popViewControllerAnimated: YES];
                                           
                                       }
                                            errorHandler: ^(id errorInfo) {
                                                [self.spinner stopAnimating];
                                            }];
}

@end
