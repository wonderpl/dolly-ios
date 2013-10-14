//
//  SYNCategoriesBarViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 19/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "GAI.h"
#import "Genre.h"
#import "SYNAppDelegate.h"
#import "SYNDeviceManager.h"
#import "SYNGenreItemView.h"
#import "SYNGenreTabViewController.h"
#import "SYNNetworkEngine.h"
#import "SubGenre.h"
#import <CoreData/CoreData.h>

@interface SYNGenreTabViewController ()

@property (nonatomic) BOOL isLoadingCategories;
@property (nonatomic, readonly) SYNGenreTabView* categoriesTabView;
@property (nonatomic, strong) NSArray* genresFetched;
@property (nonatomic, strong) NSString* homeButtomString;
@property (nonatomic, weak) Genre* currentlySelectedGenre;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;

@end


@implementation SYNGenreTabViewController

@synthesize appDelegate;


- (id) initWithHomeButton: (NSString*) homeButtomString
{
    if ((self = [super init]))
    {
        self.homeButtomString = homeButtomString;
        
        self.appDelegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    return self;
}


- (void) loadView
{
 
    
    // TODO: String are fine, presumtion of queries it NOT!
    if([self.homeButtomString isEqualToString:@"other"])
    {
        NSEntityDescription* categoryEntity = [NSEntityDescription entityForName: @"Genre"
                                                          inManagedObjectContext: appDelegate.mainManagedObjectContext];
        
        // Look for Other category and show it if present.
        NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
        [categoriesFetchRequest setEntity:categoryEntity];
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"priority == -1"];
        [categoriesFetchRequest setPredicate:predicate];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"priority" ascending:NO];
        [categoriesFetchRequest setSortDescriptors:@[sortDescriptor]];
        
        categoriesFetchRequest.includesSubentities = NO;
        
        
        NSError* error;
        
        NSArray* otherFetchArray = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                       error: &error];
        if(otherFetchArray.count > 0)
        {
            self.otherGenre = otherFetchArray[0];
            self.homeButtomString = [self.otherGenre.name uppercaseString];
            
            if(otherFetchArray.count > 1) // home cleaning
                for (Genre* duplicateOther in otherFetchArray)
                    [duplicateOther.managedObjectContext deleteObject:duplicateOther];
            
            
        }
    }
    else
    {
        self.otherGenre = nil;
    }

    self.currentlySelectedGenre = nil;
    
    SYNGenreTabView* categoriesTabView = [[SYNGenreTabView alloc] initWithSize: [SYNDeviceManager.sharedInstance currentScreenWidth]
                                                                           andHomeButton: self.homeButtomString];
    categoriesTabView.tapDelegate = self;
    
    self.view = categoriesTabView;
    
    // align to top
    self.view.frame = CGRectMake(0.0, kStandardCollectionViewOffsetY, self.view.frame.size.width, self.view.frame.size.height);
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}

#pragma mark - View Life Cycle

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    [self displayLoadedGenres];
    
        
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(clearedLocationBoundData)
                                                 name: kClearedLocationBoundData
                                               object: nil];
}

- (void) viewDidAppear: (BOOL) animated
{
    [self updateCategories];
}


- (void) viewWillDisappear: (BOOL) animated
{
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kClearedLocationBoundData
                                                  object: nil];
    [super viewWillDisappear: animated];
    
}

-(void)clearedLocationBoundData
{
    self.currentlySelectedGenre = nil;
    
    [self.categoriesTabView hideSecondaryTabs];
    
    [self updateCategories];
}

-(void)updateCategories
{
    
    self.isLoadingCategories = YES;
    
    [appDelegate.networkEngine updateCategoriesOnCompletion: ^(NSDictionary* dictionary){
        
        [appDelegate.mainRegistry registerCategoriesFromDictionary: dictionary];
        
        self.isLoadingCategories = NO;
        
        [self displayLoadedGenres];
        
        if(self.genresFetched.count == 0)
        {
            // keep calling recursively is 
            [self updateCategories];
        }
        
        
    } onError:^(NSError* error) {
        DebugLog(@"%@", [error debugDescription]);
        
        
    }];
}


- (void) displayLoadedGenres
{
    NSError* error;
    
    NSEntityDescription* categoryEntity = [NSEntityDescription entityForName: @"Genre"
                                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
    [categoriesFetchRequest setEntity: categoryEntity];
    
    NSPredicate* excludePredicate = [NSPredicate predicateWithFormat: @"priority >= 0"];
    [categoriesFetchRequest setPredicate: excludePredicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"priority"
                                                                   ascending: NO];
    
    [categoriesFetchRequest setSortDescriptors: @[sortDescriptor]];
    
    categoriesFetchRequest.includesSubentities = NO;

    self.genresFetched = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                             error: &error];
    
    
    //DebugLog(@"* Genre Objects Loaded: %i", self.genresFetched.count);
    
    if(self.genresFetched.count > 0)
    {
        [self.tabView createCategoriesTab:self.genresFetched];
        
        if(self.currentlySelectedGenre)
            [self highlightTabForGenre:self.currentlySelectedGenre];
        
    }


    
}





#pragma mark - TabView Delagate methods

