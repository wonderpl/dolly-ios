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

@end

@implementation SYNExampleUsersViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
	[appDelegate.networkEngine exampleUsersWithCompletionHandler:^(NSArray *users) {
		self.exampleUsers = users;
		
		[self.collectionView reloadData];
		
		// Scroll to the middle to indicate that the list is scrollable
		NSIndexPath *centerIndexPath = [NSIndexPath indexPathForItem:[users count] / 2 inSection:0];
		[UIView animateWithDuration:ScrollAnimationDuration animations:^{
			[self.collectionView scrollToItemAtIndexPath:centerIndexPath
										atScrollPosition:UICollectionViewScrollPositionCenteredVertically
												animated:NO];
		}];
	} errorHandler:^(NSError *error) {
		
	}];
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

@end
