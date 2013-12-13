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
#import "SYNDeviceManager.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#define kCell_2_Comment_Association_Key @"kCell_2_Comment_Association_Key"

static NSString* CommentingCellIndentifier = @"SYNCommentingCollectionViewCell";
static NSString* PlaceholderText = @"Say something nice";

@interface SYNCommentingViewController () <UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
{
    CGFloat differenceBetweenHeightAndContentSizeHeight;
    CGFloat oldContentSizeHeight;
    BOOL isAnimating;
}

@property (nonatomic, strong) IBOutlet UICollectionView* commentsCollectionView;

@property (nonatomic, strong) NSNumber* maxCommentPosition;

// Send View

@property (nonatomic, strong) IBOutlet UIView* bottomContainerView;
@property (nonatomic, strong) IBOutlet UITextView* sendMessageTextView;
@property (nonatomic, strong) IBOutlet UIImageView* sendMessageAvatarmageView;
@property (nonatomic, strong) IBOutlet UIButton* sendMessageButton;

@property (nonatomic, strong) NSMutableArray* unvalidatedCommentsQueue;

@property (nonatomic, weak) VideoInstance* videoInstance;

@property (nonatomic, strong) NSMutableArray* comments;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.comments = @[].mutableCopy; // avoid calling count on nil instance
    
    self.maxCommentPosition = @(0);
    
    oldContentSizeHeight = self.sendMessageTextView.contentSize.height;
    
    self.unvalidatedCommentsQueue = @[].mutableCopy;
    
    differenceBetweenHeightAndContentSizeHeight = self.sendMessageTextView.frame.size.height - oldContentSizeHeight;
    
    self.sendMessageTextView.text = PlaceholderText;
    
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



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
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
        
        
        
        oldContentSizeHeight = newContentSizeHeight;
        
    }
}


#pragma mark - Get Comments 

-(void)fetchCommentsFromDB
{
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    
    
    fetchRequest.entity = [NSEntityDescription entityForName: kComment
                                      inManagedObjectContext: appDelegate.searchManagedObjectContext];
    
    // comments relate to a specific video instance
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"videoInstanceId == %@", self.videoInstance.uniqueId]];
    
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"position" ascending: YES]];
    
    NSError* error;
    NSArray* fetchedArray = [appDelegate.searchManagedObjectContext executeFetchRequest: fetchRequest
                                                                                  error: &error];
    
    self.comments = @[].mutableCopy;
    
    [self.comments addObjectsFromArray:fetchedArray];
    
    [self.commentsCollectionView reloadData];
    
}

-(void)getCommentsFromServer
{
    [appDelegate.networkEngine getCommentsForUsedId:appDelegate.currentUser.uniqueId
                                          channelId:self.videoInstance.channel.uniqueId
                                         andVideoId:self.videoInstance.uniqueId
                                            inRange:self.dataRequestRange
                                  completionHandler:^(id dictionary) {
                                      
                                      if(![dictionary isKindOfClass:[NSDictionary class]])
                                          return;
                                      
                                      if(![appDelegate.mainRegistry registerCommentsFromDictionary:dictionary withExisting:self.comments])
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
    
    
    return YES;
}

- (Comment*) createCommentFromText:(NSString*)text
{
    
    
    NSDictionary* dictionary = @{
                                 @"id" : @"13245",
                                 @"position": self.maxCommentPosition,
                                 @"resource_url": @"",
                                 @"comment": text,
                                 @"validated" : @(NO), // not yet loaded from the server
                                 // @"date_added" : not passing the case will default to [NSDate date] which is correct
                                 @"user": @{
                                         @"id": appDelegate.currentUser.uniqueId,
                                         @"resource_url": @"",
                                         @"display_name": appDelegate.currentUser.displayName,
                                         @"avatar_thumbnail_url": appDelegate.currentUser.thumbnailURL
                                         }
                                 };
    
    
    Comment* adHocComment = [Comment instanceFromDictionary:dictionary
                                  usingManagedObjectContext:appDelegate.mainManagedObjectContext];
    
    
    
    return adHocComment;
}

- (void) sendComment
{
    NSString* commentText = self.sendMessageTextView.text;
    
    Comment* comment = [self createCommentFromText:commentText];
    
    
    [self.comments addObject:comment];
    
    
    self.sendMessageTextView.text = @"";
    
    [self.commentsCollectionView reloadData];
    

    
    [appDelegate.oAuthNetworkEngine postCommentForUserId:appDelegate.currentUser.uniqueId
                                               channelId:self.videoInstance.channel.uniqueId
                                              andVideoId:self.videoInstance.uniqueId
                                             withComment:commentText
                                       completionHandler:^(id dictionary) {
                                           
                                           comment.validatedValue = YES;
                                           
                                           [self.sendMessageTextView resignFirstResponder];
                                           
                                           [self.commentsCollectionView reloadData];
        
                                       } errorHandler:^(id error) {
                                           
                                           
        
                                       }];
}

#pragma mark - Button Delegates

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
    
    if(self.maxCommentPosition.integerValue < comment.positionValue)
        self.maxCommentPosition = @(comment.positionValue);
    
        
    commentingCell.loading = !comment.validatedValue; // if it is NOT validated, show loading state
    
    
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
                                                 attributes:@{ NSFontAttributeName :  correctFont}
                                                    context:nil];
    
    
    CGFloat correctHeight = rect.size.height + [SYNCommentingCollectionViewCell commentFieldFrame].origin.y + 10.0f;
    
    
    return CGSizeMake(self.commentsCollectionView.frame.size.width, correctHeight);
}


#pragma mark - Loading Comments

@end
