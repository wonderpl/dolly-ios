//
//  SYNSearchViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 15/10/2013.
//  Copyright (c) 2013 Wonder PL Ltd. All rights reserved.
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
#import "SYNDiscoverOverlayVideoViewController.h"
#import "SYNDiscoverOverlayHighlightsViewController.h"
#import "SYNTrackingManager.h"
#import "SYNGenreManager.h"
#import "SYNDiscoverSectionHeaderView.h"
#import "SYNGenreManager.h"
#import "SYNDeviceManager.h"

@import QuartzCore;

#define kAutocompleteTime 0.2
static NSString* DiscoverSectionView = @"SYNDiscoverSectionView";
static NSString* OnBoardingHeaderIndent = @"SYNOnBoardingHeader";
static const int numberOfRecents = 3;

#define kRecentlyViewed @"Recently Viewed"

typedef enum {
    kSearchTypeGenre = 0,
    kSearchTypeTerm
} kSearchType;


static NSString *kAutocompleteCellIdentifier = @"SYNSearchAutocompleteTableViewCell";

@interface SYNDiscoverViewController () < UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,
UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>



// Categories Stuff
@property (nonatomic, strong) IBOutlet UICollectionView* categoriesCollectionView;

@property (nonatomic, strong) IBOutlet UISearchBar* searchBar;

// Autocomplete Stuff
@property (nonatomic, strong) NSTimer* autocompleteTimer;
@property (nonatomic, weak) MKNetworkOperation* autocompleteNetworkOperation;
@property (nonatomic, strong) NSArray* autocompleteSuggestionsArray;
@property (nonatomic, strong) IBOutlet UITableView* autocompleteTableView;

@property (nonatomic, strong) IBOutlet UIView* sideContainerView;

@property (nonatomic, strong) SYNSearchResultsViewController* searchResultsController;

// only used on iPad
@property (nonatomic, strong) IBOutlet UIView* containerView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *sideContainerWidth;

@property (nonatomic, strong) NSIndexPath *selectedCellIndex;

@property (nonatomic, strong) NSArray *genres;

@property (nonatomic, strong) NSMutableArray *recentlyViewed;
@property (nonatomic, strong) UIBarButtonItem *moodBarButton;
@end

@implementation SYNDiscoverViewController

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;

	
	
	self.searchBar.layer.borderWidth = IS_RETINA ? 0.5 : 1.0;

	self.searchBar.layer.borderColor = [[UIColor colorWithRed: 214.0f / 255.0f
														green: 214.0f / 255.0f
														 blue: 214.0f / 255.0f
														alpha: 1.0f] CGColor];
	
    
    self.autocompleteTableView.hidden = YES;
    
    // == Set the Collection View's Cells == //
    
    [self.categoriesCollectionView registerNib:[SYNDiscoverCategoriesCell nib]
                    forCellWithReuseIdentifier:[SYNDiscoverCategoriesCell reuseIdentifier]];
    
	
	[self.categoriesCollectionView registerNib: [SYNDiscoverSectionHeaderView nib]					forSupplementaryViewOfKind: UICollectionElementKindSectionHeader
						   withReuseIdentifier: [SYNDiscoverSectionHeaderView reuseIdentifier]];
	
		
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
    if(IS_IPAD) {
        [self addChildViewController: self.searchResultsController];
        [self.containerView addSubview: self.searchResultsController.view];
        
        CGRect sResRect = self.searchResultsController.view.frame;
        sResRect.size = self.containerView.frame.size;
        self.searchResultsController.view.frame = sResRect;
    }
    
    self.sideContainerView.layer.borderColor = [[UIColor colorWithRed: 214.0f / 255.0f
															   green: 214.0f / 255.0f
																blue: 214.0f / 255.0f
															   alpha: 1.0f] CGColor];
	
    self.sideContainerView.layer.borderWidth = IS_RETINA ? 0.5f : 1.0f;
    
    [self reloadCategories];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(reloadCategories)
												 name:CategoriesReloadedNotification
											   object:nil];
	self.recentlyViewed = [[NSMutableArray alloc] init];

	
	

}

- (void)viewWillAppear:(BOOL)animated {
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
	
	
	[self.categoriesCollectionView reloadData];
	[self.categoriesCollectionView selectItemAtIndexPath:self.selectedCellIndex animated:NO scrollPosition:UICollectionViewScrollPositionNone];
	
	
	self.recentlyViewed = [self genreArrayFromDefaults];
	
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[SYNTrackingManager sharedManager] trackDiscoverScreenView];
	
	if (IS_IPHONE) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardChanged:)
													 name:UIKeyboardWillShowNotification
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardChanged:)
													 name:UIKeyboardWillHideNotification
												   object:nil];
	}
	
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	if (IS_IPHONE) {
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter removeObserver:self name:UIKeyboardWillShowNotification object:self];
		[notificationCenter removeObserver:self name:UIKeyboardWillHideNotification object:self];
	}
}

