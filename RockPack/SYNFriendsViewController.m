//
//  SYNFriendsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 22/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNFriendsViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNFacebookManager.h"
#import "ChannelOwner.h"
#import "SYNFriendThumbnailCell.h"
#import "UIImageView+WebCache.h"
#import "SYNAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SYNOAuthNetworkEngine.h"
#import "Friend.h"
#import "GAI.h"
#import "SYNFacebookManager.h"
#import "SYNSideNavigatorViewController.h"
#import <objc/runtime.h>

static char* friend_association_key = "SYNFriendThumbnailCell to Friend";

@interface SYNFriendsViewController () <UIScrollViewDelegate> {
    BOOL hasAttemptedToLoadData;
}

@property (nonatomic, strong) NSArray* friends;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;
@property (nonatomic) BOOL onRockpackFilterOn;
@property (nonatomic, strong) NSArray* displayFriends;
@property (nonatomic, weak) Friend* currentlySelectedFriend;
@property (nonatomic, strong) NSMutableString* currentSearchTerm;



//iPhone specific
@property (nonatomic, strong) IBOutlet UIView* searchContainer;
@property (weak, nonatomic) IBOutlet UIImageView *searchFieldBackground;
@property (weak, nonatomic) IBOutlet UIView *searchSlider;
@property (weak, nonatomic) IBOutlet UIButton * buttonShowSearch;

@end

@implementation SYNFriendsViewController

@synthesize appDelegate;
@synthesize onRockpackFilterOn;
@synthesize displayFriends = _displayFriends;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    onRockpackFilterOn = NO;
    
    self.currentSearchTerm = [[NSMutableString alloc] init];
    
    [self.searchField setAutocorrectionType:UITextAutocorrectionTypeNo];
    
    self.friends = @[];
    
    
    
    // Register Cells
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNFriendThumbnailCell"
                                             bundle: nil];
    
    [self.friendsCollectionView registerNib: thumbnailCellNib
                 forCellWithReuseIdentifier: @"SYNFriendThumbnailCell"];
    
    self.preLoginLabel.font = [UIFont rockpackFontOfSize:self.preLoginLabel.font.pointSize];
    
    [self.activityIndicator hidesWhenStopped];
    
    self.onFacebookButton.titleLabel.font = [UIFont rockpackFontOfSize: IS_IPAD ? 14.0f : 12.0f];
    self.onFacebookButton.contentEdgeInsets = UIEdgeInsetsMake(IS_IPAD ? 7.0f : 5.0, 0.0f, 0.0f, 0.0f);
    self.onRockpackButton.titleLabel.font = [UIFont rockpackFontOfSize: IS_IPAD ? 14.0f : 12.0f];
    self.onRockpackButton.contentEdgeInsets = UIEdgeInsetsMake(IS_IPAD ? 7.0f : 5.0, 0.0f, 0.0f, 0.0f);
    
    self.searchField.font = [UIFont rockpackFontOfSize: self.searchField.font.pointSize];
    
    // Google analytics support
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if ([[SYNFacebookManager sharedFBManager] hasActiveSession])
    {
        self.facebookLoginButton.hidden = YES;
        self.preLoginLabel.hidden = YES;
        self.friendsCollectionView.hidden = NO;
        self.activityIndicator.hidden = NO;
        
        self.onRockpackButton.hidden = NO;
        self.onFacebookButton.hidden = NO;
        
        [self fetchAndDisplayFriends];
        
        [tracker set: kGAIScreenName
               value: @"Friends All"];
    }
    else
    {
        self.onRockpackButton.hidden = YES;
        self.onFacebookButton.hidden = YES;
        self.facebookLoginButton.hidden = NO;
        self.preLoginLabel.hidden = NO;
        self.friendsCollectionView.hidden = YES;
        self.activityIndicator.hidden = YES;
        
        [tracker set: kGAIScreenName
               value: @"Friends Fb Connect"];
    }
    
    [tracker send: [[GAIDictionaryBuilder createAppView] build]];
    
    self.followInviteLabel.font = [UIFont rockpackFontOfSize:self.followInviteLabel.font.pointSize];
    
    if(IS_IPHONE)
    {
        
        
        self.searchFieldBackground.image = [[UIImage imageNamed: @"FieldSearch"]
                                    resizableImageWithCapInsets: UIEdgeInsetsMake(0.0f,20.0f, 0.0f, 20.0f)];
        
        //Push the search slider out to the right.
        CGRect searchSliderFrame = self.searchSlider.frame;
        searchSliderFrame.origin.x = searchSliderFrame.size.width;
        self.searchSlider.frame= searchSliderFrame;
        
        
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    CGRect bFrame = self.onRockpackButton.frame;
    bFrame.size.height = 54.0f;
    bFrame.origin.y -= 10.0f;
    self.onRockpackButton.frame = bFrame;
    
    bFrame = self.onFacebookButton.frame;
    bFrame.size.height = 54.0f;
    bFrame.origin.y -= 10.0f;
    self.onFacebookButton.frame = bFrame;
    
    
}


