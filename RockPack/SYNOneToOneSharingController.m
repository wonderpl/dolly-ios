//
//  SYNOneToOneSharingController.m
//  rockpack
//
//  Created by Michael Michailidis on 28/08/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "Channel.h"
#import "Friend.h"
#import "OWActivities.h"
#import "OWActivityView.h"
#import "OWActivityViewController.h"
#import "SYNAppDelegate.h"
#import "SYNFacebookManager.h"
#import "SYNOneToOneFriendCell.h"
#import "SYNOneToOneSharingController.h"
#import "SYNOneToOneSharingFriendCell.h"
#import "UIFont+SYNFont.h"
#import <UIImageView+WebCache.h>
#import "SYNMasterViewController.h"
#import "VideoInstance.h"
#import "NSString+Validation.h"
#import "UICollectionReusableView+Helpers.h"
#import "SYNWonderMailActivity.h"
#import "SYNTrackingManager.h"
#import "SYNShareOverlayViewController.h"

@import AddressBook;
@import QuartzCore;

#define kNumberOfEmptyRecentSlots 5


@interface SYNOneToOneSharingController () <UICollectionViewDataSource,
UICollectionViewDelegate,
UITextFieldDelegate,
UITableViewDataSource,
UITableViewDelegate,
UIScrollViewDelegate,
UISearchBarDelegate>
{
    BOOL displayEmailCell;
}

@property (nonatomic) BOOL hasAttemptedToLoadData;
@property (nonatomic, readonly) NSArray *searchedFriends;
@property (nonatomic, strong) Friend *friendToAddEmail;
@property (nonatomic, strong) Friend* friendHeldInQueue;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loader;
@property (nonatomic, strong) IBOutlet UICollectionView *recentFriendsCollectionView;

@property (nonatomic, strong) IBOutlet UITableView *searchResultsTableView;
@property (strong, nonatomic) IBOutlet UILabel *quickShareLabel;

@property (nonatomic, strong) IBOutlet UIView *activitiesContainerView;
@property (nonatomic, strong) NSArray *recentFriends;
@property (nonatomic, strong) NSMutableDictionary *addressBookImageCache;
@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) NSString *currentSearchTerm;
@property (nonatomic, strong) SYNNetworkOperationJsonObject* lastNetworkOperation;

@property (strong, nonatomic) IBOutlet UILabel *messageLabel;

@property (nonatomic, strong) IBOutlet UISearchBar* searchBar;

@property (strong, nonatomic) NSMutableDictionary *mutableShareDictionary;
@property (strong, nonatomic) OWActivityViewController *activityViewController;
@property (strong, nonatomic) IBOutlet UIView *textContainerView;
@property (strong, nonatomic) IBOutlet UIView *searchBarContainer;

@end


@implementation SYNOneToOneSharingController

#pragma mark - Object lifecyle


- (id) initWithInfo: (NSMutableDictionary *) mutableShareDictionary
{
    if (self = [super initWithNibName: @"SYNOneToOneSharingController"
                               bundle: nil])
    {
        self.mutableShareDictionary = mutableShareDictionary;
        
        
        self.hasAttemptedToLoadData = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardNotification:)
                                                     name:UIKeyboardWillShowNotification
         
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardNotification:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
        
    }
    
    return self;
}


