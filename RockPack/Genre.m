#import "Genre.h"
#import "NSDictionary+Validation.h"
#import "SubGenre.h"


@implementation Genre

#pragma mark - Object factory

+ (Genre *) instanceFromDictionary: (NSDictionary *) dictionary
         usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    
    NSString *uniqueId = [dictionary objectForKey: @"id"];
    
    if(!uniqueId)
        return nil;
    
    Genre *instance = [Genre insertInManagedObjectContext: managedObjectContext];
    
    [instance setAttributesFromDictionary: dictionary
                                   withId: uniqueId
                usingManagedObjectContext: managedObjectContext];
    
    return instance;
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                              withId: (NSString *) uniqueId
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    
    
    self.uniqueId = uniqueId;
    
    NSString* colourHash = [dictionary objectForKey:@"colour"
                                        withDefault:@"#00ff00"]; // default to Green
    
    if(![colourHash hasPrefix:@"#"])
        colourHash = [NSString stringWithFormat:@"0x%@", colourHash];
    else
        colourHash = [colourHash stringByReplacingOccurrencesOfString:@"#" withString:@"0x"];
    
    NSScanner* scanner = [NSScanner scannerWithString:colourHash];
    
    unsigned int intValue;
    [scanner scanHexInt:&intValue];
    
    self.colorValue = intValue;
    
    self.name = [dictionary upperCaseStringForKey: @"name"
                                      withDefault: @"-?-"];
    
    NSNumber *priorityString = (NSNumber *) dictionary[@"priority"];
    self.priority = @([priorityString integerValue]);
    
	NSArray *subcategoryDictionaries = dictionary[@"sub_categories"];
	
	NSSortDescriptor *prioritySortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:NO];
	NSArray *sortedSubcategoryDictionaries = [subcategoryDictionaries sortedArrayUsingDescriptors:@[ prioritySortDescriptor ]];
	
	NSMutableArray *subgenres = [NSMutableArray array];
	for (NSDictionary *subcategoryDictionary in sortedSubcategoryDictionaries) {
		SubGenre *subgenre = [SubGenre instanceFromDictionary:subcategoryDictionary
									usingManagedObjectContext:self.managedObjectContext];
		[subgenres addObject:subgenre];
	}
	
	self.subgenres = [NSOrderedSet orderedSetWithArray:subgenres];
}

- (NSArray *) getSubGenreIdArray
{
    NSMutableArray *subGenreIds = [[NSMutableArray alloc] initWithCapacity: self.subgenres.count];
    
    [subGenreIds addObject: self.uniqueId];
    
    for (SubGenre *subgenre in self.subgenres)
    {
        [subGenreIds addObject: subgenre.uniqueId];
    }
    
    return subGenreIds;
}


- (NSString *) description
{
    NSMutableString *descriptioString = [[NSMutableString alloc] init];
    
    [descriptioString appendFormat: @"Genre(categoryId:'%@' name:'%@'), subcategories:", self.uniqueId, self.name];
    
    for (SubGenre *sub in self.subgenres)
    {
        [descriptioString appendFormat: @"\n- %@", sub];
    }
    
    return descriptioString;
}

@end
