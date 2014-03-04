//
//  SYNCommentingViewController.m
//  dolly
//
//  Created by Michael Michailidis on 06/12/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCommentingViewController.h"
#import "SYNCommentingCollectionViewCell.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
#import "SYNAppDelegate.h"
#import "SYNMasterViewController.h"
#import "SYNDeviceManager.h"
#import "UICollectionReusableView+Helpers.h"
#import "SYNNavigationManager.h"
#import "SYNCommentsModel.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+SYNColor.h"
#import "SYNTrackingManager.h"
#import "NSRegularExpression+Username.h"

#define kMaxCommentCharacters 120
#define kCacheTimeInMinutes 1

static const CGFloat CharacterCountThreshold = 30.0;
static NSString* PlaceholderText = @"Say something nice";

@interface SYNCommentingViewController () <UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate, SYNPagingModelDelegate, SYNCommentingCollectionViewCellDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView* commentsCollectionView;

// Send View
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) IBOutlet UIView* bottomContainerView;
@property (nonatomic, strong) IBOutlet UITextView* sendMessageTextView;
@property (nonatomic, strong) IBOutlet UIImageView* sendMessageAvatarmageView;
@property (nonatomic, strong) IBOutlet UIButton* sendMessageButton;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *sendMessageTextViewHeight;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *bottomContainerViewBottom;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* generalLoader;

@property (nonatomic, strong) IBOutlet UILabel *charactersLeftLabel;

@property (nonatomic, weak) VideoInstance* videoInstance;
@property (nonatomic) BOOL loadedComments;

@property (nonatomic, strong) NSMutableArray* comments;

// holding the values for deleting until confirmed by the alert view
@property (nonatomic, weak) NSDictionary* currentlyDeletingComment;
@property (nonatomic, weak) SYNCommentingCollectionViewCell* currentlyDeletingCell;
@property (nonatomic, weak) SYNSocialCommentButton* socialButton;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *commentBottomConstraint;

@property (nonatomic, strong) SYNCommentsModel *model;
@property (nonatomic) BOOL loadingNewComments;

@end

@implementation SYNCommentingViewController

- (instancetype)initWithVideoInstance:(VideoInstance *)videoInstance withButton:(SYNSocialCommentButton*) socialButton {
	if (self = [super initWithViewId:kCommentsViewId]) {
		self.videoInstance = videoInstance;
		self.model = [SYNCommentsModel modelWithVideoInstance:videoInstance];
        self.socialButton = socialButton;
		self.model.delegate = self;
	}
	return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
																			 style:UIBarButtonItemStylePlain
																			target:nil
																			action:nil];
	
    // on iPhone the controller appears in a popup
    if (IS_IPHONE) {
		self.commentsCollectionView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    }
    
    self.sendMessageAvatarmageView.layer.cornerRadius = self.sendMessageAvatarmageView.frame.size.width * 0.5f;
    self.sendMessageAvatarmageView.clipsToBounds = YES;
    
    
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor lightGrayColor];
    
    self.sendMessageTextView.text = PlaceholderText;
    
    self.sendMessageButton.titleLabel.font = [UIFont regularCustomFontOfSize:self.sendMessageButton.titleLabel.font.pointSize];
    
    UIColor* borderColor = [UIColor colorWithWhite:(170.0f/255.0f) alpha:1.0f];
    self.sendMessageTextView.layer.borderColor = borderColor.CGColor;
    self.sendMessageTextView.layer.borderWidth = IS_RETINA ? 0.5f : 1.0f;
    self.sendMessageTextView.layer.cornerRadius = 4.0f;
    self.sendMessageTextView.clipsToBounds = YES;
    
    self.bottomContainerView.layer.borderColor = [UIColor grayColor].CGColor;
    self.bottomContainerView.clipsToBounds = YES;
    
    [self.commentsCollectionView registerNib:[SYNCommentingCollectionViewCell nib]
                  forCellWithReuseIdentifier:[SYNCommentingCollectionViewCell reuseIdentifier]];
    
    self.sendMessageTextView.font = [UIFont regularCustomFontOfSize:self.sendMessageTextView.font.pointSize];
    
    
    
    [self.sendMessageAvatarmageView setImageWithURL: [NSURL URLWithString: appDelegate.currentUser.thumbnailURL]
                                   placeholderImage: [UIImage imageNamed: @"PlaceholderAvatarFriends"]
                                            options: SDWebImageRetryFailed];
    
    
    self.generalLoader.hidden = YES;
    
	[self.model reset];
	[self.model loadNextPage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardNotified:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardNotified:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date]
                                              forKey:kUserDefaultsCommentingLastInteracted];
    
    
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame: CGRectMake(0, 0, 320, 44)];
    
    [self.refreshControl setTintColor:[UIColor dollyActivityIndicator]];
    
    [self.refreshControl addTarget: self
                            action: @selector(resetData)
                  forControlEvents: UIControlEventValueChanged];

    [self.commentsCollectionView addSubview: self.refreshControl];

    
    self.loadedComments = NO;
    self.loadingNewComments = NO;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName: kScrollMovement
                                                        object: self
                                                      userInfo: @{kScrollingDirection:@(ScrollingDirectionDown)}];
    if (!IS_IPHONE_5) {
        [self.commentBottomConstraint setConstant:88];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    // observer the size of the text view to set the frame accordingly
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kScrollMovement
                                                        object: self
                                                      userInfo: @{kScrollingDirection:@(ScrollingDirectionDown)}];
    
    [[SYNTrackingManager sharedManager] trackCommentingScreenView];
}


