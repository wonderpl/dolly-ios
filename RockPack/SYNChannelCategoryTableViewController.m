//
//  SYNChannelCategoryTableViewController.m
//  rockpack
//
//  Created by Mats Trovik on 23/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "GAI.h"
#import "Genre.h"
#import "SYNAppDelegate.h"
#import "SYNChannelCategoryTableCell.h"
#import "SYNChannelCategoryTableHeader.h"
#import "SYNChannelCategoryTableViewController.h"
#import "SYNNetworkEngine.h"
#import "SubGenre.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNChannelCategoryTableViewController ()
{
    BOOL hasRetried;
}

@property (nonatomic, strong) NSArray *categoriesDatasource;
@property (nonatomic, strong) NSMutableArray *transientDatasource;
@property (nonatomic, strong) NSIndexPath *lastSelectedIndexpath;
@property (nonatomic, strong) NSMutableDictionary *headerRegister;

@end

@implementation SYNChannelCategoryTableViewController

#pragma mark - Object Lifecycle

- (id) initWithCoder: (NSCoder *) aDecoder
{
    if ((self = [super initWithCoder: aDecoder]))
    {
        [self commonSetup];
    }
    
    return self;
}


- (id) initWithNibName: (NSString *) nibNameOrNil
                bundle: (NSBundle *) nibBundleOrNil
{
    if ((self = [super initWithNibName: nibNameOrNil
                                bundle: nibBundleOrNil]))
    {
        [self commonSetup];
    }
    
    return self;
}


- (void) commonSetup
{
    _headerRegister = [NSMutableDictionary dictionary];
    _showAllCategoriesHeader = YES;
}


- (void) dealloc
{
    // Stop observing everything
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}


#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.accessibilityLabel = @"Genre Table";
    
    [self.tableView registerNib: [UINib nibWithNibName: @"SYNChannelCategoryTableCell"
                                                bundle: [NSBundle mainBundle]]
         forCellReuseIdentifier: @"SYNChannelCategoryTableCell"];
    
    self.tableView.scrollsToTop = NO;
    
    self.titleLabel.font = [UIFont regularCustomFontOfSize: self.titleLabel.font.pointSize];
    
    if (self.showAllCategoriesHeader)
    {
        // Show all category
        SYNChannelCategoryTableHeader *topHeader = [[SYNChannelCategoryTableHeader alloc] init];
        topHeader.frame = CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 45.0f);
        [topHeader layoutSubviews];
        topHeader.titleLabel.text = NSLocalizedString(@"POPULAR", nil);
        topHeader.headerButton.tag = -1;
        topHeader.titleLabel.textColor = [UIColor whiteColor];
        
        topHeader.titleLabel.shadowColor = [UIColor colorWithWhite: 1.0f
                                                             alpha: 0.15f];
        
        topHeader.backgroundImage.image = [UIImage imageNamed: @"CategorySlideSelected"];
        
        [topHeader.headerButton addTarget: self
                                   action: @selector(tappedAllCategories:)
                         forControlEvents: UIControlEventTouchUpInside];
        
        [topHeader.headerButton addTarget: self
                                   action: @selector(pressedAllCategories:)
                         forControlEvents: UIControlEventTouchDown];
        
        [topHeader.headerButton addTarget: self
                                   action: @selector(releasedAllCategories:)
                         forControlEvents: UIControlEventTouchUpOutside];
        
        [topHeader.arrowImage removeFromSuperview];
        self.tableView.tableHeaderView = topHeader;
    }
    else
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"priority == -1"];
        
        self.otherGenre = [self fetchGenreWithPredicate: predicate
                                       includeSubGenres: NO];
        
        if (self.otherGenre)
        {
            SYNChannelCategoryTableHeader *topHeader = [[SYNChannelCategoryTableHeader alloc] init];
            topHeader.frame = CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 45.0f);
            [topHeader layoutSubviews];
            topHeader.titleLabel.text = [self.otherGenre.name uppercaseString];
            topHeader.headerButton.tag = -1;
            topHeader.backgroundImage.image = [UIImage imageNamed: @"CategorySlide"];
            
            [topHeader.headerButton addTarget: self
                                       action: @selector(tappedOtherCategory:)
                             forControlEvents: UIControlEventTouchUpInside];
            
            [topHeader.headerButton addTarget: self
                                       action: @selector(pressedOtherCategory:)
                             forControlEvents: UIControlEventTouchDown];
            
            [topHeader.headerButton addTarget: self
                                       action: @selector(releasedOtherCategorys:)
                             forControlEvents: UIControlEventTouchUpOutside];
            
            [topHeader.arrowImage removeFromSuperview];
            
            self.tableView.tableHeaderView = topHeader;
        }
    }
    
    if (self.closeButton)
    {
        [self.closeButton addTarget: self
                             action: @selector(closeButtonTapped:)
                   forControlEvents: UIControlEventTouchUpInside];
    }
    
    if (self.confirmButton)
    {
        [self.confirmButton addTarget: self
                               action: @selector(confirmButtonTapped:)
                     forControlEvents: UIControlEventTouchUpInside];
    }
    
    [self loadCategories];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(clearedLocationBoundData)
                                                 name: kClearedLocationBoundData
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(forceRefreshCategories:)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
}


