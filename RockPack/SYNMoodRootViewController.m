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

#import "SYNSearchResultsVideoCell.h"

#define LARGE_AMOUNT_OF_ROWS 10000
#define WATCH_BUTTON_ANIMATION_TIME 0.4

@interface SYNMoodRootViewController ()
@property (strong, nonatomic) IBOutlet UIPickerView *defaultPicker;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;

@property (nonatomic, strong) NSArray *moods;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topWatchConstraint;
@property (nonatomic, weak) IBOutlet UICollectionView *moodCollectionView;
@property (nonatomic, weak) IBOutlet UILabel *iWantToLabel;
@property (strong, nonatomic) IBOutlet UIButton *watchButton;

@property (strong, nonatomic) IBOutlet UICollectionView *videoCollectionView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topTitleConstraint;
@property (nonatomic, readonly) Mood* currentMood;
@property (nonatomic, strong) IBOutlet UIImageView* backgroundImageView;
@property (nonatomic, strong) NSArray* videoArray;
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
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
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
    
    
    [[self.defaultPicker.subviews objectAtIndex:1] setHidden:YES];
    [[self.defaultPicker.subviews objectAtIndex:2] setHidden:YES];
    
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
                                                          
                                                          
                                                          
                                                          self.videoArray = @[[sortedVideos objectAtIndex:0]];
                                                          
                                                          [self.videoCollectionView reloadData];
                                                          
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
        
//            VideoInstance *videoInstance = self.videoArray[indexPath.item];
//        UIViewController* viewController = [SYNCarouselVideoPlayerViewController viewControllerWithVideoInstances:sortedVideos selectedIndex:0];
//        
//        [strongSelf presentViewController:viewController animated:YES completion:nil];
        
    }
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
    
}

- (void)showWatchButton {
    self.watchButton.hidden = NO;
    self.watchButton.alpha = 0.0f;
    
    [UIView animateWithDuration:WATCH_BUTTON_ANIMATION_TIME animations:^{
        self.watchButton.alpha = 1.0f;
    }];
    
    if (IS_IPAD) {
        [self watchButtonTapped:nil];
    }
    
}


#pragma mark - Orientation

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    [self.moodCollectionView reloadData];
}

- (void) positionElementsForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
}

-(void)setMoods:(NSArray *)moods {
    _moods = moods;
    
    if(moods.count > 0) {
        [self.moodCollectionView reloadData];
        
        // center the moods list to the middle
        [self.moodCollectionView scrollToItemAtIndexPath: [NSIndexPath indexPathForItem:(LARGE_AMOUNT_OF_ROWS/2) inSection:0] atScrollPosition: UICollectionViewScrollPositionCenteredVertically animated: NO];
        [self showWatchButton];
    }
}

-(Mood*)currentMood {
    
    CGPoint point = CGPointMake(self.moodCollectionView.frame.size.width * 0.5f,
                                self.moodCollectionView.frame.size.height * 0.5f + self.moodCollectionView.contentOffset.y);
    
    NSIndexPath* indexPath = [self.moodCollectionView indexPathForItemAtPoint:point];
    
    Mood* cMood = self.moods [indexPath.item % self.moods.count];
    
    
    return cMood;
}

#pragma mark - UIPicker Delegates


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.moods count]*LARGE_AMOUNT_OF_ROWS;
}

#pragma mark - UIPickerView Delegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    
    if (IS_IPAD) {
        return 30.0;
    }
    
    return 24.0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    // not gtting called
    Mood* mood = self.moods [row % self.moods.count];
    
    return mood.name;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self showWatchButton];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel* tmpLabel = (UILabel*)view;
    if (!tmpLabel){
        tmpLabel = [[UILabel alloc] init];
        tmpLabel.adjustsFontSizeToFitWidth = YES;
        tmpLabel.textAlignment = NSTextAlignmentCenter;
        //        tmpLabel.font = [UIFont lightCustomFontOfSize:14];
        tmpLabel.font = [tmpLabel.font fontWithSize:14];
        if (IS_IPAD) {
            tmpLabel.font = [tmpLabel.font fontWithSize:25];
        }
        
        
        tmpLabel.textColor = [UIColor colorWithRed: 136.0f / 255.0f
                                             green: 134.0f / 255.0f
                                              blue: 168.0f / 255.0f
                                             alpha: 1.0f];
        tmpLabel.alpha = 1.0f;
        //        tmpLabel.backgroundColor = [UIColor dollyMoodColor];
    }
    self.watchButton.hidden = YES;
    
    Mood* mood = self.moods [row % self.moods.count];
    tmpLabel.text = mood.name;
    return tmpLabel;
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



@end
