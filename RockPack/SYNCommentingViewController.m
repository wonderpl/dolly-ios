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
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#define kMaxCommentCharacters 120
#define kCacheTimeInMinutes 1

static NSString* CommentingCellIndentifier = @"SYNCommentingCollectionViewCell";
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


@property (nonatomic, weak) VideoInstance* videoInstance;

@property (nonatomic, strong) NSMutableArray* comments;

// holding the values for deleting until confirmed by the alert view
@property (nonatomic, weak) Comment* currentlyDeletingComment;
@property (nonatomic, weak) SYNCommentingCollectionViewCell* currentlyDeletingCell;

@end

@implementation SYNCommentingViewController

- (id)initWithVideoInstance:(VideoInstance*)videoInstance {
	if (self = [super initWithViewId:kCommentsViewId]) {
		self.videoInstance = videoInstance;
	}
	return self;
}

#pragma mark - View Life Cycle

// only gets called on iPhone
- (void) backButtonPressed : (UIBarButtonItem*) barButton
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kScrollMovement
                                                        object:self
                                                      userInfo:@{kScrollingDirection:@(ScrollingDirectionUp)}];
    [self.navigationController popViewControllerAnimated:YES];
	
	if (self.presentingViewController) {
		[self dismissViewControllerAnimated:YES completion:nil];
	} else {
		[appDelegate.masterViewController removeOverlayControllerAnimated:YES];
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // on iPhone the controller appears in a popup
    if (IS_IPHONE)
    {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                                 style:UIBarButtonItemStyleBordered
                                                                                target:self
                                                                                action:@selector(backButtonPressed:)];
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName: kScrollMovement
                                                            object: self
                                                          userInfo: @{kScrollingDirection:@(ScrollingDirectionUp)}];
        
    }
    
    
    
    self.sendMessageAvatarmageView.layer.cornerRadius = self.sendMessageAvatarmageView.frame.size.width * 0.5f;
    self.sendMessageAvatarmageView.clipsToBounds = YES;
    
    
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor lightGrayColor];
    
    self.comments = @[].mutableCopy; // avoid calling count on nil instance
    
    self.sendMessageTextView.text = PlaceholderText;
    
    self.sendMessageButton.titleLabel.font = [UIFont regularCustomFontOfSize:self.sendMessageButton.titleLabel.font.pointSize];
    
    UIColor* borderColor = [UIColor colorWithWhite:(170.0f/255.0f) alpha:1.0f];
    self.sendMessageTextView.layer.borderColor = borderColor.CGColor;
    self.sendMessageTextView.layer.borderWidth = IS_RETINA ? 0.5f : 1.0f;
    self.sendMessageTextView.layer.cornerRadius = 4.0f;
    self.sendMessageTextView.clipsToBounds = YES;
    
    self.bottomContainerView.layer.borderColor = [UIColor grayColor].CGColor;
    self.bottomContainerView.clipsToBounds = YES;
    
    [self.commentsCollectionView registerNib:[UINib nibWithNibName:CommentingCellIndentifier bundle:nil]
                  forCellWithReuseIdentifier:CommentingCellIndentifier];
    
    self.sendMessageTextView.font = [UIFont regularCustomFontOfSize:self.sendMessageTextView.font.pointSize];
    
    
    
    [self.sendMessageAvatarmageView setImageWithURL: [NSURL URLWithString: appDelegate.currentUser.thumbnailURL]
                                   placeholderImage: [UIImage imageNamed: @"PlaceholderAvatarFriends"]
                                            options: SDWebImageRetryFailed];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardNotified:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardNotified:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    
    self.generalLoader.hidden = YES;
    
    // gets the comments from the DB
    
    [self refreshCollectionView];
    
    [self getCommentsFromServer];
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    // observer the size of the text view to set the frame accordingly
    [self.sendMessageTextView addObserver:self
                               forKeyPath:kTextViewContentSizeKey
                                  options:NSKeyValueObservingOptionNew
                                  context:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kScrollMovement
                                                        object: self
                                                      userInfo: @{kScrollingDirection:@(ScrollingDirectionDown)}];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.sendMessageTextView removeObserver:self forKeyPath:kTextViewContentSizeKey];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Keyboard Animation

- (void)keyboardNotified:(NSNotification*)notification {
    if (IS_IPHONE) {
		NSDictionary* userInfo = [notification userInfo];
		NSTimeInterval animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
		UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
		CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
		
		BOOL isShowing = [[notification name] isEqualToString:UIKeyboardWillShowNotification];
		
		self.bottomContainerViewBottom.constant = (isShowing ? CGRectGetHeight(keyboardFrame) : 0.0);
		
		[UIView animateWithDuration:animationDuration
							  delay:0.0f
							options:(animationCurve << 16) // convert AnimationCurve to AnimationOption
						 animations:^{
							 [self.view layoutIfNeeded];
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
		CGSize contentSize = [change[NSKeyValueChangeNewKey] CGSizeValue];
		self.sendMessageTextViewHeight.constant = contentSize.height;
		
		[UIView animateWithDuration:0.2f animations:^{
			[self.view layoutIfNeeded];
		}];
    }
}

#pragma mark - Get Comments

-(void)fetchCommentsFromDB
{
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    
    
    fetchRequest.entity = [NSEntityDescription entityForName: kComment
                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    // comments relate to a specific video instance
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"videoInstanceId == %@", self.videoInstance.uniqueId]];
    
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"dateAdded" ascending: YES]];
    
    NSError* error;
    NSArray* fetchedArray = [appDelegate.mainManagedObjectContext executeFetchRequest: fetchRequest
                                                                                error: &error];
    
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
    
    
    
    return YES;
}

- (void) refreshCollectionView
{
    
    [self fetchCommentsFromDB];
    
    
    [self.commentsCollectionView reloadData];
    
#warning Decide upon the correct method
    // hack to reposition the collection view, otherwise the change gets overriden
//    [self performSelector:@selector(positionCollectionView) withObject:nil afterDelay:0.01f];
    
//    [self.commentsCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.comments.count - 1 inSection:0]
//                                        atScrollPosition:UICollectionViewScrollPositionBottom
//                                                animated:NO];
}

//-(void)positionCollectionView
//{
//    CGFloat offsetValue = self.commentsCollectionView.contentSize.height - self.commentsCollectionView.frame.size.height;
//    [self.commentsCollectionView setContentOffset:CGPointMake(0.0f, offsetValue)];
//}

#pragma mark - Sending Comment


- (void) sendComment
{
    NSString* commentText = self.sendMessageTextView.text;
    
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

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // override the abstract so that you dont send notifications to the navigation manager
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
                                                 
                                                 [wself refreshCollectionView];
                                                 
                                                 
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
    SYNCommentingCollectionViewCell* commentingCell = [cv dequeueReusableCellWithReuseIdentifier:CommentingCellIndentifier
                                                                                    forIndexPath:indexPath];
    Comment* comment = self.comments[indexPath.item];
    
    commentingCell.comment = comment;
    
    
        
    commentingCell.loading = !comment.validatedValue; // if it is NOT validated, show loading state
    
    if([comment.userId isEqualToString:appDelegate.currentUser.uniqueId])
    {
        // only the user can delete his own comments
        commentingCell.deletable = YES;
        commentingCell.delegate = self;
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
    
    CGRect rect = [comment.commentText boundingRectWithSize:(CGSize){kCommentTextSizeWidth, CGFLOAT_MAX}
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{ NSFontAttributeName : correctFont }
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
    
    
    
    NSError* error;
    [comment.managedObjectContext save:&error];
    
}



@end