#pragma mark - load data

- (void) clearedLocationBoundData
{
    hasRetried = NO;
    [self loadCategories];
    [self tappedAllCategories: nil];
}


- (void) loadCategories
{
    SYNAppDelegate *appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    NSEntityDescription *categoryEntity = [NSEntityDescription entityForName: @"Genre"
                                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
    
    [categoriesFetchRequest setEntity: categoryEntity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"priority >= 0"];
    [categoriesFetchRequest setPredicate: predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"priority"
                                                                   ascending: NO];
    
    [categoriesFetchRequest setSortDescriptors: @[sortDescriptor]];
    
    categoriesFetchRequest.includesSubentities = NO;
    
    NSError *error;
    
    self.categoriesDatasource = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                    error: &error];
    
    if (self.categoriesDatasource.count <= 0 && !hasRetried)
    {
        [appDelegate.networkEngine updateCategoriesOnCompletion: ^(NSDictionary *dictionary) {
            BOOL registryResultOk = [appDelegate.mainRegistry
                                     registerCategoriesFromDictionary: dictionary];
            
             if (!registryResultOk)
             {
                 DebugLog(@"*** Cannot Register Genre Objects! ***");
                 return;
             }
             
             [self loadCategories];
         }
         
         
         onError: ^(NSError *error) {
             DebugLog(@"%@", [error debugDescription]);
         }];
        hasRetried = YES;
        return;
    }
    else
    {
        self.transientDatasource = [NSMutableArray arrayWithCapacity: [self.categoriesDatasource count] + 1];
        
        for (Genre *category in self.categoriesDatasource)
        {
            NSMutableDictionary *categoryEntry = [NSMutableDictionary dictionaryWithObject: category.name
                                                                                    forKey: kCategoryNameKey];
            [self.transientDatasource addObject: categoryEntry];
        }
        
        [self.tableView reloadData];
    }
}


- (void) forceRefreshCategories: (NSNotification *) note
{
    SYNAppDelegate *appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    [appDelegate.networkEngine updateCategoriesOnCompletion: ^(NSDictionary *dictionary) {
        BOOL registryResultOk = [appDelegate.mainRegistry
                                 registerCategoriesFromDictionary: dictionary];
        
         if (!registryResultOk)
         {
             DebugLog(@"*** Cannot Register Genre Objects! ***");
             return;
         }
         
         [self loadCategories];
     }
     onError: ^(NSError *error) {
         DebugLog(@"%@", [error debugDescription]);
     }];
}


#pragma mark - UITableView Delegate/Data Source

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return [self.transientDatasource count];
}


- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    return [[self.transientDatasource[section] valueForKey: kSubCategoriesKey] count];
}


- (CGFloat) tableView: (UITableView *) tableView heightForHeaderInSection: (NSInteger) section
{
    return 44.0f;
}


- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    return 44.0f;
}


- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    SubGenre *subCategory = [self.transientDatasource[indexPath.section] valueForKey: kSubCategoriesKey][indexPath.row];
    SYNChannelCategoryTableCell *cell = (SYNChannelCategoryTableCell *) [tableView dequeueReusableCellWithIdentifier: @"SYNChannelCategoryTableCell"];
    
    cell.titleLabel.text = subCategory.name;
    
    return cell;
}