- (void) viewDidDisappear:(BOOL)animated {
	
	[super viewDidDisappear:animated];
	if (IS_IPAD) {
		self.navigationController.navigationBarHidden = NO;
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	[self updateContainerWidths];
}


#pragma mark - Data Retrieval

- (void)selectCategoryForCollection:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath {
	
	int index = indexPath.section;
	
	if (index>0) {
		index--;
	}
	
	Genre *subGenre;
	
	if (indexPath.section == 1) {
		subGenre = self.recentlyViewed[indexPath.row];
	} else {
		Genre *genre = self.genres[index];
		subGenre = genre.subgenres[indexPath.row];
	}
	
	BOOL inRecentlyViewed = [self.recentlyViewed containsObject:subGenre];
	int indexOfRecent = [self.recentlyViewed indexOfObject:subGenre];
	BOOL editiorsPicks = index ==0;
	
	
	//We never add editors picks to recently viewed
 	if (!editiorsPicks) {
		[self addSubGenreToRecents:subGenre];
	}
	
	if (IS_IPAD && !editiorsPicks) {
		
		if (self.recentlyViewed.count <=numberOfRecents) {
			
			if (!inRecentlyViewed) {
				[self.categoriesCollectionView performBatchUpdates:^{
					[self insertSubGenreToRecentLyViewed:subGenre];
				} completion:^(BOOL finished) {
					[self.categoriesCollectionView reloadData];
					[self.categoriesCollectionView selectItemAtIndexPath:self.selectedCellIndex animated:NO scrollPosition:UICollectionViewScrollPositionNone];
				}];
			} else {
								
				// Dont move if item is already at the top
				if (indexOfRecent != 0) {
					[self.categoriesCollectionView moveItemAtIndexPath:[NSIndexPath indexPathForRow:indexOfRecent inSection:1] toIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
				}
				
			}
		} else {
			if (indexPath.section != 1) {
				[self.categoriesCollectionView performBatchUpdates:^{
					[self insertSubGenreToRecentLyViewed:subGenre];
					[self removeLastObjectFromRecentlyViewed];
				} completion:nil];
			}
		}
		
	}
	
	if (IS_IPHONE) {
		if (self.recentlyViewed.count > numberOfRecents) {
			[self.recentlyViewed removeLastObject];
		}
	}
	
	if (IS_IPAD) {
		[self.categoriesCollectionView reloadData];
		[self.categoriesCollectionView selectItemAtIndexPath:self.selectedCellIndex animated:NO scrollPosition:UICollectionViewScrollPositionNone];
	}
	
	
    NSString *title = (IS_IPHONE ? subGenre.name : @"");
    
    [self dispatchSearch:subGenre.uniqueId
               withTitle:title
                 forType:kSearchTypeGenre];
	
	
	[[NSUserDefaults standardUserDefaults] setObject:[self defaultsArrayFromRecents] forKey:kUserDefaultsRecentlyViewed];
	
}



- (NSMutableArray*) genreArrayFromDefaults {
	
	NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
	
	NSArray *defaultsArray = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsRecentlyViewed];
	
	
	if (!defaultsArray) {
		return [NSMutableArray new];
	}
	
	
	for (int i = 0; i < defaultsArray.count; i++) {
		Genre *subGenre = [[SYNGenreManager sharedManager] genreWithId:[defaultsArray objectAtIndex:i]];
		if (subGenre) {
			[mutableArray addObject:subGenre];
		}
	}
	return mutableArray;
}

- (NSMutableArray*) defaultsArrayFromRecents {
	
	NSMutableArray *arr = [[NSMutableArray alloc] init];
	for (Genre *genre in self.recentlyViewed) {
		[arr addObject:genre.uniqueId];
	}
	
	return arr;
}

- (void)moveSubGenreToTheTop :(Genre*) subGenre fromIndex:(NSIndexPath*) indexPath {
	
	[self.categoriesCollectionView performBatchUpdates:^{
		[self.categoriesCollectionView moveItemAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
	} completion:nil];
	
}

- (void)insertSubGenreToRecentLyViewed:(Genre *) subGenre {
	[self.categoriesCollectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:0 inSection:1]]];
}

