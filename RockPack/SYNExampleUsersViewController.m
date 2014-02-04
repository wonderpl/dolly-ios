//
//  SYNExampleUsersViewController.m
//  dolly
//
//  Created by Sherman Lo on 14/01/14.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNExampleUsersViewController.h"
#import "UICollectionReusableView+Helpers.h"
#import "SYNExampleUserCell.h"
#import "SYNAppDelegate.h"
#import "SYNNetworkEngine.h"
#import "SYNGradientMaskView.h"

static const CGFloat ScrollAnimationDuration = 1.0;

@interface SYNExampleUsersViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *exampleUsers;

@property (nonatomic, strong) IBOutlet SYNGradientMaskView *gradientView;
@property (nonatomic, assign) CGPoint scrollingPoint, endPoint;
@property (nonatomic, strong) NSTimer *scrollingTimer;

@end

@implementation SYNExampleUsersViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
    [self performSelector:@selector(getUsersAndAnimate) withObject:self afterDelay:2.5f];

}

- (void) getUsersAndAnimate {
    SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
	[appDelegate.networkEngine exampleUsersWithCompletionHandler:^(NSArray *users) {
		self.exampleUsers = users;
		
		[self.collectionView reloadData];
        [self scrollSlowly];
        
	} errorHandler:^(NSError *error) {
		
	}];

    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [self.exampleUsers count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	SYNExampleUserCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[SYNExampleUserCell reuseIdentifier]
																			  forIndexPath:indexPath];
	
	NSDictionary *exampleUser = self.exampleUsers[indexPath.row];
	
	NSString *largeURLString = [exampleUser[@"avatar_thumbnail_url"] stringByReplacingOccurrencesOfString:@"/thumbnail_medium/"
																							   withString:@"/thumbnail_large/"];
	if ([largeURLString length]) {
		[cell.imageView setImageFromURL:[NSURL URLWithString:largeURLString]
					   placeHolderImage:[UIImage imageNamed:@"PlaceholderNotificationAvatar.png"]];
	}
	
	cell.nameLabel.text = [exampleUser[@"display_name"] uppercaseString];
	cell.descriptionLabel.text = ([exampleUser[@"description"] isKindOfClass:[NSString class]] ? exampleUser[@"description"] : nil );
	
	return cell;
}


- (void)scrollSlowly {
    if (self.exampleUsers.count>1) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:       UICollectionViewScrollPositionCenteredVertically animated:NO];
    }
        
    // 230 == height of the cell
    
    self.endPoint = CGPointMake(0, (self.exampleUsers.count * 230));
    
    //Start off screen
    self.scrollingPoint = CGPointMake(0, -600);
    self.scrollingTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(scrollSlowlyToPoint) userInfo:nil repeats:YES];
}

- (void)scrollSlowlyToPoint {
    self.collectionView.contentOffset = self.scrollingPoint;
    if (self.scrollingPoint.y> self.endPoint.y) {
        
        [self.scrollingTimer invalidate];
    }
    
    self.scrollingPoint = CGPointMake(self.scrollingPoint.x, self.scrollingPoint.y+2);
}



@end