- (void) tableView: (UITableView *) tableView willDisplayCell: (UITableViewCell *) cell forRowAtIndexPath: (NSIndexPath *) indexPath
{
    if ([indexPath isEqual: self.lastSelectedIndexpath])
    {
        [cell setSelected: YES];
    }
}


- (UIView *) tableView: (UITableView *) tableView viewForHeaderInSection: (NSInteger) section
{
    NSDictionary *dictionary = self.transientDatasource[section];
    SYNChannelCategoryTableHeader *header = (self.headerRegister)[@(section)];
    
    if (!header)
    {
        header = [[SYNChannelCategoryTableHeader alloc] init];
        (self.headerRegister)[@(section)] = header;
    }
    
    [header layoutSubviews];
    header.titleLabel.text = dictionary[kCategoryNameKey];
    
    if ([dictionary valueForKey: kSubCategoriesKey])
    {
        header.backgroundImage.image = [UIImage imageNamed: @"CategorySlideSelected"];
        header.arrowImage.image = [UIImage imageNamed: @"IconCategorySlideChevronSelected"];
        
        if (self.lastSelectedIndexpath.row < 0)
        {
            header.titleLabel.textColor = [UIColor whiteColor];
            header.titleLabel.shadowColor = [UIColor colorWithWhite: 1.0f
                                                              alpha: 0.15f];
        }
        else
        {
            header.titleLabel.textColor = [UIColor colorWithRed: 14.0f / 255.0f
                                                          green: 67.0f / 255.0f
                                                           blue: 86.0f / 255.0f
                                                          alpha: 1.0f];
            
            header.titleLabel.shadowColor = [UIColor colorWithWhite: 0.0f
                                                              alpha: 0.15f];
        }
    }
    else
    {
        header.backgroundImage.image = [UIImage imageNamed: @"CategorySlide"];
        header.arrowImage.image = [UIImage imageNamed: @"IconCategorySlideChevron"];
        
        header.titleLabel.textColor = [UIColor colorWithRed: 106.0f / 255.0f
                                                      green: 114.0f / 255.0f
                                                       blue: 122.0f / 255.0f
                                                      alpha: 1.0f];
        
        header.titleLabel.shadowColor = [UIColor colorWithWhite: 1.0f
                                                          alpha: 0.75f];
    }
    
    [header.headerButton addTarget: self
                            action: @selector(tappedHeader:)
                  forControlEvents: UIControlEventTouchUpInside];
    
    [header.headerButton addTarget: self
                            action: @selector(pressedHeader:)
                  forControlEvents: UIControlEventTouchDown]; // make highlighted
    
    [header.headerButton addTarget: self
                            action: @selector(releasedHeader:)
                  forControlEvents: UIControlEventTouchUpOutside]; // make un-highlighted
    
    header.headerButton.tag = section;
    
    return header;
}


#pragma mark - Table view delegate

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    SubGenre *subCategory = (self.transientDatasource)[indexPath.section][kSubCategoriesKey][indexPath.row];
    
    //Callback to update content
    if (!self.confirmButton)
    {
        if ([self.categoryTableControllerDelegate respondsToSelector: @selector(categoryTableController:didSelectSubCategory:)])
        {
            [self.categoryTableControllerDelegate categoryTableController: self
                                                     didSelectSubCategory: subCategory];
        }
    }
    
    self.lastSelectedIndexpath = indexPath;
    SYNChannelCategoryTableHeader *headerView = (self.headerRegister)[@(self.lastSelectedIndexpath.section)];
    
    headerView.titleLabel.textColor = [UIColor colorWithRed: 14.0f / 255.0f
                                                      green: 67.0f / 255.0f
                                                       blue: 86.0f / 255.0f
                                                      alpha: 1.0f];
    
    headerView.titleLabel.shadowColor = [UIColor colorWithWhite: 0.0f
                                                          alpha: 0.15f];
}


#pragma mark - Table header tap callback

- (void) pressedHeader: (UIButton *) header;
{
    SYNChannelCategoryTableHeader *headerView = (self.headerRegister)[@(header.tag)];
    headerView.backgroundImage.image = [UIImage imageNamed: @"CategorySlideHighlighted"];
}