- (void)removeLastObjectFromRecentlyViewed{
	
    [self.categoriesCollectionView performBatchUpdates:^{
        [self.recentlyViewed removeObjectAtIndex:numberOfRecents];
        NSIndexPath *indexPath =[NSIndexPath indexPathForRow:numberOfRecents-1 inSection:1];
        [self.categoriesCollectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
		
    } completion:^(BOOL finished) {
		
    }];
}



- (void)addSubGenreToRecents:(Genre*) subgenre {
	
	if ([self.recentlyViewed containsObject:subgenre]) {
		[self.recentlyViewed removeObject:subgenre];
	}
	
	[self.recentlyViewed insertObject:subgenre atIndex:0];
	
}

#pragma mark - CollectionView Delegate/Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return [self.genres count]+1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
	
	if (section == 1) {
		return self.recentlyViewed.count;
	}
	
	int index = section;
	
	if (index>0) {
		index--;
	}
	
	Genre *genre = self.genres[index];
	return [genre.subgenres count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	SYNDiscoverCategoriesCell *categoryCell = [cv dequeueReusableCellWithReuseIdentifier:[SYNDiscoverCategoriesCell reuseIdentifier]
                                                                            forIndexPath: indexPath];
	SubGenre *subGenre;
	
	
	
	int index = indexPath.section;
	
	if (index>0) {
		index--;
	}
	
	
	if (indexPath.section == 1) {
		subGenre = [self.recentlyViewed objectAtIndex:indexPath.row];

	} else {
		Genre *genre = self.genres[index];
		subGenre = genre.subgenres[indexPath.row];
	}
	
	UIColor *genreColor = [[SYNGenreManager sharedManager] colorForGenreWithId:subGenre.uniqueId];
	
	categoryCell.selectedColor = genreColor;
	categoryCell.deSelectedColor = [UIColor whiteColor];
		
    categoryCell.label.text = subGenre.name;
	
	
    return categoryCell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if (self.selectedCellIndex) {
        [collectionView selectItemAtIndexPath:self.selectedCellIndex animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        
    }
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	self.selectedCellIndex = indexPath;
    [self selectCategoryForCollection:collectionView atIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
	if (section == 1 && self.recentlyViewed.count == 0) {
		return CGSizeMake(0, 0);
	} else if (section == 0) {
        return CGSizeMake(0, 0);
    } else {
        return CGSizeMake(self.categoriesCollectionView.bounds.size.width, 45);
    }
}



- (CGSize)collectionView:(UICollectionView *)collectionView
				  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	return CGSizeMake(CGRectGetWidth(collectionView.frame), 36);
}


- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath
{
	if (kind == UICollectionElementKindSectionHeader)
    {
        SYNDiscoverSectionHeaderView *supplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind: kind
																							 withReuseIdentifier: [SYNDiscoverSectionHeaderView reuseIdentifier]
																									forIndexPath: indexPath];
		
		
		if (indexPath.section == 0) {
			
		}
		
		else if (indexPath.section == 1) {
			[supplementaryView setTitleText: kRecentlyViewed];
			
		} else {
			
			int index = indexPath.section;
			if (index>0) {
				index--;
			}
			Genre *genre = self.genres[index];
			
			[supplementaryView setTitleText: genre.name];
			
		}
		
		return supplementaryView;
    }
    
	return nil;
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
		
		
		if (UIDeviceOrientationIsPortrait([[SYNDeviceManager sharedInstance] orientation])) {
			sideWidth = 273;
		}
		self.sideContainerWidth.constant = sideWidth;
		
		[self.categoriesCollectionView.collectionViewLayout invalidateLayout];
	}
}

- (void)reloadCategories {
	self.genres = [[SYNGenreManager sharedManager] genres];
	
    [self.categoriesCollectionView reloadData];
	
	if ([self.genres count] && IS_IPAD) {
        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
		[self selectCategoryForCollection:self.categoriesCollectionView atIndexPath:firstIndexPath];
        [self.categoriesCollectionView selectItemAtIndexPath:firstIndexPath
													animated:NO
											  scrollPosition:UICollectionViewScrollPositionNone];

    }
	

}

- (void)keyboardChanged:(NSNotification *)notification {
	NSDictionary* userInfo = [notification userInfo];
	NSTimeInterval animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
	CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
	
	BOOL isShowing = [[notification name] isEqualToString:UIKeyboardWillShowNotification];
	
	CGFloat keyboardHeight = CGRectGetHeight(keyboardFrame);
	CGFloat keyboardHeightChange = (isShowing ? keyboardHeight : 0.0);
	
	UICollectionView *collectionView = self.categoriesCollectionView;
	UITableView *tableView = self.autocompleteTableView;
	
	[UIView animateWithDuration:animationDuration
						  delay:0.0f
						options:(animationCurve << 16) // convert AnimationCurve to AnimationOption
					 animations:^{
						 collectionView.contentInset = UIEdgeInsetsMake(collectionView.contentInset.top,
																		collectionView.contentInset.left,
																		keyboardHeightChange,
																		collectionView.contentInset.right);
						 tableView.contentInset = UIEdgeInsetsMake(tableView.contentInset.top,
																   tableView.contentInset.left,
																   keyboardHeightChange,
																   tableView.contentInset.right);
					 } completion:nil];
}


- (UIImage *)imageWithColor:(UIColor*) color {
	
	
	CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    CGContextSetFillColorWithColor(context, [[UIColor blueColor] CGColor]);
    CGContextFillRect(context, rect);
	
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return image;

}

- (UIImage *)searchFieldBackgroundImageForState:(UIControlState)state {
	
	
	CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    CGContextSetFillColorWithColor(context, [[UIColor blueColor] CGColor]);
    CGContextFillRect(context, rect);
	
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return image;

}


@end
