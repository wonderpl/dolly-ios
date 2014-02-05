//
//  SYNMoodViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 16/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNMoodRootViewController.h"
#import "SYNMoodCell.h"
#import "UIFont+SYNFont.h"
#import "SYNFadingFlowLayout.h"
#import "SYNCarouselVideoPlayerViewController.h"
#import "SYNDeviceManager.h"
#import "Mood.h"
#import "VideoInstance.h"
#import "UINavigationBar+Appearance.h"
#import "UIColor+SYNColor.h"
#import "SYNCarouselVideoPlayerViewController.h"
#import "UICollectionReusableView+Helpers.h"
#import "SYNVideoPlayerAnimator.h"
#import "SYNSearchResultsVideoCell.h"
#import "SYNSearchVideoPlayerViewController.h"

#define LARGE_AMOUNT_OF_ROWS 10000
#define WATCH_BUTTON_ANIMATION_TIME 0.4

@interface SYNMoodRootViewController ()
@property (strong, nonatomic) IBOutlet UIPickerView *defaultPicker;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;

@property (strong, nonatomic) IBOutlet UIView *viewContainer;
@property (nonatomic, strong) NSArray *moods;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topWatchConstraint;
@property (nonatomic, weak) IBOutlet UICollectionView *moodCollectionView;
@property (nonatomic, weak) IBOutlet UILabel *iWantToLabel;
@property (strong, nonatomic) IBOutlet UIButton *watchButton;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *videoCollectionView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topTitleConstraint;
@property (nonatomic, readonly) Mood* currentMood;
@property (nonatomic, strong) IBOutlet UIImageView* backgroundImageView;
@property (nonatomic, strong) NSArray* videoArray;
@property (nonatomic, strong) SYNVideoPlayerAnimator *videoPlayerAnimator;
@property (strong, nonatomic) IBOutlet UIImageView *moodBackground;
@property (nonatomic, assign) CGPoint scrollingPoint, endPoint;
@property (nonatomic, strong) NSTimer *scrollingTimer;

@end


@implementation SYNMoodRootViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.moods = @[];
    
    // Setup mood collection view
    [self.moodCollectionView registerClass:[SYNMoodCell class]
                forCellWithReuseIdentifier:NSStringFromClass([SYNMoodCell class])];
    [self.videoCollectionView registerNib:[SYNSearchResultsVideoCell nib]
                forCellWithReuseIdentifier:[SYNSearchResultsVideoCell reuseIdentifier]];

    
    self.iWantToLabel.font = [UIFont regularCustomFontOfSize: self.iWantToLabel.font.pointSize];
    self.iWantToLabel.textColor = [UIColor dollyMoodColor];
    
    self.moodCollectionView.scrollsToTop = NO;
    
    [self loadMoods];
    
    [self getUpdatedMoods];

    
    
    self.watchButton.layer.cornerRadius = 15.5f;
    self.watchButton.layer.masksToBounds = YES;
    
    self.watchButton.layer.borderWidth = 1.5f;
    self.watchButton.layer.borderColor = [[UIColor dollyMoodColor] CGColor];
    
    if (IS_IPHONE) {
        self.defaultPicker.transform = CGAffineTransformScale(self.defaultPicker.transform, 1.3f, 1.40f);
    } else {
        self.defaultPicker.transform = CGAffineTransformScale(self.defaultPicker.transform, 1.0f, 1.10f);
    }
    
    if (!IS_IPHONE_5) {
        //TODO: need to move views for 3.5
        self.topTitleConstraint.constant -= 24.0f;
        self.topWatchConstraint.constant += 34.0f;
        
    }
    
    NSIndexPath *centerIndexPath = [NSIndexPath indexPathForItem:10 inSection:0];
    
    if (self.moods.count>0) {
        [self.moodCollectionView scrollToItemAtIndexPath:centerIndexPath
                                        atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                                animated:YES];
    }

    self.videoArray = @[];
    [self updateLayoutForOrientation:[SYNDeviceManager.sharedInstance orientation]];
    

}

