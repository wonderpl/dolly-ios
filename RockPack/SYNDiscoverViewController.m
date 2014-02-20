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
#import "UIColor+SYNColor.h"
#import "UICollectionReusableView+Helpers.h"
#import "SYNMasterViewController.h"
#import "UIButton+WebCache.h"
#import "SYNGenreManager.h"
#import "SYNDiscoverSectionView.h"
#import "SYNOnBoardingHeader.h"
#import "UINavigationBar+Appearance.h"
#import "SYNTrackingManager.h"
@import QuartzCore;

#define kAutocompleteTime 0.2
static NSString* DiscoverSectionView = @"SYNDiscoverSectionView";
static NSString* OnBoardingHeaderIndent = @"SYNOnBoardingHeader";

typedef enum {
    kSearchTypeGenre = 0,
    kSearchTypeTerm
} kSearchType;


static NSString *kAutocompleteCellIdentifier = @"SYNSearchAutocompleteTableViewCell";

@interface SYNDiscoverViewController () < UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,
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

@property (nonatomic, weak) SubGenre* popularSubGenre;




// only used on iPad
@property (nonatomic, strong) IBOutlet UIView* containerView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *sideContainerWidth;

@property (nonatomic, strong) NSIndexPath *selectedCellIndex;
@end

@implementation SYNDiscoverViewController

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if (IS_IPAD) {
        self.searchBar.layer.borderWidth = 1.0f;
        self.searchBar.layer.borderColor = [[UIColor dollyMediumGray] CGColor];
    }
    
    
    
    self.autocompleteTableView.hidden = YES;
    
    // change the BG color of the text field inside the searcBar
    UITextField *txfSearchField = [self.searchBar valueForKey:@"_searchField"];
    if(txfSearchField)
        txfSearchField.backgroundColor = [UIColor dollySearchBarColor];
    
    // == Set the Collection View's Cells == //
    
    
    [self.categoriesCollectionView registerNib:[SYNDiscoverCategoriesCell nib]
                    forCellWithReuseIdentifier:[SYNDiscoverCategoriesCell reuseIdentifier]];
    
    [self.categoriesCollectionView registerNib: [UINib nibWithNibName: OnBoardingHeaderIndent bundle: nil]
          forSupplementaryViewOfKind: UICollectionElementKindSectionHeader
                 withReuseIdentifier: OnBoardingHeaderIndent];

    if(IS_IPHONE)
    {
        // to allow for full screen scroll of the categories
        UIEdgeInsets cInset = self.categoriesCollectionView.contentInset;
        cInset.top = 108.f;
        self.categoriesCollectionView.contentInset = cInset;
    }
    
    self.autocompleteSuggestionsArray = [NSArray array]; // just so we have an array to return count == 0
    
    
    // == Handle Search Results Controller for iPad (integrated in the view), for iPhone it is loaded upon demand as a different page
    
    self.searchResultsController = [[SYNSearchResultsViewController alloc] initWithViewId:kSearchViewId];
    
    // you want to load the search display controller only for iPad, on iPhone in slides in as a navigation
    if(IS_IPAD)
    {
        [self addChildViewController: self.searchResultsController];
        [self.containerView addSubview: self.searchResultsController.view];
        
        CGRect sResRect = self.searchResultsController.view.frame;
        sResRect.size = self.containerView.frame.size;
        self.searchResultsController.view.frame = sResRect;
        
        [self.searchResultsController searchForGenre:self.popularSubGenre.uniqueId];
    }
    
    
    if (!IS_IPHONE_5) {
        UIEdgeInsets tmpInsets = self.categoriesCollectionView.contentInset;
        tmpInsets.bottom += 88;
        [self.categoriesCollectionView setContentInset: tmpInsets];

    }
    
    if (IS_IPAD) {
        self.navigationController.navigationBarHidden = YES;        
    }

	[self.categoriesCollectionView registerNib:[SYNDiscoverSectionView nib]
				   forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
						  withReuseIdentifier:[SYNDiscoverSectionView reuseIdentifier]];

    self.sideContainerView.layer.borderColor = [[UIColor dollyMediumGray] CGColor];
    if (IS_RETINA) {
        self.sideContainerView.layer.borderWidth = 0.5f;
    } else {
        self.sideContainerView.layer.borderWidth = 1.0f;
    }
    
    [self reloadCategories];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(reloadCategories)
												 name:CategoriesReloadedNotification
											   object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (IS_IPAD) {
        self.navigationController.navigationBarHidden = YES;
    }
	
	// This is to handle the case where we're on the profile page and popToRootViewControllerAnimated is called.
	// For some reason viewWillDisappear isn't being called on the SYNProfileRootViewController so the
	// navigation bar is left with a transparent background.
	if (IS_IPHONE) {
		[self.navigationController.navigationBar setBackgroundTransparent:NO];
	}

	[self updateContainerWidths];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[SYNTrackingManager sharedManager] trackDiscoverScreenView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	
    if (IS_IPAD) {
        self.navigationController.navigationBarHidden = NO;
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	[self updateContainerWidths];
}


