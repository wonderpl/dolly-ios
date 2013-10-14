//
//  SYNAutocompleteViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 15/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "AppConstants.h"
#import "MKNetworkOperation.h"
#import "SYNAppDelegate.h"
#import "SYNAutocompleteSuggestionsController.h"
#import "SYNNetworkEngine.h"
#import "SYNSearchBoxViewController.h"
#import "SYNTextField.h"
#import "UIFont+SYNFont.h"
#import "SYNSearchCategoriesTableViewController.h"
#import "SYNDeviceManager.h"

#define kGrayPanelBorderWidth 2.0

#define kAutocompleteTime 0.2

@interface SYNSearchBoxViewController ()

@property (nonatomic) CGFloat initialPanelHeight;
@property (nonatomic, strong) NSTimer* autocompleteTimer;
@property (nonatomic, strong) NSArray* nib;
@property (nonatomic, strong) SYNAutocompleteSuggestionsController* autoSuggestionController;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;
@property (nonatomic, weak) SYNTextField* searchTextField;
@property (nonatomic, weak) MKNetworkOperation* autocompleteNetworkOperation;
@property (nonatomic, strong) SYNSearchCategoriesTableViewController* searchCategoriesController;

@end


@implementation SYNSearchBoxViewController

@synthesize appDelegate;
@synthesize initialPanelHeight;
@synthesize searchBoxView;

#pragma mark - Object lifecycle

- (void) dealloc
{
    // Defensive programming
    self.searchTextField.delegate = nil;
    self.autoSuggestionController.tableView.delegate = nil;
}


#pragma mark - View lifecycle

- (void) loadView
{
    if (IS_IPAD || IS_IOS_7_OR_GREATER)
    {
        self.view = [SYNSearchBoxView searchBoxView];
    }
    else
    {
        self.nib =[[NSBundle mainBundle] loadNibNamed:@"SYNSearchBoxIphoneView" owner:self options:nil];
        self.view = self.nib[0];
    }    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchTyped:)
                                                 name:kSearchTyped object:nil];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kSearchTyped object:nil];
}

-(void)searchTyped:(NSNotification*)notification
{
    [self dismissSearchCategoriesIPhone];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    self.searchTextField = self.searchBoxView.searchTextField;
    self.searchTextField.delegate = self;
    
    [self.searchTextField addTarget: self
                             action: @selector(textFieldDidChange:)
                   forControlEvents: UIControlEventEditingChanged];

    self.autoSuggestionController = [[SYNAutocompleteSuggestionsController alloc] init];
    self.autoSuggestionController.tableView.delegate = self;
    
    CGRect tableViewFrame = self.autoSuggestionController.tableView.frame;
    
    if (IS_IPAD)
    {
        tableViewFrame.origin.x = self.searchTextField.frame.origin.x - 10.0;
        tableViewFrame.origin.y = 66.0;
        self.searchTextField.placeholder = @"What are you into?";
    }
    else
    {
        tableViewFrame.origin.y = self.searchBoxView.frame.size.height;
        self.searchCategoriesController = [[SYNSearchCategoriesTableViewController alloc] initWithStyle:UITableViewStylePlain];
    }
    
    self.autoSuggestionController.tableView.frame = tableViewFrame;
    self.autoSuggestionController.tableView.hidden = YES;
    
    [self.view addSubview:self.autoSuggestionController.tableView];
    
    
}
-(void)dismissSearchCategoriesIPhone
{
    if(IS_IPAD) return;
    
    __weak SYNSearchBoxViewController* wself = self;
    [UIView animateWithDuration:0.3f animations:^{

        wself.searchCategoriesController.tableView.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        
        [self.searchCategoriesController.tableView removeFromSuperview];
        [self.searchBoxView resizeForHeight: 0.0f];
        
    }];
}


