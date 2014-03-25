//
//  SYNProfileSubscriptionViewController.m
//  dolly
//
//  Created by Cong Le on 10/03/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNProfileSubscriptionViewController.h"
#import "SYNChannelMidCell.h"
#import "SYNChannelDetailsViewController.h"
#import "UIColor+SYNColor.h"
#import "SYNActivityManager.h"
#import "SYNProfileHeader.h"
#import "SYNChannelSearchCell.h"
#import "UICollectionReusableView+Helpers.h"
#import "UIFont+SYNFont.h"
#import "SYNDeviceManager.h"
#import "SYNProfileViewController.h"

#define PARALLAX_SCROLL_VALUE 2.0f
#define SEARCHBAR_Y 430.0f
#define FULL_NAME_LABEL_IPHONE 364.0f // lower is down
#define FULL_NAME_LABEL_IPAD_PORTRAIT 533.0f
#define FULLNAMELABELIPADLANDSCAPE 412.0f

//TODO: Variables

@interface SYNProfileSubscriptionViewController () <UISearchBarDelegate, SYNPagingModelDelegate, SYNChannelMidCellDelegate>
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *defaultLayout;

@property (nonatomic, strong) IBOutlet UIView *fakeNavigationBar;
@property (nonatomic, strong) IBOutlet UILabel *fakeNavigationBarTitle;
@property (nonatomic, strong) NSArray *filteredSubscriptions;
@property (nonatomic, strong) NSString *currentSearchTerm;
@property (nonatomic, assign) BOOL searchMode;
@property (nonatomic, assign) BOOL shouldBeginEditing;
@property (nonatomic, strong) SYNProfileHeader* headerView;
@property (nonatomic, strong) UISearchBar* searchBar;
@property (nonatomic, strong) UITapGestureRecognizer *tapToHideKeyoboard;
@property (nonatomic, strong) SYNProfileSubscriptionModel *model;
@property (nonatomic, strong) UITapGestureRecognizer *tapToResetCells;


@end

@implementation SYNProfileSubscriptionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //TODO: Helpers
    
    [self.cv registerNib: [SYNChannelMidCell nib]
forCellWithReuseIdentifier: [SYNChannelMidCell reuseIdentifier]];
    
    [self.cv registerNib: [SYNProfileHeader nib]
forSupplementaryViewOfKind: UICollectionElementKindSectionHeader
     withReuseIdentifier: [SYNProfileHeader reuseIdentifier]];
    
    
    [self.cv registerNib: [SYNChannelSearchCell nib]
forCellWithReuseIdentifier:[SYNChannelSearchCell reuseIdentifier]];
    
    [self.cv registerNib:[SYNChannelFooterMoreView nib]
forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
     withReuseIdentifier:[SYNChannelFooterMoreView reuseIdentifier]];
    
    //    [self setUpSearchBar];
    self.filteredSubscriptions = [self.channelOwner.subscriptions array];
    [self.cv reloadData];
    
    if (self.isUserProfile && IS_IPHONE) {
        
        //Search bar added to view because as reload data messes it up when its a cell.
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 494, CGRectGetWidth(self.cv.frame), 44)];
        self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        //        [self enableCancelButton:self.searchBar];
        self.searchBar.delegate = self;
        
        //        [self.searchBar setBarTintColor:[UIColor whiteColor]];
        
        
        self.searchBar.tintColor = [UIColor colorWithRed: (127.0f / 255.0f)
                                                   green: (127.0f / 255.0f)
                                                    blue: (127.0f / 255.0f)
                                                   alpha: 1.0f];
        //good
        self.searchBar.translucent = YES;
        
        self.searchBar.layer.borderWidth = IS_RETINA ? 0.5f: 1.0f;
        self.searchBar.layer.borderColor = [[UIColor dollyMediumGray] CGColor];
        
        //TODO: Look into making it a cell
        [self.cv insertSubview:self.searchBar belowSubview:self.headerView];
        [self.cv addSubview:self.searchBar];
        [self.cv setContentOffset:CGPointMake(0, 44)];
        
    }
    
    self.tapToHideKeyoboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    self.fakeNavigationBarTitle.font = [UIFont regularCustomFontOfSize:20];
    [self.fakeNavigationBarTitle setText: _channelOwner.displayName];
    
    self.tapToResetCells = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDescriptionCurrentlyShowing)];
    
    [self.view addGestureRecognizer:self.tapToResetCells];
    [self.tapToResetCells setEnabled:NO];
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    if (IS_IPAD) {
        [self updateLayoutForOrientation: [[SYNDeviceManager sharedInstance] orientation]];
    }
    
    
    if (!IS_IPHONE_5 && IS_IPHONE) {
        UIEdgeInsets tmpInsets = self.cv.contentInset;
        tmpInsets.bottom += 88;
        [self.cv setContentInset: tmpInsets];
    }

    //    [self.model reset];
    //    [self.model loadNextPage];
    
}


