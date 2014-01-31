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
#import "Comment.h"
#import "SYNMasterViewController.h"
#import "SYNDeviceManager.h"
#import "UICollectionReusableView+Helpers.h"
#import "SYNNavigationManager.h"
#import <QuartzCore/QuartzCore.h>

#define kMaxCommentCharacters 120
#define kCacheTimeInMinutes 1

static const CGFloat CharacterCountThreshold = 30.0;
static NSString* PlaceholderText = @"Say something nice";

@interface SYNCommentingViewController () <UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView* commentsCollectionView;

// Send View

@property (nonatomic, strong) IBOutlet UIView* bottomContainerView;
@property (nonatomic, strong) IBOutlet UITextView* sendMessageTextView;
@property (nonatomic, strong) IBOutlet UIImageView* sendMessageAvatarmageView;
@property (nonatomic, strong) IBOutlet UIButton* sendMessageButton;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *sendMessageTextViewHeight;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *bottomContainerViewBottom;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* generalLoader;

@property (nonatomic, strong) IBOutlet UILabel *charactersLeftLabel;

@property (nonatomic, weak) VideoInstance* videoInstance;

@property (nonatomic, strong) NSMutableArray* comments;

// holding the values for deleting until confirmed by the alert view
@property (nonatomic, weak) Comment* currentlyDeletingComment;
@property (nonatomic, weak) SYNCommentingCollectionViewCell* currentlyDeletingCell;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *commentBottomConstraint;
@end

@implementation SYNCommentingViewController

- (instancetype)initWithVideoInstance:(VideoInstance *)videoInstance {
	if (self = [super initWithViewId:kCommentsViewId]) {
		self.videoInstance = videoInstance;
	}
	return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
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
    
    // gets the comments from the DB
    
    [self refreshCollectionView];
    
    [self getCommentsFromServer];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardNotified:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardNotified:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];

    
    
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
    
    
}

-(void)viewWillDisappear:(BOOL)animated
{

}
- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
   
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

#pragma mark - Get Comments

- (void)fetchCommentsFromDB {
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[Comment entityName]];
	
	[fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"videoInstanceId == %@", self.videoInstance.uniqueId]];
	[fetchRequest setSortDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"dateAdded" ascending:YES] ]];

	NSArray* fetchedArray = [appDelegate.mainManagedObjectContext executeFetchRequest:fetchRequest
																				error:nil];

	self.comments = [NSMutableArray arrayWithArray:fetchedArray];


}

-(void)getCommentsFromServer
{
    /* NOTE: Comments are CACHED so we need to save on the fly comments carefuly */
    
    SYNAbstractNetworkEngine* networkEngineToUse;
    NSDate* lastInteractedWithCommenting = (NSDate*)[[NSUserDefaults standardUserDefaults] objectForKey: kUserDefaultsCommentingLastInteracted];
    
    
    if(!lastInteractedWithCommenting) // first time we launched this section
        lastInteractedWithCommenting = [NSDate distantPast];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSMinuteCalendarUnit
                                               fromDate:lastInteractedWithCommenting
                                                 toDate:[NSDate date]
                                                options:0];
    
    
    
    if (components.minute <= kCacheTimeInMinutes)
    {
        networkEngineToUse = appDelegate.oAuthNetworkEngine;
    }
    else
    {
        networkEngineToUse = appDelegate.networkEngine;
    }
    
    
    if(self.comments.count == 0)
    {
        self.generalLoader.hidden = NO;
        [self.generalLoader startAnimating];
    }
    
    [networkEngineToUse getCommentsForUsedId:appDelegate.currentUser.uniqueId
                                   channelId:self.videoInstance.channel.uniqueId
                                  andVideoId:self.videoInstance.uniqueId
                                     inRange:self.dataRequestRange
                           completionHandler:^(id dictionary) {
                                      
                                      if(![dictionary isKindOfClass:[NSDictionary class]])
                                          return;
                                      
                                      if(![appDelegate.mainRegistry registerCommentsFromDictionary:dictionary
                                                                                      withExisting:self.comments
                                                                                forVideoInstanceId:self.videoInstance.uniqueId])
                                      {
                                          self.comments = @[].mutableCopy;
                                          
                                
                                      }
                               
                               self.generalLoader.hidden = YES;
                               
                            
                               [self refreshCollectionView];
        
                                  } errorHandler:^(id error) {
                            
                                      
                            }];
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
    
    [self fetchCommentsFromDB];
    
    
    [self.commentsCollectionView reloadData];
	
	if ([self.comments count]) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.comments count] - 1 inSection:0];
		[self.commentsCollectionView scrollToItemAtIndexPath:indexPath
											atScrollPosition:UICollectionViewScrollPositionBottom
													animated:NO];
	}
}

