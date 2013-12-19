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

#define kCell_2_Comment_Association_Key @"kCell_2_Comment_Association_Key"

static NSString* CommentingCellIndentifier = @"SYNCommentingCollectionViewCell";
static NSString* PlaceholderText = @"Say something nice";

@interface SYNCommentingViewController () <UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate>
{
    CGFloat differenceBetweenHeightAndContentSizeHeight;
    CGFloat oldContentSizeHeight;
    BOOL isAnimating;
}

@property (nonatomic, strong) IBOutlet UICollectionView* commentsCollectionView;


// Send View

@property (nonatomic, strong) IBOutlet UIView* bottomContainerView;
@property (nonatomic, strong) IBOutlet UITextView* sendMessageTextView;
@property (nonatomic, strong) IBOutlet UIImageView* sendMessageAvatarmageView;
@property (nonatomic, strong) IBOutlet UIButton* sendMessageButton;


@property (nonatomic, weak) VideoInstance* videoInstance;

@property (nonatomic, strong) NSMutableArray* comments;

// holding the values for deleting until confirmed by the alert view
@property (nonatomic, weak) Comment* currentlyDeletingComment;
@property (nonatomic, weak) SYNCommentingCollectionViewCell* currentlyDeletingCell;

@end

@implementation SYNCommentingViewController

- (id) initWithVideoInstance:(VideoInstance*)videoInstance
{
    if (self = [super initWithViewId:kCommentsViewId])
    {
        
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
                                                      userInfo:@{kScrollingDirection:@(ScrollingDirectionDown)}];
    
    [self.navigationController popViewControllerAnimated:YES];
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
    
    
    oldContentSizeHeight = self.sendMessageTextView.contentSize.height;
    
    
    differenceBetweenHeightAndContentSizeHeight = self.sendMessageTextView.frame.size.height - oldContentSizeHeight;
    
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
    
    [self fetchCommentsFromDB];
    
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
    
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.sendMessageTextView removeObserver:self forKeyPath:kTextViewContentSizeKey];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Keyboard Animation

- (void) keyboardNotified:(NSNotification*)notification
{
    
    NSDictionary* userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    // Get the values from the Keyboard Animation to match it exactly
    
    CGRect keyboardFrame;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    
    UIView* viewToMove;
    CGRect targetFrame;
    
    if(IS_IPAD)
    {
        viewToMove = self.navigationController.view;
        
        targetFrame = viewToMove.frame;
        
        if([notification.name isEqualToString:UIKeyboardWillShowNotification])
        {
            targetFrame.origin.y -= 110.0f;
        }
        else if ([notification.name isEqualToString:UIKeyboardWillHideNotification])
        {
            targetFrame.origin.y += 110.0f;
        }
    }
    else
    {
        
        viewToMove = self.bottomContainerView;
        
        targetFrame = self.bottomContainerView.frame;
        
        if([notification.name isEqualToString:UIKeyboardWillShowNotification])
        {
            targetFrame.origin.y -= 212.0f;
        }
        else if ([notification.name isEqualToString:UIKeyboardWillHideNotification])
        {
            targetFrame.origin.y += 212.0f;
        }
        
    }
    
    isAnimating = YES;
    
    [UIView animateWithDuration:animationDuration delay:0.0f
                        options:(animationCurve << 16) // convert AnimationCurve to AnimationOption
                     animations:^{
                         
                         viewToMove.frame = targetFrame;
                         
                     } completion:^(BOOL finished) {
        
                         isAnimating = NO;
                     }];
    
}


#pragma mark - KVO



- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString: kTextViewContentSizeKey])
    {
        
        
        CGFloat newContentSizeHeight = self.sendMessageTextView.contentSize.height;
        
        CGFloat diff = newContentSizeHeight - oldContentSizeHeight - differenceBetweenHeightAndContentSizeHeight;
        
        // just subtract it the first time and then set to 0 (I do not know or care why it works!)
        differenceBetweenHeightAndContentSizeHeight = 0;
        
        // = offset View = //
        
        CGRect bottonViewFrame = self.bottomContainerView.frame;
        bottonViewFrame.origin.y -= diff;
        bottonViewFrame.size.height += diff;
        self.bottomContainerView.frame = bottonViewFrame;
        
        
        // = offset TextView = //
        
        CGRect tvFrame = self.sendMessageTextView.frame;
    
        tvFrame.size.height += diff;
        
        self.sendMessageTextView.frame = tvFrame;
        
        
        
        // = set image = //
        
        CGRect imgFrame = self.sendMessageAvatarmageView.frame;
        
        imgFrame.origin.y += diff;
        
        self.sendMessageAvatarmageView.frame = imgFrame;
        
        
        // = set image = //
        
        CGRect btnFrame = self.sendMessageButton.frame;
        
        btnFrame.origin.y += diff;
        
        self.sendMessageButton.frame = btnFrame;
        
        
        
        oldContentSizeHeight = newContentSizeHeight;
        
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
    
    [self.commentsCollectionView reloadData];
    
    CGFloat offsetValue = self.commentsCollectionView.contentSize.height - self.commentsCollectionView.frame.size.height;
    [self.commentsCollectionView setContentOffset:CGPointMake(0.0f, offsetValue)];
    
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
    
    
    
    if (components.minute >= kCacheTimeInMinutes)
    {
        
        
        networkEngineToUse = appDelegate.oAuthNetworkEngine;
        
        
        
    }
    else
    {
        networkEngineToUse = appDelegate.networkEngine;
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
                                      
                                      [self fetchCommentsFromDB];
        
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
    
    [self fetchCommentsFromDB];
    
    
    self.sendMessageTextView.text = @"";
    
    [self.commentsCollectionView reloadData];
    
    
    __weak SYNCommentingViewController* wself = self;
    
    void(^ErrorBlock)(id) = ^(id error) {
        
        [wself deleteComment:comment];
        
        [wself.commentsCollectionView reloadData];
        
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
                                               NSLog(@"%@", error);
                                               ErrorBlock(@{@"error" : @"could not save to managed context"});
                                               return;
                                           }
                                           
                                           
                                           
                                           [self.sendMessageTextView resignFirstResponder];
                                           
                                           [self.commentsCollectionView reloadData];
        
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
    
    adHocComment.recentValue = YES;
    
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
                                                 
                                                 [wself.commentsCollectionView reloadData];
                                                 
                                                 
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
    for (Comment* comment in self.comments)
        if(!comment.validatedValue)
            [comment.managedObjectContext deleteObject:comment];
    
}



@end
