//
//  SYNSearchViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 15/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNSearchAutocompleteTableViewCell.h"
#import "Genre.h"


#define kAutocompleteTime 0.2

@interface SYNSearchViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) IBOutlet UIImageView* searchFieldBGImageView;
@property (nonatomic, strong) IBOutlet UITextField* searchField;
@property (nonatomic, strong) IBOutlet UIButton* searchCloseButton;

// Categories Stuff
@property (nonatomic, strong) IBOutlet UICollectionView* categoriesCollectionView;
@property (nonatomic, strong) NSArray* categoriesDataArray;

// Autocomplete Stuff
@property (nonatomic, strong) NSTimer* autocompleteTimer;
@property (nonatomic, weak) MKNetworkOperation* autocompleteNetworkOperation;
@property (nonatomic, strong) NSArray* autocompleteSuggestionsArray;
@property (nonatomic, strong) IBOutlet UITableView* autocompleteTableView;

@end

@implementation SYNSearchViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set the image here instead of the XIB to make it streachable
    self.searchFieldBGImageView.image = [[UIImage imageNamed: @"FieldSearch"]
                                            resizableImageWithCapInsets: UIEdgeInsetsMake(0.0f,20.0f, 0.0f, 20.0f)];
    
    self.searchField.font = [UIFont rockpackFontOfSize: self.searchField.font.pointSize];
    self.searchField.textColor = [UIColor colorWithRed: 40.0/255.0 green: 45.0/255.0 blue: 51.0/255.0 alpha: 1.0];
    self.searchField.layer.shadowOpacity = 1.0;
    self.searchField.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.searchField.layer.shadowOffset = CGSizeMake(0.0f,1.0f);
    self.searchField.layer.shadowRadius = 0.0f;
    self.searchField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    // Display Search instead of Return on iPhone Keyboard
    self.searchField.returnKeyType = UIReturnKeySearch;
    
    self.autocompleteSuggestionsArray = [NSArray array]; // just so we have an array to return count == 0
    
    // == Load and Display Categories == //
    
    [self loadCategories];
    
    [self.categoriesCollectionView reloadData];
}

#pragma mark - Data Retrieval

- (void) loadCategories
{
    NSEntityDescription* categoryEntity = [NSEntityDescription entityForName: @"Genre"
                                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    
    NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
    [categoriesFetchRequest setEntity:categoryEntity];
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"priority" ascending:NO];
    [categoriesFetchRequest setSortDescriptors:@[sortDescriptor]];
    
    categoriesFetchRequest.includesSubentities = NO; // No SubGenres
    
    
    NSError* error;
    
    NSArray* genresFetchedArray = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                      error: &error];
    
    self.categoriesDataArray = [NSArray arrayWithArray:genresFetchedArray];
    
}

#pragma mark - CollectionView Delegate/Data Source

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}

- (NSInteger) collectionView: (UICollectionView *) view numberOfItemsInSection: (NSInteger) section
{
    return self.categoriesDataArray.count;
}



- (UICollectionViewCell *) collectionView: (UICollectionView *) cv cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    Genre* genre = self.categoriesDataArray[indexPath.item];
    
    
    return [[UICollectionViewCell alloc] init];
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Genre* selectedGenre = self.categoriesDataArray[indexPath.item];
}


#pragma mark - UITableView Delegate/Data Source

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    return self.autocompleteSuggestionsArray.count;
}


- (UITableViewCell *) tableView: (UITableView *) tableView
          cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;
    
    if (!(cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier]))
        cell = [[SYNSearchAutocompleteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    cell.textLabel.text = [((NSString*)self.autocompleteSuggestionsArray[indexPath.row]) capitalizedString];
    
    return cell;
}


#pragma mark - TextField Delegate and Autocomplete Methods

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
    
    __weak SYNSearchViewController* wself = self;
    
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
        
    };
    
    
    MKNKErrorBlock errorBlock = ^(NSError* error) {
        
    };
    
    // == Make and Save the Request == //
    
    self.autocompleteNetworkOperation = [appDelegate.networkEngine getAutocompleteForHint: self.searchField.text
                                                                              forResource: appDelegate.searchEntity
                                                                             withComplete: processBlock
                                                                                 andError: errorBlock];
}

@end
