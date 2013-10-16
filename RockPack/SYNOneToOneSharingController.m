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
#import "RegexKitLite.h"
#import "SYNAppDelegate.h"
#import "SYNDeviceManager.h"
#import "SYNFacebookManager.h"
#import "SYNFriendThumbnailCell.h"
#import "SYNOneToOneFriendCell.h"
#import "SYNOneToOneSharingController.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
#import "VideoInstance.h"
#import "SYNAppDelegate.h"
#import "SYNOneToOneSharingFriendCell.h"
#import <AddressBook/AddressBook.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import "GAI.h"

#define kOneToOneSharingViewId	  @"kOneToOneSharingViewId"
#define kNumberOfEmptyRecentSlots 5


@interface SYNOneToOneSharingController () <UICollectionViewDataSource,
                                            UICollectionViewDelegate,
                                            UITextFieldDelegate,
                                            UITableViewDataSource,
                                            UITableViewDelegate,
                                            UIScrollViewDelegate>
{
    BOOL displayEmailCell;
}

@property (nonatomic) BOOL hasAttemptedToLoadData;
@property (nonatomic) BOOL keyboardIsOnScreen;
@property (nonatomic) BOOL typingMode;
@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, readonly) NSArray *searchedFriends;
@property (nonatomic, strong) Friend *friendToAddEmail;
@property (nonatomic, strong) Friend* friendHeldInQueue;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loader;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* facebookLoader;
@property (nonatomic, strong) IBOutlet UIButton *authorizeFacebookButton;
@property (nonatomic, strong) IBOutlet UIButton *closeButton;
@property (nonatomic, strong) IBOutlet UICollectionView *recentFriendsCollectionView;
@property (nonatomic, strong) IBOutlet UIImageView *searchFieldFrameImageView;
@property (nonatomic, strong) IBOutlet UILabel * facebookLabel;
@property (nonatomic, strong) IBOutlet UILabel *shareLabel;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UITableView *searchResultsTableView;
@property (nonatomic, strong) IBOutlet UITextField *searchTextField;
@property (nonatomic, strong) IBOutlet UIView *activitiesContainerView;
@property (nonatomic, strong) NSArray *recentFriends;
@property (nonatomic, strong) NSCache *addressBookImageCache;
@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) NSMutableString *currentSearchTerm;
@property (nonatomic, strong) SYNNetworkOperationJsonObject* lastNetworkOperation;
@property (nonatomic, strong) UIImage *imageToShare;
@property (strong, nonatomic) NSMutableDictionary *mutableShareDictionary;
@property (strong, nonatomic) OWActivityViewController *activityViewController;

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
    
    [self.loader hidesWhenStopped];
    self.facebookLoader.hidden = YES;
    
    self.friends = [NSMutableArray array];
    self.recentFriends = @[];
    
    self.addressBookImageCache = [[NSCache alloc] init];
    
    self.currentSearchTerm = [[NSMutableString alloc] init];
    
    self.closeButton.hidden = YES;
     
    self.searchTextField.font = [UIFont rockpackFontOfSize: self.searchTextField.font.pointSize];
    self.titleLabel.font = [UIFont boldRockpackFontOfSize: self.titleLabel.font.pointSize];
    self.shareLabel.font = [UIFont rockpackFontOfSize: self.titleLabel.font.pointSize];
    
    [self.recentFriendsCollectionView registerNib: [UINib nibWithNibName: @"SYNOneToOneSharingFriendCell" bundle: nil]
                       forCellWithReuseIdentifier: @"SYNOneToOneSharingFriendCell"];
    
    self.searchFieldFrameImageView.image = [[UIImage imageNamed: @"FieldSearch"]
                                            resizableImageWithCapInsets: UIEdgeInsetsMake(2.0f, 20.0f, 2.0f, 20.0f)];

    if (IS_IPHONE)
    {
        // resize for iPhone
        CGRect vFrame = self.view.frame;
        vFrame.size.width = 320.0f;
        
        self.view.frame = vFrame;
        
        CGRect cbFrame = self.closeButton.frame;
        cbFrame.origin.x = 278.0f;
        self.closeButton.frame = cbFrame;
        
        UIEdgeInsets ei = self.searchResultsTableView.contentInset;
        ei.bottom = 58.0f;
        self.searchResultsTableView.contentInset = ei;
    }
    
    self.originalFrame = CGRectZero;
    
    // Basic recognition
    self.loader.hidden = YES;

    BOOL canReadAddressBook = NO;
    
    switch (ABAddressBookGetAuthorizationStatus())
    {
        case kABAuthorizationStatusNotDetermined:
            DebugLog(@"AddressBook Status: Not Determined, asking for authorization");
            [self requestAddressBookAuthorization];
            break;
            
        case kABAuthorizationStatusDenied:
            DebugLog(@"AddressBook Status: Denied");
            break;
            
        case kABAuthorizationStatusRestricted:
            DebugLog(@"AddressBook Status: Restricted");
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
        displayEmailCell = NO;
        [self fetchAndDisplayFriends];
    }
    else
    {
        displayEmailCell = YES;
        
        if(!canReadAddressBook)
        {
            self.searchTextField.placeholder = @"Type an email address";
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

    // Google analytics support
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set: kGAIScreenName
           value: @"Share"];
    
    [tracker send: [[GAIDictionaryBuilder createAppView] build]];
}


- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];
    
    self.originalFrame = self.view.frame;
}


// Recursively, enable or disable controls contained in a view
- (void) controlsVisibleInView: (UIView *) view
                       visible: (BOOL) visible
{
    // I this is a control, then consider this a leaf
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


- (void) reEnableShareButtons
{
    // Enable the buttons as we have now found a share link
    [self controlsVisibleInView: self.activitiesContainerView
                        visible: TRUE];
}


- (void) keyboardNotification: (NSNotification *) notification
{
    if ([[notification name] isEqualToString: UIKeyboardWillShowNotification])
    {
        self.keyboardIsOnScreen = YES;
    }
    else if ([[notification name] isEqualToString: UIKeyboardWillHideNotification])
    {
        self.keyboardIsOnScreen = NO;
    }
    
    [UIView animateWithDuration: 0.3
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         // push popup up
                         CGRect vFrame = self.view.frame;
                         
                         if (_keyboardIsOnScreen)
                         {
                             vFrame.origin.y -= 160.0f;
                         }
                         else
                         {
                             vFrame.origin.y += 160.0f;
                         }
                         
                         self.view.frame = vFrame;
                         
                         self.typingMode = _keyboardIsOnScreen; // try and set it to no when the k/bord comes down, the method will check for text
                     }
                     completion: nil];
}


- (void) setTypingMode: (BOOL) typingMode
{
    if (typingMode == _typingMode)
    {
        return;
    }
    
    // if there is still text, do not remove the close button
    if (!typingMode && self.searchTextField.text.length > 0)
    {
        return;
    }
    
    _typingMode = typingMode;
    
    [UIView animateWithDuration: 0.2
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         self.closeButton.alpha = _typingMode ? 1.0f : 0.0f;
                         
                         CGRect sfFrame = self.searchFieldFrameImageView.frame;
                         
                         if (IS_IPAD)
                         {
                             sfFrame.size.width = _typingMode ? 362.0f : 400.0f;
                         }
                         else
                         {
                             sfFrame.size.width = _typingMode ? 272.0f : 300.0f;
                         }
                         
                         self.searchFieldFrameImageView.frame = sfFrame;
                     }
                     completion: ^(BOOL finished) {
                         self.closeButton.hidden = !_typingMode; // hide when not in typing mode
                     }];
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
    
    NSMutableArray *activities = @[facebookActivity, twitterActivity].mutableCopy;
    
    if ([MFMailComposeViewController canSendMail])
    {
        OWMailActivity *mailActivity = [[OWMailActivity alloc] init];
        [activities addObject: mailActivity];
        
        // TODO: We might want to disable the email icon here if we don't have email on this device (iPod touch or non-configured email)
    }
    
    CGRect aViewFrame = CGRectZero;
    aViewFrame.size = self.activitiesContainerView.frame.size;
    
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
            if (granted)
            {
                NSLog(@"Address Book Access GRANTED");
                
                // saves the address book friends in the DB
                [self fetchAddressBookFriends];
                
                // populates the self.friends array with possibly new data
                [self fetchAndDisplayFriends];
            }
            else
            {
                NSLog(@"Address Book Access DENIED");
                
                if (!hasFacebookSession)
                {
                }
            }
            
            id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
            
            [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"goal"
                                                                   action: @"AddressBookPerm"
                                                                    label: granted ? @"accepted": @"rejected"
                                                                    value: nil] build]];
            if (addressBookRef)
            {
                CFRelease(addressBookRef);
            }
        });
    });
}


