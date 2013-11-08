//
//  SYNSearchViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 15/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "Genre.h"
#import "SYNDeviceManager.h"
#import "SYNDiscoverAutocompleteCell.h"
#import "SYNDiscoverCategoriesCell.h"
#import "SYNDiscoverViewController.h"
#import "SYNSearchResultsViewController.h"
#import "SubGenre.h"
#import "UIFont+SYNFont.h"
@import QuartzCore;

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

@property (nonatomic, strong) Genre* popularGenre;

@end

@implementation SYNDiscoverViewController


- (void)viewDidLoad
{
    
    
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.colorMapForCells = @{};
    self.searchBar.layer.borderWidth = 1.0f;
    self.searchBar.layer.borderColor = [[UIColor whiteColor] CGColor];
    if(IS_IPHONE)
    {
        
        
    }
    
    
    
    self.autocompleteTableView.hidden = YES;
    
    // change the BG color of the text field inside the searcBar
    UITextField *txfSearchField = [self.searchBar valueForKey:@"_searchField"];
    if(txfSearchField)
        txfSearchField.backgroundColor = [UIColor colorWithRed: (224.0f / 255.0f)
                                                         green: (224.0f / 255.0f)
                                                          blue: (224.0f / 255.0f)
                                                         alpha: 1.0f];
    
    
    // == Set the Collection View's Cells == //
    
    
    [self.categoriesCollectionView registerNib: [UINib nibWithNibName: kCategoryCellIndetifier bundle: nil]
                    forCellWithReuseIdentifier: kCategoryCellIndetifier];
    
    
    
    self.autocompleteSuggestionsArray = [NSArray array]; // just so we have an array to return count == 0
    
    
    // == Handle Search Results Controller for iPad (integrated in the view), for iPhone it is loaded upon demand as a different page
    
    self.searchResultsController = [[SYNSearchResultsViewController alloc] initWithViewId:kSearchViewId];
    
    
    // self.loadingPanelView.hidden = NO; // hide by default and only show when there are no categories
    
    // Check for existence of popular category
    
    NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
    
    categoriesFetchRequest.entity = [NSEntityDescription entityForName: kGenre
                                                inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    categoriesFetchRequest.predicate = [NSPredicate predicateWithFormat:@"name == %@", kPopularGenreName];
    
    categoriesFetchRequest.includesSubentities = NO; // this will avoid getting both the Genre and SubGenre called 'POPULAR'
    
    NSError* error;
    
    NSArray* genresFetchedArray = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                      error: &error];
    
    
    
    SubGenre* popularSubGenre;
    // probably the database is cold so need to reload everything
    if(genresFetchedArray.count == 0)
    {
      
        _popularGenre = [Genre insertInManagedObjectContext: appDelegate.mainManagedObjectContext];
        _popularGenre.uniqueId = kPopularGenreUniqueId;
        _popularGenre.name = [NSString stringWithString:kPopularGenreName];
        _popularGenre.priorityValue = 100000;
        
        
        popularSubGenre = [SubGenre insertInManagedObjectContext:appDelegate.mainManagedObjectContext];
        popularSubGenre.uniqueId = kPopularGenreUniqueId;
        popularSubGenre.name = [NSString stringWithString:kPopularGenreName];
        popularSubGenre.priorityValue = 100000;
        
        // NOTE: Since SubGenres are only displayed, the POPULAR Genre needs to have one SubGenre also called POPULAR to display in the list
        [_popularGenre.subgenresSet addObject:popularSubGenre];
        
        if(!_popularGenre)
            return;
        
        [appDelegate.mainManagedObjectContext save:&error];
        
        [self displayPopupMessage: NSLocalizedString(@"feed_screen_empty_message", nil)
                       withLoader: YES];
        
        [self loadCategories];
        
    }
    else
    {
        _popularGenre = (Genre*)genresFetchedArray[0];
        popularSubGenre = (SubGenre*)_popularGenre.subgenres[0];
        // housekeeping (remove duplicates)
        if(genresFetchedArray.count > 1)
        {
            for (int i = 1; i < genresFetchedArray.count; i++)
            {
                Genre* popularClone = (Genre*)genresFetchedArray[i];
                [popularClone.managedObjectContext delete:popularClone];
                
            }
        }
        
        [self fetchAndDisplayCategories];
        
        [self loadCategories];
        
        
    }
    
    // you want to load the search display controller only for iPad, on iPhone in slides in as a navigation
    if(IS_IPAD)
    {
        [self addChildViewController: self.searchResultsController];
        [self.containerView addSubview: self.searchResultsController.view];
        
        CGRect sResRect = self.searchResultsController.view.frame;
        sResRect.size = self.containerView.frame.size;
        self.searchResultsController.view.frame = sResRect;
        
        // this should always be true since we are either creating it on the fly or it is in DB already
        if(popularSubGenre)
        {
            [self.searchResultsController searchForGenre:popularSubGenre.uniqueId];
        }
        else
        {
            AssertOrLog(@"Popular SubGenre was not created at this stage...");
        }
    }
    
    
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.topItem.title = self.title;
}