-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

    if ([self.model totalItemCount]) {
        self.videoInstance.commentCountValue = [self.model totalItemCount];
    }

    //Updates the iphone comment cont
    [self.socialButton setCount:self.videoInstance.commentCountValue];
    [appDelegate saveContext:YES];
    self.sendMessageTextView.text = @"";

}


#pragma mark - Keyboard Animation

- (void)keyboardNotified:(NSNotification*)notification {
    if (IS_IPHONE) {
		NSDictionary* userInfo = [notification userInfo];
		NSTimeInterval animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
		UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
		CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
		
		BOOL isShowing = [[notification name] isEqualToString:UIKeyboardWillShowNotification];
		
		CGFloat keyboardHeight = CGRectGetHeight(keyboardFrame);
		CGFloat keyboardHeightChange = (isShowing ? keyboardHeight : 0.0);
		
		self.bottomContainerViewBottom.constant = keyboardHeightChange;
        
        if (!IS_IPHONE_5) {
            self.bottomContainerViewBottom.constant = keyboardHeightChange+88;
            
        }
		
		CGFloat newYOffset = self.commentsCollectionView.contentOffset.y + (isShowing ? keyboardHeight : -keyboardHeight);
		
		UICollectionView *collectionView = self.commentsCollectionView;
		UIView *view = self.view;
		[UIView animateWithDuration:animationDuration
							  delay:0.0f
							options:(animationCurve << 16) // convert AnimationCurve to AnimationOption
						 animations:^{
							 collectionView.contentInset = UIEdgeInsetsMake(collectionView.contentInset.top,
																			collectionView.contentInset.left,
																			keyboardHeightChange,
																			collectionView.contentInset.right);
							 collectionView.contentOffset = CGPointMake(0, newYOffset);
							 
							 [view layoutIfNeeded];
						 } completion:^(BOOL finished) {
							 
						 }];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:kTextViewContentSizeKey]) {
		CGSize oldContentSize = [change[NSKeyValueChangeOldKey] CGSizeValue];
		CGSize newContentSize = [change[NSKeyValueChangeNewKey] CGSizeValue];
		
		self.sendMessageTextViewHeight.constant = newContentSize.height;
		self.charactersLeftLabel.hidden = (newContentSize.height == CharacterCountThreshold);
		
		UICollectionView *collectionView = self.commentsCollectionView;
		CGFloat heightDifference = (newContentSize.height - oldContentSize.height);
		
		[UIView animateWithDuration:0.2f animations:^{
			collectionView.contentInset = UIEdgeInsetsMake(collectionView.contentInset.top,
														   collectionView.contentInset.left,
														   collectionView.contentInset.bottom + heightDifference,
														   collectionView.contentInset.right);
			collectionView.contentOffset = CGPointMake(0, collectionView.contentOffset.y + heightDifference);
			
			[self.view layoutIfNeeded];
		}];
    }
}