-(void) viewDidDisAppear:(BOOL)animated
{
    
    [self updateLayoutForOrientation:[SYNDeviceManager.sharedInstance orientation]];
}

-(void) viewWillAppear:(BOOL)animated
{
    [self updateLayoutForOrientation:[SYNDeviceManager.sharedInstance orientation]];
}



-(void) spinAnimationWithRow : (NSNumber*) row {
    [self.defaultPicker selectRow:[row integerValue] inComponent:0 animated:YES];
}

-(void) spinAnimation : (NSNumber*) row {
    [UIView animateWithDuration:2.0f animations:^{
        [self.defaultPicker selectRow:[row integerValue] inComponent:0 animated:NO];
    }];
}


#pragma mark - Getting Mood Objects

- (void) loadMoods {
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Mood"];
    
    NSError* error;
    self.moods = [appDelegate.mainManagedObjectContext executeFetchRequest:fetchRequest
                                                                     error:&error];
    if(self.moods == 0) {
        //TODO: No moods what do??
    }
    
    [self.moodCollectionView reloadData];

}

-(void) getUpdatedMoods {
    [appDelegate.networkEngine getMoodsWithCompletionHandler:^(id responce) {
        
        if(![responce isKindOfClass:[NSDictionary class]])
            return;
        
        if([appDelegate.mainRegistry registerMoodsFromDictionary:responce
                                               withExistingMoods:self.moods]) {
            [self loadMoods];
            [self scrollSlowly];

        }
        
        
        
    } errorHandler:^(id error) {
        
        
        
    }];
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if([[SYNDeviceManager sharedInstance] isPortrait] && IS_IPAD) {
        [self positionElementsForInterfaceOrientation:UIDeviceOrientationPortrait];
    }
    
    // Hides the 2 lines in the default picker
    [self updateLayoutForOrientation:[SYNDeviceManager.sharedInstance orientation]];

}

#pragma mark - Control Callbacks
- (IBAction)watchButtonTapped:(id)sender {
    
    
    
    self.watchButton.userInteractionEnabled = NO;
    
	__weak typeof(self) weakSelf = self;
	
    [appDelegate.oAuthNetworkEngine getRecommendationsForUserId: appDelegate.currentUser.uniqueId
                                                  andEntityName: kVideoInstance
                                                         params: @{@"mood":self.currentMood.uniqueId}
                                              completionHandler: ^(id response) {
												  
												  __strong typeof(self) strongSelf = weakSelf;
                                                  
                                                  if(![response isKindOfClass:[NSDictionary class]])
                                                      return;
                                                  
                                                  if(![appDelegate.searchRegistry registerVideoInstancesFromDictionary:response
                                                                                                            withViewId:self.viewId])
                                                      return;
												  
												  NSArray *videoInstances = response[@"videos"][@"items"];
												  NSArray *videoInstanceIds = [videoInstances valueForKey:@"id"];
												  
                                                  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[VideoInstance entityName]];
												  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueId IN %@", videoInstanceIds];
												  [fetchRequest setPredicate:predicate];
                                                  
                                                  NSArray* videosArray = [appDelegate.searchManagedObjectContext executeFetchRequest:fetchRequest
                                                                                                                               error:NULL];
												  
                                                  if (![videosArray count]) {
                                                      // implement
                                                  }
												  
												  NSArray *sortedVideos = [strongSelf sortedVideoInstances:videosArray inIdOrder:videoInstanceIds];
												  if (sortedVideos.count > 0) {
                                                      

                                                      if (IS_IPHONE) {
                                                          UIViewController* viewController = [SYNCarouselVideoPlayerViewController viewControllerWithVideoInstances:sortedVideos selectedIndex:0];

                                                          [strongSelf presentViewController:viewController animated:YES completion:nil];
                                                          
                                                      } else {
                                                          
                                                          
                                                          UIViewController* viewController = [SYNCarouselVideoPlayerViewController viewControllerWithVideoInstances:self.videoArray selectedIndex:0];
                                                          
                                                          SYNVideoPlayerAnimator *animator = [[SYNVideoPlayerAnimator alloc] init];
                                                          animator.delegate = self;
                                                          animator.cellIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                                                          self.videoPlayerAnimator = animator;
                                                          viewController.transitioningDelegate = animator;
                                                          
                                                          [self presentViewController:viewController animated:YES completion:nil];

                                                      }
                                                  }
                                                  
                                                  strongSelf.watchButton.userInteractionEnabled = YES;

                                              } errorHandler:^(id error) {
                                                  
                                              }];
}


