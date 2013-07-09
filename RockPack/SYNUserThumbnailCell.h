//
//  SYNUserThumbnailCell.h
//  rockpack
//
//  Created by Michael Michailidis on 08/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SYNUserThumbnailCell : UICollectionViewCell

@property (nonatomic, strong) NSString* imageUrlString;

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel* nameLabel;
@property (nonatomic, strong) IBOutlet UILabel* usernameLabel;

-(void)setDisplayName:(NSString*)name andUsername:(NSString*)username;

@end
