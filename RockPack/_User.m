// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.m instead.

#import "_User.h"

const struct UserAttributes UserAttributes = {
	.current = @"current",
	.dateOfBirth = @"dateOfBirth",
	.emailAddress = @"emailAddress",
	.firstName = @"firstName",
	.fullNameIsPublic = @"fullNameIsPublic",
	.gender = @"gender",
	.lastName = @"lastName",
	.locale = @"locale",
	.loginOrigin = @"loginOrigin",
};

const struct UserRelationships UserRelationships = {
	.externalAccounts = @"externalAccounts",
};

const struct UserFetchedProperties UserFetchedProperties = {
};

@implementation UserID
@end

@implementation _User

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"User";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"User" inManagedObjectContext:moc_];
}

- (UserID*)objectID {
	return (UserID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"currentValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"current"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"fullNameIsPublicValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"fullNameIsPublic"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"genderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"gender"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"loginOriginValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"loginOrigin"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic current;



- (BOOL)currentValue {
	NSNumber *result = [self current];
	return [result boolValue];
}

- (void)setCurrentValue:(BOOL)value_ {
	[self setCurrent:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveCurrentValue {
	NSNumber *result = [self primitiveCurrent];
	return [result boolValue];
}

- (void)setPrimitiveCurrentValue:(BOOL)value_ {
	[self setPrimitiveCurrent:[NSNumber numberWithBool:value_]];
}





@dynamic dateOfBirth;






@dynamic emailAddress;






@dynamic firstName;






@dynamic fullNameIsPublic;



- (BOOL)fullNameIsPublicValue {
	NSNumber *result = [self fullNameIsPublic];
	return [result boolValue];
}

- (void)setFullNameIsPublicValue:(BOOL)value_ {
	[self setFullNameIsPublic:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveFullNameIsPublicValue {
	NSNumber *result = [self primitiveFullNameIsPublic];
	return [result boolValue];
}

- (void)setPrimitiveFullNameIsPublicValue:(BOOL)value_ {
	[self setPrimitiveFullNameIsPublic:[NSNumber numberWithBool:value_]];
}





@dynamic gender;



- (int32_t)genderValue {
	NSNumber *result = [self gender];
	return [result intValue];
}

- (void)setGenderValue:(int32_t)value_ {
	[self setGender:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveGenderValue {
	NSNumber *result = [self primitiveGender];
	return [result intValue];
}

- (void)setPrimitiveGenderValue:(int32_t)value_ {
	[self setPrimitiveGender:[NSNumber numberWithInt:value_]];
}





@dynamic lastName;






@dynamic locale;






@dynamic loginOrigin;



- (int16_t)loginOriginValue {
	NSNumber *result = [self loginOrigin];
	return [result shortValue];
}

- (void)setLoginOriginValue:(int16_t)value_ {
	[self setLoginOrigin:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveLoginOriginValue {
	NSNumber *result = [self primitiveLoginOrigin];
	return [result shortValue];
}

- (void)setPrimitiveLoginOriginValue:(int16_t)value_ {
	[self setPrimitiveLoginOrigin:[NSNumber numberWithShort:value_]];
}





@dynamic externalAccounts;

	
- (NSMutableSet*)externalAccountsSet {
	[self willAccessValueForKey:@"externalAccounts"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"externalAccounts"];
  
	[self didAccessValueForKey:@"externalAccounts"];
	return result;
}
	






@end