#pragma mark - UICollectionView Data Source Stubs

// To be implemented by subclasses
- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger) section {
    
    if (collectionView == self.moodCollectionView) {
        return self.moods.count > 0 ? LARGE_AMOUNT_OF_ROWS : 0;
        
    }
    
    
    return self.videoArray.count;
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView {
    return 1;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath {
    
    if (cv == self.moodCollectionView) {
        SYNMoodCell *moodCell = [self.moodCollectionView dequeueReusableCellWithReuseIdentifier: NSStringFromClass([SYNMoodCell class])
                                                                                   forIndexPath: indexPath];
        
        Mood* mood = self.moods [indexPath.item % self.moods.count];
        
        moodCell.titleLabel.text = mood.name;
        
        return moodCell;

    }

    if (cv == self.videoCollectionView) {
        
        
        SYNSearchResultsVideoCell *videoCell = [cv dequeueReusableCellWithReuseIdentifier:[SYNSearchResultsVideoCell reuseIdentifier]
                                                                                         forIndexPath:indexPath];
        
        
        videoCell.videoInstance = (VideoInstance*)(self.videoArray[indexPath.item]);
        videoCell.delegate = self;
        
        
        return videoCell;

        
    }

    return nil;

}

//- (CGSize)collectionView:(UICollectionView *)collectionView
//                  layout:(UICollectionViewLayout*)collectionViewLayout
//  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    // == first of last item
//    if (indexPath.row == 0 || (indexPath.row % self.moods.count == self.moods.count-1)) {
//        return CGSizeMake(self.moodCollectionView.frame.size.width, (IS_IPAD ? 35.0f :35.0f));
//    }
//    
//    return CGSizeMake(self.moodCollectionView.frame.size.width, (IS_IPAD ? 40.0f :40.0f));
//}


- (void) collectionView: (UICollectionView *) cv
didSelectItemAtIndexPath: (NSIndexPath *)indexPath {
    
    if (cv == self.moodCollectionView) {
        if (self.currentMood == self.moods [indexPath.item % self.moods.count]) {
            [self watchButtonTapped:nil];
        }
    }
    
    if (cv == self.videoCollectionView) {
        
        UIViewController* viewController = [SYNCarouselVideoPlayerViewController viewControllerWithVideoInstances:self.videoArray selectedIndex:0];
		
		SYNVideoPlayerAnimator *animator = [[SYNVideoPlayerAnimator alloc] init];
		animator.delegate = self;
		animator.cellIndexPath = indexPath;
		self.videoPlayerAnimator = animator;
		viewController.transitioningDelegate = animator;
		
		[self presentViewController:viewController animated:YES completion:nil];
    
    }

}


- (id<SYNVideoInfoCell>)videoCellForIndexPath:(NSIndexPath *)indexPath {
	return (SYNSearchResultsVideoCell *)[self.videoCollectionView cellForItemAtIndexPath:indexPath];
}

#pragma mark - ScrollView Delegate (Override to avoid tab bar animating)


-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // override
    
    [self showWatchButton];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self showWatchButton];
    }
}

- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // override
    [self showWatchButton];
    
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    // override
    self.watchButton.hidden = YES;
    self.videoCollectionView.hidden = YES;
    
    
    if (self.scrollingTimer) {
        [self.scrollingTimer invalidate];
    }

}