#pragma mark - Data Retrieval

- (void) fetchAndDisplayCategories
{
    
    NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
    
    categoriesFetchRequest.entity = [NSEntityDescription entityForName: kGenre
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
    

    [self.categoriesCollectionView reloadData];
    
    
}

-(SubGenre*)popularSubGenre
{
    // lazy loading
    if(!_popularSubGenre)
    {
        NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
        
        categoriesFetchRequest.entity = [NSEntityDescription entityForName: kGenre
                                                    inManagedObjectContext: appDelegate.mainManagedObjectContext];
        
        categoriesFetchRequest.predicate = [NSPredicate predicateWithFormat:@"name == %@", kPopularGenreName];
        
        NSError* error;
        
        NSArray* fetchedArray = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                    error: &error];
        
        
        
        if(fetchedArray.count > 0)
        {
            _popularSubGenre = (SubGenre*)fetchedArray[0];
        }
    }
    
    return _popularSubGenre;
}
- (void) selectCategoryForCollection:(UICollectionView *)collectionView atIndexPath: (NSIndexPath *)indexPath{
        Genre* currentGenre = self.genres[indexPath.section];
        SubGenre* subgenre = currentGenre.subgenres[indexPath.item];
        
        
        NSString *title = (IS_IPHONE ? subgenre.name : @"");
        
        [self dispatchSearch:subgenre.uniqueId
                   withTitle:title
                     forType:kSearchTypeGenre];
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
    
    SYNDiscoverCategoriesCell *categoryCell = [cv dequeueReusableCellWithReuseIdentifier:[SYNDiscoverCategoriesCell reuseIdentifier]
                                                                            forIndexPath: indexPath];
    
    //Editors picks still get there color
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        categoryCell.selectedColor = [UIColor darkerColorForColor:[[SYNGenreManager sharedInstance] colorFromID:subgenre.uniqueId]] ;
        categoryCell.deSelectedColor = [[SYNGenreManager sharedInstance] colorFromID:subgenre.uniqueId];
        categoryCell.backgroundColor = [[SYNGenreManager sharedInstance] colorFromID:subgenre.uniqueId];
        
    } else {
        categoryCell.selectedColor = [[SYNGenreManager sharedInstance] colorFromID:subgenre.uniqueId];
        categoryCell.deSelectedColor = [UIColor whiteColor];
    }
    
    categoryCell.label.text = subgenre.name;
            
    return categoryCell;
}

-(BOOL) collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if (self.selectedCellIndex) {
        [collectionView selectItemAtIndexPath:self.selectedCellIndex animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        
    }

}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectCategoryForCollection:collectionView atIndexPath:indexPath];
    self.selectedCellIndex = indexPath;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return CGSizeMake(0, 0);
    }else {
        return CGSizeMake(self.categoriesCollectionView.bounds.size.width, 14);
    }
}


- (CGSize)collectionView:(UICollectionView *)collectionView
				  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	return CGSizeMake(CGRectGetWidth(collectionView.frame), 44);
}


- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath
{
    UICollectionReusableView *supplementaryView = nil;
    
    if (kind == UICollectionElementKindSectionFooter)
    {
        
        Genre* currentGenre = self.genres[indexPath.section];

        
        supplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind: kind
                                                               withReuseIdentifier: DiscoverSectionView
                                                                      forIndexPath: indexPath];
        SubGenre* subgenre = currentGenre.subgenres[indexPath.item];
        ((SYNDiscoverSectionView*)supplementaryView).background.backgroundColor = [[SYNGenreManager sharedInstance] colorFromID:subgenre.uniqueId];
        
        
    }
    
    return supplementaryView;
}


#pragma mark - UITableView Delegate/Data Source

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    return self.autocompleteSuggestionsArray.count;
}


- (UITableViewCell *) tableView: (UITableView *) tableView
          cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    
    SYNDiscoverAutocompleteCell *cell;
    
    if (!(cell = [tableView dequeueReusableCellWithIdentifier: kAutocompleteCellIdentifier]))
        cell = [[SYNDiscoverAutocompleteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: kAutocompleteCellIdentifier];
    
    id autocompleteItem = self.autocompleteSuggestionsArray[indexPath.row];
    if([autocompleteItem isKindOfClass:[NSString class]])
    {
        cell.textLabel.text = [((NSString*)autocompleteItem) capitalizedString];
    }
    else if ([autocompleteItem isKindOfClass:[NSDictionary class]])
    {
        
        cell.textLabel.text = autocompleteItem[@"term"];
        
        NSString* type = autocompleteItem[@"type"];
        if([type isEqualToString:@"user"])
        {
            cell.userAvatarButton.hidden = NO;
            
            [cell.userAvatarButton setImageWithURL: [NSURL URLWithString: autocompleteItem[@"thumbnail"]]
                                          forState: UIControlStateNormal
                                  placeholderImage: [UIImage imageNamed: @"PlaceholderNotificationAvatar.png"]
                                           options: SDWebImageRetryFailed];
            
            [cell.userAvatarButton addTarget:self
                                      action:@selector(userAvatarButtonPressed:)
                            forControlEvents:UIControlEventTouchUpInside];
        }
        
    }
    
    return cell;
}

- (void) userAvatarButtonPressed: (UIButton*) button
{
    UIView* candidateCell = button;
    while (![candidateCell isKindOfClass:[SYNDiscoverAutocompleteCell class]]) {
        candidateCell = candidateCell.superview;
    }
    
    if(![candidateCell isKindOfClass:[SYNDiscoverAutocompleteCell class]])
    {
        AssertOrLog(@"Could not retrieve SYNDiscoverAutocompleteCell cell from %@", button);
        return;
    }
    
    SYNDiscoverAutocompleteCell* cell = (SYNDiscoverAutocompleteCell*)candidateCell;
    NSIndexPath* indexPath = [self.autocompleteTableView indexPathForCell:cell];
    
    NSDictionary* data = self.autocompleteSuggestionsArray[indexPath.row];

    NSDictionary* channelOwnerData = @{@"id":data[@"id"], @"avatar_thumbnail_url":data[@"thumbnail"], @"display_name":data[@"name"]};
    ChannelOwner* coSelected = [ChannelOwner instanceFromDictionary:channelOwnerData
                                          usingManagedObjectContext:appDelegate.searchManagedObjectContext
                                                ignoringObjectTypes:kIgnoreAll];
    
    if(!coSelected)
        return;
    
    [self.searchBar resignFirstResponder];
    
    [self viewProfileDetails:coSelected];
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id suggestion = self.autocompleteSuggestionsArray[indexPath.row];
	NSString *searchTerm;
    if([suggestion isKindOfClass:[NSString class]])
    {
        searchTerm = (NSString*)suggestion;
        
        [self dispatchSearch:searchTerm
                   withTitle:searchTerm
                     forType:kSearchTypeTerm];
    }
    else if ([suggestion isKindOfClass:[NSDictionary class]])
    {
        
        searchTerm = ((NSDictionary*)suggestion)[@"term"];
        NSString* searchType = ((NSDictionary*)suggestion)[@"type"];
        if([searchType isEqualToString:@"user"])
        {
            SYNDiscoverAutocompleteCell* cellPressed = (SYNDiscoverAutocompleteCell*)[tableView cellForRowAtIndexPath:indexPath];
            [self userAvatarButtonPressed:cellPressed.userAvatarButton];
        }
        else
        {
            [self dispatchSearch:searchTerm
                       withTitle:searchTerm
                         forType:kSearchTypeTerm];
        }
    }
    
    self.searchBar.text = searchTerm;
    
    
    [self closeAutocomplete];
    
}

