//
//  SYNSearchViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 15/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNDiscoverViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNDiscoverAutocompleteCell.h"
#import "Genre.h"
#import "SubGenre.h"
#import "SYNSearchResultsViewController.h"
#import "SYNDeviceManager.h"
#import "AppConstants.h"
#import "SYNDiscoverCategoriesCell.h"
#import <QuartzCore/QuartzCore.h>

#define kAutocompleteTime 0.2

typedef enum {
    kSearchTypeGenre = 0,
    kSearchTypeTerm
} kSearchType;


static NSString* kCategoryCellIndetifier = @"SYNDiscoverCategoriesCell";
static NSString *kAutocompleteCellIdentifier = @"SYNSearchAutocompleteTableViewCell";

@interface SYNDiscoverViewController () < UICollectionViewDataSource, UICollectionViewDelegate,
                                        UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>



// Categories Stuff
@property (nonatomic, strong) IBOutlet UICollectionView* categoriesCollectionView;
@property (nonatomic, strong) NSArray* genres;

@property (nonatomic, strong) IBOutlet UISearchBar* searchBar;

// Autocomplete Stuff
@property (nonatomic, strong) NSTimer* autocompleteTimer;
@property (nonatomic, weak) MKNetworkOperation* autocompleteNetworkOperation;
@property (nonatomic, strong) NSArray* autocompleteSuggestionsArray;
@property (nonatomic, strong) IBOutlet UITableView* autocompleteTableView;

@property (nonatomic, strong) IBOutlet UIView* sideContainerView;

@property (nonatomic, strong) SYNSearchResultsViewController* searchResultsController;

@property (nonatomic, strong) NSDictionary* colorMapForCells;

// only used on iPad
@property (nonatomic, strong) IBOutlet UIView* containerView;

@end

@implementation SYNDiscoverViewController


- (void)viewDidLoad
{
    
    
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.colorMapForCells = @{};
    
    
    self.autocompleteTableView.hidden = YES;
    
    
    // == Set the Collection View's Cells == //
    
    
    [self.categoriesCollectionView registerNib: [UINib nibWithNibName: kCategoryCellIndetifier bundle: nil]
                    forCellWithReuseIdentifier: kCategoryCellIndetifier];
    
    
    
    self.autocompleteSuggestionsArray = [NSArray array]; // just so we have an array to return count == 0
    
    
    // == Handle Search Results Controller for iPad (integrated in the view), for iPhone it is loaded upon demand as a different page
    
    self.searchResultsController = [[SYNSearchResultsViewController alloc] initWithViewId:kSearchViewId];
    
    
    
    if(IS_IPAD)
    {
        [self addChildViewController: self.searchResultsController]; // containment
        [self.containerView addSubview: self.searchResultsController.view];
        
        CGRect sResRect = self.searchResultsController.view.frame;
        sResRect.size = self.containerView.frame.size;
        self.searchResultsController.view.frame = sResRect;
    }
    
    // Check for existence of popular category
    
    NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
    
    categoriesFetchRequest.entity = [NSEntityDescription entityForName: @"Genre"
                                                inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    categoriesFetchRequest.predicate = [NSPredicate predicateWithFormat:@"name == %@", kPopularGenreName];
    
    NSError* error;
    
    NSArray* genresFetchedArray = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                      error: &error];
    
    // probably the database is cold so need to reload everything
    if(genresFetchedArray.count == 0)
    {
        [self createPopular];
        [self loadCategories];
    }
    
    else
    {
        // housekeeping
        if(genresFetchedArray.count > 1)
        {
            for (int i = 1; i < genresFetchedArray.count; i++)
            {
                Genre* popularClone = (Genre*)genresFetchedArray[i];
                [popularClone.managedObjectContext delete:popularClone];
                
            }
        }
        
        [self fetchCategories];
        
        [self loadCategories];
        
    }
    
    
    
    [self.categoriesCollectionView reloadData];
    
    
    
    
}

- (void) createPopular
{
    NSDictionary* popularGenreData = @{@"id":@"90", @"priority":@(1000), @"name":kPopularGenreName};
    
    
    Genre* popularGenre = [Genre instanceFromDictionary:popularGenreData
                              usingManagedObjectContext:appDelegate.mainManagedObjectContext];
    
    if(!popularGenre)
        return;
    
    [appDelegate saveContext:NO];
}


#pragma mark - Data Retrieval

- (void) fetchCategories
{
    
    NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
    
    categoriesFetchRequest.entity = [NSEntityDescription entityForName: @"Genre"
                                                inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"priority" ascending:NO];
    
    [categoriesFetchRequest setSortDescriptors:@[sortDescriptor]];
    
    
    
    NSError* error;
    
    NSArray* genresFetchedArray = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                      error: &error];
    
    
    self.genres = [NSArray arrayWithArray:genresFetchedArray];
    
    NSMutableDictionary* mutDictionary = @{}.mutableCopy;
    for (Genre* genre in self.genres)
    {
        
        CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
        UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
        
        mutDictionary[genre.name] = color;
        
    }
    self.colorMapForCells = [NSDictionary dictionaryWithDictionary:mutDictionary];
    
}

- (void) loadCategories
{
    
    
    
    [appDelegate.networkEngine updateCategoriesOnCompletion: ^(NSDictionary* dictionary){
        
        [appDelegate.mainRegistry performInBackground:^BOOL(NSManagedObjectContext *backgroundContext) {
            
            return [appDelegate.mainRegistry registerCategoriesFromDictionary: dictionary];
            
        } completionBlock:^(BOOL success) {
            
            [self fetchCategories];
            
            [self.categoriesCollectionView reloadData];
            
        }];
        
        
    } onError:^(NSError* error) {
        
        DebugLog(@"%@", [error debugDescription]);
        
        
    }];
}