#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.friends = [NSMutableArray array];
    self.recentFriends = @[];
    
    self.addressBookImageCache = [[NSMutableDictionary alloc] init];
    
    self.currentSearchTerm = @"";
    
    [self.recentFriendsCollectionView registerNib:[SYNOneToOneSharingFriendCell nib]
                       forCellWithReuseIdentifier:[SYNOneToOneSharingFriendCell reuseIdentifier]];
    
    self.searchBar.backgroundColor = [UIColor colorWithRed: 246.0f / 255.0f
                                                     green: 246.0f / 255.0f
                                                      blue: 246.0f / 255.0f
                                                     alpha: 1.0f];
    
    
    
    [self.quickShareLabel setFont:[UIFont boldCustomFontOfSize:self.quickShareLabel.font.pointSize]];
    [self.messageLabel setFont:[UIFont lightCustomFontOfSize:self.messageLabel.font.pointSize]];
    
    if (IS_IPHONE)
    {
        // resize panel for iPhone
        CGRect vFrame = self.view.frame;
        vFrame.size.width = 320.0f;
        
        self.view.frame = vFrame;
        
        
        UIEdgeInsets ei = self.searchResultsTableView.contentInset;
        ei.bottom = 58.0f;
        self.searchResultsTableView.contentInset = ei;
        
        CGRect frame = self.textContainerView.frame;
        frame.origin.x -= 49;
        self.textContainerView.frame = frame;
        
        frame = self.messageLabel.frame;
        frame.size.width = 320;
        frame.origin.x += 29;
        
        self.messageLabel.frame = frame;
        
    }
    
    
    if (IS_IPAD)
    {
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.searchBarContainer.frame byRoundingCorners:UIRectCornerTopLeft| UIRectCornerTopRight                                                         cornerRadii:CGSizeMake(10.0, 10.0)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = self.searchBarContainer.bounds;
        maskLayer.path = maskPath.CGPath;
        self.searchBarContainer.layer.mask = maskLayer;
    }

    
    // Basic recognition
    self.loader.hidden = YES;
    
    BOOL canReadAddressBook = NO;
    
    

    switch (ABAddressBookGetAuthorizationStatus())
    {
        case kABAuthorizationStatusNotDetermined:
            DebugLog(@"AddressBook Status: Not Determined, asking for authorization");
            [self requestAddressBookAuthorization];
            break;
            
        case kABAuthorizationStatusDenied:{
            [self showAlertView];
            DebugLog(@"AddressBook Status: Denied");
        }
            break;
            
        case kABAuthorizationStatusRestricted:
            DebugLog(@"AddressBook Status: Restricted");

            [self showAlertView];
            break;
            
        case kABAuthorizationStatusAuthorized:
            DebugLog(@"AddressBook Status: Authorized, fetching contacts");
            [self fetchAddressBookFriends];
            canReadAddressBook = YES;
            break;
            
        default:
            break;
    }
    
    
    // if the user is FB connected try and pull his friends
    if ([[SYNFacebookManager sharedFBManager] hasActiveSession])
    {
        DebugLog(@"The user is FB connected, trying to pull friends from server");
        displayEmailCell = YES;
        [self fetchAndDisplayFriends];
    }
    else
    {
        displayEmailCell = YES;
        
        if(!canReadAddressBook)
        {
            //TODO: Replace below
            //self.searchTextField.placeholder = @"Type an email address";
        }
        
        [self fetchAndDisplayFriends];
        self.hasAttemptedToLoadData = YES;
        [self.recentFriendsCollectionView reloadData]; // to display the add email cell
    }
    
    // always present the buttons at the bottom
    [self presentActivities];
    
    // If we don't have the share link yet, disable the share activity buttons until we receive a share link obtained notification
    if (self.mutableShareDictionary[@"url"] == [NSNull null])
    {
        // Disable the buttons if there is no share link
        [self controlsVisibleInView: self.activitiesContainerView
                            visible: FALSE];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(reEnableShareButtons)
                                                     name: kShareLinkForObjectObtained
                                                   object: nil];
        return;
    }
	
	[[SYNTrackingManager sharedManager] trackShareScreenView];
    

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[[SYNTrackingManager sharedManager] trackShareScreenView];
    
    [self.recentFriendsCollectionView reloadData];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsShareFirstTime]) {
        
        SYNShareOverlayViewController *overlay = [[SYNShareOverlayViewController alloc] init];
        [overlay addToViewController:self];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultsShareFirstTime];
    }
   
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.addressBookImageCache = nil;
}

// Recursively, enable or disable controls contained in a view
- (void) controlsVisibleInView: (UIView *) view
                       visible: (BOOL) visible
{
    // If this is a control, then consider this a leaf
    if ([view isKindOfClass: [UIControl class]])
    {
        ((UIControl *) view).enabled = visible;
        
    }
    else
    {
        // Otherwise, iterate its subviews (if any)
        for (UIView *subView in view.subviews)
        {
            [self controlsVisibleInView: subView
                                visible: visible];
        }
    }
}

// Enable the buttons when we have found a share link from the server (i.e. the network call has returned)
- (void) reEnableShareButtons
{
    
    [self controlsVisibleInView: self.activitiesContainerView
                        visible: YES];
}


