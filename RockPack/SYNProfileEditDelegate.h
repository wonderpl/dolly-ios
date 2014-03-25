//
//  SYNProfileEditDelegate.h
//  dolly
//
//  Created by Cong Le on 19/03/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SYNProfileEditDelegate <NSObject>

@required
- (void) setCollectionViewContentOffset:(CGPoint)contentOffset animated:(BOOL) animated;
- (void) updateCoverImage: (NSString*) url;
- (void) updateAvatarImage: (NSString*) url;
- (void) updateUserDescription: (NSString*) descriptionString;

@end