- (void) setChannelOwner:(ChannelOwner *)channelOwner {
    _channelOwner = channelOwner;
    
    self.model = [SYNProfileSubscriptionModel modelWithChannelOwner:channelOwner];
    self.model.delegate = self;
    self.isUserProfile = (BOOL)[_channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId];
}

#pragma mark - Scrollview delegates

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [super scrollViewWillBeginDragging:scrollView];
    [self hideDescriptionCurrentlyShowing];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [super scrollViewDidScroll:scrollView];
    [self coverPhotoAnimation];
	[self moveNameLabelWithOffset:scrollView.contentOffset.y];
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self moveNameLabelWithOffset:scrollView.contentOffset.y];
}

- (void) coverPhotoAnimation {
    if (self.cv.contentOffset.y<=0) {
        [self.headerView.coverImage setContentMode:UIViewContentModeScaleAspectFill];
        [self.headerView.coverImageTop setConstant:self.cv.contentOffset.y];
    } else {
        [self.headerView.coverImage setContentMode:UIViewContentModeCenter];
        [self.headerView.coverImageTop setConstant:self.cv.contentOffset.y/PARALLAX_SCROLL_VALUE];
    }
}

- (void) moveNameLabelWithOffset :(CGFloat) offset {
    
    float offSetCheck = IS_IPHONE? FULL_NAME_LABEL_IPHONE: UIDeviceOrientationIsPortrait([[SYNDeviceManager sharedInstance] orientation]) ? FULL_NAME_LABEL_IPAD_PORTRAIT: FULLNAMELABELIPADLANDSCAPE;
    
    if (offset > offSetCheck) {
        self.fakeNavigationBar.hidden = NO;
		
        CGAffineTransform move = CGAffineTransformMakeTranslation(0,-FULL_NAME_LABEL_IPHONE+offset);
		
        self.headerView.fullNameLabel.transform = move;
    } else {
        CGAffineTransform move = CGAffineTransformMakeTranslation(0,0);
        self.headerView.fullNameLabel.transform = move;
        self.fakeNavigationBar.hidden = YES;
		
    }
}


#pragma mark - UICollectionView DataSource/Delegate

- (NSInteger) collectionView: (UICollectionView *) view numberOfItemsInSection: (NSInteger) section
{
    return self.model.itemCount + (self.isUserProfile&&IS_IPHONE ? 1:0);
}

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    UICollectionViewCell *cell = nil;
    NSInteger index = indexPath.row - (self.isUserProfile&&IS_IPHONE ? 1:0);
    
    if (indexPath.row == 0 && self.isUserProfile && IS_IPHONE) {
        
        //TODO: Helpers
        SYNChannelSearchCell *searchCell = [collectionView dequeueReusableCellWithReuseIdentifier: [SYNChannelSearchCell reuseIdentifier]
                                                                                     forIndexPath: indexPath];
        cell = searchCell;
        
    } else {
        SYNChannelMidCell *channelThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: [SYNChannelMidCell reuseIdentifier] forIndexPath: indexPath];
        
        Channel *channel;
        
        if (index < [self.filteredSubscriptions count]) {
            channel = self.filteredSubscriptions[index];
            //text is set in the channelmidcell setChannel method
            channelThumbnailCell.channel = channel;
        } else {
            channelThumbnailCell.channel = nil;
        }
        
        channelThumbnailCell.viewControllerDelegate = self;
        
        cell = channelThumbnailCell;
        
    }
	
    return cell;
}

- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNChannelMidCell* cell = (SYNChannelMidCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    SYNChannelMidCell *selectedCell = cell;
    
    if (selectedCell.state != ChannelMidCellStateDefault) {
        [selectedCell setState: ChannelMidCellStateDefault withAnimation:YES];
        return;
    }
    
    
    if (indexPath.row < [self.filteredSubscriptions count]) {
        
        int index = indexPath.row - (self.isUserProfile&&IS_IPHONE ? 1 : 0);
        
        Channel *channel = self.filteredSubscriptions[index];
        //        self.navigationController.navigationBarHidden = NO;
        
        SYNChannelDetailsViewController *channelVC = [[SYNChannelDetailsViewController alloc] initWithChannel:channel usingMode:kChannelDetailsModeDisplay];
        
        [self.navigationController pushViewController:channelVC animated:YES];
    }
    
    return;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (IS_IPHONE) {
        if (indexPath.row == 0  && self.isUserProfile) {
            return CGSizeMake(320, 44);
        }
    }
    
    return self.defaultLayout.itemSize;
}


- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath {
    UICollectionReusableView *supplementaryView = nil;
	if (kind == UICollectionElementKindSectionHeader) {
        
        supplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind: kind
                                                               withReuseIdentifier: [SYNProfileHeader reuseIdentifier]
                                                                      forIndexPath: indexPath];
        self.headerView = ((SYNProfileHeader*)supplementaryView);
        self.headerView.channelOwner = self.channelOwner;
        self.headerView.isUserProfile = self.isUserProfile;
        self.headerView.delegate = (SYNProfileViewController*)self.parentViewController;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        self.footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                             withReuseIdentifier:[SYNChannelFooterMoreView reuseIdentifier]
                                                                    forIndexPath:indexPath];
        supplementaryView = self.footerView;
        
		if ([self.model hasMoreItems]) {
			self.footerView.showsLoading = YES;
			
			[self.model loadNextPage];
		}
    }
    
    return supplementaryView;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
	return ((collectionView == self.cv && [self.model hasMoreItems]) ? [self footerSize] : CGSizeZero);
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    // cant seem to get value from the layout
    
    if (IS_IPHONE) {
        if (self.isUserProfile) {
            return CGSizeMake(320, 494);
        } else {
            return CGSizeMake(320, 516);
        }
    } else {
        if (UIDeviceOrientationIsPortrait([[SYNDeviceManager sharedInstance] orientation])) {
            return CGSizeMake(self.view.frame.size.width, 701);
        } else {
            return CGSizeMake(self.view.frame.size.width, 574);
        }
    }
    return CGSizeZero;
}


#pragma mark - Searchbar delegates

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    //    self.searchMode = NO;
    //[self calculateOffsetForSearch];
    
    [self.cv setContentOffset:CGPointZero animated:YES];
    
    double delayInSeconds = 0.4;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        UIEdgeInsets tmp = self.defaultLayout.sectionInset;
        tmp.bottom += 300;
        self.defaultLayout.sectionInset = tmp;
        [self.cv.collectionViewLayout invalidateLayout];
        
    });
    
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.currentSearchTerm = searchBar.text;
    [self.cv reloadData];
    
    self.searchMode = NO;
    
    [self.searchBar resignFirstResponder];
    
    if (searchBar.text.length == 0) {
        [self.searchBar setShowsCancelButton:NO animated:YES];
    } else {
        [self enableCancelButton: self.searchBar];
    }
    
    self.cv.contentOffset = CGPointMake(0, SEARCHBAR_Y);
    [self.searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //To not get the keyboard to show when the x button is clicked
    //    if(![self.followingSearchBar isFirstResponder]) {
    //        self.shouldBeginEditing = NO;
    //    }
    
    
    self.currentSearchTerm = searchBar.text;
	
    [self.searchBar resignFirstResponder];
    
    if (searchBar.text.length == 0) {
        [self.searchBar setShowsCancelButton:NO animated:YES];
    } else {
        self.searchBar.showsCancelButton = YES;
    }
    
    
	self.filteredSubscriptions = [self filteredSubscriptionsForSearchTerm:searchBar.text];
	
    
    [self.cv reloadData];
    [self.searchBar becomeFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)bar
{
    // boolean to check if the keyboard should show
    BOOL boolToReturn = self.shouldBeginEditing;
    self.searchMode = YES;
    
    //    [self stopCollectionScrollViews];
    
    if (self.shouldBeginEditing)
    {
        
        [UIView animateWithDuration:0.2 animations:^{
            self.cv.contentOffset = CGPointMake(0, SEARCHBAR_Y);
            
        } completion:^(BOOL finished) {
            UIEdgeInsets tmp = self.defaultLayout.sectionInset;
            tmp.bottom += 300;
            self.defaultLayout.sectionInset = tmp;
            [self.cv.collectionViewLayout invalidateLayout];
        }];
        [self.searchBar setShowsCancelButton:YES animated:YES];
        
        
        
    }
    
    self.shouldBeginEditing = YES;
    
    return boolToReturn;
}

- (void)enableCancelButton:(UISearchBar *)searchBar {
    for (UIView *view in searchBar.subviews)
    {
        for (id subview in view.subviews)
        {
            if ( [subview isKindOfClass:[UIButton class]] )
            {
                [subview setEnabled:YES];
                return;
            }
        }
    }
}


- (NSArray *)filteredSubscriptionsForSearchTerm:(NSString *)searchTerm {
	if ([searchTerm length]) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title BEGINSWITH[cd] %@", searchTerm];
		return [[self.channelOwner.subscriptions array] filteredArrayUsingPredicate:predicate];
	}
	return [self.channelOwner.subscriptions array];
}