#pragma mark - UISearchBar Delegate and Autocomplete Methods

- (BOOL) searchBarShouldBeginEditing: (UISearchBar *) searchBar
{
    
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (![self.searchBar.text length]) {
		[self closeAutocomplete];
    }
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
        [self closeAutocomplete];
        
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
        NSString* term;
        for (NSArray* suggestion in suggestionsReturned)
        {
            if(!suggestion)
                continue;
            
            term = suggestion[0];
            
            
            // parse metadata elements in array
            
            NSArray* objectData = (NSArray*)suggestion[1];
            if(![objectData isKindOfClass:[NSArray class]])
            {
                [wordsReturned addObject: term];
                continue;
            }
            
            NSString* objectType = (NSString*)objectData[0];
            
            NSMutableDictionary* dataDictionary = @{@"type" : objectType , @"term" : term}.mutableCopy;
                                                    
            

            if([objectType isEqualToString:@"user"])
            {
              
                NSString* userId = (NSString*)objectData[1];
                dataDictionary[@"id"] = userId;
                NSString* name = (NSString*)objectData[2];
                dataDictionary[@"name"] = name;
                NSString* avatarUrl = (NSString*)objectData[3];
                dataDictionary[@"thumbnail"] = avatarUrl;
            }
            
            [wordsReturned addObject:dataDictionary];
            
            // might want to parse the rest
        }
        
        
        wself.autocompleteSuggestionsArray = [NSArray arrayWithArray:wordsReturned];
        
        
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


#pragma mark - Perform Search

- (void) dispatchSearch:(NSString*)searchTerm
              withTitle:(NSString*)title
                forType:(kSearchType)type
{
    
    [self.searchBar setShowsCancelButton:NO animated:YES];
    
    [self.searchBar resignFirstResponder];
    
    [self.autocompleteTimer invalidate];
    
    [self closeAutocomplete];
    
    if(IS_IPHONE)
    {
        // the hack below is used to trigger the viewDidLoad function which initialises blocks and gets the appDelegate
        UIView* view_hack = self.searchResultsController.view;
        #pragma unused(view_hack)
        
        self.searchResultsController.navigationItem.title = title;
        
        [self.navigationController pushViewController:self.searchResultsController
                                             animated:YES];
        
        // hide the 'DISCOVER' text next to the back button as it appears by default
    }
    else // if(IS_IPAD)
    {
        // in the case of the iPad the navigation bar title needs to be changed manually
//        self.navigationController.navigationBar.topItem.title = title;
    }
    
    if(type == kSearchTypeGenre) {
        if (![searchTerm isEqualToString:@""]) {
            self.searchBar.text = @"";
        }
        [self.searchResultsController searchForGenre:searchTerm];
    } else {
		[[SYNTrackingManager sharedManager] trackSearchInitiated];
		
        [self.categoriesCollectionView deselectItemAtIndexPath:self.selectedCellIndex animated:YES];
        self.selectedCellIndex = nil;
        [self.searchResultsController searchForTerm:searchTerm];
    }
   
}


#pragma mark - Helper Methods

-(void)closeAutocomplete
{
    self.autocompleteTableView.hidden = YES;
    self.autocompleteSuggestionsArray = @[];
    [self.autocompleteTableView reloadData];
}


- (void)updateContainerWidths {
	if (IS_IPAD) {
		CGFloat width = CGRectGetWidth(self.view.bounds);
		CGFloat sideWidth = (int)(width / 3.0);
		
		self.sideContainerWidth.constant = sideWidth;
		
		[self.categoriesCollectionView.collectionViewLayout invalidateLayout];
	}
}

- (void)reloadCategories {
    [self fetchAndDisplayCategories];
	
    if (self.genres.count > 0 && IS_IPAD) {
        [self.categoriesCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        
        [self selectCategoryForCollection:self.categoriesCollectionView atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
}

@end
