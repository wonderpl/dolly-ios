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
#import <AddressBook/AddressBook.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#define kOneToOneSharingViewId	  @"kOneToOneSharingViewId"
#define kNumberOfEmptyRecentSlots 5


@interface SYNOneToOneSharingController () <UICollectionViewDataSource,
                                            UICollectionViewDelegate,
                                            UITextFieldDelegate,
                                            UITableViewDataSource,
                                            UITableViewDelegate>

@property (nonatomic, readonly) BOOL isInAuthorizationScreen;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loader;
@property (nonatomic, strong) IBOutlet UIButton *authorizeAddressBookButton;
@property (nonatomic, strong) IBOutlet UIButton *authorizeFacebookButton;
@property (nonatomic, strong) IBOutlet UIButton *closeButton;
@property (nonatomic, strong) IBOutlet UICollectionView *recentFriendsCollectionView;
@property (nonatomic, strong) IBOutlet UIImageView *searchFieldFrameImageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UITableView *searchResultsTableView;
@property (nonatomic, strong) IBOutlet UITextField *searchTextField;
@property (nonatomic, strong) IBOutlet UITextView *messageTextView;
@property (nonatomic, strong) IBOutlet UIView *activitiesContainerView;
@property (nonatomic, strong) IBOutlet UIView *authorizationView;
@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) NSArray *recentFriends;
@property (nonatomic, strong) NSArray *searchedFriends;
@property (nonatomic, strong) NSCache *addressBookImageCache;
@property (nonatomic, strong) NSMutableString *currentSearchTerm;
@property (nonatomic, strong) UIImage *imageToShare;
@property (nonatomic, weak) Friend *friendToAddEmail;
@property (strong, nonatomic) NSMutableDictionary *mutableShareDictionary;
@property (strong, nonatomic) OWActivityViewController *activityViewController;

@end


@implementation SYNOneToOneSharingController


- (id) initWithInfo: (NSMutableDictionary *) mutableShareDictionary
{
    if (self = [super initWithNibName: @"SYNOneToOneSharingController"
                               bundle: nil])
    {
        self.mutableShareDictionary = mutableShareDictionary;
    }
    
    return self;
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.loader hidesWhenStopped];
    
    self.friends = [NSArray array];
    self.recentFriends = [NSArray array];
    self.searchedFriends = [NSArray array];
    
    self.addressBookImageCache = [[NSCache alloc] init];
    
    self.currentSearchTerm = [[NSMutableString alloc] init];
    
    self.closeButton.hidden = YES;
    
    self.messageTextView.font = [UIFont rockpackFontOfSize: self.messageTextView.font.pointSize];
    self.searchTextField.font = [UIFont rockpackFontOfSize: self.searchTextField.font.pointSize];
    self.titleLabel.font = [UIFont boldRockpackFontOfSize: self.titleLabel.font.pointSize];
    
    [self.recentFriendsCollectionView registerNib: [UINib nibWithNibName: @"SYNFriendThumbnailCell" bundle: nil]
                       forCellWithReuseIdentifier: @"SYNFriendThumbnailCell"];
    
    self.searchFieldFrameImageView.image = [[UIImage imageNamed: @"FieldSearch"]
                                            resizableImageWithCapInsets: UIEdgeInsetsMake(0.0f, 20.0f, 0.0f, 20.0f)];
    
    if (IS_IPHONE)
    {
        // resize for iPhone
        CGRect vFrame = self.view.frame;
        vFrame.size.width = 320.0f;
        
        self.view.frame = vFrame;
        
        CGRect cbFrame = self.closeButton.frame;
        cbFrame.origin.x = 378.0f;
        self.closeButton.frame = cbFrame;
    }
}


- (BOOL) isInAuthorizationScreen
{
    return (BOOL) (self.authorizationView.superview != nil);
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    // Basic recognition
    self.loader.hidden = YES;
    
    BOOL hasFacebookSession = [[SYNFacebookManager sharedFBManager] hasActiveSession];
    ABAuthorizationStatus aBookAuthStatus = ABAddressBookGetAuthorizationStatus();
    
    if (aBookAuthStatus != kABAuthorizationStatusAuthorized)
    {
        // if it is the first time we are requesting authorization
        if (aBookAuthStatus == kABAuthorizationStatusNotDetermined)
        {
            // request authorization
            [self requestAddressBookAuthorization];
        }
        
        // in the meantime...
        if (!hasFacebookSession) // if there is neither a FB account
        {
            // present view with the two buttons
            [self presentAuthorizationScreen];
        }
        else
        {
            // load friends asynchronously and add them to the friends list when done
            [self fetchFriends];
            
            [self presentActivities];
        }
    }
    else // (status == kABAuthorizationStatusAuthorized)
    {
        // present main view
        [self fetchAddressBookFriends];
            
        if (hasFacebookSession)
        {
            // Pull up recently shared friends...
            [self fetchFriends];
        }
        
        [self presentActivities];
    }
}