#pragma mark - Sending Comment


- (void) sendComment
{
    NSString* commentText = self.sendMessageTextView.text;
	if (![commentText length]) {
		[self.sendMessageTextView resignFirstResponder];
		return;
	}
    
    Comment* comment = [self createCommentFromText:commentText];
    
    if(!comment)
    {
        DebugLog(@"Could not create comment");
        return;
    }
    
    
    self.sendMessageTextView.text = @"";
    
    [self refreshCollectionView];
    
    
    __weak SYNCommentingViewController* wself = self;
    
    void(^ErrorBlock)(id) = ^(id error) {
        
        [wself deleteComment:comment];
        
        [wself refreshCollectionView];
        
        [[[UIAlertView alloc] initWithTitle:@"Sorry..."
                                    message:@"An error occured when sending your message..."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    };
    
    
    [appDelegate.oAuthNetworkEngine postCommentForUserId:appDelegate.currentUser.uniqueId
                                               channelId:self.videoInstance.channel.uniqueId
                                              andVideoId:self.videoInstance.uniqueId
                                             withComment:commentText
                                       completionHandler:^(id dictionary) {
                                           
                                           if(![dictionary isKindOfClass:[NSDictionary class]] ||
                                              ![[dictionary objectForKey:@"id"] isKindOfClass:[NSNumber class]])
                                           {
                                               ErrorBlock(@{@"error" : @"responce is not a discionary"});
                                           }
                                           
                                           comment.validatedValue = YES;
                                           
                                           NSNumber* commentId = (NSNumber*)[dictionary objectForKey:@"id"];
                                           if(![commentId isKindOfClass:[NSNumber class]])
                                           {
                                               ErrorBlock(@{@"error" : @"responce is not a discionary"});
                                               return;
                                           }
                                           
                                           // save the correct url in order to be able to delete
                                           comment.uniqueId = [commentId stringValue];
                                           
                                           
                                           NSError* error;
                                           if(![comment.managedObjectContext save:&error])
                                           {
                                               DebugLog(@"%@", error);
                                               ErrorBlock(@{@"error" : @"could not save to managed context"});
                                               return;
                                           }
                                           
                                           [wself.sendMessageTextView resignFirstResponder];
                                           
                                           [wself refreshCollectionView];
        
                                       } errorHandler:ErrorBlock];
}


- (Comment*) createCommentFromText:(NSString*)text
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
    
    
    Comment* adHocComment = [Comment instanceFromDictionary:dictionary
                                  usingManagedObjectContext:appDelegate.mainManagedObjectContext];
    
    adHocComment.localDataValue = YES;
    
    adHocComment.videoInstanceId = self.videoInstance.uniqueId;
    
    [appDelegate saveContext:NO];
    
    
    return adHocComment;
}
// override the abstract so that you dont send notifications to the navigation manager

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
}

- (void) scrollViewWillBeginDragging: (UIScrollView *) scrollView
{
}

- (void) scrollViewDidEndDragging: (UIScrollView *) scrollView willDecelerate: (BOOL) decelerate
{
}

#pragma mark - Button Delegates (Deleting)

-(void)deleteButtonPressed:(UIButton*)sender
{
    
    UIView* candidate = sender;
    while (![candidate isKindOfClass:[SYNCommentingCollectionViewCell class]]) {
        candidate = candidate.superview;
    }
    
    if(![candidate isKindOfClass:[SYNCommentingCollectionViewCell class]])
        return;
    
    self.currentlyDeletingCell = (SYNCommentingCollectionViewCell*)candidate;
    
    self.currentlyDeletingCell.deleting = YES;
    self.currentlyDeletingCell.loading = YES;
    
    NSIndexPath* cellIndexPath = [self.commentsCollectionView indexPathForCell:self.currentlyDeletingCell];
    
    self.currentlyDeletingComment = self.comments [cellIndexPath.item];
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Delete Comment"
                                                        message:@"Are you sure you want to delete this comment?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    
    [alertView show];
    
    
}

-(BOOL)deleteComment:(Comment*)comment
{
    
    
    [self.comments removeObject:comment];
    
    [comment.managedObjectContext deleteObject:comment];
    
    
    NSError* saveError;
    if(![comment.managedObjectContext save:&saveError])
    {
        // if we get an error...
        if(!comment.isDeleted)
        {
            [self.comments addObject:comment]; // put it back
        }
        DebugLog(@"%@", saveError);
        return NO;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:comment.dateAdded
                                              forKey:kUserDefaultsCommentingLastInteracted];
    
    return YES;
}