#pragma mark - Data Retrieval

- (void) fetchAndDisplayCategories
{
    
    NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
    
    categoriesFetchRequest.entity = [NSEntityDescription entityForName: @"Genre"
                                                inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"priority" ascending:NO];
    
    [categoriesFetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // this is so that empty genres are not returned since only the subgenres are displayed
    categoriesFetchRequest.predicate = [NSPredicate predicateWithFormat:@"subgenres.@count > 0"];
    
    categoriesFetchRequest.includesSubentities = NO;
    
    NSError* error;
    
    NSArray* genresFetchedArray = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                      error: &error];
    
    
    self.genres = [NSArray arrayWithArray:genresFetchedArray];
    
    // create temporary colors
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
    
    [self.categoriesCollectionView reloadData];
    
    
}

- (void) loadCategories
{
    
    [appDelegate.networkEngine updateCategoriesOnCompletion: ^(NSDictionary* dictionary){
        
        [appDelegate.mainRegistry performInBackground:^BOOL(NSManagedObjectContext *backgroundContext) {
            
            return [appDelegate.mainRegistry registerCategoriesFromDictionary: dictionary];
            
        } completionBlock:^(BOOL success) {
            
            [self removePopupMessage];
            
            [self fetchAndDisplayCategories];
            
            
            
        }];
        
        
    } onError:^(NSError* error) {
        
        [self removePopupMessage];
        
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
    
    
    // if we are on the last cell of the section, hide the separator line
    categoryCell.separator.hidden = (BOOL)(indexPath.item == (currentGenre.subgenres.count - 1));
    categoryCell.backgroundColor = self.colorMapForCells[currentGenre.name];
    
    categoryCell.label.text = subgenre.name;
    
    
    return categoryCell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Genre* currentGenre = self.genres[indexPath.section];
    SubGenre* subgenre = currentGenre.subgenres[indexPath.item];
    
    [self dispatchSearch:subgenre.uniqueId
               withTitle:subgenre.name
                 forType:kSearchTypeGenre];
    
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
    
    [self dispatchSearch:suggestion
               withTitle:suggestion
                 forType:kSearchTypeTerm];
    
    [self closeAutocomplete];
}

#pragma mark - UISearchBar Delegate and Autocomplete Methods

- (BOOL) searchBarShouldBeginEditing: (UISearchBar *) searchBar
{
    //[searchbar setText: @""];
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    
    
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [self closeAutocomplete];
    [self.searchBar resignFirstResponder];
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
    
    
    [self dispatchSearch:searchBar.text
               withTitle:searchBar.text
                 forType:kSearchTypeTerm];
}


- (void) dispatchSearch:(NSString*)searchTerm
              withTitle:(NSString*)title
                forType:(kSearchType)type
{
    
    if(IS_IPHONE)
    {
        // the hack below is used to trigger the viewDidLoad function which initialises blocks and gets the appDelegate
        UIView* view_hack = self.searchResultsController.view;
        #pragma unused(view_hack)
        
        self.searchResultsController.title = title;
        
        [self.navigationController pushViewController:self.searchResultsController
                                             animated:YES];
        
        
        
        
    }
    else // if(IS_IPAD)
    {
        // in the case of the iPad the navigation bar title needs to be changed manually
        self.navigationController.navigationBar.topItem.title = title;
        
    }
    
    if(type == kSearchTypeGenre)
        [self.searchResultsController searchForGenre:searchTerm];
    else
        [self.searchResultsController searchForTerm:searchTerm];
    
    
    
    
}


#pragma mark - Helper Methods

-(void)closeAutocomplete
{
    self.autocompleteTableView.hidden = YES;
    self.autocompleteSuggestionsArray = @[];
    [self.autocompleteTableView reloadData];
}

@end