#pragma mark - Data Retrieval

- (void) fetchAndDisplayFriends
{
    __weak SYNAppDelegate *appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    __weak SYNOneToOneSharingController *weakSelf = self;
    
    NSError *error;
    NSArray *existingFriendsArray;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity: [NSEntityDescription entityForName: @"Friend"
                                         inManagedObjectContext: appDelegate.searchManagedObjectContext]];
    
    
    existingFriendsArray = [appDelegate.searchManagedObjectContext
                            executeFetchRequest: fetchRequest
                            error: &error];
    
    if (!error)
    {
        [self.friends removeAllObjects];
        
        NSMutableArray *recentlySharedFriendsMutableArray = [NSMutableArray arrayWithCapacity: existingFriendsArray.count]; // maximum
        
        for (Friend *existingFriend in existingFriendsArray)
        {
            [self.friends addObject: existingFriend];
            
            if (existingFriend.lastShareDate)
            {
                [recentlySharedFriendsMutableArray addObject: existingFriend];
            }
        }
        
        // sort by date
        self.recentFriends = [recentlySharedFriendsMutableArray sortedArrayUsingComparator: ^NSComparisonResult (Friend *friendA, Friend *friendB) {
            return [friendB.lastShareDate
                    compare: friendA.lastShareDate];
        }];

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
        self.addressBookImageCache = [[NSCache alloc] init]; // keep a valid cache to avoid unexpecatble crashes
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
    return (!self.hasAttemptedToLoadData ? 0 : (displayEmailCell ? 1 : 0) + self.recentFriends.count + kNumberOfEmptyRecentSlots);
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNOneToOneSharingFriendCell *userThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNOneToOneSharingFriendCell"
                                                                                                forIndexPath: indexPath];
    NSInteger realIndex = indexPath.item;
    
    if (realIndex == 0 && displayEmailCell)
    {
        userThumbnailCell.imageView.image = [UIImage imageNamed: @"ShareAddEntry.jpg"];
        userThumbnailCell.nameLabel.text = @"Add New";
        
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
        
        if (friend.displayName && ![friend.displayName isEqualToString: @""])
        {
            nameToDisplay = friend.displayName;
        }
        else if (friend.email && ![friend.email isEqualToString: @""])
        {
            nameToDisplay = friend.email;
        }
        else
        {
            nameToDisplay = @"";
        }
        
        if ([friend.thumbnailURL hasPrefix: @"cached://"])                     // cached from address book image
        {
            NSPurgeableData *pdata = [self.addressBookImageCache
                                      objectForKey: friend.thumbnailURL];
            
            UIImage *img;
            
            if (!pdata || !(img = [UIImage imageWithData: pdata])) // address book friends with no image
            {
                img = [UIImage imageNamed: @"ABContactPlaceholder"];
            }
            
            userThumbnailCell.imageView.image = img;
        }
        else if ([friend.thumbnailURL hasPrefix: @"http"])                                // includes https of course
        {
            if ([friend.thumbnailURL rangeOfString: @"localhost"].location == NSNotFound) // is not a fake URL
            {
                [userThumbnailCell.imageView
                 setImageWithURL: [NSURL URLWithString: friend.thumbnailURL]
                 placeholderImage: [UIImage imageNamed: @"PlaceholderAvatarChannel"]
                 options: SDWebImageRetryFailed];
            }
            else if (friend.email)
            {
                userThumbnailCell.imageView.image = [UIImage imageNamed: @"ABContactPlaceholder"];
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
            userThumbnailCell.imageView.image = [UIImage imageNamed: @"ABContactPlaceholder"];
        }
        
        userThumbnailCell.nameLabel.text = nameToDisplay;
        
        
        userThumbnailCell.imageView.alpha = 1.0f;
    }
    else // on the fake slots (stubs)
    {
        userThumbnailCell.imageView.image = [UIImage imageNamed: @"RecentContactPlaceholder"];
        userThumbnailCell.nameLabel.text = @"Recent";
        
        
        CGFloat factor = 1.0f - ((float) (realIndex - self.recentFriends.count) / (float) kNumberOfEmptyRecentSlots);
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
        cell.detailTextLabel.text = @"Is on Rockpack";
    }
    else if ([self isValidEmail: friend.email])
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
        NSPurgeableData *pdata = [self.addressBookImageCache
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
        
        if ([self isValidEmail: friend.email]) // has a valid email
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
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"goal"
                                                           action: @"SearchFriendtoShare"
                                                            label: (lastCellPressed ? @"New" : ([friend.externalSystem
                                                                                                 isEqualToString: kFacebook] ? @"fromFB" : @"fromAB"))
                                                            value: nil] build]];
    
    [tableView removeFromSuperview];
    
    self.searchTextField.text = @"";
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
        titleText = [NSString stringWithFormat: @"Enter an Email for %@", friend.firstName];
    }
    
    self.friendToAddEmail = friend; // either a newly created or
    
    UIAlertView *prompt = [[UIAlertView alloc] initWithTitle: titleText
                                                     message: @"We'll send this pack to their email."
                                                    delegate: self
                                           cancelButtonTitle: @"Cancel"
                                           otherButtonTitles: @"Send", nil];
    
    prompt.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    prompt.delegate = self;
    
    if ([self isValidEmail: self.currentSearchTerm])
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
    
    return [self isValidEmail: textfield.text];
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
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    NSString* whereFrom = [self.friendToAddEmail.externalSystem isEqualToString:kFacebook] ? @"fromFB" : @"New";
    
    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"goal"
                                                           action: @"ProvideEmailtoShare"
                                                            label: whereFrom
                                                            value: nil] build]];
    
    [self sendEmailToFriend: self.friendToAddEmail];
}