- (void)showWatchButton {
    self.watchButton.hidden = NO;

    self.watchButton.alpha = 0.0f;
    
    [UIView animateWithDuration:WATCH_BUTTON_ANIMATION_TIME animations:^{
        self.watchButton.alpha = 1.0f;
    }];
    
    if (IS_IPAD) {
        
        
        self.watchButton.userInteractionEnabled = NO;
        
        __weak typeof(self) weakSelf = self;
        
        [appDelegate.oAuthNetworkEngine getRecommendationsForUserId: appDelegate.currentUser.uniqueId
                                                      andEntityName: kVideoInstance
                                                             params: @{@"mood":self.currentMood.uniqueId}
                                                  completionHandler: ^(id response) {
                                                      
                                                      __strong typeof(self) strongSelf = weakSelf;
                                                      
                                                      if(![response isKindOfClass:[NSDictionary class]])
                                                          return;
                                                      
                                                      if(![appDelegate.searchRegistry registerVideoInstancesFromDictionary:response
                                                                                                                withViewId:self.viewId])
                                                          return;
                                                      
                                                      NSArray *videoInstances = response[@"videos"][@"items"];
                                                      NSArray *videoInstanceIds = [videoInstances valueForKey:@"id"];
                                                      
                                                      NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[VideoInstance entityName]];
                                                      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueId IN %@", videoInstanceIds];
                                                      [fetchRequest setPredicate:predicate];
                                                      
                                                      NSArray* videosArray = [appDelegate.searchManagedObjectContext executeFetchRequest:fetchRequest
                                                                                                                                   error:NULL];
                                                      
                                                      if (![videosArray count]) {
                                                          // implement
                                                      }
                                                      
                                                      NSArray *sortedVideos = [strongSelf sortedVideoInstances:videosArray inIdOrder:videoInstanceIds];
                                                      if (sortedVideos.count > 0) {
                                                          
                                                          
                                                          
                                                              
                                                              self.videoArray = @[[sortedVideos objectAtIndex:0]];
                                                              
                                                              [self.videoCollectionView reloadData];
                                                              
                                                              
                                                              if (self.videoArray.count==1) {
                                                                  self.videoCollectionView.hidden = NO;
                                                                  self.videoCollectionView.alpha = 0.0f;
                                                                  
                                                                  [UIView animateWithDuration:0.5 animations:^{
                                                                      self.videoCollectionView.alpha = 1.0f;
                                                                  }];
                                                              }
                                                          
                                                      }
                                                      
                                                      strongSelf.watchButton.userInteractionEnabled = YES;
                                                      
                                                  } errorHandler:^(id error) {
                                                      
                                                  }];
    }
    
}


#pragma mark - Orientation

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    
    self.videoCollectionView.alpha = 0.0;
    self.moodCollectionView.alpha = 0.0;
//    self.watchButton.alpha = 0.0;
//    self.moodBackground.alpha = 0.0;
//    self.iWantToLabel.alpha = 0.0;
    
    [self.moodCollectionView reloadData];
    [self.videoCollectionView reloadData];
}

- (void) positionElementsForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

}

-(void)setMoods:(NSArray *)moods {
    _moods = moods;
    
    if(moods.count > 0) {
        [self.moodCollectionView reloadData];
        
        // center the moods list to the middle
        [self.moodCollectionView scrollToItemAtIndexPath: [NSIndexPath indexPathForItem:(LARGE_AMOUNT_OF_ROWS/2) inSection:0] atScrollPosition: UICollectionViewScrollPositionCenteredVertically animated: NO];
//        [self showWatchButton];
    }
}

-(Mood*)currentMood {
    
    CGPoint point = CGPointMake(self.moodCollectionView.frame.size.width * 0.5f,
                                self.moodCollectionView.frame.size.height * 0.5f + self.moodCollectionView.contentOffset.y);
    
    NSIndexPath* indexPath = [self.moodCollectionView indexPathForItemAtPoint:point];
    
    Mood* cMood = self.moods [indexPath.item % self.moods.count];
    
    
    return cMood;
}


- (NSArray *)sortedVideoInstances:(NSArray *)videoInstances inIdOrder:(NSArray *)videoInstanceIds {
	NSMutableArray *sortedVideoInstances = [NSMutableArray array];
	
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:videoInstances
														   forKeys:[videoInstances valueForKey:@"uniqueId"]];
	
	for (NSString *videoInstanceId in videoInstanceIds) {
		[sortedVideoInstances addObject:dictionary[videoInstanceId]];
	}
	
	return sortedVideoInstances;
}