- (void) keyboardNotification:(NSNotification *)notification {
	BOOL keyboardIsOnScreen = [[notification name] isEqualToString:UIKeyboardWillShowNotification];
    
    [UIView animateWithDuration: 0.3
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         // push popup up
                         CGRect vFrame = self.view.frame;
						 
						 CGRect offset = CGRectZero;
						 if (self.presentingViewController) {
							 // This will be set if we're using iOS7 view controller transitions, in which case the view isn't
							 // transformed, so we have to manually offset it along the correct axis
							 offset.origin = [self keyboardOffsetForInterfaceOrientation:self.interfaceOrientation];
                             
                             
                             
						 } else {
							 offset.origin = CGPointMake(0, -160);
						 }
						 
                         if (keyboardIsOnScreen) {
                             
							 vFrame = CGRectOffset(vFrame, offset.origin.x, offset.origin.y);
                             
                         } else {
                             
							 vFrame = CGRectOffset(vFrame, -offset.origin.x, -offset.origin.y);
                         }
                         
                         self.view.frame = vFrame;
                         
                     }
                     completion: nil];
}

- (CGPoint)keyboardOffsetForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    CGPoint point = CGPointZero;
    switch (interfaceOrientation)
    {
            
        case UIInterfaceOrientationPortrait:
        {
            point = CGPointMake(0, -160);
            if(!IS_IPHONE_5)
                point.y += 60.0f;
        }
        break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            point = CGPointMake(0, 160);
            if(!IS_IPHONE_5)
                point.y -= 60.0f;
            
        }
        break;
            
        case UIInterfaceOrientationLandscapeLeft:
        {
           point = CGPointMake(-160, 0);
        }
        break;
            
        case UIInterfaceOrientationLandscapeRight:
        {
            point = CGPointMake(160, 0);
        }
        break;
            
    }
	return point;
}


- (void) showLoader: (BOOL) show
{
    if (show)
    {
        [self.loader startAnimating];
        self.loader.hidden = NO;
        self.recentFriendsCollectionView.hidden = YES;
    }
    else
    {
        [self.loader stopAnimating];
        self.loader.hidden = YES;
        self.recentFriendsCollectionView.hidden = NO;
    }
}


- (void) presentActivities
{
    // load activities
    OWFacebookActivity *facebookActivity = [[OWFacebookActivity alloc] init];
    OWTwitterActivity *twitterActivity = [[OWTwitterActivity alloc] init];
	OWMailActivity *mailActivity = [[OWMailActivity alloc] init];
    
	NSArray *activities = @[ facebookActivity, twitterActivity, mailActivity ];
    
    if (![MFMailComposeViewController canSendMail])
    {
        mailActivity.enabled = NO;
    }
    
    self.activityViewController = [[OWActivityViewController alloc] initWithViewController: self
                                                                                activities: activities];
    
    self.activityViewController.userInfo = self.mutableShareDictionary;
    
    [self.activitiesContainerView addSubview: self.activityViewController.view];
}


- (void) requestAddressBookAuthorization
{
    CFErrorRef error = NULL;
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (addressBookRef == NULL)
    {
        return;
    }
    
    BOOL hasFacebookSession = [[SYNFacebookManager sharedFBManager] hasActiveSession];
    
    ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
        dispatch_async(dispatch_get_main_queue(), ^{
			
			[[SYNTrackingManager sharedManager] trackAddressBookPermission:granted];
			
            if (granted)
            {
                DebugLog(@"Address Book Access GRANTED");
                
                // saves the address book friends in the DB
                [self fetchAddressBookFriends];
                
                // populates the self.friends array with possibly new data
                [self fetchAndDisplayFriends];
            }
            else
            {
                DebugLog(@"Address Book Access DENIED");
                
                if (!hasFacebookSession)
                {
                }
            }
            
            if (addressBookRef)
            {
                CFRelease(addressBookRef);
            }
        });
    });
}

- (NSString *)shareType {
	return self.mutableShareDictionary[@"type"];
}

#pragma mark - Data Retrieval

