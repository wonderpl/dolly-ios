// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ChannelOwner.m instead.

#import "_ChannelOwner.h"

const struct ChannelOwnerAttributes ChannelOwnerAttributes = {
	.name = @"name",
	.thumbnailURL = @"thumbnailURL",
};

const struct ChannelOwnerRelationships ChannelOwnerRelationships = {
	.channels = @"channels",
};

const struct ChannelOwnerFetchedProperties ChannelOwnerFetchedProperties = {
};

@implementation ChannelOwnerID
@end

@implementation _ChannelOwner

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ChannelOwner" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ChannelOwner";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ChannelOwner" inManagedObjectContext:moc_];
}

- (ChannelOwnerID*)objectID {
	return (ChannelOwnerID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic name;






@dynamic thumbnailURL;






@dynamic channels;

	
- (NSMutableSet*)channelsSet {
	[self willAccessValueForKey:@"channels"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"channels"];
  
	[self didAccessValueForKey:@"channels"];
	return result;
}
	






@end
