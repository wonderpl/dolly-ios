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
#import "SYNHTTPSessionManager.h"
#import "SYNLocationManager.h"
#import "SubGenre.h"

@interface SYNGenreManager ()

@property (nonatomic, copy) NSArray *genres;
@property (nonatomic, copy) NSDictionary *genresById;

@property (nonatomic, strong) NSURLSessionDataTask *task;

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSMutableArray *pendingCompletionBlocks;

@end


@implementation SYNGenreManager

#pragma mark - Public class

+ (instancetype)sharedManager {
    static dispatch_once_t onceQueue;
    static SYNGenreManager *manager;
    dispatch_once(&onceQueue, ^{
		manager = [[self alloc] init];
	});
    return manager;
}

#pragma mark - Init / Dealloc

- (instancetype)init {
	if (self = [super init]) {
		self.pendingCompletionBlocks = [NSMutableArray array];
	}
	return self;
}

#pragma mark - Public

- (void)fetchGenresWithCompletion:(SYNNetworkArrayResultBlock)completionBlock {
	completionBlock = completionBlock ?: ^(NSArray *results){};
	
	if (self.task) {
		[self.pendingCompletionBlocks addObject:[completionBlock copy]];
		
		return;
	}
	
	SYNHTTPSessionManager *sessionManager = [SYNHTTPSessionManager standardAPIManager];
	
	SYNLocationManager *locationManager = [SYNLocationManager sharedManager];
	
	NSDictionary *parameters = @{ @"locale"   : locationManager.locale,
								  @"location" : locationManager.location };
	
	SYNNetworkArrayResultBlock internalCompletionBlock = ^(NSArray *results) {
		completionBlock(results);
		
		for (SYNNetworkArrayResultBlock completionBlock in self.pendingCompletionBlocks) {
			completionBlock(results);
		}
		[self.pendingCompletionBlocks removeAllObjects];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:CategoriesReloadedNotification
															object:results];
		
		self.task = nil;
	};
	
	NSURLSessionDataTask *task = [sessionManager GET:kAPICategories
										  parameters:parameters
											 success:^(NSURLSessionDataTask *task, id responseObject) {
												 [self deleteExistingGenres];
												 
												 NSArray *genres = [self importGenresFromResponse:responseObject];
												 
												 [self.managedObjectContext save:nil];
												 
												 self.genres = genres;
												 self.genresById = [self keyGenresById:genres];
												 
												 internalCompletionBlock(genres);
											 }
											 failure:^(NSURLSessionDataTask *task, NSError *error) {
												 NSArray *genres = [self fetchExistingGenres];
												 internalCompletionBlock(genres);
											 }];
	
	self.task = task;
	
	[task resume];
}

- (UIColor *)colorForGenreWithId:(NSString *)genreId {
	Genre *genre = self.genresById[genreId];
	if (genre.color) {
		return [UIColor colorWithHex:genre.colorValue];
	}
	return [UIColor defaultCategoryColor];
}

- (Genre *)genreWithId:(NSString *)genreId {
	return self.genresById[genreId];
}

- (NSDictionary *)keyGenresById:(NSArray *)genres {
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	for (Genre *genre in genres) {
		dictionary[genre.uniqueId] = genre;
		for (SubGenre *subGenre in genre.subgenres) {
			dictionary[subGenre.uniqueId] = subGenre;
		}
	}
	return dictionary;
}

- (NSManagedObjectContext *)managedObjectContext {
	SYNAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	return appDelegate.mainManagedObjectContext;
}

- (void)deleteExistingGenres {
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[Genre entityName]];
	NSArray *genres = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
	for (Genre *genre in genres) {
		[self.managedObjectContext deleteObject:genre];
	}
}

- (NSArray *)fetchExistingGenres {
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[Genre entityName]];
	
	NSArray *sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:NO] ];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	return [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
}

- (NSArray *)importGenresFromResponse:(NSDictionary *)responseDictionary {
	NSArray *genreDictionaries = responseDictionary[@"categories"][@"items"];
	
	NSArray *sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:NO] ];
	NSArray *sortedGenreDictionaries = [genreDictionaries sortedArrayUsingDescriptors:sortDescriptors];
	
	NSMutableArray *genres = [NSMutableArray array];
	for (NSDictionary *genreDictionary in sortedGenreDictionaries) {
		Genre *genre = [Genre instanceFromDictionary:genreDictionary usingManagedObjectContext:self.managedObjectContext];
		[genres addObject:genre];
	}
	
	return genres;
}

@end