#pragma mark - Get channels

- (void) getChannels {
    
    __weak typeof(self) weakSelf = self;
    
    MKNKUserSuccessBlock successBlock = ^(NSDictionary *dictionary) {
        weakSelf.loadingMoreContent = NO;
        NSError *error = nil;
        
        [weakSelf.channelOwner setSubscriptionsDictionary: dictionary];
        //#warning cache all the channels to activity manager?
        // is there a better way?
        // can use the range object, this should be poosible
        if (weakSelf.channelOwner.uniqueId == appDelegate.currentUser.uniqueId) {
            for (Channel *tmpChannel in weakSelf.channelOwner.subscriptions) {
                [SYNActivityManager.sharedInstance addChannelSubscriptionsObject:tmpChannel];
            }
        }
        [weakSelf.cv reloadData];
        [weakSelf.channelOwner.managedObjectContext save: &error];
        
    };
    
    // define success block //
    MKNKUserErrorBlock errorBlock = ^(NSDictionary *errorDictionary) {
        weakSelf.loadingMoreContent = NO;
        DebugLog(@"Update action failed");
    };
    //    Working load more videos for user channels
    
    NSRange range = NSMakeRange(0, 100);
    
    [appDelegate.oAuthNetworkEngine subscriptionsForUserId: weakSelf.channelOwner.uniqueId
                                                   inRange: range
                                         completionHandler: successBlock
                                              errorHandler: errorBlock];
}


#pragma mark - setOffset

- (void) setContentOffSet: (CGPoint) offset {
    [self.cv setContentOffset:offset];
}


#pragma mark - Gesture reconisers

-(void)dismissKeyboard {
    [self.searchBar resignFirstResponder];
}

#pragma mark - channel mid cell delegate
- (void) cellStateChanged {
    [self hideDescriptionCurrentlyShowing];
    [self.tapToResetCells setEnabled:YES];
}


#pragma mark - bar buttons

-(void) hideDescriptionCurrentlyShowing
{
    
    [self.tapToResetCells setEnabled:NO];
    
    for (UICollectionViewCell *cell in [self.cv visibleCells]) {
        if ([cell isKindOfClass:[SYNChannelMidCell class]]) {
            if (((SYNChannelMidCell*)cell).state != ChannelMidCellStateAnimating) {
                [((SYNChannelMidCell*)cell) setState:ChannelMidCellStateDefault withAnimation:YES];
            }
        }
    }
}


#pragma mark - Paging model delegates


- (void)pagingModelDataUpdated:(SYNPagingModel *)pagingModel {
    [self.cv reloadData];
    [self.headerView.segmentedController setSelectedSegmentIndex:1];
}

- (void)pagingModelErrorOccurred:(SYNPagingModel *)pagingModel {
}



#pragma mark - Orientation change

- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration {
    [self updateLayoutForOrientation: toInterfaceOrientation];
}


- (void) updateLayoutForOrientation: (UIDeviceOrientation) orientation {
    
    if (IS_IPHONE) {
        return;
    }
    
    if (UIDeviceOrientationIsPortrait(orientation)) {
        self.defaultLayout.minimumLineSpacing = 14.0f;
        self.defaultLayout.sectionInset = UIEdgeInsetsMake(0, 47.0, 70.0, 47.0);
        self.defaultLayout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 701);
    } else {
        self.defaultLayout.sectionInset = UIEdgeInsetsMake(0, 21.0, 70.0, 21.0);
        self.defaultLayout.minimumLineSpacing = 14.0f;
        self.defaultLayout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 574);
    }
    
    [self.cv.collectionViewLayout invalidateLayout];
}



@end
