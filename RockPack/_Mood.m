// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Mood.m instead.

#import "_Mood.h"

const struct MoodAttributes MoodAttributes = {
	.name = @"name",
};

const struct MoodRelationships MoodRelationships = {
};

const struct MoodFetchedProperties MoodFetchedProperties = {
};

@implementation MoodID
@end

@implementation _Mood

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Mood" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Mood";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Mood" inManagedObjectContext:moc_];
}

- (MoodID*)objectID {
	return (MoodID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic name;











@end