- (void) fetchAndDisplayFriends
{
    __weak SYNAppDelegate *appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    __weak SYNOneToOneSharingController *weakSelf = self;
    NSError *error;
    NSMutableArray *existingFriendsArray = [[NSMutableArray alloc] init];
    
    [existingFriendsArray addObjectsFromArray:[self getFriendsOrderedByName]];
    [existingFriendsArray addObjectsFromArray:[self getFriendsOrderedByEmail]];
    
    if (!error)
    {
        [self.friends removeAllObjects];
        
        NSMutableArray *recentlySharedFriendsMutableArray = [NSMutableArray arrayWithCapacity: existingFriendsArray.count]; // maximum
        
        NSMutableDictionary *lastSharedEmail = [[NSMutableDictionary alloc]init];
        NSMutableDictionary *existingFriendsByEmail = [[NSMutableDictionary alloc]init];
        
        for (Friend *existingFriend in existingFriendsArray)
        {
            if (![existingFriendsByEmail objectForKey:existingFriend.email]) {
                [self.friends addObject: existingFriend];
                if (existingFriend.email) {
                    [existingFriendsByEmail setObject:existingFriend forKey:existingFriend.email];
                }
            }
            
            if (existingFriend.lastShareDate && existingFriend.email)
            {
				if (!lastSharedEmail[existingFriend.email]) {
                    [recentlySharedFriendsMutableArray addObject: existingFriend];
                    lastSharedEmail[existingFriend.email] = existingFriend.email;
				}

            }
        }
        
        
        // sort by date
        self.recentFriends = [recentlySharedFriendsMutableArray sortedArrayUsingComparator: ^NSComparisonResult (Friend *friendA, Friend *friendB) {
            
            return [friendB.lastShareDate compare: friendA.lastShareDate];
        }];
        
        
        if ([self.recentFriends count]>7) {
            self.recentFriends = [self.recentFriends objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 8)]];

        }
        [self.recentFriendsCollectionView reloadData];
    }
    
    if (self.lastNetworkOperation) // to avoid infinite recursion
    {
        return;
    }
    
    if (self.friends.count == 0)
    {
        [self showLoader: YES];
    }
    
    MKNKUserSuccessBlock successBlock = ^(id dictionary) {
        if ([appDelegate.searchRegistry
             registerFriendsFromDictionary: dictionary])
        {
            [weakSelf fetchAndDisplayFriends]; // this will reload the collection view
        }
        else
        {
            DebugLog(@"There was a problem loading friends");
        }
        
        self.hasAttemptedToLoadData = YES;
        
        [self showLoader: NO];
    };
    
    MKNKUserSuccessBlock failureBlock = ^(id dictionary) {
        self.hasAttemptedToLoadData = YES;
        
        [self showLoader: NO];
    };
    
    self.lastNetworkOperation = [appDelegate.oAuthNetworkEngine
                                 friendsForUser: appDelegate.currentUser
                                 onlyRecent: NO
                                 completionHandler: successBlock
                                 errorHandler: failureBlock];
}

- (NSArray*) getFriendsOrderedByName {
    
    __weak SYNAppDelegate *appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSError *error;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity: [NSEntityDescription entityForName: @"Friend"
                                         inManagedObjectContext: appDelegate.searchManagedObjectContext]];
    
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"displayName != %@", @""]];
    
    return [NSMutableArray arrayWithArray:[appDelegate.searchManagedObjectContext executeFetchRequest: fetchRequest
                                                                                                error: &error]];
}


// This gets Friends that do not have a display name
- (NSArray*)getFriendsOrderedByEmail {
    __weak SYNAppDelegate *appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity: [NSEntityDescription entityForName: @"Friend"
                                         inManagedObjectContext: appDelegate.searchManagedObjectContext]];

    fetchRequest.sortDescriptors =  @[[NSSortDescriptor sortDescriptorWithKey:@"email" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"displayName == %@", @""]];
    
    return [NSMutableArray arrayWithArray:[appDelegate.searchManagedObjectContext executeFetchRequest: fetchRequest
                                                                                                error: &error]];
}

- (void) fetchAddressBookFriends
{
    CFErrorRef error = NULL;
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (addressBookRef == NULL)
    {
        return;
    }
    
    SYNAppDelegate *appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    NSArray *arrayOfAddressBookContacts = (__bridge_transfer NSArray *) ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    
    self.addressBookImageCache = [appDelegate.searchRegistry
                                  registerFriendsFromAddressBookArray: arrayOfAddressBookContacts];
    
    CFRelease(addressBookRef);
    
    if (self.addressBookImageCache) // if there is a cache (even if it's empty) then searchRegistry completed succesfully
    {
        [self.recentFriendsCollectionView reloadData];
    }
    else
    {
        self.addressBookImageCache = [[NSMutableDictionary alloc] init]; // keep a valid cache to avoid unexpecatble crashes
    }
}