#pragma mark - Orientation change

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:0.15 animations:^{
        self.videoCollectionView.alpha = 0.0;
        self.moodCollectionView.alpha = 0.0;
        self.watchButton.alpha = 0.0f;
    } completion:^(BOOL finished) {
        
    }];

    
}

- (void) didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation
{
    
    [self updateLayoutForOrientation:fromInterfaceOrientation];
   
    [UIView animateWithDuration:0.3 animations:^{
        self.videoCollectionView.alpha = 1.0;
        self.moodCollectionView.alpha = 1.0;
        self.watchButton.alpha = 1.0;
        self.moodBackground.alpha = 1.0;
        self.iWantToLabel.alpha = 1.0;
    } completion:^(BOOL finished) {
 
    }];

}

- (void) updateLayoutForOrientation: (UIInterfaceOrientation) fromInterfaceOrientation
{
    
    if (IS_IPAD) {
        // land scape
        if (UIDeviceOrientationIsLandscape([SYNDeviceManager.sharedInstance orientation])) {
            self.videoCollectionView.frame = CGRectMake(403, 136, 436, 459);
            self.watchButton.frame = CGRectMake(109, 662, self.watchButton.frame.size.width, self.watchButton.frame.size.height);
            
            self.moodCollectionView.frame = CGRectMake(118, 312, self.moodCollectionView.frame.size.width, self.moodCollectionView.frame.size.height);
            self.iWantToLabel.frame = CGRectMake(-25, 432, self.iWantToLabel.frame.size.width, self.iWantToLabel.frame.size.height);
//            self.titleLabel.frame = CGRectMake(17, 176, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height);
            self.moodBackground.frame = CGRectMake(1, 270, self.moodBackground.frame.size.width, self.moodBackground.frame.size.height);
            
        } else {
            self.videoCollectionView.frame = CGRectMake(246, 248, 436, 459);
            self.watchButton.frame = CGRectMake(80, 800, self.watchButton.frame.size.width, self.watchButton.frame.size.height);
            self.moodCollectionView.frame = CGRectMake(118, 372, self.moodCollectionView.frame.size.width, self.moodCollectionView.frame.size.height);
            self.iWantToLabel.frame = CGRectMake(-25, 492, self.iWantToLabel.frame.size.width, self.iWantToLabel.frame.size.height);
            self.moodBackground.frame = CGRectMake(1, 330, self.moodBackground.frame.size.width, self.moodBackground.frame.size.height);
            
        }
        
    }
    
}


- (void)scrollSlowly {
    if (self.moods.count>1) {
        [self.moodCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:200 inSection:0] atScrollPosition:       UICollectionViewScrollPositionCenteredVertically animated:NO];
    } else  {
        return;
    }
    
    // 230 == height of the cell
    
    
    self.endPoint = CGPointMake(0, self.moodCollectionView.bounds.origin.y+(self.moods.count * 40.0f)+floorf(arc4random()%10)*40.0f);
    
    //Start off screen
    self.scrollingPoint = CGPointMake(0, self.moodCollectionView.bounds.origin.y);
    self.scrollingTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(scrollSlowlyToPoint) userInfo:nil repeats:YES];
}

- (void)scrollSlowlyToPoint {
    self.moodCollectionView.bounds = CGRectMake(self.scrollingPoint.x, self.scrollingPoint.y, self.moodCollectionView.bounds.size.width, self.moodCollectionView.bounds.size.height);
    if (self.scrollingPoint.y> self.endPoint.y) {
        
        [self.scrollingTimer invalidate];
        [self showWatchButton];
    }
    
    self.scrollingPoint = CGPointMake(self.scrollingPoint.x, self.scrollingPoint.y+4);
}

- (void) profileButtonPressedForCell:(UICollectionViewCell *)cell {
    
}

-(void) channelButtonPressedForCell:(UICollectionViewCell *)cell {
    
}

@end