- (void) presentActivities
{
    [self fetchFriends];
    
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
                               
                               // populates the friends array
                               [self fetchAddressBookFriends];
                               
                               // if in auth mode
                               if (self.isInAuthorizationScreen)
                               {
                                   [self.authorizationView removeFromSuperview];
                               }
                           }
                           else
                           {
                               NSLog(@"Address Book Access DENIED");
                               
                               if (!hasFacebookSession)
                               {
                                   [self presentAuthorizationScreen];
                               }
                           }
                           
                           CFRelease(addressBookRef);

                       });
          });
}


- (void) presentAuthorizationScreen
{
    CGRect aViewRect = self.authorizationView.frame;
    
    aViewRect.origin.y = 50.0f;
    self.authorizationView.frame = aViewRect;
    [self.view addSubview: self.authorizationView];
}


#pragma mark - Data Retrieval

- (void) fetchFriends
{
    __weak SYNOneToOneSharingController *weakSelf = self;
    SYNAppDelegate *appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    self.loader.hidden = NO;
    [self.loader startAnimating];
    
    [appDelegate.oAuthNetworkEngine friendsForUser: appDelegate.currentUser
                                            recent: NO
                                 completionHandler: ^(id dictionary) {
                                     NSDictionary *usersDictionary = dictionary[@"users"];
                                     
                                     if (!usersDictionary)
                                     {
                                         return;
                                     }
                                     
                                     NSArray *itemsDictionary = usersDictionary[@"items"];
                                     
                                     if (!itemsDictionary)
                                     {
                                         return;
                                     }
                                     
                                     NSInteger friendsCount = itemsDictionary.count;
                                     
                                     NSMutableArray *fbFriendsMutableArray = [NSMutableArray arrayWithArray: self.friends];
                                     NSMutableArray *rFriendsMutableArray = [NSMutableArray arrayWithCapacity: friendsCount]; // max
                                     
                                     for (NSDictionary * itemDictionary in itemsDictionary)
                                     {
                                         Friend *friend = [Friend instanceFromDictionary: itemDictionary
                                                               usingManagedObjectContext: appDelegate.searchManagedObjectContext];
                                         
                                         if (!friend || !friend.hasIOSDevice)  // filter for users with iOS devices only
                                         {
                                             return;
                                         }
                                         
                                         [fbFriendsMutableArray addObject: friend];
                                         
                                         // parse date for recent
                                         
                                         if (friend.lastShareDate)
                                         {
                                             [rFriendsMutableArray addObject: friend];
                                         }
                                     }
                                     
                                     weakSelf.friends = [NSArray arrayWithArray: fbFriendsMutableArray]; // already contains the original friends
                                     
                                     weakSelf.recentFriends = [NSArray arrayWithArray: rFriendsMutableArray];
                                     
                                     [self.loader stopAnimating];
                                     self.loader.hidden = YES;
                                     
                                     [self.recentFriendsCollectionView reloadData];
                                 } errorHandler: ^(id dictionary) {
                                     [self.loader stopAnimating];
                                     self.loader.hidden = YES;
                                 }];
}


