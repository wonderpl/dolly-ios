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
#import "SYNDiscoverCategoriesCell.h"

#define kAutocompleteTime 0.2

static NSString* kCategoryCellIndetifier = @"SYNDiscoverCategoriesCell";
static NSString *kAutocompleteCellIdentifier = @"SYNSearchAutocompleteTableViewCell";

@interface SYNDiscoverViewController () < UICollectionViewDataSource, UICollectionViewDelegate,
                                        UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIImageView* searchFieldBGImageView;
@property (nonatomic, strong) IBOutlet UITextField* searchField;
@property (nonatomic, strong) IBOutlet UIButton* searchCloseButton;

// Categories Stuff
@property (nonatomic, strong) IBOutlet UICollectionView* categoriesCollectionView;
@property (nonatomic, strong) NSArray* genres;

// Autocomplete Stuff
@property (nonatomic, strong) NSTimer* autocompleteTimer;
@property (nonatomic, weak) MKNetworkOperation* autocompleteNetworkOperation;
@property (nonatomic, strong) NSArray* autocompleteSuggestionsArray;
@property (nonatomic, strong) IBOutlet UITableView* autocompleteTableView;

@property (nonatomic, strong) IBOutlet UIView* sideContainerView;

@property (nonatomic, strong) SYNSearchResultsViewController* searchResultsController;

@property (nonatomic, strong) NSDictionary* colorMapForCells;

@end

@implementation SYNDiscoverViewController






- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.colorMapForCells = @{
                              @"" : @""
                              
                              
                              };
    
    self.autocompleteTableView.hidden = YES;
    
    
    // == Set the Collection View's Cells == //
    
    
    [self.categoriesCollectionView registerNib: [UINib nibWithNibName: kCategoryCellIndetifier bundle: nil]
                    forCellWithReuseIdentifier: kCategoryCellIndetifier];
    
    
    
    // set the image here instead of the XIB to make it streachable
    self.searchFieldBGImageView.image = [[UIImage imageNamed: @"FieldSearch"]
                                 resizableImageWithCapInsets: UIEdgeInsetsMake(0.0f,20.0f, 0.0f, 20.0f)];
    
    
    self.searchField.font = [UIFont lightCustomFontOfSize: self.searchField.font.pointSize];
    self.searchField.textColor = [UIColor colorWithRed: 40.0/255.0 green: 45.0/255.0 blue: 51.0/255.0 alpha: 1.0];
    self.searchField.layer.shadowOpacity = 1.0;
    self.searchField.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.searchField.layer.shadowOffset = CGSizeMake(0.0f,1.0f);
    self.searchField.layer.shadowRadius = 0.0f;
    self.searchField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchField.clearButtonMode = UITextFieldViewModeNever;
    
    // Display Search instead of Return on iPhone Keyboard
    self.searchField.returnKeyType = UIReturnKeySearch;
    
    self.autocompleteSuggestionsArray = [NSArray array]; // just so we have an array to return count == 0
    
    
    // == Handle Search Results Controller for iPad (integrated in the view), for iPhone it is loaded upon demand as a different page
    
    self.searchResultsController = [[SYNSearchResultsViewController alloc] initWithViewId:kSearchViewId];
    CGRect resultsFrame = CGRectZero;
    
    if(IS_IPAD)
    {
        
        resultsFrame.origin.x = self.sideContainerView.frame.origin.x + self.sideContainerView.frame.size.width;
        resultsFrame.origin.y = 0.0f;
        resultsFrame.size.width = [[SYNDeviceManager sharedInstance] currentScreenWidth] - resultsFrame.origin.x;
        resultsFrame.size.height = [[SYNDeviceManager sharedInstance] currentScreenHeight];
        
        
        [self addChildViewController: self.searchResultsController]; // containment
        [self.view addSubview: self.searchResultsController.view];
        
        
    }
    else // IS_IPHONE
    {
        
        resultsFrame.size = [[SYNDeviceManager sharedInstance] currentScreenSize];
        
        
    }
    
    self.searchResultsController.view.frame = resultsFrame;
    
    // == Load and Display Categories == //
    
    [self fetchCategories];
    
    
    [self.categoriesCollectionView reloadData];
    
    // == Since this is method is called once use it to update the categories == //
    
    [self loadCategories];
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
    
    
    categoryCell.backgroundColor = [UIColor redColor];
    
    categoryCell.label.text = subgenre.name;
    
    
    return categoryCell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SubGenre* selectedGenre = self.genres[indexPath.item];
    
    [self dispatchSearch:selectedGenre.name];
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
}

#pragma mark - UITextField Delegate and Autocomplete Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [self dispatchSearch:textField.text];
    
    return YES;
}

- (void) textViewDidBeginEditing: (UITextView *) textView
{
    [textView setText: @""];
}


- (BOOL) textField: (UITextField *) textField shouldChangeCharactersInRange: (NSRange) range replacementString: (NSString *) newCharacter
{
    // 1. Do not accept blank characters at the beggining of the field
    if ([newCharacter isEqualToString: @" "] && self.searchField.text.length == 0)
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
    
    self.autocompleteNetworkOperation = [appDelegate.networkEngine getAutocompleteForHint: self.searchField.text
                                                                              forResource: appDelegate.searchEntity
                                                                             withComplete: processBlock
                                                                                 andError: errorBlock];
}


- (void) dispatchSearch:(NSString*)searchTerm
{
    [self.searchResultsController searchForString:searchTerm];
    
    if(IS_IPHONE)
    {
        [self.navigationController pushViewController:self.searchResultsController
                                             animated:YES];
        
        
    }
}

#pragma mark - Close Button Delegates

-(IBAction)closeButtonPressed:(id)sender
{
    [self clearSearch];
}

-(void)clearSearch
{
    self.searchField.text = @"";
    self.autocompleteTableView.hidden = YES;
}

#pragma mark - Rotation Callbacks

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    CGRect sideContainerFrame = self.sideContainerView.frame;
    sideContainerFrame.size.width = UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ? 342.0f : 300.0f;
    self.sideContainerView.frame = sideContainerFrame;
}
@end