-(IBAction)switchClicked:(UIButton*)tab
{
    if( tab.selected ) // do not re-select
        return;
    
    [self.searchField resignFirstResponder];
    
    // Google analytics support
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if (tab == self.onRockpackButton)
    {
        self.onFacebookButton.selected = NO;
        self.followInviteLabel.text = NSLocalizedString(@"friends_follow", nil);
        
        [tracker set: kGAIScreenName
               value: @"Friends RP"];
    }
    else
    {
        self.onRockpackButton.selected = NO;
        self.followInviteLabel.text = NSLocalizedString(@"friends_invite", nil);
        
        [tracker set: kGAIScreenName
               value: @"Friends All"];
    }
        
    [tracker send: [[GAIDictionaryBuilder createAppView] build]];
    
    tab.selected = YES;
    
    [self.friendsCollectionView reloadData];
}


-(void)fetchAndDisplayFriends
{
    
    
    NSError *error;
    NSArray *existingFriendsArray;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity: [NSEntityDescription entityForName: @"Friend"
                                         inManagedObjectContext: appDelegate.searchManagedObjectContext]];
    
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"externalSystem != %@ AND hasIOSDevice == YES", kEmail];
    
    existingFriendsArray = [appDelegate.searchManagedObjectContext executeFetchRequest: fetchRequest
                                                                                 error: &error];
    
    
    
    if(!error)
    {
   
        self.friends = [NSArray arrayWithArray:existingFriendsArray];
        
        self.onRockpackButton.selected = YES;
        self.followInviteLabel.text = NSLocalizedString(@"friends_follow", nil);
        
        
        
        [self.friendsCollectionView reloadData];
        
        
    }
    
    if(hasAttemptedToLoadData)
        return;
    
    hasAttemptedToLoadData = YES;
    
    __weak SYNFriendsViewController* weakSelf = self;
    
    [weakSelf showLoader:YES];
    
    [appDelegate.oAuthNetworkEngine friendsForUser:appDelegate.currentUser
                                        onlyRecent:NO
                                 completionHandler:^(id dictionary) {
        
                                     if([appDelegate.searchRegistry registerFriendsFromDictionary:dictionary])
                                     {
                                         [weakSelf fetchAndDisplayFriends];
                                     }
                                     else
                                     {
                                         DebugLog(@"There was a problem loading friends");
                                     }
                                     
                                     
                                     [weakSelf showLoader:NO];
        
                                     
        
                                     [self fetchAndDisplayFriends];
        
        
                                 } errorHandler:^(id dictionary) {
                                     
                                     
                                     
                                     
                                     [weakSelf showLoader:NO];
                                     
        
                                 }];
}
-(void)showLoader:(BOOL)show
{
    if(show)
    {
        [self.activityIndicator startAnimating];
        
        self.onRockpackButton.hidden = YES;
        self.onFacebookButton.hidden = YES;
    }
    else
    {
        self.onRockpackButton.hidden = NO;
        self.onFacebookButton.hidden = NO;
        
        
        [self.activityIndicator stopAnimating];
    }
}