- (void) fetchAddressBookFriends
{
    CFErrorRef error = NULL;
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (addressBookRef == NULL)
    {
        return;
    }
    
    NSArray *arrayOfAllPeople = (__bridge_transfer NSArray *) ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    
    SYNAppDelegate *appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSInteger total = [arrayOfAllPeople count];
    NSString *firstName, *lastName;
    NSData *imageData;
    Friend *contactFriend;
    NSMutableArray *friendsArrayMut = [NSMutableArray arrayWithArray: self.friends];
    
    for (NSUInteger peopleCounter = 0; peopleCounter < total; peopleCounter++)
    {
        ABRecordRef currentPerson = (__bridge ABRecordRef) [arrayOfAllPeople objectAtIndex: peopleCounter];
        ABRecordID cid;
        
        if (!currentPerson || ((cid = ABRecordGetRecordID(currentPerson)) == kABRecordInvalidID))
            continue;
        
        
        ABMultiValueRef emailAddressMultValue = ABRecordCopyValue(currentPerson, kABPersonEmailProperty);
        NSArray *emailAddresses = (__bridge NSArray *) ABMultiValueCopyArrayOfAllValues(emailAddressMultValue);
        CFRelease(emailAddressMultValue);
        
        if(emailAddresses.count > 0) // only keep contacts with email addresses
            continue;
        
        firstName = (__bridge_transfer NSString *) ABRecordCopyValue(currentPerson, kABPersonFirstNameProperty);
        lastName = (__bridge_transfer NSString *) ABRecordCopyValue(currentPerson, kABPersonLastNameProperty);
        
        
        imageData = (__bridge_transfer NSData *) ABPersonCopyImageData(currentPerson);
        
        contactFriend = [Friend insertInManagedObjectContext: appDelegate.searchManagedObjectContext];
        contactFriend.viewId = kOneToOneSharingViewId;
        contactFriend.uniqueId = [NSString stringWithFormat: @"%i", cid];
        contactFriend.displayName = [NSString stringWithFormat: @"%@ %@", firstName, lastName];
        contactFriend.email =  (NSString*)emailAddresses[0]; // we are guaranteed to have at least one due to the conditional above
        contactFriend.externalSystem = @"email";
        contactFriend.externalUID = [NSString stringWithFormat: @"%i", cid];
        
        if (imageData)
        {
            NSString *key = [NSString stringWithFormat: @"cached://%@", contactFriend.uniqueId];
            contactFriend.thumbnailURL = key;
            
            [self.addressBookImageCache setObject: imageData
                                           forKey: key];
        }
        
        [friendsArrayMut addObject: contactFriend];
    }
    
    self.friends = [NSArray arrayWithArray: friendsArrayMut]; // already contains the original friends
    
    CFRelease(addressBookRef);
    
    [self.recentFriendsCollectionView reloadData]; // in case we have found new images
}


#pragma mark - UICollectionView Delegate/Data Source

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (NSInteger) collectionView: (UICollectionView *) view numberOfItemsInSection: (NSInteger) section
{
    return self.recentFriends.count + kNumberOfEmptyRecentSlots; // slots for the recent fake items
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNFriendThumbnailCell *userThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNFriendThumbnailCell"
                                                                                          forIndexPath: indexPath];
    
    if (indexPath.item < self.recentFriends.count)
    {
        Friend *friend = self.recentFriends[indexPath.row];
        userThumbnailCell.nameLabel.text = friend.displayName;
        
        if ([friend.thumbnailURL
             hasPrefix: @"cached://"])
        {
            NSPurgeableData *pdata = [self.addressBookImageCache objectForKey: friend.thumbnailURL];
            
            UIImage *img;
            
            if (!pdata || !(img = [UIImage imageWithData: pdata]))
            {
                img = [UIImage imageNamed: @"ABContactPlaceholder"];
            }
            
            userThumbnailCell.imageView.image = img;
        }
        else
        {
            [userThumbnailCell.imageView setImageWithURL: [NSURL URLWithString: friend.thumbnailLargeUrl]
                                        placeholderImage: [UIImage imageNamed: @"PlaceholderAvatarChannel"]
                                                 options: SDWebImageRetryFailed];
        }
        
        [userThumbnailCell setDisplayName: friend.displayName];
        
        userThumbnailCell.imageView.alpha = 1.0f;
        userThumbnailCell.shadowImageView.alpha = 1.0f;
    }
    else // on the fake slots
    {
        userThumbnailCell.imageView.image = [UIImage imageNamed: @"RecentContactPlaceholder"];
        userThumbnailCell.nameLabel.text = @"Recent";
        // userThumbnailCell.backgroundColor = [UIColor redColor];
        
        CGFloat factor = 1.0f - ((float) (indexPath.row - self.recentFriends.count) / (float) kNumberOfEmptyRecentSlots);
        // fade slots
        userThumbnailCell.imageView.alpha = factor;
        userThumbnailCell.shadowImageView.alpha = factor;
    }
    
    return userThumbnailCell;
}


- (BOOL) collectionView: (UICollectionView *) collectionView
         shouldSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    // "Recent" stub cells are not clickable...
    
    return indexPath.item < self.recentFriends.count;
}


- (void)	  collectionView: (UICollectionView *) collectionView
          didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    // it will (should) only be called for indexPath.item < self.recentFriends.count
    
    Friend *friend = self.recentFriends[indexPath.row];
    
    if ([friend.externalSystem isEqualToString: kEmail])
    {
        [self sendEmailToFriend: friend];
    }
    else if ([friend.externalSystem isEqualToString: kFacebook])
    {
        // do facebook stuff
    }
}


#pragma mark - UITableView Delegate/Data Source

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}


- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    return self.searchedFriends.count + 1; // for add new email
}


- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    SYNOneToOneFriendCell *cell = [tableView dequeueReusableCellWithIdentifier: @"SYNOneToOneFriendCell"];
    
    if (cell == nil)
    {
        cell = [[SYNOneToOneFriendCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                            reuseIdentifier: @"SYNOneToOneFriendCell"];
    }
    
    // set the labels on the cell
    
    if (indexPath.row < self.searchedFriends.count)
    {
        Friend *friend = self.searchedFriends[indexPath.row];
        cell.textLabel.text = friend.displayName;
        
        if ([self isValidEmail: friend.email])
        {
            cell.detailTextLabel.text = friend.email;
        }
        else
        {
            cell.detailTextLabel.text = @"Pick and email address";
        }
        
        // image
        
        if ([friend.thumbnailURL hasPrefix: @"http"])                   // good for http and https
        {
            [cell.imageView
             setImageWithURL: [NSURL URLWithString: friend.thumbnailLargeUrl]
             placeholderImage: [UIImage imageNamed: @"PlaceholderAvatarChannel"]
             options: SDWebImageRetryFailed];
        }
        else if ([friend.thumbnailURL hasPrefix: @"cached://"])                   // has been cached from the address book access
        {
            NSPurgeableData *pdata = [self.addressBookImageCache objectForKey: friend.thumbnailURL];
            
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
    }
    else // special last "add new email cell"
    {
        cell.textLabel.text = @"Add a new email address";
    }
    
    return cell;
}


- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath;
{
    return 50.0f;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    Friend *friend;
    NSString *titleText = @"Enter a New Email";
    
    if (indexPath.row < self.searchedFriends.count)
    {
        friend = self.searchedFriends[indexPath.row];
        titleText = [NSString stringWithFormat: @"Enter an Email for %@", friend.firstName];
    }
    
    self.friendToAddEmail = friend;
    
    if ([self isValidEmail: friend.email]) // has a valid email
    {
        // send email
        
        [self sendEmailToFriend: friend];
    }
    else // either no email or clicked on the last cell
    {
        if (!self.friendToAddEmail)
        {
            // create friend on the fly
            SYNAppDelegate *appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
            
            self.friendToAddEmail = [Friend insertInManagedObjectContext: appDelegate.searchManagedObjectContext];
            self.friendToAddEmail.externalSystem = @"email";
        }
        
        UIAlertView *prompt = [[UIAlertView alloc] initWithTitle: titleText
                                                         message: @"We'll send this channel to their email."
                                                        delegate: self
                                               cancelButtonTitle: @"Cancel"
                                               otherButtonTitles: @"Send", nil];
        
        prompt.alertViewStyle = UIAlertViewStylePlainTextInput;
        prompt.delegate = self;
        [prompt show];
    }
    
    [tableView removeFromSuperview];
}


#pragma mark - UIAlertViewDelegate

- (BOOL) alertViewShouldEnableFirstOtherButton: (UIAlertView *) alertView
{
    UITextField *textfield = [alertView textFieldAtIndex: 0];
    
    return [self isValidEmail: textfield.text];
}


- (void) alertView: (UIAlertView *) alertView didDismissWithButtonIndex: (NSInteger) buttonIndex
{
    if (buttonIndex == 0)
    {
        return;
    }
    
    UITextField *textfield = [alertView textFieldAtIndex: 0];
    
    self.friendToAddEmail.email = textfield.text;
    self.friendToAddEmail.externalUID = self.friendToAddEmail.email; // workaround the fact that we do not have a UID for this new user
    
    [self sendEmailToFriend: self.friendToAddEmail];
}


#pragma mark - UITextFieldDelegate

- (BOOL) textField: (UITextField *) textField shouldChangeCharactersInRange: (NSRange) range replacementString: (NSString *) newCharacter
{
    NSUInteger oldLength = textField.text.length;
    NSUInteger newCharacterLength = newCharacter.length;
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = (oldLength + newCharacterLength) - rangeLength;
    
    self.currentSearchTerm = [NSMutableString stringWithString: [textField.text uppercaseString]];
    
    if (oldLength < newLength)
    {
        [self.currentSearchTerm appendString: [newCharacter uppercaseString]];
    }
    else
    {
        [self.currentSearchTerm deleteCharactersInRange: NSMakeRange(self.currentSearchTerm.length - 1, 1)];
    }
    
    // if a search has actually been typed
    
    if (self.currentSearchTerm.length > 0)
    {
        NSPredicate *searchPredicate = [NSPredicate predicateWithBlock: ^BOOL (Friend *friend, NSDictionary *bindings) {
            return [[friend.firstName uppercaseString] hasPrefix: self.currentSearchTerm] ||
            [[friend.lastName uppercaseString] hasPrefix: self.currentSearchTerm];
        }];
        
        self.searchedFriends = [self.friends filteredArrayUsingPredicate: searchPredicate];
    }
    else
    {
        self.searchedFriends = self.friends;
    }
    
    [self.searchResultsTableView reloadData];
    
    return YES;
}


- (BOOL) textFieldShouldBeginEditing: (UITextField *) textField
{
    self.searchedFriends = self.friends;
    
    CGRect sResTblFrame = self.searchResultsTableView.frame;
    
    sResTblFrame.origin.y = 110.0f;
    sResTblFrame.size.height = self.view.frame.size.height - sResTblFrame.origin.y;
    
    self.searchResultsTableView.frame = sResTblFrame;

    [self.view addSubview: self.searchResultsTableView];
    
    [self.searchResultsTableView reloadData];
    
    self.closeButton.hidden = NO;
    
    [UIView animateWithDuration: 0.3
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         CGRect vFrame = self.view.frame;
                         vFrame.origin.y -= 160.0f;
                         self.view.frame = vFrame;
                     }
                     completion: nil];
    
    
    return YES;
}


