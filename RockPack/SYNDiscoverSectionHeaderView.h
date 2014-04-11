//
//  SYNDiscoverSectionHeaderView.h
//  dolly
//
//  Created by Cong Le on 02/04/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNDiscoverSectionHeaderView : UICollectionReusableView
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

- (void)setTitleText : (NSString*) title;

@end
