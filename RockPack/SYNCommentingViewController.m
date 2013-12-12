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

static NSString* CommentingCellIndentifier = @"SYNCommentingCollectionViewCell";


@interface SYNCommentingViewController () <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView* commentsCollectionView;

@property (nonatomic, strong) NSNumber* maxCommentPosition;

// Send View

@property (nonatomic, strong) IBOutlet UIView* bottomContainerView;
@property (nonatomic, strong) IBOutlet UITextField* sendMessageTextField;
@property (nonatomic, strong) IBOutlet UIImageView* sendMessageAvatarmageView;
@property (nonatomic, strong) IBOutlet UIButton* sendMessageButton;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.comments = @[].mutableCopy; // avoid calling count on nil instance
    
    self.maxCommentPosition = @(0);
    
    [self.commentsCollectionView registerNib:[UINib nibWithNibName:CommentingCellIndentifier bundle:nil]
                  forCellWithReuseIdentifier:CommentingCellIndentifier];
    
    self.sendMessageTextField.font = [UIFont regularCustomFontOfSize:self.sendMessageTextField.font.pointSize];
    
    
    
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




- (void) keyboardNotified: (NSNotification*) notification
{
    if(IS_IPAD)
    {
        CGRect sFrame = self.navigationController.view.frame;
        if([notification.name isEqualToString:UIKeyboardWillShowNotification])
            sFrame.origin.y -= 110.0f;
        else if ([notification.name isEqualToString:UIKeyboardWillHideNotification])
            sFrame.origin.y += 110.0f;
        
        __weak SYNCommentingViewController* wself = self;
        [UIView animateWithDuration:0.3f animations:^{
            wself.navigationController.view.frame = sFrame;
        }];
    }
    else // is IPHONE
    {
        CGRect sFrame = self.bottomContainerView.frame;
        if([notification.name isEqualToString:UIKeyboardWillShowNotification])
            sFrame.origin.y -= 220.0f;
        else if ([notification.name isEqualToString:UIKeyboardWillHideNotification])
            sFrame.origin.y += 220.0f;
        
        __weak SYNCommentingViewController* wself = self;
        [UIView animateWithDuration:0.3f animations:^{
            wself.bottomContainerView.frame = sFrame;
        }];
    }
    
    
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

#pragma mark - UITextFieldDelegate

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendComment];
    
    return YES;
}

- (Comment*) createCommentFromText:(NSString*)text
{
    
    
    NSDictionary* dictionary = @{
                                 @"id" : @"13245",
                                 @"position": self.maxCommentPosition,
                                 @"resource_url": @"",
                                 @"comment": text,
                                 @"date_added": @"2013-12-10T18:15:57.319368",
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
    NSString* commentText = self.sendMessageTextField.text;
    
    [self.comments addObject:[self createCommentFromText:commentText]];
    
    self.sendMessageTextField.text = @"";
    
    [self.sendMessageTextField resignFirstResponder];
    
    [self.commentsCollectionView reloadData];
    
    return;
    
    [appDelegate.oAuthNetworkEngine postCommentForUserId:appDelegate.currentUser.uniqueId
                                               channelId:self.videoInstance.channel.uniqueId
                                              andVideoId:self.videoInstance.uniqueId
                                             withComment:commentText
                                       completionHandler:^(id dictionary) {
                                           
                                           [self.comments addObject:[self createCommentFromText:commentText]];
                                           
                                           self.sendMessageTextField.text = @"";
                                           
                                           [self.sendMessageTextField resignFirstResponder];
                                           
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
    
    if(self.maxCommentPosition.integerValue < comment.positionValue)
        self.maxCommentPosition = @(comment.positionValue);
    
    
    
    return commentingCell;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView
//                  layout:(UICollectionViewLayout*)collectionViewLayout
//  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//    
//    
//    
//    
//}


#pragma mark - Loading Comments

@end