-(IBAction)facebookLoginPressed:(id)sender
{
    self.activityIndicator.center = self.facebookLoginButton.center;
    
    [self.activityIndicator startAnimating];
    
    self.facebookLoginButton.hidden = YES;
    
    self.preLoginLabel.text = @"Logging In";
    
    //Weak variables to avoid block retain cycles
    __weak SYNFriendsViewController* weakSelf = self;
    __weak SYNAppDelegate* weakAppDelegate = appDelegate;
    
    SYNFacebookManager* facebookManager = [SYNFacebookManager sharedFBManager];
    
    
    [facebookManager loginOnSuccess: ^(NSDictionary<FBGraphUser> *dictionary) {
        
        FBAccessTokenData* accessTokenData = [[FBSession activeSession] accessTokenData];
        
        [weakAppDelegate.oAuthNetworkEngine connectFacebookAccountForUserId: appDelegate.currentUser.uniqueId
                                                         andAccessTokenData: accessTokenData
                                                          completionHandler: ^(id no_responce) {
                                                              
                                                              [weakSelf.activityIndicator stopAnimating];
                                                              
                                                              weakSelf.friendsCollectionView.hidden = NO;
                                                              weakSelf.preLoginLabel.hidden = YES;
                                                              weakSelf.facebookLoginButton.hidden = YES;
                                                              
                                                              weakSelf.onRockpackButton.hidden = NO;
                                                              weakSelf.onFacebookButton.hidden = NO;
                                                              
                                                              [weakSelf fetchAndDisplayFriends];
            
                                                          } errorHandler:^(id error) {
                                                              
                                                              [weakSelf.activityIndicator stopAnimating];
                                                              
                                                              weakSelf.facebookLoginButton.hidden = NO;
                                                              
                                                              weakSelf.preLoginLabel.text = @"We could not Log you in becuase this FB account seems to be associated with a different User.";
                                                              
                                                              [[SYNFacebookManager sharedFBManager] logoutOnSuccess:^{
                                                                  
                                                              } onFailure:^(NSString *errorMessage) {
                                                                  
                                                              }];
            
                                                          }];
        
        
    } onFailure: ^(NSString* errorString) {
        
        [weakSelf.activityIndicator stopAnimating];
        
        weakSelf.facebookLoginButton.hidden = NO;
        
        weakSelf.preLoginLabel.text = @"Log in with Facebook was cancelled.";
        
        
     }];

}

#pragma mark - UICollectionView Delegate/Data Source

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    return self.displayFriends.count;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    Friend *friend = self.displayFriends[indexPath.row];
    
    SYNFriendThumbnailCell *userThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNFriendThumbnailCell"
                                                                                        forIndexPath: indexPath];
    
    userThumbnailCell.nameLabel.text = friend.displayName;
    
    [userThumbnailCell.imageView setImageWithURL: [NSURL URLWithString: friend.thumbnailLargeUrl]
                                placeholderImage: [UIImage imageNamed: @"PlaceholderAvatarChannel"]
                                         options: SDWebImageRetryFailed];
    
    [userThumbnailCell setDisplayName: friend.displayName];
    
    
    
    objc_setAssociatedObject(userThumbnailCell, friend_association_key, friend, OBJC_ASSOCIATION_ASSIGN);
    
    return userThumbnailCell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchField resignFirstResponder];
}


#pragma mark - UITextViewDelegate

- (BOOL) textField: (UITextField *) textField shouldChangeCharactersInRange: (NSRange) range replacementString: (NSString *) newCharacter
{
    
    NSUInteger oldLength = textField.text.length;
    NSUInteger newCharacterLength = newCharacter.length;
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = (oldLength + newCharacterLength) - rangeLength;
    
    
    self.currentSearchTerm = [NSMutableString stringWithString:[self.searchField.text uppercaseString]];
    if(oldLength < newLength)
        [self.currentSearchTerm appendString:[newCharacter uppercaseString]];
    else
        [self.currentSearchTerm deleteCharactersInRange:NSMakeRange(self.currentSearchTerm.length - 1, 1)];
    
    
    
    // this will ask .displayFriends which will filter the friends array accroding to the search term
    [self.friendsCollectionView reloadData];
    
    return YES;
}

-(NSArray*)displayFriends
{
    
    // first decide which tab we are on ...
    if(self.onRockpackButton.selected)
    {
        _displayFriends = [self rockpackFriends];
        
        
    }
    else
    {
        _displayFriends = [self facebookFriends];
        
    }
    
    // ... then filter search according to term if present
    if(self.currentSearchTerm.length > 0)
    {
        NSPredicate* searchPredicate = [NSPredicate predicateWithBlock:^BOOL(Friend* friend, NSDictionary *bindings) {
            
            NSString* nameToCompare = [friend.displayName uppercaseString];
            
            BOOL result = [nameToCompare hasPrefix:self.currentSearchTerm];
            
            if(self.onRockpackButton.selected) // is on the second tab
            {
                result = result & friend.isOnRockpack;
            }
            
            return result;
        }];
        
        _displayFriends = [_displayFriends filteredArrayUsingPredicate:searchPredicate];
    }
    
    if(_displayFriends.count == 0)
    {
        // show message
        self.preLoginLabel.hidden = NO;
        self.preLoginLabel.text = NSLocalizedString(@"friends_name_not_found", nil);;
    }
    else
    {
        self.preLoginLabel.hidden = YES;
    }
    
    return _displayFriends;
    
}

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    [self.searchField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self.currentSearchTerm setString:@""];
    [self.friendsCollectionView reloadData];
    return YES;
}



- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    SYNFriendThumbnailCell* cellClicked = (SYNFriendThumbnailCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    cellClicked.selected = YES;
    
    self.currentlySelectedFriend = objc_getAssociatedObject(cellClicked, friend_association_key);
    
    if(!self.currentlySelectedFriend.isOnRockpack) // facebook friend, invite to rockpack
    {
        id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
        
        [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                               action: @"friendToInvite"
                                                                label: nil
                                                                value: nil] build]];
        
        [[SYNFacebookManager sharedFBManager] sendAppRequestToFriend:self.currentlySelectedFriend
                                                           onSuccess:^{
                                                               id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
                                                               
                                                               [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"goal"
                                                                                                                      action: @"friendInvited"
                                                                                                                       label: nil
                                                                                                                       value: nil] build]];
                                                               
                                                               [appDelegate.viewStackManager removePopoverView];
                                                               
                                                           } onFailure:^(NSError *error) {
                                                               
                                                               [appDelegate.viewStackManager removePopoverView];
                                                               
                                                           }];
    }
    else // on rockpack, go to profile
    {
        ChannelOwner* friendAsChannelOwner = (ChannelOwner*)self.currentlySelectedFriend;
        
        
        
        
        appDelegate.viewStackManager.returnBlock = ^{
            [appDelegate.viewStackManager openSideNavigatorToIndex:kFriendsRowIndex];
        };
        [appDelegate.viewStackManager viewProfileDetails:friendAsChannelOwner];
        
    }
    
    [self.searchField resignFirstResponder];
    
}


-(void)dealloc
{
    [self.searchContainer removeFromSuperview];
    // clean associations
    for (UICollectionViewCell* visibleCell in self.friendsCollectionView.visibleCells) {
        objc_removeAssociatedObjects(visibleCell);
    }
}

#pragma mark - iPhone Search bar

-(void)addSearchBarToView:(UIView*)view
{
    CGRect searchContainerFrame = self.searchContainer.frame;
    searchContainerFrame.origin = CGPointMake(46.0f, 0.0f);
    self.searchContainer.frame = searchContainerFrame;
    [view addSubview:self.searchContainer];
}

- (IBAction)closeSearchBox:(id)sender {
    [self.searchField resignFirstResponder];
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationCurveEaseOut animations:^{
        CGRect newFrame = self.searchSlider.frame;
        newFrame.origin.x = newFrame.size.width;
        self.searchSlider.frame = newFrame;
    } completion:^(BOOL finished) {
        
        if (finished)
        {
            self.buttonShowSearch.hidden = NO;
            
            [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.buttonShowSearch.alpha = 1.0f;
            } completion:nil];
        }
    }];
}

- (IBAction)revealSearchBox:(id)sender {
    
    self.buttonShowSearch.hidden = YES;
    self.buttonShowSearch.alpha = 0.0f;
    
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationCurveEaseIn animations:^{
        CGRect newFrame = self.searchSlider.frame;
        newFrame.origin.x = 0.0f;
        self.searchSlider.frame = newFrame;
    } completion:^(BOOL finished) {
        [self.searchField becomeFirstResponder];
    }];
}

#pragma mark - Helper Methods

-(NSArray*)facebookFriends
{
    return [self.friends filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"externalSystem == %@ AND isOnRockpack == NO", kFacebook]];
}

-(NSArray*)rockpackFriends
{
    
    return [self.friends filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"resourceURL != NULL"]];
}

-(void)setTitleForFriendsTab:(NSString*)ftText andRockpackTab:(NSString*)rtText
{
    // set first tab
    [self.onFacebookButton setTitle:ftText forState:UIControlStateNormal];
    [self.onFacebookButton setTitle:ftText forState:UIControlStateHighlighted];
    [self.onFacebookButton setTitle:ftText forState:UIControlStateSelected];
    
    // set second tab
    [self.onRockpackButton setTitle:rtText forState:UIControlStateNormal];
    [self.onRockpackButton setTitle:rtText forState:UIControlStateHighlighted];
    [self.onRockpackButton setTitle:rtText forState:UIControlStateSelected];
}
@end