- (void) releasedHeader: (UIButton *) header
{
    SYNChannelCategoryTableHeader *headerView = (self.headerRegister)[@(header.tag)];
    NSMutableDictionary *sectionDictionary = self.transientDatasource[header.tag];
    NSArray *subCategories = sectionDictionary[kSubCategoriesKey];
    
    if (subCategories)
    {
        headerView.backgroundImage.image = [UIImage imageNamed: @"CategorySlideSelected"];
        headerView.arrowImage.image = [UIImage imageNamed: @"IconCategorySlideChevronSelected"];
    }
    else
    {
        headerView.backgroundImage.image = [UIImage imageNamed: @"CategorySlide"];
        headerView.arrowImage.image = [UIImage imageNamed: @"IconCategorySlideChevron"];
    }
}


- (void) tappedHeader: (UIButton *) header
{
    [CATransaction begin];
    
    BOOL needToOpen = !self.lastSelectedIndexpath || self.lastSelectedIndexpath.section != header.tag;
    
    if (needToOpen)
    {
        Genre *category = self.categoriesDatasource[header.tag];
        
        if ([category.subgenres count] < 1)
        {
            needToOpen = NO;
        }
        else
        {            
            [CATransaction setCompletionBlock: ^{
                NSIndexPath *topElement = [NSIndexPath indexPathForRow: 0
                                                             inSection: header.tag];
                
                // Double-check that we can actually scroll to that row
                if (!topElement || ([self tableView: self.tableView
                                          numberOfRowsInSection: header.tag] > 0))
                {
                    [self.tableView scrollToRowAtIndexPath: topElement
                                          atScrollPosition: UITableViewScrollPositionTop
                                                  animated: YES];
                }
            }];
        }
    }
    else
    {
        if (self.lastSelectedIndexpath.section == header.tag && self.lastSelectedIndexpath.row < 0)
        {
            [CATransaction setCompletionBlock: ^{
                [self.tableView setContentOffset: CGPointZero
                                        animated: YES];
            }];
        }
    }
    
    [self.tableView beginUpdates];
    
    //close previously open section
    if (self.lastSelectedIndexpath && (needToOpen || self.lastSelectedIndexpath.row < 0) )
    {
        //close previously open section
        [self closeSection: self.lastSelectedIndexpath.section];
    }
    
    if (needToOpen)
    {
        //expand new section
        [self expandSection: header.tag];
        [self deselectOtherCategory];
    }
    else
    {
        if (self.lastSelectedIndexpath.row < 0)
        {
            //Close an open cateogry and selecte the "all category" header
            self.lastSelectedIndexpath = nil;
            
            if ([self.categoryTableControllerDelegate respondsToSelector: @selector(categoryTableController:didSelectCategory:)])
            {
                [self.categoryTableControllerDelegate categoryTableController: self
                                                            didSelectCategory: nil];
            }
            
            [self tappedOtherCategory: nil];
        }
        else
        {
            //Re-select a top level category after a subcategory has been selected previously.
            SYNChannelCategoryTableHeader *headerView = (self.headerRegister)[@(self.lastSelectedIndexpath.section)];
            headerView.backgroundImage.image = [UIImage imageNamed: @"CategorySlideSelected"];
            headerView.arrowImage.image = [UIImage imageNamed: @"IconCategorySlideChevronSelected"];
            headerView.titleLabel.textColor = [UIColor whiteColor];
            
            headerView.titleLabel.shadowColor = [UIColor colorWithWhite: 1.0f
                                                                  alpha: 0.15f];
            
            [self.tableView reloadRowsAtIndexPaths: @[self.lastSelectedIndexpath]
                                  withRowAnimation: UITableViewRowAnimationNone];
            
            Genre *category = self.categoriesDatasource[self.lastSelectedIndexpath.section];
            
            self.lastSelectedIndexpath = [NSIndexPath indexPathForRow: -1
                                                            inSection: self.lastSelectedIndexpath.section];
            
            if (!self.confirmButton && [self.categoryTableControllerDelegate respondsToSelector: @selector(categoryTableController:didSelectCategory:)])
            {
                [self.categoryTableControllerDelegate categoryTableController: self
                                                            didSelectCategory: category];
            }
        }
    }
    
    [self.tableView endUpdates];
    
    [CATransaction commit];
}


