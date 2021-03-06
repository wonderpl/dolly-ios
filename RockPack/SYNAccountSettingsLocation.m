//
//  SYNAccountSettingsLocation.m
//  rockpack
//
//  Created by Michael Michailidis on 21/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNAccountSettingOtherTableViewCell.h"
#import "SYNAccountSettingsLocation.h"
#import "SYNAppDelegate.h"
#import "SYNOAuthNetworkEngine.h"
#import "UIFont+SYNFont.h"
#import "UIColor+SYNColor.h"
#import "SYNMasterViewController.h"
#import "SYNTrackingManager.h"
#import "User.h"
#import "SYNGenreManager.h"

@interface SYNAccountSettingsLocation ()

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, weak) User* user;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;
@property (nonatomic, strong) UIActivityIndicatorView* spinner;

@end

@implementation SYNAccountSettingsLocation
@synthesize appDelegate;
@synthesize spinner;

#pragma mark - Object lifecycle



- (void) dealloc
{
    // Defensive programming
    self.tableView.delegate = nil;
    self.tableView.dataSource = self;
}


#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    // == Table View == //
    CGRect tableViewFrame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 200.0);
    self.tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundView = nil;
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    [self.view addSubview:self.tableView];
	
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.user = appDelegate.currentUser;
    
    // == Spinner == //
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGRect spinnerFrame = self.spinner.frame;
    spinnerFrame.origin.y = self.tableView.frame.origin.y + self.tableView.frame.size.height + 20.0;
    spinnerFrame.origin.x = self.tableView.frame.size.width * 0.5 - spinnerFrame.size.width * 0.5;
    [self.spinner setColor:[UIColor dollyActivityIndicator]];
    self.spinner.frame = CGRectIntegral(spinnerFrame);
    [self.view addSubview:self.spinner];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;
    cell = [[SYNAccountSettingOtherTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                                      reuseIdentifier: CellIdentifier];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.row == 0)
    {
        cell.textLabel.text = NSLocalizedString (@"United States", nil);
        if([self.user.locale isEqualToString: @"en-us"])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else if(indexPath.row == 1)
    {
        cell.textLabel.text = NSLocalizedString (@"United Kingdom", nil);
        if ([self.user.locale isEqualToString: @"en-gb"])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    cell.textLabel.font = [UIFont lightCustomFontOfSize:16.0];
    
    return cell;
}

- (void) didTapBackButton:(id)sender {
    if(self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath: indexPath];
    if(cell.accessoryType == UITableViewCellAccessoryCheckmark) // if it is already selected, return.
        return;
    
    
    
    [[self.tableView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ((UITableViewCell*)obj).accessoryType = UITableViewCellAccessoryNone;
    }];
    
    [self changeUserLocaleForValue:(indexPath.row == 1) ? @"en-gb" : @"en-us"];
    
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [self.spinner startAnimating];
}

- (void)changeUserLocaleForValue:(NSString*)newLocale {
	[[SYNTrackingManager sharedManager] trackAccountPropertyChanged:@"Location"];
	
    __weak SYNAccountSettingsLocation* wself = self;
    [self.appDelegate.oAuthNetworkEngine changeUserField:@"locale"
                                                 forUser:appDelegate.currentUser
                                            withNewValue:newLocale
                                       completionHandler:^ (NSDictionary * dictionary){
                                           
                                           appDelegate.currentUser.locale = newLocale;
                                           
                                           // This is not currently needed on Wonder because we don't change the data between locales
                                           if (0) {
                                               [appDelegate clearCoreDataMainEntities:NO];

                                               [[SYNGenreManager sharedManager] fetchGenresWithCompletion:^(NSArray *results) {
                                                   [spinner stopAnimating];
                                                   [wself.navigationController popViewControllerAnimated:YES];
                                               }];
                                           } else {
                                               [spinner stopAnimating];
                                               [wself.navigationController popViewControllerAnimated:YES];
                                           }
										   
                                       } errorHandler:^(id errorInfo) {
                                           
                                           
                                           [self.spinner stopAnimating];
                                           
                                           
                                           
                                       }];
}

@end
