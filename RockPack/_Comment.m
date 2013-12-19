// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Comment.m instead.

#import "_Comment.h"

const struct CommentAttributes CommentAttributes = {
	.commentText = @"commentText",
	.dateAdded = @"dateAdded",
	.displayName = @"displayName",
	.position = @"position",
	.recent = @"recent",
	.thumbnailUrl = @"thumbnailUrl",
	.userId = @"userId",
	.validated = @"validated",
	.videoInstanceId = @"videoInstanceId",
};

const struct CommentRelationships CommentRelationships = {
};

const struct CommentFetchedProperties CommentFetchedProperties = {
};

@implementation CommentID
@end

@implementation _Comment

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Comment";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Comment" inManagedObjectContext:moc_];
}

- (CommentID*)objectID {
	return (CommentID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"positionValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"position"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"recentValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"recent"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"validatedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"validated"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic commentText;






@dynamic dateAdded;






@dynamic displayName;






@dynamic position;



- (int32_t)positionValue {
	NSNumber *result = [self position];
	return [result intValue];
}

- (void)setPositionValue:(int32_t)value_ {
	[self setPosition:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitivePositionValue {
	NSNumber *result = [self primitivePosition];
	return [result intValue];
}

- (void)setPrimitivePositionValue:(int32_t)value_ {
	[self setPrimitivePosition:[NSNumber numberWithInt:value_]];
}





@dynamic recent;



- (BOOL)recentValue {
	NSNumber *result = [self recent];
	return [result boolValue];
}

- (void)setRecentValue:(BOOL)value_ {
	[self setRecent:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveRecentValue {
	NSNumber *result = [self primitiveRecent];
	return [result boolValue];
}

- (void)setPrimitiveRecentValue:(BOOL)value_ {
	[self setPrimitiveRecent:[NSNumber numberWithBool:value_]];
}





@dynamic thumbnailUrl;






@dynamic userId;






@dynamic validated;



- (BOOL)validatedValue {
	NSNumber *result = [self validated];
	return [result boolValue];
}

- (void)setValidatedValue:(BOOL)value_ {
	[self setValidated:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveValidatedValue {
	NSNumber *result = [self primitiveValidated];
	return [result boolValue];
}

- (void)setPrimitiveValidatedValue:(BOOL)value_ {
	[self setPrimitiveValidated:[NSNumber numberWithBool:value_]];
}





@dynamic videoInstanceId;











@end
