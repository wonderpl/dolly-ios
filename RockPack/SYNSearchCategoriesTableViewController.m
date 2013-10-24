//
//  SYNSearchCategoriesTableViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 13/08/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchCategoriesTableViewController.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNNetworkEngine.h"
#import "SYNAppDelegate.h"
#import "UIColor+SYNColor.h"
#import "UIFont+SYNFont.h"
#import "SYNDeviceManager.h"

static NSString *SearchGenresTableCellIdentifier = @"SYNSearchCategoriesIphoneCell";

@interface SYNSearchCategoriesTableViewController ()

@property (nonatomic, strong) NSArray* searchCategories;
@property (nonatomic) BOOL hasRetried;
@property (nonatomic, strong) UIFont* cellFont;
@property (nonatomic, strong) UIColor* cellTextColor;

@end

@implementation SYNSearchCategoriesTableViewController
@synthesize hasRetried;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.cellFont = [UIFont lightCustomFontOfSize: 16.0];
    self.cellTextColor = [UIColor colorWithRed:(106.0f/255.0f) green:(114.0f/255.0f) blue:(122.0f/255.0f) alpha:1.0f];
    
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor rockpacLedColor];
    self.tableView.backgroundColor = [UIColor colorWithRed: 241.0f/255.0f green: 241.0f/255.0f blue: 241.0f/255.0f alpha: 1.0f];
    self.tableView.scrollEnabled = !IS_IPHONE_5;
    self.tableView.scrollsToTop = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 10.0f, 0.0f);
    
    [self loadData];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    
}

-(void)loadData
{
    SYNAppDelegate *appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    NSEntityDescription *categoryEntity = [NSEntityDescription entityForName: @"Genre"
                                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
    
    [categoriesFetchRequest setEntity: categoryEntity];
    
    [categoriesFetchRequest setIncludesSubentities:NO]; // no subgenres needed
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"priority >= 0"];
    [categoriesFetchRequest setPredicate: predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"priority"
                                                                   ascending: NO];
    
    [categoriesFetchRequest setSortDescriptors: @[sortDescriptor]];
    
    categoriesFetchRequest.includesSubentities = NO;
    
    NSError *error;
    
    self.searchCategories = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                error: &error];
    
    if (self.searchCategories.count == 0 && !hasRetried) // only request once
    {
        [appDelegate.networkEngine updateCategoriesOnCompletion: ^(NSDictionary *dictionary) {
            
                BOOL registryResultOk = [appDelegate.mainRegistry registerCategoriesFromDictionary: dictionary];
            
                if (!registryResultOk)
                {
                    DebugLog(@"*** Cannot Register Genre Objects! ***");
                    return;
                }
            
                [self loadData];
            
            } onError: ^(NSError *error) {
                DebugLog(@"%@", [error debugDescription]);
            }];
        
            hasRetried = YES;
            return;
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 42.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.searchCategories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
    return nil;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.navigationManager navigateToPageByName:kChannelsViewId];
    
    
    
    
    
   
}

-(void)setSize:(CGSize)size
{
    CGRect viewRect = self.tableView.frame;
    viewRect.size = size;
    self.tableView.frame = viewRect;
    
}


@end