#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([self.sendMessageTextView.text isEqualToString:PlaceholderText])
    {
        self.sendMessageTextView.text = @"";
    }
}


- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.sendMessageTextView.text = PlaceholderText;
}



- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"])
    {
        [self sendComment];
        return NO;
    }
    
    
    // == Exceeded character count ? == //
    
    if(range.location >= kMaxCommentCharacters)
    {
        return NO;
    }
    
	NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
	NSInteger charactersLeft = kMaxCommentCharacters - [newString length];
	self.charactersLeftLabel.text = [NSString stringWithFormat:@"%d", charactersLeft];
    
    return YES;
}

- (void) refreshCollectionView
{
    self.loadingNewComments = NO;
    [self.model loadNewComments];
    
    [self.commentsCollectionView reloadData];
}

#pragma mark - Sending Comment


- (void) sendComment
{
    NSString* commentText = self.sendMessageTextView.text;
	if (![commentText length]) {
		[self.sendMessageTextView resignFirstResponder];
		return;
	}
    
    NSDictionary* comment = [self createCommentFromText:commentText];
    
    if(!comment)
    {
        DebugLog(@"Could not create comment");
        return;
    }
    
    
    self.sendMessageTextView.text = @"";
    
    __weak SYNCommentingViewController* wself = self;
    
    void(^ErrorBlock)(id) = ^(id error) {
        
        [wself deleteComment:comment];
        
        [[[UIAlertView alloc] initWithTitle:@"Sorry..."
                                    message:@"An error occured when sending your message..."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    };
	
	NSRegularExpression *usernameRegex = [NSRegularExpression usernameRegex];
	BOOL hasTaggedUsers = !![[usernameRegex matchesInString:commentText options:0 range:NSMakeRange(0, [commentText length])] count];
    
    [appDelegate.oAuthNetworkEngine postCommentForUserId:appDelegate.currentUser.uniqueId
                                               channelId:self.videoInstance.channel.uniqueId
                                              andVideoId:self.videoInstance.uniqueId
                                             withComment:commentText
                                       completionHandler:^(id dictionary) {
										   
										   [[SYNTrackingManager sharedManager] trackCommentPostedWithTaggedUsers:hasTaggedUsers];
                                           
                                           if(![dictionary isKindOfClass:[NSDictionary class]] ||
                                              ![[dictionary objectForKey:@"id"] isKindOfClass:[NSNumber class]])
                                           {
                                               ErrorBlock(@{@"error" : @"responce is not a discionary"});
                                           }
                                           
                                           [wself.sendMessageTextView resignFirstResponder];
                                           
                                           [wself refreshCollectionView];
                                           wself.videoInstance.commentCountValue = [wself.model totalItemCount];

                                           
                                           [[NSUserDefaults standardUserDefaults] setObject:[NSDate date]
                                                                                     forKey:kUserDefaultsCommentingLastInteracted];
                                       } errorHandler:ErrorBlock];
}


- (NSDictionary*) createCommentFromText:(NSString*)text
{
    
    
    NSDictionary* dictionary = @{
                                 @"id" : @(999), // temp id
                                 @"position": @(0),
                                 @"resource_url": @"",
                                 @"comment": text,
                                 @"validated" : @(NO), // not yet loaded from the server
                                 @"date_added" : [NSDate date],
                                 @"user": @{
                                         @"id": appDelegate.currentUser.uniqueId,
                                         @"resource_url": @"",
                                         @"display_name": appDelegate.currentUser.displayName,
                                         @"avatar_thumbnail_url": appDelegate.currentUser.thumbnailURL
                                         }
                                 };
    
    
    //    Comment* adHocComment = [Comment instanceFromDictionary:dictionary
    //                                  usingManagedObjectContext:appDelegate.mainManagedObjectContext];
    //
    //    adHocComment.localDataValue = YES;
    //
    //    adHocComment.videoInstanceId = self.videoInstance.uniqueId;
    //
    //    [appDelegate saveContext:NO];
    
    
    return dictionary;
}
// override the abstract so that you dont send notifications to the navigation manager


-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // override
    self.loadedComments = NO;
}




#pragma mark - Button Delegates (Deleting)

-(BOOL)deleteComment:(NSDictionary*)comment {
    [[NSUserDefaults standardUserDefaults] setObject:comment[@"date_added"]
                                              forKey:kUserDefaultsCommentingLastInteracted];
    
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        __weak SYNCommentingViewController* wself = self;
        [appDelegate.oAuthNetworkEngine deleteCommentForUserId:appDelegate.currentUser.uniqueId
                                                     channelId:self.videoInstance.channel.uniqueId
                                                       videoId:self.videoInstance.uniqueId
                                                  andCommentId:self.currentlyDeletingComment[@"id"]
                                             completionHandler:^(id responce) {
                                                 
                                                 
                                                 [wself.model removeObjectAtIndex:[self.commentsCollectionView indexPathForCell:self.currentlyDeletingCell].row];
                                                 
                                                 wself.currentlyDeletingCell.deleting = NO;
                                                 wself.currentlyDeletingCell.loading = NO;
                                                 
                                                 
                                                 
                                                 
                                                 [wself.commentsCollectionView performBatchUpdates:^{
                                                     //            [self.comments removeObject:self.currentlyDeletingComment];
                                                     
                                                     UIView *v = wself.currentlyDeletingCell;
                                                     
                                                     NSIndexPath *indexPathToDelete = [wself.commentsCollectionView indexPathForItemAtPoint: v.center];
                                                     
                                                     [wself.commentsCollectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPathToDelete]];
                                                 } completion:^(BOOL finished) {
                                                     [wself.commentsCollectionView reloadData];
                                                
                                                 }];
                                                 
                                                 
                                                 
                                             } errorHandler:^(id error) {
                                                 
                                             }];
    }
    else
    {
        self.currentlyDeletingCell.loading = NO;
        self.currentlyDeletingCell.deleting = NO;
    }
}