- (void) expandSection: (NSInteger) section
{
    NSMutableDictionary *sectionDictionary = self.transientDatasource[section];
    
    Genre *category = self.categoriesDatasource[section];
    NSArray *newSubCategories = [category.subgenres array];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"priority > 0"];
    
    newSubCategories = [newSubCategories filteredArrayUsingPredicate: predicate];
    
    NSSortDescriptor *idSortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"priority"
                                                                     ascending: NO];
    
    newSubCategories = [newSubCategories sortedArrayUsingDescriptors: @[idSortDescriptor]];
    sectionDictionary[kSubCategoriesKey] = newSubCategories;
    (self.transientDatasource)[section] = sectionDictionary;
    
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity: [newSubCategories count]];
    
    for (int i = 0; i < [newSubCategories count]; i++)
    {
        [indexPaths addObject: [NSIndexPath indexPathForRow: i
                                                  inSection: section]];
    }
    
    [self.tableView insertRowsAtIndexPaths: indexPaths
                          withRowAnimation: UITableViewRowAnimationTop];
    
    SYNChannelCategoryTableHeader *headerView = (self.headerRegister)[@(section)];
    
    [UIView transitionWithView: headerView
                      duration: 0.25
                       options: UIViewAnimationOptionTransitionCrossDissolve
                    animations: ^{
                        headerView.titleLabel.textColor = [UIColor whiteColor];
                        headerView.titleLabel.shadowColor = [UIColor  colorWithWhite: 1.0f
                                                                               alpha: 0.15f];
                        headerView.backgroundImage.image = [UIImage imageNamed: @"CategorySlideSelected"];
                        headerView.arrowImage.image = [UIImage imageNamed: @"IconCategorySlideChevronSelected"];
                    }
     
     
                    completion: nil];
    
    //Callback to update content
    if (!self.confirmButton)
    {
        if ([self.categoryTableControllerDelegate respondsToSelector: @selector(categoryTableController:didSelectCategory:)])
        {
            [self.categoryTableControllerDelegate categoryTableController: self
                                                        didSelectCategory: category];
        }
    }
    
    self.lastSelectedIndexpath = [NSIndexPath indexPathForRow: -1
                                                    inSection: section];
}


- (void) closeSection: (NSInteger) section
{
    NSMutableDictionary *sectionDictionary = self.transientDatasource[section];
    NSArray *subCategories = sectionDictionary[kSubCategoriesKey];
    
    [sectionDictionary removeObjectForKey: kSubCategoriesKey];
    (self.transientDatasource)[section] = sectionDictionary;
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity: [subCategories count]];
    
    for (int i = 0; i < [subCategories count]; i++)
    {
        [indexPaths addObject: [NSIndexPath indexPathForRow: i
                                                  inSection: section]];
    }
    
    [self.tableView deleteRowsAtIndexPaths: indexPaths
                          withRowAnimation: UITableViewRowAnimationTop];
    
    SYNChannelCategoryTableHeader *headerView = (self.headerRegister)[@(section)];
    [UIView transitionWithView: headerView
                      duration: 0.25
                       options: UIViewAnimationOptionTransitionCrossDissolve
                    animations: ^{
                        headerView.titleLabel.textColor = [UIColor	colorWithRed: 106.0f / 255.0f
                                                                          green: 114.0f / 255.0f
                                                                           blue: 122.0f / 255.0f
                                                                          alpha: 1.0f];
                        headerView.titleLabel.shadowColor = [UIColor  colorWithWhite: 1.0f
                                                                               alpha: 0.75f];
                        headerView.arrowImage.image = [UIImage imageNamed: @"IconCategorySlideChevron"];
                        headerView.backgroundImage.image = [UIImage imageNamed: @"CategorySlide"];
                    }
                    completion: nil];
}


#pragma mark - allCategories header

- (void) pressedAllCategories: (UIButton *) header;
{
    SYNChannelCategoryTableHeader *headerView = (SYNChannelCategoryTableHeader *) self.tableView.tableHeaderView;
    headerView.backgroundImage.image = [UIImage imageNamed: @"CategorySlideHighlighted"];
}

- (void) releasedAllCategories: (UIButton *) header
{
    SYNChannelCategoryTableHeader *headerView = (SYNChannelCategoryTableHeader *) self.tableView.tableHeaderView;
    
    headerView.backgroundImage.image = [UIImage imageNamed: @"CategorySlide"];
}


