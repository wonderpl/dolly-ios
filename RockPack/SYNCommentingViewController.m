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

static NSString* CommentingCellIndentifier = @"SYNCommentingCollectionViewCell";

@interface SYNCommentingViewController () <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView* commentsCollectionView;
@property (nonatomic, strong) NSArray* commments;



// Send View

@property (nonatomic, strong) IBOutlet UIView* bottomContainerView;
@property (nonatomic, strong) IBOutlet UITextField* sendMessageTextField;
@property (nonatomic, strong) IBOutlet UIImageView* sendMessageAvatarmageView;
@property (nonatomic, strong) IBOutlet UIButton* sendMessageButton;

@property (nonatomic, weak) VideoInstance* videoInstance;

@property (nonatomic, strong) NSArray* comments;

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
    
    self.commments = @[]; // avoid calling count on nil instance
    
    
    [self.commentsCollectionView registerNib:[UINib nibWithNibName:CommentingCellIndentifier bundle:nil]
                  forCellWithReuseIdentifier:CommentingCellIndentifier];
    
    self.sendMessageTextField.font = [UIFont regularCustomFontOfSize:self.sendMessageTextField.font.pointSize];
    
    [self getCommentsFromServer];
    
}



- (void) viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardNotified:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardNotified:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
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
    self.comments = [appDelegate.searchManagedObjectContext executeFetchRequest: fetchRequest
                                                                          error: &error];
    
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
                                          self.comments = @[];
                                          
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

- (void) sendComment
{
    
    [appDelegate.oAuthNetworkEngine postCommentForUserId:appDelegate.currentUser.uniqueId
                                               channelId:self.videoInstance.channel.uniqueId
                                              andVideoId:self.videoInstance.uniqueId
                                             withComment:self.sendMessageTextField.text
                                       completionHandler:^(id dictionary) {
                                           
                                           
                                           NSLog(@"Sucess!");
                                           
        
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
	return self.commments.count;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNCommentingCollectionViewCell* commentingCell = [cv dequeueReusableCellWithReuseIdentifier:CommentingCellIndentifier
                                                                                    forIndexPath:indexPath];
    
    
    
    
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