- (IBAction)sendButtonPressed:(id)sender
{
    [self sendComment];
}


#pragma mark - UICollectionView Delegate/Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return self.model.itemCount;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *) cv
                  cellForItemAtIndexPath:(NSIndexPath *) indexPath
{
    SYNCommentingCollectionViewCell* commentingCell = [cv dequeueReusableCellWithReuseIdentifier:[SYNCommentingCollectionViewCell reuseIdentifier]
                                                                                    forIndexPath:indexPath];
    //    Comment* comment = self.comments[indexPath.item];
	
	NSDictionary *comment = [self.model itemAtIndex:indexPath.item];
    
    commentingCell.comment = comment;
    
    
    
    //    commentingCell.loading = !comment.validatedValue; // if it is NOT validated, show loading state
    commentingCell.delegate = self;
    
    //
    if([comment[@"user"][@"id"] isEqualToString:appDelegate.currentUser.uniqueId])
    {
        // only the user can delete his own comments
        commentingCell.deletable = YES;
    }
    
    
    return commentingCell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary* comment = [self.model itemAtIndex:indexPath.item];
    // size
    
    UIFont* correctFont = [SYNCommentingCollectionViewCell commentFieldFont];
	NSParagraphStyle *paragraphStyle = [SYNCommentingCollectionViewCell paragraphStyle];
    
    CGRect rect = [comment[@"comment"] boundingRectWithSize:(CGSize){kCommentTextSizeWidth, CGFLOAT_MAX}
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{ NSFontAttributeName : correctFont,
															   NSParagraphStyleAttributeName : paragraphStyle}
                                                    context:nil];
    
    
    
    CGFloat correctHeight = rect.size.height + [SYNCommentingCollectionViewCell commentFieldFrame].origin.y + 10.0f;
    
    
    return CGSizeMake(self.commentsCollectionView.frame.size.width, correctHeight);
}

