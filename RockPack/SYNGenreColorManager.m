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


@property (nonatomic, strong) NSMutableDictionary *genreColors;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;

@end


@implementation SYNGenreColorManager

@synthesize appDelegate;

+ (instancetype) sharedInstance
{
    static dispatch_once_t onceQueue;
    static SYNGenreColorManager *categoryColorManager = nil;
    
    dispatch_once(&onceQueue, ^
                  {
                      categoryColorManager = [[self alloc] init];

                  });
    
    return categoryColorManager;
}

-(id)init
{
	if (self = [super init]) {
		self.genreColors = [[NSMutableDictionary alloc] init];
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];

    }
    return self;
}


-(void)registerGenreColorsFromCoreData
{
    NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
    
    categoriesFetchRequest.entity = [NSEntityDescription entityForName: kGenre
                                                inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    categoriesFetchRequest.includesSubentities = NO;
    
    NSError* error;
    
    NSArray* genresFetchedArray = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest error: &error];
    
    NSArray* genres = [NSArray arrayWithArray:genresFetchedArray];
    
    for (Genre *tmpGenre in genres)
    {
        [self.genreColors setObject:[UIColor colorWithHex: [tmpGenre.color integerValue]] forKey:tmpGenre.uniqueId];
        for (Genre *tmpSubGenre in tmpGenre.subgenres) {
            [self.genreColors setObject:[UIColor colorWithHex: [tmpGenre.color integerValue]] forKey:tmpSubGenre.uniqueId];
        }
    }
    
    //Default color
    
    [self.genreColors setObject:[UIColor colorWithRed:172.0/255.0f green:172.0/255.0f blue:172.0/255.0f alpha:1.0f] forKey:@""];
}

-(UIColor *) colorFromID : (NSString *) categoryId
{
    return [self.genreColors objectForKey:categoryId];
}



@end
