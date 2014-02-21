//
//  SYNCategoryManager.m
//  dolly
//
//  Created by Cong on 02/01/2014.
//  Copyright (c) 2014 Nick Banks. All rights reserved.
//

#import "SYNGenreManager.h"
#import "UIColor+SYNColor.h"
#import "AppConstants.h"
#import "SYNAppDelegate.h"
#import "UIColor+SYNColor.h"

@interface SYNGenreManager ()

@property (nonatomic, copy) NSDictionary *genreColors;
@property (nonatomic, copy) NSDictionary *genreNames;

@end


@implementation SYNGenreManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceQueue;
    static SYNGenreManager *categoryColorManager = nil;
    
    dispatch_once(&onceQueue, ^{
                      categoryColorManager = [[self alloc] init];
                  });
    
    return categoryColorManager;
}

- (void)registerGenreColorsFromCoreData {
	SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *categoriesFetchRequest = [NSFetchRequest fetchRequestWithEntityName:[Genre entityName]];
    categoriesFetchRequest.includesSubentities = NO;
    NSArray* genres = [appDelegate.mainManagedObjectContext executeFetchRequest:categoriesFetchRequest error:nil];
	
	NSMutableDictionary *genreColors = [NSMutableDictionary dictionary];
	NSMutableDictionary *genreNames = [NSMutableDictionary dictionary];
    
    for (Genre *genre in genres) {
		genreColors[genre.uniqueId] = [UIColor colorWithHex:genre.colorValue];
		genreNames[genre.uniqueId] = genre.name;
		
        for (Genre *subGenre in genre.subgenres) {
			genreColors[subGenre.uniqueId] = [UIColor colorWithHex: genre.colorValue];
			genreNames[subGenre.uniqueId] = subGenre.name;
        }
    }

	self.genreColors = genreColors;
	self.genreNames = genreNames;
}

- (UIColor *)colorFromID:(NSString *)categoryId {
	return (self.genreColors[categoryId] ?: [UIColor defaultCategoryColor]);
}

- (NSString *)nameFromID:(NSString *)genreId {
	return self.genreNames[genreId];
}

@end