-(void)userAvatarButtonPressed:(UIButton*)button
{
    if(!button)
        return;
    
    [self.sendMessageTextView resignFirstResponder];

    // find correct cell
    
    UIView* candidateCell = button;
    while(![candidateCell isKindOfClass:[SYNCommentingCollectionViewCell class]])
        candidateCell = candidateCell.superview;
    
    if(![candidateCell isKindOfClass:[SYNCommentingCollectionViewCell class]])
        return;
    
    SYNCommentingCollectionViewCell* cell = (SYNCommentingCollectionViewCell*)candidateCell;
    Comment* comment = cell.comment;
    if(!comment)
        return;
    
    
    
    // create a ChannelOwner
    
    NSDictionary* channelOwnerData = @{@"id":comment.userId,
                                       @"avatar_thumbnail_url":comment.thumbnailUrl,
                                       @"display_name":comment.displayName};
    
    ChannelOwner* co = [ChannelOwner instanceFromDictionary:channelOwnerData
                                  usingManagedObjectContext:appDelegate.mainManagedObjectContext
                                        ignoringObjectTypes:kIgnoreAll];
    
    SYNAbstractViewController* controllerToShowProfile;
    if(IS_IPHONE)
    {
        controllerToShowProfile = self;
    }
    else
    {
        controllerToShowProfile = appDelegate.masterViewController.showingViewController;
        [appDelegate.masterViewController removeOverlayControllerAnimated:YES];
    }
    
    [controllerToShowProfile viewProfileDetails:co];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        
        
        
        __weak SYNCommentingViewController* wself = self;
        [appDelegate.oAuthNetworkEngine deleteCommentForUserId:appDelegate.currentUser.uniqueId
                                                     channelId:self.videoInstance.channel.uniqueId
                                                       videoId:self.videoInstance.uniqueId
                                                  andCommentId:self.currentlyDeletingComment.uniqueId
                                             completionHandler:^(id responce) {
                                                 
                                                 [wself deleteComment:wself.currentlyDeletingComment];
                                                 
                                                 wself.currentlyDeletingCell.deleting = NO;
                                                 wself.currentlyDeletingCell.loading = NO;
                                                 
                                                 
                                                 
                                                 
                                                 [wself.commentsCollectionView performBatchUpdates:^{
                                                     //            [self.comments removeObject:self.currentlyDeletingComment];
                                                     
                                                     UIView *v = wself.currentlyDeletingCell;
                                                     
                                                     NSIndexPath *indexPathToDelete = [wself.commentsCollectionView indexPathForItemAtPoint: v.center];
                                                     
                                                     [wself.commentsCollectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPathToDelete]];
                                                 } completion:^(BOOL finished) {
                                                     [wself refreshCollectionView];

                                                     
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

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
	return 1;
}


- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger) section
{
	return self.comments.count;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNCommentingCollectionViewCell* commentingCell = [cv dequeueReusableCellWithReuseIdentifier:[SYNCommentingCollectionViewCell reuseIdentifier]
                                                                                    forIndexPath:indexPath];
    Comment* comment = self.comments[indexPath.item];
    
    commentingCell.comment = comment;
    
    
        
    commentingCell.loading = !comment.validatedValue; // if it is NOT validated, show loading state
    commentingCell.delegate = self;

    if([comment.userId isEqualToString:appDelegate.currentUser.uniqueId])
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
    
    Comment* comment = self.comments[indexPath.item];
    // size
    
    UIFont* correctFont = [SYNCommentingCollectionViewCell commentFieldFont];
	NSParagraphStyle *paragraphStyle = [SYNCommentingCollectionViewCell paragraphStyle];
    
    CGRect rect = [comment.commentText boundingRectWithSize:(CGSize){kCommentTextSizeWidth, CGFLOAT_MAX}
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
    // delete all the comments for which we did not retrieve an OK. They might still have been saved and will appear upon load
    // but we need to be consistent by only showing what we are certain has been received form the server
    Comment* comment;
    for (comment in self.comments)
    {
        if(!comment.validatedValue)
        {
            DebugLog(@"Deleting unvalidated comment: %@", comment);
            [comment.managedObjectContext deleteObject:comment];
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    
    NSError* error;
    [comment.managedObjectContext save:&error];
    
}

@end