#pragma mark - Dealloc

// this controller gets destroyed and recreated every time we press the comment button so need to catch dealloc rather than viewDidUnload
- (void) dealloc
{
    //    // delete all the comments for which we did not retrieve an OK. They might still have been saved and will appear upon load
    //    // but we need to be consistent by only showing what we are certain has been received form the server
    //    Comment* comment;
    //    for (comment in self.comments)
    //    {
    //        if(!comment.validatedValue)
    //        {
    //            DebugLog(@"Deleting unvalidated comment: %@", comment);
    //            [comment.managedObjectContext deleteObject:comment];
    //        }
    //    }
    //
    //    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //    
    //    
    //    NSError* error;
    //    [comment.managedObjectContext save:&error];
    
}

- (void)resetData {
    self.loadingNewComments = YES;
	[self.model loadNextPage];
}


#pragma mark - Paging Delegates

- (void)pagingModelDataUpdated:(SYNPagingModel *)pagingModel {
    [self.refreshControl endRefreshing];
    [self.commentsCollectionView reloadData];
    
    
    if ([self.model itemCount] && !self.loadingNewComments) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.model itemCount]-1 inSection:0];
		[self.commentsCollectionView scrollToItemAtIndexPath:indexPath
											atScrollPosition:UICollectionViewScrollPositionBottom
													animated:YES];
        
    }else if (self.loadingNewComments) {
        
        
    }
    self.loadingNewComments = NO;
    
    
}

- (void)pagingModelErrorOccurred:(SYNPagingModel *)pagingModel {
    [self.refreshControl endRefreshing];
}

- (void)commentCell:(SYNCommentingCollectionViewCell *)cell usernameSelected:(NSString *)username {
	ChannelOwner *channelOwner = [ChannelOwner channelOwnerWithUsername:username
												 inManagedObjectContext:[appDelegate mainManagedObjectContext]];
	
    channelOwner.username = username;
    
        SYNAbstractViewController* controllerToShowProfile;
    if (IS_IPHONE) {
        controllerToShowProfile = self;
    } else {
        controllerToShowProfile = appDelegate.masterViewController.showingViewController;
        [appDelegate.masterViewController removeOverlayControllerAnimated:YES];
    }
	
    [controllerToShowProfile viewProfileDetails:channelOwner];
}

- (void)commentCellDeleteButtonPressed:(SYNCommentingCollectionViewCell *)cell {
    self.currentlyDeletingCell = cell;
    
    self.currentlyDeletingCell.deleting = YES;
    self.currentlyDeletingCell.loading = YES;
    
    NSIndexPath* cellIndexPath = [self.commentsCollectionView indexPathForCell:self.currentlyDeletingCell];
    
    self.currentlyDeletingComment = [self.model itemAtIndex:cellIndexPath.item];
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Delete Comment"
                                                        message:@"Are you sure you want to delete this comment?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    
    [alertView show];
}

- (void)commentCellUserAvatarButtonPressed:(SYNCommentingCollectionViewCell *)cell {
	[self.sendMessageTextView resignFirstResponder];
    
    NSDictionary* comment = cell.comment;
    if(!comment)
        return;
    
    // create a ChannelOwner
    
    NSDictionary* channelOwnerData = @{@"id":comment[@"user"][@"id"],
                                       @"avatar_thumbnail_url":comment[@"user"][@"avatar_thumbnail_url"],
                                       @"display_name":comment[@"user"][@"display_name"]};
    
    ChannelOwner* co = [ChannelOwner instanceFromDictionary:channelOwnerData
                                  usingManagedObjectContext:appDelegate.mainManagedObjectContext
                                        ignoringObjectTypes:kIgnoreAll];
    
    SYNAbstractViewController* controllerToShowProfile;
    if (IS_IPHONE) {
        controllerToShowProfile = self;
    } else {
        controllerToShowProfile = appDelegate.masterViewController.showingViewController;
        [appDelegate.masterViewController removeOverlayControllerAnimated:YES];
    }
    
    [controllerToShowProfile viewProfileDetails:co];
}

@end