- (void) tappedAllCategories: (UIButton *) header
{
    SYNChannelCategoryTableHeader *headerView = (SYNChannelCategoryTableHeader *) self.tableView.tableHeaderView;
    
    headerView.titleLabel.textColor = [UIColor whiteColor];
    headerView.titleLabel.shadowColor = [UIColor colorWithWhite: 1.0f
                                                          alpha: 0.15f];
    headerView.backgroundImage.image = [UIImage imageNamed: @"CategorySlideSelected"];
    
    if (self.lastSelectedIndexpath)
    {
        [self closeSection: self.lastSelectedIndexpath.section];
    }
    
    if ([self.categoryTableControllerDelegate respondsToSelector: @selector(categoryTableControllerDeselectedAll:)])
    {
        [self.categoryTableControllerDelegate categoryTableControllerDeselectedAll: self];
    }
    
    self.lastSelectedIndexpath = nil;
}


#pragma mark - OtherCategory tapped

- (void) pressedOtherCategory: (UIButton *) header;
{
    SYNChannelCategoryTableHeader *headerView = (SYNChannelCategoryTableHeader *) self.tableView.tableHeaderView;
    headerView.backgroundImage.image = [UIImage imageNamed: @"CategorySlideHighlighted"];
}

- (void) releasedOtherCategory: (UIButton *) header
{
    SYNChannelCategoryTableHeader *headerView = (SYNChannelCategoryTableHeader *) self.tableView.tableHeaderView;
    
    headerView.backgroundImage.image = [UIImage imageNamed: @"CategorySlide"];
}


- (void) tappedOtherCategory: (UIButton *) header
{
    SYNChannelCategoryTableHeader *headerView = (SYNChannelCategoryTableHeader *) self.tableView.tableHeaderView;
    
    headerView.titleLabel.textColor = [UIColor whiteColor];
    headerView.titleLabel.shadowColor = [UIColor colorWithWhite: 1.0f
                                                          alpha: 0.15f];
    headerView.backgroundImage.image = [UIImage imageNamed: @"CategorySlideSelected"];
    
    if (self.lastSelectedIndexpath)
    {
        [self closeSection: self.lastSelectedIndexpath.section];
    }
    
    self.lastSelectedIndexpath = nil;
}


- (void) deselectOtherCategory;
{
    SYNChannelCategoryTableHeader *headerView = (SYNChannelCategoryTableHeader *) self.tableView.tableHeaderView;
    
    headerView.titleLabel.textColor = [UIColor colorWithRed: 106.0f / 255.0f
                                                      green: 114.0f / 255.0f
                                                       blue: 122.0f / 255.0f
                                                      alpha: 1.0f];
    
    headerView.titleLabel.shadowColor = [UIColor colorWithWhite: 1.0f
                                                          alpha: 0.75f];
    
    headerView.backgroundImage.image = [UIImage imageNamed: @"CategorySlide"];
}

#pragma mark - Set Selected Genre

- (void) setSelectedCategoryForId: (NSString *) selectedCategoryId
{
    if (!selectedCategoryId)
    {
        //Set Other selected
        SYNChannelCategoryTableHeader *headerView = (SYNChannelCategoryTableHeader *) self.tableView.tableHeaderView;
        headerView.titleLabel.textColor = [UIColor whiteColor];
        headerView.titleLabel.shadowColor = [UIColor colorWithWhite: 1.0f
                                                              alpha: 0.15f];
        headerView.backgroundImage.image = [UIImage imageNamed: @"CategorySlideSelected"];
        return;
    }
    
    //We'll pre-select the right genre by simulating the equivalent user input
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == %@", selectedCategoryId];
    Genre *genreToSelect = [self fetchGenreWithPredicate: predicate
                                        includeSubGenres: YES];
    
    if (genreToSelect)
    {
        //We've found the selected genre
        if ([genreToSelect isKindOfClass: [SubGenre class]])
        {
            //It's a sub genre. First open it's parent category
            SubGenre *subGenre = (SubGenre *) genreToSelect;
            
            //Is it the "other/other" category?
            if ([subGenre.genre isEqual: self.otherGenre])
            {
                SYNChannelCategoryTableHeader *headerView = (SYNChannelCategoryTableHeader *) self.tableView.tableHeaderView;
                headerView.titleLabel.textColor = [UIColor whiteColor];
                headerView.titleLabel.shadowColor = [UIColor colorWithWhite: 1.0f
                                                                      alpha: 0.15f];
                headerView.backgroundImage.image = [UIImage imageNamed: @"CategorySlideSelected"];
                
                return;
            }
            
            Genre *superGenre = subGenre.genre;
            int index = [self.categoriesDatasource indexOfObject: superGenre];
            
            if (index != NSNotFound)
            {
                SYNChannelCategoryTableHeader *header = (SYNChannelCategoryTableHeader *) [self tableView: nil
                                                                                                viewForHeaderInSection: index];
                [self tappedHeader: header.headerButton];
                //Now try to get the index of the subGenre
                NSMutableDictionary *sectionDictionary = self.transientDatasource[index];
                NSArray *subGenres = sectionDictionary[kSubCategoriesKey];
                
                if (subGenres)
                {
                    int subCategoryIndex = [subGenres indexOfObject: subGenre];
                    
                    if (subCategoryIndex != NSNotFound)
                    {
                        [self tableView: nil
                              didSelectRowAtIndexPath: [NSIndexPath indexPathForRow: subCategoryIndex
                                                                          inSection: index]];
                        
                        [[self.tableView cellForRowAtIndexPath: self.lastSelectedIndexpath] setSelected: YES];
                    }
                }
            }
        }
        else
        {
            //It's a genre, expand its section
            int index = [self.categoriesDatasource indexOfObject: genreToSelect];
            
            if (index != NSNotFound)
            {
                SYNChannelCategoryTableHeader *header = (SYNChannelCategoryTableHeader *) [self tableView: nil
                                                                                                viewForHeaderInSection: index];
                [self tappedHeader: header.headerButton];
            }
        }
    }
}


