//
//  SYNGenreManager.h
//  dolly
//
//  Created by Cong on 02/01/2014.
//  Copyright (c) 2014 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYNNetworkTypes.h"

@class Genre;

@interface SYNGenreManager : NSObject

@property (nonatomic, copy, readonly) NSArray *genres;

+ (instancetype)sharedManager;

- (void)fetchGenresWithCompletion:(SYNNetworkArrayResultBlock)completionBlock;

- (UIColor *)colorForGenreWithId:(NSString *)genreId;

- (Genre *)genreWithId:(NSString *)genreId;

@end