#pragma mark - UICollectionView Delegate/Data Source

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (NSInteger) collectionView: (UICollectionView *) view numberOfItemsInSection: (NSInteger) section
{
    // if we have not yet loaded, present nothing, otherwise if we have a FB connection do NOT present email cell
    return (!self.hasAttemptedToLoadData ? 0 : (displayEmailCell ? 1 : 0) + (self.recentFriends.count>3 ? self.recentFriends.count : 3));
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNOneToOneSharingFriendCell *userThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier:[SYNOneToOneSharingFriendCell reuseIdentifier]
                                                                                                forIndexPath:indexPath];
    NSInteger realIndex = indexPath.item;
    
    if (realIndex == 0)
    {
        userThumbnailCell.imageView.image = [UIImage imageNamed: @"ShareAddEntry.jpg"];
        
        [userThumbnailCell setDisplayName: @"Add New"];
        
        userThumbnailCell.imageView.alpha = 1.0f;
        
        return userThumbnailCell;
    }
    
    if (displayEmailCell)
    {
        realIndex -= 1;
    }
    
    if (realIndex < self.recentFriends.count) // real recent friends cell
    {
        Friend *friend = self.recentFriends[realIndex];
        
        NSString *nameToDisplay;
        
        if ([friend.displayName length] > 0)
        {
            nameToDisplay = friend.displayName;
            
        }
        else
        {
            nameToDisplay = friend.email;
        }
        
        if ([friend.thumbnailURL hasPrefix: @"cached://"])                     // cached from address book image
        {
            NSData *pdata = [self.addressBookImageCache
                                      objectForKey: friend.thumbnailURL];
            
            UIImage *img;
            
            if (!pdata || !(img = [UIImage imageWithData: pdata])) // address book friends with no image
            {
                img = [UIImage imageNamed: @"PlaceholderAvatarChannel"];
            }
            
            userThumbnailCell.imageView.image = img;
        }
        else if ([friend.thumbnailURL hasPrefix: @"http"]) // includes https
        {
            if ([friend.thumbnailURL rangeOfString: @"localhost"].location == NSNotFound) // is not a fake URL
            {
                [userThumbnailCell.imageView setImageWithURL: [NSURL URLWithString: friend.thumbnailURL]
                                            placeholderImage: [UIImage imageNamed: @"PlaceholderAvatarChannel"]
                                                     options: SDWebImageRetryFailed];
            }
            else if (friend.email)
            {
                userThumbnailCell.imageView.image = [UIImage imageNamed: @"PlaceholderAvatarChannel"];
            }
            else
            {
                userThumbnailCell.imageView.image = [UIImage imageNamed: @"PlaceholderAvatarChannel"];
            }
        }
        else if (friend.isOnRockpack)
        {
            userThumbnailCell.imageView.image = [UIImage imageNamed: @"PlaceholderAvatarChannel"];
        }
        else
        {
            userThumbnailCell.imageView.image = [UIImage imageNamed: @"PlaceholderAvatarChannel"];
        }
        
        [userThumbnailCell setDisplayName:nameToDisplay];
        
        
        userThumbnailCell.imageView.alpha = 1.0f;
    }
    else // on the fake slots (stubs)
    {
        userThumbnailCell.imageView.image = [UIImage imageNamed: @"RecentContactPlaceholder"];
        userThumbnailCell.nameLabel.text = @"Recent";
        
        
        CGFloat factor = 1.0f - ((float) (realIndex - self.recentFriends.count) / (8-self.recentFriends.count));
        // fade slots
        userThumbnailCell.imageView.alpha = factor;
    }
    
    return userThumbnailCell;
}


- (BOOL) collectionView: (UICollectionView *) collectionView
shouldSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    // "Recent" stub cells are not clickable...
    return indexPath.item + (displayEmailCell ? 0 : 1) <= self.recentFriends.count;
}


- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    // it will (should) only be called for indexPath.item - 1 < self.recentFriends.count so it will exclude stub cells
    
    if (indexPath.item == 0 && displayEmailCell) // first cell
    {
        [self presentAlertToFillEmailForFriend: nil];
        return;
    }
    
    Friend *friend = self.recentFriends[indexPath.row - (displayEmailCell ? 1 : 0)];
    
    
    [self sendEmailToFriend: friend];
}