#pragma mark - UI button interactions (only present in channel create/edit)

- (IBAction) confirmButtonTapped: (id) sender
{
    if ([self.categoryTableControllerDelegate respondsToSelector: @selector(categoryTableController:didSelectSubCategory:)])
    {
        if (self.lastSelectedIndexpath)
        {
            if (self.lastSelectedIndexpath.row >= 0)
            {
                if ([self.categoryTableControllerDelegate respondsToSelector: @selector(categoryTableController:didSelectSubCategory:)])
                {
                    SubGenre *subCategory = (self.transientDatasource[self.lastSelectedIndexpath.section])[kSubCategoriesKey][self.lastSelectedIndexpath.row];
                    [self.categoryTableControllerDelegate categoryTableController: self
                                                             didSelectSubCategory: subCategory];
                }
            }
            else
            {
                if ([self.categoryTableControllerDelegate respondsToSelector: @selector(categoryTableController:didSelectCategory:)])
                {
                    Genre *category = self.categoriesDatasource[self.lastSelectedIndexpath.section];
                    [self.categoryTableControllerDelegate categoryTableController: self
                                                                didSelectCategory: category];
                }
            }
            
            
            
        }
        else
        {
            //no selected indexpath.
            if ([self.categoryTableControllerDelegate respondsToSelector: @selector(categoryTableController:didSelectCategory:)])
            {
                [self.categoryTableControllerDelegate categoryTableController: self
                                                            didSelectCategory: self.otherGenre];
            }
        }
    }
}


- (IBAction) closeButtonTapped: (id) sender
{
    if ([self.categoryTableControllerDelegate respondsToSelector: @selector(categoryTableControllerDeselectedAll:)])
    {
        [self.categoryTableControllerDelegate categoryTableControllerDeselectedAll: self];
    }
}


#pragma mark - fetchHelper
- (Genre *) fetchGenreWithPredicate: (NSPredicate *) predicate includeSubGenres: (BOOL) includeSubGenres
{
    SYNAppDelegate *appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    NSEntityDescription *categoryEntity = [NSEntityDescription entityForName: @"Genre"
                                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    // Look for Other category and show it if present.
    NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
    
    [categoriesFetchRequest setEntity: categoryEntity];
    
    [categoriesFetchRequest setPredicate: predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"priority"
                                                                   ascending: NO];
    [categoriesFetchRequest setSortDescriptors: @[sortDescriptor]];
    
    categoriesFetchRequest.includesSubentities = includeSubGenres;
    
    NSError *error;
    
    NSArray *otherFetchArray = [appDelegate.mainManagedObjectContext
                                executeFetchRequest: categoriesFetchRequest
                                error: &error];
    
    if ([otherFetchArray count] == 1)
    {
        return otherFetchArray[0];
    }
    
    return nil;
}

@end