#pragma mark - CollectionView Delegate/Data Source



- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    
    return self.genres.count;
}

- (NSInteger) collectionView: (UICollectionView *) view numberOfItemsInSection: (NSInteger) section
{
    
    return ((Genre*)self.genres[section]).subgenres.count;
}



- (UICollectionViewCell *) collectionView: (UICollectionView *) cv cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    Genre* currentGenre = self.genres[indexPath.section];
    SubGenre* subgenre = currentGenre.subgenres[indexPath.item];
    
    SYNDiscoverCategoriesCell *categoryCell = [cv dequeueReusableCellWithReuseIdentifier: kCategoryCellIndetifier
                                                                            forIndexPath: indexPath];
    
    
    categoryCell.backgroundColor = self.colorMapForCells[currentGenre.name];
    
    categoryCell.label.text = subgenre.name;
    
    
    return categoryCell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SubGenre* selectedGenre = self.genres[indexPath.item];
    
    [self dispatchSearch:selectedGenre.uniqueId forType:kSearchTypeGenre];
}




#pragma mark - UITableView Delegate/Data Source

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    return self.autocompleteSuggestionsArray.count;
}


- (UITableViewCell *) tableView: (UITableView *) tableView
          cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    
    UITableViewCell *cell;
    
    if (!(cell = [tableView dequeueReusableCellWithIdentifier: kAutocompleteCellIdentifier]))
        cell = [[SYNDiscoverAutocompleteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: kAutocompleteCellIdentifier];
    
    cell.textLabel.text = [((NSString*)self.autocompleteSuggestionsArray[indexPath.row]) capitalizedString];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* suggestion = self.autocompleteSuggestionsArray[indexPath.row];
    
    [self dispatchSearch:suggestion];
    
    [self closeAutocomplete];
}

#pragma mark - UISearchBar Delegate and Autocomplete Methods

- (BOOL) searchBarShouldBeginEditing: (UISearchBar *) searchbar
{
    //[searchbar setText: @""];
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    
    
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [self closeAutocomplete];
}

- (BOOL) searchBar: (UISearchBar *) searchBar shouldChangeTextInRange: (NSRange) range replacementText: (NSString *) text
{
    
    
    // 1. Do not accept blank characters at the beggining of the field
    if ([text isEqualToString: @" "] && self.searchBar.text.length == 0)
        return NO;
    
    // 2. if there are less than 3 chars currently typed do not perform search
    if ((range.location - range.length) < 2)
    {
        // TODO: close suggestion box
        return YES;
    }
    
    // == Restart Timer == //
    
    if (self.autocompleteTimer)
        [self.autocompleteTimer invalidate];
    
    self.autocompleteTimer = [NSTimer scheduledTimerWithTimeInterval: kAutocompleteTime
                                                              target: self
                                                            selector: @selector(performAutocompleteSearch:)
                                                            userInfo: nil
                                                             repeats: NO];
    return YES;
}


- (void) performAutocompleteSearch: (NSTimeInterval*) interval
{
    [self.autocompleteTimer invalidate];
    
    self.autocompleteTimer = nil;
    
    // == Define Process and Error Blocks == //
    
    __weak SYNDiscoverViewController* wself = self;
    
    MKNKAutocompleteProcessBlock processBlock = ^(NSArray * array) {
        
        NSArray* suggestionsReturned = array[1];
        
        if (suggestionsReturned.count == 0)
        {
            
            return;
        }
        
        NSMutableArray* wordsReturned = [NSMutableArray array];
        
        for (NSArray* suggestion in suggestionsReturned)
        {
            if(!suggestion)
                continue;
            
            [wordsReturned addObject: suggestion[0]];
        }
        
        
        
        wself.autocompleteSuggestionsArray =
        [NSArray arrayWithArray:wordsReturned];
        
        
        wself.autocompleteTableView.hidden = NO;
        
        [wself.autocompleteTableView reloadData];
        
    };
    
    
    MKNKErrorBlock errorBlock = ^(NSError* error) {
        
        
        
    };
    
    // == Make and Save the Request == //
    
    self.autocompleteNetworkOperation = [appDelegate.networkEngine getAutocompleteForHint: self.searchBar.text
                                                                              forResource: appDelegate.searchEntity
                                                                             withComplete: processBlock
                                                                                 andError: errorBlock];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self dispatchSearch:searchBar.text];
}

- (void) dispatchSearch:(NSString*)searchTerm
{
    [self dispatchSearch:searchTerm forType:kSearchTypeTerm];
}
- (void) dispatchSearch:(NSString*)searchTerm forType:(kSearchType)type
{
    if(type == kSearchTypeGenre)
    {
        
        [self.searchResultsController searchForGenre:searchTerm];
    }
    else
    {
        [self.searchResultsController searchForTerm:searchTerm];
    }
    
    
    if(IS_IPHONE)
    {
        [self.navigationController pushViewController:self.searchResultsController
                                             animated:YES];
        
        
    }
}


#pragma mark - Helper Methods

-(void)closeAutocomplete
{
    self.autocompleteTableView.hidden = YES;
    self.autocompleteSuggestionsArray = @[];
    [self.autocompleteTableView reloadData];
}

@end
