#import "Recommendation.h"
#import "NSDictionary+Validation.h"
#import "ChannelOwner.h"
#import "SYNActivityManager.h"

@interface Recommendation ()

@end


@implementation Recommendation

+ (Recommendation *)instanceFromDictionary:(NSDictionary *) dictionary
				 usingManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    if (![dictionary isKindOfClass: [NSDictionary class]] || ![dictionary objectForKey:@"id"])
        return nil;
    
    Recommendation *instance = [Recommendation insertInManagedObjectContext: managedObjectContext];
    
    
    [instance setAttributesFromDictionary: dictionary];
    
    
    return instance;
}

- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
{
    
    self.uniqueId = [dictionary objectForKey:@"id"
                                 withDefault:@""];
    
	self.position = dictionary[@"position"];
    
	self.categoryId = [NSString stringWithFormat:@"%@", dictionary[@"category"]];
    
    self.displayName = [dictionary objectForKey:@"display_name"
                                    withDefault:@""];
    self.avatarUrl = [dictionary objectForKey:@"avatar_thumbnail_url"
                                  withDefault:@""];
    
    self.descriptionText = [dictionary objectForKey:@"description"
                                        withDefault:@""];
    
    
    if (dictionary[@"tracking_code"]) {
        [[SYNActivityManager sharedInstance] addObjectFromDict:dictionary];
    }
}

- (ChannelOwner *)channelOwner {
	NSDictionary* coDictionary = @{@"id": self.uniqueId,
								   @"display_name" : self.displayName,
								   @"avatar_thumbnail_url" : self.avatarUrl};
	
	ChannelOwner *co = [ChannelOwner instanceFromDictionary:coDictionary
								  usingManagedObjectContext:self.managedObjectContext
										ignoringObjectTypes:kIgnoreAll];
	return co;
}

- (NSString*) description {
    return [NSString stringWithFormat:@"[Recommendation %p <co_name:%@, categoryId:%@>]", self, self.displayName, self.categoryId];
}

@end