#pragma mark - UITableView Delegate/Data Source

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}


- (NSInteger) tableView: (UITableView *) tableView
  numberOfRowsInSection: (NSInteger) section
{
    return self.searchedFriends.count + 1; // for add new email
}


- (UITableViewCell *) tableView: (UITableView *) tableView
          cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    SYNOneToOneFriendCell *cell = [tableView dequeueReusableCellWithIdentifier: @"SYNOneToOneFriendCell"];
    
    if (cell == nil)
    {
        cell = [[SYNOneToOneFriendCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                            reuseIdentifier: @"SYNOneToOneFriendCell"];
    }
    
    if (indexPath.row == self.searchedFriends.count) // last 'special' cell
    {
        cell.imageView.image = [UIImage imageNamed: @"ShareAddEntrySmall.jpg"];
        
        cell.textLabel.text = @"Add a new email address";
        cell.detailTextLabel.text = @"";
        cell.special = YES;
        return cell;
    }
    
    cell.special = NO;
    
    Friend *friend = self.searchedFriends[indexPath.row];
    cell.textLabel.text = friend.displayName;
    
    if (friend.isOnRockpack)
    {
        cell.detailTextLabel.text = @"Is on Wonder PL";
    }
    else if ([friend.email isValidEmail])
    {
        cell.detailTextLabel.text = friend.email;
    }
    else
    {
        cell.detailTextLabel.text = @"Pick an email address";
    }
    
    // image
    
    if ([friend.thumbnailURL hasPrefix: @"http"])                     // good for http and https
    {
        [cell.imageView setImageWithURL: [NSURL URLWithString: friend.thumbnailLargeUrl]
                       placeholderImage: [UIImage imageNamed: @"PlaceholderAvatarChannel"]
                                options: SDWebImageRetryFailed];
    }
    else if ([friend.thumbnailURL hasPrefix: @"cached://"])                                       // has been cached from the address book access
    {
        NSData *pdata = [self.addressBookImageCache
                                  objectForKey: friend.thumbnailURL];
        
        UIImage *img;
        
        if (!pdata || !(img = [UIImage imageWithData: pdata]))
        {
            img = [UIImage imageNamed: @"ABContactPlaceholder"];
        }
        
        cell.imageView.image = img;
    }
    else
    {
        cell.imageView.image = [UIImage imageNamed: @"PlaceholderAvatarChannel"];
    }
    
    
    
    return cell;
}


- (CGFloat) tableView: (UITableView *) tableView
heightForRowAtIndexPath: (NSIndexPath *) indexPath;
{
    return 50.0f;
}


- (void) tableView: (UITableView *) tableView
didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    Friend *friend;
    
    BOOL lastCellPressed = NO;
    
    if (indexPath.row < self.searchedFriends.count)
    {
        friend = self.searchedFriends[indexPath.row];
        
        if ([friend.email isValidEmail]) // has a valid email
        {
            [self sendEmailToFriend: friend];
        }
        else // no email
        {
            [self presentAlertToFillEmailForFriend: friend];
        }
    }
    else // last cell pressed
    {
        lastCellPressed = YES;
        [self presentAlertToFillEmailForFriend: nil];
    }
    
	NSString *origin = (lastCellPressed ? @"New" : ([friend.externalSystem isEqualToString: kFacebook] ? @"fromFB" : [friend.externalSystem isEqualToString: kTwitter] ? @"fromTwitter" : @"fromAB"));
    
	[[SYNTrackingManager sharedManager] trackShareFriendSearchSelect:origin];
	
    [tableView removeFromSuperview];
}


#pragma mark - UIAlertViewDelegate