- (void) presentSearchCategoriesIPhone
{
    if (IS_IPAD) return;

    [self.view insertSubview:self.searchCategoriesController.tableView atIndex:0];
    
    self.searchCategoriesController.tableView.alpha = 1.0f;
    
    [self.searchBoxView resizeForHeight: 548.0f]; // 548.0f max

    CGRect searchTBVFrame = self.searchCategoriesController.tableView.frame;
    searchTBVFrame.origin = CGPointMake(0.0f, IS_IOS_7_OR_GREATER ? 74.0f : 64.0f);
    self.searchCategoriesController.tableView.frame = searchTBVFrame;
    [self.searchCategoriesController setSize:CGSizeMake(self.view.frame.size.width,
                                                       [[SYNDeviceManager sharedInstance] currentScreenHeightWithStatusBar] - searchTBVFrame.origin.y)];

    __weak SYNSearchBoxViewController* wself = self;
    
     self.searchCategoriesController.tableView.alpha = 0.0f;
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationCurveEaseOut animations:^{
        wself.searchCategoriesController.tableView.alpha = 1.0f;
 
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - Text Field Delegate

- (void) clear
{
    if(self.autocompleteNetworkOperation)
        [self.autocompleteNetworkOperation cancel];
    
    [self.autoSuggestionController clearWords];
    
    self.autoSuggestionController.tableView.hidden = YES;
    
    if(IS_IPAD)
        [self resizeTableView: YES];
    
}


- (void) textFieldDidChange: (UITextField *) textView
{
    if([textView.text length] == 0)
    {
        [self clear];
        
    }
}


- (void) textViewDidBeginEditing: (UITextView *) textView
{
    [textView setText: @""];
}


- (BOOL) textField: (UITextField *) textField
         shouldChangeCharactersInRange: (NSRange) range
         replacementString: (NSString *) newCharacter
{
    // 1. Do not accept blank characters at the beggining of the field
    if ([newCharacter isEqualToString: @" "] && self.searchTextField.text.length == 0)
        return NO;
    
    // 2. if there are less than 3 chars currently typed do not perform search
    if ((range.location - range.length) < 2)
    {
        // close suggestion box
        [self clear];
        
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
    
    
    self.autocompleteNetworkOperation = [appDelegate.networkEngine getAutocompleteForHint: self.searchTextField.text
                                                                              forResource: appDelegate.searchEntity
                                                                             withComplete: ^(NSArray* array) {
                                                                                 
                                            NSArray* suggestionsReturned = array[1];
                                             
                                            
                                             
                                            if (suggestionsReturned.count == 0)
                                            {
                                                [self.autoSuggestionController clearWords];
                                                return;
                                            }
                                                                                  
                                            NSMutableArray* wordsReturned = [NSMutableArray array];
                                             
                                            for (NSArray* suggestion in suggestionsReturned)
                                            {
                                                if(!suggestion)
                                                    continue;
                                                
                                                [wordsReturned addObject: suggestion[0]];
                                            }
                                                                                  
                                             
                                            [self.autoSuggestionController addWords:wordsReturned];
                                             
                                            [self resizeTableView:NO];
                                             
                                            self.autoSuggestionController.tableView.hidden = NO;
                                             
                                        } andError: ^(NSError* error) {
                                        
                                        }];
}


- (void) resizeTableView:(BOOL)force
{
    if(force || [self.searchTextField isFirstResponder])
    {
        CGFloat tableViewHeight = self.autoSuggestionController.tableHeight;
        [self.searchBoxView resizeForHeight: tableViewHeight];
    }
}


- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    NSString* currentSearchTerm = self.searchTextField.text;
    
    if ([self.searchTextField.text isEqualToString: @""])
        return NO;
    
    [self.autocompleteTimer invalidate];    
    self.autocompleteTimer = nil;
    
    if(self.autocompleteNetworkOperation)
    {
        [self.autocompleteNetworkOperation cancel];
    }
    
    [self clear];
    
    
    
    // calls the MasterViewController
    [NSNotificationCenter.defaultCenter postNotificationName: kSearchTyped
                                                      object: self
                                                    userInfo: @{kSearchTerm : currentSearchTerm}];
    
    [self.searchTextField resignFirstResponder];
    
    return YES;
}


#pragma mark - TableView Delegate

- (void) tableView: (UITableView *) tableView
         didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    NSString* wordsSelected = [self.autoSuggestionController getWordAtIndex: indexPath.row];
    
    self.searchTextField.text = [wordsSelected uppercaseString];
    
    [self.autoSuggestionController clearWords];
    
    [self resizeTableView:YES];
    
    [self textFieldShouldReturn: self.searchTextField];
}


- (SYNSearchBoxView*) searchBoxView
{
    return (SYNSearchBoxView*)self.view;
}


@end