#pragma mark - UITextFieldDelegate

- (BOOL) textField: (UITextField *) textField shouldChangeCharactersInRange: (NSRange) range replacementString: (NSString *) newCharacter
{
    NSUInteger oldLength = textField.text.length;
    NSUInteger newCharacterLength = newCharacter.length;
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = (oldLength + newCharacterLength) - rangeLength;
    
    self.currentSearchTerm = [NSMutableString stringWithString: textField.text];
    
    if (oldLength < newLength)
    {
        [self.currentSearchTerm appendString: newCharacter];
    }
    else
    {
        [self.currentSearchTerm deleteCharactersInRange: NSMakeRange(self.currentSearchTerm.length - 1, 1)];
    }

    [self.searchResultsTableView reloadData];
    
    return YES;
}


- (NSArray *) searchedFriends
{
    if (self.currentSearchTerm.length > 0)
    {
        NSPredicate *searchPredicate = [NSPredicate predicateWithBlock: ^BOOL (Friend *friend, NSDictionary *bindings) {
            // either first or last name matches
            return ([[friend.firstName uppercaseString] hasPrefix: [self.currentSearchTerm uppercaseString]]) ||
            ([[friend.lastName uppercaseString] hasPrefix: [self.currentSearchTerm uppercaseString]]);
        }];
        
        return [self.friends filteredArrayUsingPredicate: searchPredicate];
    }
    else
    {
        return self.friends;
    }
}


- (BOOL) textFieldShouldBeginEditing: (UITextField *) textField
{
    self.currentSearchTerm = [NSMutableString stringWithString:@""];
    
    CGRect sResTblFrame = self.searchResultsTableView.frame;
    
    sResTblFrame.origin.y = 104.0f;
    sResTblFrame.size.height = self.view.frame.size.height - sResTblFrame.origin.y;
    
    self.searchResultsTableView.frame = sResTblFrame;

    [self.view addSubview: self.searchResultsTableView];
    
    [self.searchResultsTableView reloadData];
    
    self.closeButton.hidden = NO;
    self.closeButton.alpha = 0.0f;
    
    self.typingMode = YES;
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"goal"
                                                           action: @"SearchFriendtoShare"
                                                            label: nil
                                                            value: nil] build]];
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.searchTextField resignFirstResponder];
    
    return YES;
}


#pragma mark - Button Delegates

- (IBAction) closeButtonPressed: (id) sender
{
    self.searchTextField.text = @"";
    [self.searchResultsTableView removeFromSuperview];
    [self.searchTextField resignFirstResponder];
    self.closeButton.hidden = YES;
    self.typingMode = NO; // this should animate the search box back to full length
}


