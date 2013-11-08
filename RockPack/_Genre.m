// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Genre.m instead.

#import "_Genre.h"

const struct GenreAttributes GenreAttributes = {
	.color = @"color",
	.name = @"name",
	.priority = @"priority",
};

const struct GenreRelationships GenreRelationships = {
	.subgenres = @"subgenres",
};

const struct GenreFetchedProperties GenreFetchedProperties = {
};

@implementation GenreID
@end

@implementation _Genre

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Genre" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Genre";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Genre" inManagedObjectContext:moc_];
}

- (GenreID*)objectID {
	return (GenreID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"colorValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"color"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"priorityValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"priority"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic color;



- (int64_t)colorValue {
	NSNumber *result = [self color];
	return [result longLongValue];
}

- (void)setColorValue:(int64_t)value_ {
	[self setColor:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveColorValue {
	NSNumber *result = [self primitiveColor];
	return [result longLongValue];
}

- (void)setPrimitiveColorValue:(int64_t)value_ {
	[self setPrimitiveColor:[NSNumber numberWithLongLong:value_]];
}





@dynamic name;






@dynamic priority;



- (int32_t)priorityValue {
	NSNumber *result = [self priority];
	return [result intValue];
}

- (void)setPriorityValue:(int32_t)value_ {
	[self setPriority:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitivePriorityValue {
	NSNumber *result = [self primitivePriority];
	return [result intValue];
}

- (void)setPrimitivePriorityValue:(int32_t)value_ {
	[self setPrimitivePriority:[NSNumber numberWithInt:value_]];
}





@dynamic subgenres;

	
- (NSMutableOrderedSet*)subgenresSet {
	[self willAccessValueForKey:@"subgenres"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"subgenres"];
  
	[self didAccessValueForKey:@"subgenres"];
	return result;
}
	






@end
