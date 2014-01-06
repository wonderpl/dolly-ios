//
//  SYNCategoryColorManager.m
//  dolly
//
//  Created by Cong on 02/01/2014.
//  Copyright (c) 2014 Nick Banks. All rights reserved.
//

#import "SYNGenreColorManager.h"
#import "UIColor+SYNColor.h"
#import "AppConstants.h"
#import "SYNAppDelegate.h"

@interface SYNGenreColorManager ()

@property (nonatomic, copy) NSDictionary *genreColors;

@end


@implementation SYNGenreColorManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceQueue;
    static SYNGenreColorManager *categoryColorManager = nil;
    
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
    
    for (Genre *genre in genres) {
		genreColors[genre.uniqueId] = [UIColor colorWithHex:genre.colorValue];
		
        for (Genre *subGenre in genre.subgenres) {
			genreColors[subGenre.uniqueId] = [UIColor colorWithHex: genre.colorValue];
        }
    }

	self.genreColors = genreColors;
}

- (UIColor *)colorFromID:(NSString *)categoryId {
	UIColor *defaultColor = [UIColor colorWithRed:172.0/255.0f green:172.0/255.0f blue:172.0/255.0f alpha:1.0f];
	
	return (self.genreColors[categoryId] ?: defaultColor);
}

@end