- (IBAction) authorizeFacebookButtonPressed: (UIButton *) button
{
    button.hidden = YES;
    self.facebookLoader.hidden = NO;
    [self.facebookLoader startAnimating];
    __weak SYNAppDelegate *weakAppDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    SYNFacebookManager *facebookManager = [SYNFacebookManager sharedFBManager];
    
    [facebookManager loginOnSuccess: ^(NSDictionary < FBGraphUser > *dictionary) {
        FBAccessTokenData *accessTokenData = [[FBSession activeSession] accessTokenData];
        
        [weakAppDelegate.oAuthNetworkEngine
         connectFacebookAccountForUserId: weakAppDelegate.currentUser.uniqueId
         andAccessTokenData: accessTokenData
         completionHandler: ^(id noResponce) {
             [self fetchAndDisplayFriends];
             
             self.facebookLoader.hidden = YES;
             [self.facebookLoader stopAnimating];
             
             button.hidden = NO;
         }
         
         
         errorHandler: ^(id error) {
             button.hidden = NO;
             
             self.facebookLoader.hidden = YES;
             [self.facebookLoader stopAnimating];
             
             NSString *message;
             
             if ([error isKindOfClass: [NSDictionary class]] && (message = error[@"message"]))
             {
                 if ([message isEqualToString: @"External account mismatch"])
                 {
                     self.facebookLabel.text = @"Log in failed. This account seems to be associated with a different User.";
                 }
             }
             
             [[SYNFacebookManager sharedFBManager] logoutOnSuccess: ^{
             } onFailure: ^(NSString *errorMessage) {
             }];
         }];
    }  onFailure: ^(NSString *errorString) {
        self.facebookLabel.text = @"Log in with Facebook was cancelled.";
        self.facebookLoader.hidden = YES;
        [self.facebookLoader stopAnimating];
        button.hidden = NO;
    }];
}


#pragma mark - Helper Methods

- (BOOL) isValidEmail: (NSString *) emailCandidate
{
    return [emailCandidate isMatchedByRegex: @"^([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})$"];
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
    
    [self.searchTextField resignFirstResponder];
    
    SYNAppDelegate *appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    __weak SYNOneToOneSharingController *wself = self;
    
    [appDelegate.oAuthNetworkEngine
     emailShareWithObjectType: self.mutableShareDictionary[@"type"]
     objectId: self.mutableShareDictionary[@"object_id"]
     withFriend: friend
     completionHandler: ^(id no_content) {
         friend.lastShareDate = [NSDate date];                                // update the date
         
         BOOL foundFriend = NO;
         
         for (Friend * loadedFriend in self.friends)
         {
             if ([loadedFriend.email isEqualToString: friend.email])
             {
                 foundFriend = YES;
                 loadedFriend.lastShareDate = friend.lastShareDate;
             }
         }
         
         if (foundFriend)
         {
             [friend.managedObjectContext deleteObject: friend];
         }
         
         NSError * error;
         [friend.managedObjectContext save: &error];
         
         wself.friendToAddEmail = nil;
         
         wself.view.userInteractionEnabled = YES;
         
         [self fetchAndDisplayFriends];
         
         [self showLoader: NO];
         
         NSString *typeName = [self.mutableShareDictionary[@"type"] isEqualToString: @"channel"] ? @"Pack" : @"Video";
         
         NSString *notificationText = [NSString stringWithFormat: NSLocalizedString(@"sharing_object_sent", nil), typeName];
         
         [appDelegate.viewStackManager presentSuccessNotificationWithMessage: notificationText];
         [appDelegate.viewStackManager removePopoverView];
         
         id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
         NSString *actionType =
         [self.mutableShareDictionary[@"type"] isEqualToString: @"channel"] ? @"channelShared" : @"videoShared";
         
         [tracker send: [[GAIDictionaryBuilder  createEventWithCategory: @"goal"
                                                                 action: actionType
                                                                  label: @"1to1"
                                                                  value: nil] build]];
     } errorHandler: ^(NSDictionary *error) {
         NSString *title = @"Email Couldn't be Sent";
         NSString *reason = @"Unkown reson";
         NSDictionary *formErrors = error[@"form_errors"];
         
         NSLog(@"%@", error);
         
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
         
         UIAlertView *prompt = [[UIAlertView alloc]	 initWithTitle: title
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


- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end
