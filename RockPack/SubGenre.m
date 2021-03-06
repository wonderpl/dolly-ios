#import "Genre.h"
#import "NSDictionary+Validation.h"
#import "SubGenre.h"


@implementation SubGenre

+ (SubGenre *) instanceFromDictionary: (NSDictionary *) dictionary
            usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    
    
    // Get the unique id of this object from the dictionary that has been passed in
    NSString *uniqueId = [dictionary objectForKey: @"id"];
    
    
    if(!uniqueId)
        return nil;
    
    SubGenre *instance = [SubGenre insertInManagedObjectContext: managedObjectContext];
    
    
    
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
    
    self.name = [dictionary objectForKey: @"name"
                                      withDefault: @"-?-"];
    
    NSNumber *priorityString = (NSNumber *) dictionary[@"priority"];
    self.priority = @([priorityString integerValue]);
    
    NSNumber *isDefault = dictionary[@"default"];
    self.isDefaultValue = [isDefault boolValue];
}

- (NSNumber *)color {
	return self.genre.color;
}

- (NSString *)genreName {
	return self.genre.name;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"[Subgenre %p (label:'%@', priority:%i)", self, self.name, self.priorityValue];
}


@end