- (void) presentAlertToFillEmailForFriend: (Friend *) friend
{
    SYNAppDelegate *appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSString *titleText;
    
    if (!friend) // possibly by pressing the 'add new email' cell
    {
        // create friend on the fly
        friend = [Friend insertInManagedObjectContext: appDelegate.searchManagedObjectContext];
        friend.externalSystem = @"email";
        
        titleText = @"Enter a New Email";
    }
    else
    {
        titleText = [NSString stringWithFormat: @"Enter an Email for %@", friend.displayName];
    }
    
    self.friendToAddEmail = friend; // either a newly created or
    
    NSString *message = @"";
    
    if ([self.mutableShareDictionary[@"type"] isEqualToString:@"video_instance"]) {
        message = NSLocalizedString(@"sharing_video", @"alertview message when sending a email");

    } else if ([self.mutableShareDictionary[@"type"] isEqualToString:@"channel"]){
        message = NSLocalizedString(@"sharing_collection", @"alertview message when sending a channel");
    }

    UIAlertView *prompt = [[UIAlertView alloc] initWithTitle: titleText
                                                     message: message
                                                    delegate: self
                                           cancelButtonTitle: @"Cancel"
                                           otherButtonTitles: @"Send", nil];
    
    prompt.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    prompt.delegate = self;
    
    if ([self.currentSearchTerm isValidEmail])
    {
        UITextField *textField = [prompt textFieldAtIndex: 0];
        [textField setText: self.currentSearchTerm];
    }
    
    [prompt show];
}


// as the user types in the alert box, only enable the SEND button when a valid address has been entered
- (BOOL) alertViewShouldEnableFirstOtherButton: (UIAlertView *) alertView
{
    UITextField *textfield = [alertView textFieldAtIndex: 0];
    
    return [textfield.text isValidEmail];
}


- (void) alertView: (UIAlertView *) alertView didDismissWithButtonIndex: (NSInteger) buttonIndex
{
    if (buttonIndex == 0) // cancel button pressed
        return;
    
    // Send Button has been pressed
    UITextField *textfield = [alertView textFieldAtIndex: 0];
    
    self.friendToAddEmail.email = textfield.text;
    
    if([self.friendToAddEmail.externalSystem isEqualToString:kEmail]) // otherwise it might be facebook
    {
        self.friendToAddEmail.uniqueId = self.friendToAddEmail.email;
        self.friendToAddEmail.externalUID = self.friendToAddEmail.email; // workaround the fact that we do not have a UID for this new user
    }
	
	[[SYNTrackingManager sharedManager] trackShareEmailEnteredIsNew:![self.friendToAddEmail.externalSystem isEqualToString:kFacebook]];
	
    [self sendEmailToFriend: self.friendToAddEmail];
}


#pragma mark - UISearchBar Delegate Methods


- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
	self.currentSearchTerm = @"";
    [self.searchResultsTableView removeFromSuperview];
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [self.recentFriendsCollectionView reloadData];
    
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    if([self.searchBar.text isEqualToString:@""])
    {
        [self.searchBar resignFirstResponder];
        
    }
    
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    
    [self.searchBar resignFirstResponder];
}
- (BOOL) searchBar: (UISearchBar *) searchBar shouldChangeTextInRange: (NSRange) range replacementText: (NSString *) text
{
	self.currentSearchTerm = [searchBar.text stringByReplacingCharactersInRange:range withString:text];
    
    [self.searchResultsTableView reloadData];
    
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [[SYNTrackingManager sharedManager] trackShareFriendSearch];
}

- (BOOL)searchBarShouldBeginEditing: (UISearchBar *)searchBar
{
    
    // show cancel button
    [searchBar setShowsCancelButton:YES animated:YES];
    
    // clear the current search term
	self.currentSearchTerm = @"";
    
    CGRect sResTblFrame = self.searchResultsTableView.frame;
    
    sResTblFrame.origin.y = 44.0f;
    sResTblFrame.size.height = MIN(self.view.frame.size.height, self.view.frame.size.width) - 44;
  
    self.searchResultsTableView.frame = sResTblFrame;
    
    [self.view addSubview: self.searchResultsTableView];
    [self.searchResultsTableView reloadData];
    
    return YES;
}



#pragma mark - Helper Methods

- (NSArray *) searchedFriends
{
    if (self.currentSearchTerm.length > 0)
    {
		NSString *searchTerm = self.currentSearchTerm;
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstName BEGINSWITH[cd] %@ OR lastName BEGINSWITH[cd] %@ OR email BEGINSWITH[cd] %@", searchTerm, searchTerm, searchTerm];
        
        return [self.friends filteredArrayUsingPredicate: predicate];
    }
    else
    {
        return self.friends;
    }
}