- (void) textFieldDidEndEditing: (UITextField *) textField
{
    [UIView animateWithDuration: 0.2
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         CGRect vFrame = self.view.frame;
                         vFrame.origin.y += 160.0f;
                         self.view.frame = vFrame;
                     }
                     completion: nil];
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
}


- (IBAction) authorizeFacebookButtonPressed: (id) sender
{
}


- (IBAction) authorizeAddressBookButtonPressed: (id) sender
{
    [self requestAddressBookAuthorization];
}


#pragma mark - Helper Methods

- (BOOL) isValidEmail: (NSString *) emailCandidate
{
    if (!emailCandidate || ![emailCandidate isKindOfClass: [NSString class]])
    {
        return NO;
    }
    
    return [emailCandidate isMatchedByRegex: @"^([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})$"];
}


- (void) sendEmailToFriend: (Friend *) friend
{
    self.view.userInteractionEnabled = NO;
    self.loader.hidden = NO;
    [self.loader startAnimating];
    self.recentFriendsCollectionView.hidden = YES;
    
    [self.searchTextField resignFirstResponder];
    
    SYNAppDelegate *appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    __weak SYNOneToOneSharingController *wself = self;
     
    [appDelegate.oAuthNetworkEngine emailShareWithObjectType: self.mutableShareDictionary[@"type"]
                                                    objectId: self.mutableShareDictionary[@"object_id"]
                                                  withFriend: friend
                                           completionHandler: ^(id no_content) {
                                               UIAlertView *prompt = [[UIAlertView alloc] initWithTitle: @"Email Sent!"
                                                                                                message: nil
                                                                                               delegate: self
                                                                                      cancelButtonTitle: @"OK"
                                                                                      otherButtonTitles: nil];
                                               [prompt show];
                                               
                                               if (![self isValidEmail: wself.friendToAddEmail.email])                          // if an email has been passed succesfully, register it (temporarily)
                                               {
                                                   NSError *error;
                                                   [friend.managedObjectContext save: &error];
                                               }
                                               else                            // clean it for the next appearence of the table view
                                               {
                                                   wself.friendToAddEmail.email = nil;
                                               }
                                               
                                               NSMutableArray *updatedRecentFriends = wself.recentFriends.mutableCopy;
                                               [updatedRecentFriends addObject: wself.friendToAddEmail];
                                               
                                               wself.recentFriends = [NSArray arrayWithArray: updatedRecentFriends];
                                               
                                               [wself.recentFriendsCollectionView reloadData];
                                               
                                               wself.friendToAddEmail = nil;
                                               
                                               wself.view.userInteractionEnabled = YES;
                                               
                                               wself.loader.hidden = YES;
                                               [wself.loader stopAnimating];
                                               wself.recentFriendsCollectionView.hidden = NO;
                                           } errorHandler: ^(NSDictionary *error) {
                                               NSString *title = @"Email Couldn't be Sent";
                                               NSString *reason = @"Unkown reson";
                                               NSDictionary *formErrors = error[@"form_errors"];
                                               
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
                                               
                                               wself.friendToAddEmail.email = nil;
                                               wself.friendToAddEmail = nil;
                                               
                                               self.view.userInteractionEnabled = YES;
                                           }];
}

@end
