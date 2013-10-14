//
//  SYNAccountSettingsLocation.m
//  rockpack
//
//  Created by Michael Michailidis on 21/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "GAI.h"
#import "SYNAccountSettingOtherTableViewCell.h"
#import "SYNAccountSettingsLocation.h"
#import "SYNAppDelegate.h"
#import "SYNOAuthNetworkEngine.h"
#import "UIFont+SYNFont.h"
#import "User.h"

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

- (id) init
{
    if (self = [super init])
    {
        self.contentSizeForViewInPopover = CGSizeMake(380, 476);

        CGRect tableViewFrame = CGRectMake((IS_IPAD ? 1.0 : 0.0), 0.0, (IS_IPAD ? 378.0 : 320.0), 200.0);
        self.tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStyleGrouped];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.opaque = NO;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundView = nil;
        self.tableView.scrollEnabled = NO;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        self.user = appDelegate.currentUser;
        
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        CGRect spinnerFrame = self.spinner.frame;
        spinnerFrame.origin.y = self.tableView.frame.origin.y + self.tableView.frame.size.height + 20.0;
        spinnerFrame.origin.x = self.tableView.frame.size.width * 0.5 - spinnerFrame.size.width * 0.5;
        self.spinner.frame = CGRectIntegral(spinnerFrame);
        [self.view addSubview:self.spinner];
    }
    
    return self;
}


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
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;

    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"accountPropertyChanged"
                                                            label: @"Location"
                                                            value: nil] build]];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    [self.view addSubview:self.tableView];
	
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
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
    titleLabel.text = NSLocalizedString (@"settings_popover_location_title", nil);
    titleLabel.font = [UIFont boldRockpackFontOfSize:18.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.shadowColor = [UIColor whiteColor];
    titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    
    
    UIView * labelContentView = [[UIView alloc]init];
    [labelContentView addSubview:titleLabel];
    
    self.navigationItem.titleView = labelContentView;
    
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
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
    
    cell.textLabel.font = [UIFont rockpackFontOfSize:16.0];
    
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

-(void)changeUserLocaleForValue:(NSString*)newLocale
{
    __weak SYNAccountSettingsLocation* wself = self;
    [self.appDelegate.oAuthNetworkEngine changeUserField:@"locale"
                                                 forUser:appDelegate.currentUser
                                            withNewValue:newLocale
                                       completionHandler:^ (NSDictionary * dictionary){
                                           
                                           appDelegate.currentUser.locale = newLocale;
                                           
                                           [spinner stopAnimating];
                                           
                                           [appDelegate clearCoreDataMainEntities:NO];
                                           
                                           
                                           [wself.navigationController popViewControllerAnimated:YES];
                                           
                                       } errorHandler:^(id errorInfo) {
                                           
                                           
                                           [self.spinner stopAnimating];
                                           
                                           
                                           
                                       }];
}

@end