- (void) handleMainTap: (UIView *) tab
{
    
    SYNGenreItemView* genreTab = (SYNGenreItemView*)tab;
    
    if (!tab || tab.tag == 0) // home button pressed
    {
        
        [self.delegate handleMainTap: tab];
        
        
        if(self.otherGenre)
        {
            //The "OTHER" category has been chosen on the channel create or edit screen
            
            [self.delegate handleNewTabSelectionWithGenre: self.otherGenre];
            
        }
        
        else
        {
            [self.delegate handleNewTabSelectionWithGenre: nil];
        }
        
        self.currentlySelectedGenre = nil;
        
        [self.categoriesTabView hideSecondaryTabs];
        
        return;   
    }
    
    self.currentlySelectedGenre = (Genre*)genreTab.model;

    [self handleMainGenreSelection:self.currentlySelectedGenre];

    [self.delegate handleMainTap: tab];
    
    
    [self.delegate handleNewTabSelectionWithGenre:self.currentlySelectedGenre];
    
    // == Log Category in Google Analytics == //
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker send: [[[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                            action: @"categoryItemClick"
                                                             label: self.currentlySelectedGenre.name
                                                             value: nil] set: self.currentlySelectedGenre.name forKey: [GAIFields customDimensionForIndex: kGADimensionCategory]] build]];
}

-(void)handleMainGenreSelection:(Genre*)genreSelected
{
   
    
    NSArray* newSubCategories = [genreSelected.subgenres array];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"priority > 0"];
    newSubCategories = [newSubCategories filteredArrayUsingPredicate:predicate];
    NSSortDescriptor* idSortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"priority"
                                                                     ascending: NO];
    
    newSubCategories = [newSubCategories sortedArrayUsingDescriptors:@[idSortDescriptor]];
    
    // Finally Show SubGenres if needed
    
    if (self.delegate && [self.delegate showSubGenres])
    {
        [self.tabView createSubcategoriesTab:newSubCategories];
    }
}


- (void) handleSecondaryTap: (UIView *) tab
{
    
    SYNGenreItemView* subGenreTab = (SYNGenreItemView*)tab;
    
    self.currentlySelectedGenre = (SubGenre*)subGenreTab.model;
    
    [self.delegate handleSecondaryTap: tab];
    
    [self.delegate handleNewTabSelectionWithGenre: self.currentlySelectedGenre];
    
    
    
    // == Log subcategory in Google Analytics == //
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    // TODO: Not sure if we need both of these
    [tracker send: [[[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"categoryItemClick"
                                                            label: self.currentlySelectedGenre.name
                                                            value: nil] set: self.currentlySelectedGenre.name forKey: [GAIFields customDimensionForIndex: kGADimensionCategory]] build]];
}

-(SYNGenreTabView*)categoriesTabView
{
    return (SYNGenreTabView *)self.view;
}

-(void) deselectAll
{
    [self.categoriesTabView deselectAll];
}


#pragma mark - Getting Genre from Tab Bar 

-(void)highlightTabForGenre:(Genre*)genre
{
    
    NSIndexPath* indexPath = [self findIndexPathForGenreId:genre.uniqueId];
    
    Genre* genreToSelect = (Genre*)(self.genresFetched)[indexPath.section];
    
    if(indexPath.item != -1)
    {
        genreToSelect = (SubGenre*)(genreToSelect.subgenres)[indexPath.item];
        
    }
    
    [self.categoriesTabView highlightTabWithGenre:genreToSelect];
    
    return;
}

-(Genre*)selectAndReturnGenreForIndexPath:(NSIndexPath*)indexPath andSubcategories:(BOOL)subcats
{
    if(!self.genresFetched || !indexPath || !(self.genresFetched.count > indexPath.section))
        return nil;
    
    
    Genre* genreToSelect = (Genre*)(self.genresFetched)[indexPath.section];
    
    if(subcats && genreToSelect.subgenres.count > indexPath.item && indexPath.item != -1)
    {
        genreToSelect = (SubGenre*)(genreToSelect.subgenres)[indexPath.item];
        [self handleMainGenreSelection:((SubGenre*)genreToSelect).genre];
    }
    
    
    [self.categoriesTabView highlightTabWithGenre:genreToSelect];
    
    
    return genreToSelect;
        
}

-(NSIndexPath*)findIndexPathForGenreId:(NSString*)genreId
{
    if (self.otherGenre)
    {
        NSArray* otherSubCategory = [[self.otherGenre.subgenres array] filteredArrayUsingPredicate:
                                     [NSPredicate predicateWithFormat:@"uniqueId = %@", genreId]];
        
        if([otherSubCategory count])
        {
            //The Other/other category is selected by default. return nothing;
            return nil;
        }
    }
    
    NSInteger section = -1;
    NSInteger item = -1;
    
    NSInteger _section = 0;
    NSInteger _item = 0;
    
    for (Genre* genre in self.genresFetched)
    {
        if([genre.uniqueId isEqualToString:genreId])
        {
            section = _section; // the genre is a top level category
            item = -1; // ... so it does not have a subcat
            break;
        }
            
        
        for (SubGenre* subgenre in genre.subgenres)
        {
            if([subgenre.uniqueId isEqualToString:genreId])
            {
                
                section = [self.genresFetched indexOfObject:subgenre.genre]; // get the parent genre
                item = _item;
                break;
            }
            _item++;
        }
        
        _section++;
        _item = 0;
    }
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:item inSection:section];
    return indexPath;
}

#pragma mark - Orientation Change

- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration
{
    [self.tabView refreshViewForOrientation: toInterfaceOrientation];
}

@end
