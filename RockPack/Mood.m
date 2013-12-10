#import "Mood.h"
#import "NSDictionary+Validation.h"

@interface Mood ()

// Private interface goes here.

@end


@implementation Mood

+ (Mood *) instanceFromDictionary: (NSDictionary *) dictionary
        usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    if (![dictionary isKindOfClass: [NSDictionary class]])
        return nil;
    
    NSString *uniqueId = dictionary[@"id"];
    
    if (![uniqueId isKindOfClass: [NSString class]])
        return nil;
    
    Mood *instance = [Mood insertInManagedObjectContext: managedObjectContext];
    
    instance.uniqueId = uniqueId;
    
    
    [instance setAttributesFromDictionary: dictionary];
    
    
    return instance;
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
{
    
    self.name = [dictionary objectForKey:@"name"
                             withDefault:@""];
}

@end