#pragma mark - Send Email
- (void) shareLinkObtained
{
    DebugLog(@"Getting the Share link completed");
    [self sendEmailToFriend: self.friendHeldInQueue];
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kShareLinkForObjectObtained
                                                  object: nil];
}


- (void) sendEmailToFriend: (Friend *) friend
{
    // check for info data
    
    if (!friend)
    {
        return;
    }
    
    [self showLoader: YES];
    
    self.view.userInteractionEnabled = NO;
    
    if (self.mutableShareDictionary[@"url"] == [NSNull null])
    {
        // not ready
        DebugLog(@"Getting the Share link did not seem to finish, registering for completion");
        
        self.friendHeldInQueue = friend;
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(shareLinkObtained)
                                                     name: kShareLinkForObjectObtained
                                                   object: nil];
        return;
    }
    
    self.friendHeldInQueue = nil;
    
    SYNAppDelegate *appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    __weak SYNOneToOneSharingController *wself = self;
	
    
    [appDelegate.oAuthNetworkEngine emailShareWithObjectType: self.mutableShareDictionary[@"type"]
                                                    objectId: self.mutableShareDictionary[@"object_id"]
                                                  withFriend: friend
                                           completionHandler: ^(id no_content) {
                                               
                                               friend.lastShareDate = [NSDate date];
                                               
                                               NSError * error;
                                               [friend.managedObjectContext save: &error];
                                               
                                               wself.friendToAddEmail = nil;
                                               
                                               [self searchBarTextDidEndEditing:self.searchBar];
                                               
                                               [self fetchAndDisplayFriends];
                                               
                                               [self showLoader: NO];
                                               
                                               NSString *typeName =
                                               [self.mutableShareDictionary[@"type"] isEqualToString: @"channel"] ? @"Collection" : @"Video";
                                               
                                               NSString *notificationText =
                                               [NSString stringWithFormat: NSLocalizedString(@"sharing_object_sent", nil), typeName];
                                               
                                               [appDelegate.masterViewController presentNotificationWithMessage:notificationText
                                                                                                        andType:NotificationMessageTypeSuccess];
                                               
											   if ([self.mutableShareDictionary[@"type"] isEqualToString:@"channel"]) {
												   [[SYNTrackingManager sharedManager] trackCollectionShareCompletedWithService:@"1to1"];
											   } else {
												   [[SYNTrackingManager sharedManager] trackVideoShareCompletedWithService:@"1to1"];
											   }
											   
											   [self dismissViewControllerAnimated:YES completion:^{
												   [appDelegate.masterViewController presentNotificationWithMessage:notificationText
																											andType:NotificationMessageTypeSuccess];
											   }];
											   
                                           } errorHandler: ^(NSDictionary *error) {
                                               
                                               NSString *title = @"Email Couldn't be Sent";
                                               NSString *reason = @"Unkown reson";
                                               NSDictionary *formErrors = error[@"form_errors"];
                                               
                                               DebugLog(@"%@", error);
                                               
                                               if (formErrors[@"email"])
                                               {
                                                   reason = @"The email could be wrong or the service down.";
                                               }
                                               
                                               if (formErrors[@"external_system"])
                                               {
                                                   reason = @"The email could be wrong or the service down.";
                                               }
                                               
                                               if (formErrors[@"object_id"])
                                               {
                                                   reason = @"The email could be wrong or the service down.";
                                               }
                                               
                                               UIAlertView *prompt = [[UIAlertView alloc] initWithTitle: title
                                                                                                message: reason
                                                                                               delegate: self
                                                                                      cancelButtonTitle: @"OK"
                                                                                      otherButtonTitles: nil];
                                               
                                               [prompt show];
                                               
                                               friend.email = nil;
                                               
                                               wself.friendToAddEmail = nil;
                                               
                                               [self showLoader: NO];
                                               
                                               self.view.userInteractionEnabled = YES;
                                               
                                           }];
}

#pragma mark - alertview

- (void) showAlertView {

    int value = [[[NSUserDefaults standardUserDefaults] valueForKey:kUserDefaultsSharingAlert] intValue];

    if (value<2) {
        
        
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sharing", @"sharing alertview title")
                                                     message:NSLocalizedString(@"sharing_message", @"sharing alert view message")
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil, nil];

        [av show];
        
        value++;
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:value] forKey:kUserDefaultsSharingAlert];
    }
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end
