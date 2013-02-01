#import "NSObject+HDSerialization.h"
#import <objc/runtime.h>
#import "HDUtils.h"
#import "HDProperties.h"
#import "NSData+Base64.h"

NSString *const HDSerializationTypeKey = @"type";
NSString *const HDSerializationValueKey = @"value";
NSString *const HDSerializationNameKey = @"name";
NSString *const HDSerializationPropertiesKey = @"properties";

#pragma mark -
#pragma mark Forward declarations
static NSString *HDSerializationGetType(id propValue);
static id HDSerializationGetSerializedValueFromFoundationObject(id propValue);
static NSObject* HDSerializationGetFoundationObjectFromSerializedValue(NSObject *serializedValue, NSString *typeAsString, UnknownEntityHandler unknownHandler, NSArray *blacklist);
static NSObject* HDObjectWithDeserializedHDData(NSObject *data, UnknownEntityHandler handler, NSArray* blacklist);

static NSString *HDSerializationGetType(id propValue) {
  if([propValue isKindOfClass:[NSValue class]]) {
    // Figure out which type of value
    const char *objcType = [propValue objCType];
    if(strcmp(objcType, @encode(CGRect)) == 0)
      return @"CGRect";
    else if(strcmp(objcType, @encode(CGPoint)) == 0)
      return @"CGPoint";
    else if(strcmp(objcType, @encode(CGSize)) == 0)
      return @"CGSize";
    else if(strcmp(objcType, @encode(NSInteger)) == 0)
      return @"NSInteger";
    else {
      NSCAssert(0, @"Don't know the type of struct");
      return @"";
    }
  }
  else if([propValue isKindOfClass:[NSArray class]])
    return @"NSArray";
  else if([propValue isKindOfClass:[NSDictionary class]])
    return @"NSDictionary";
  else if([propValue isKindOfClass:[NSString class]])
    return @"NSString";
  else if([propValue isKindOfClass:[NSData class]])
    return @"NSData";
  else
    return @(object_getClassName(propValue));
}

static id HDSerializationGetSerializedValueFromFoundationObject(id propValue) {
  if ([propValue isKindOfClass:[NSValue class]]) {
    NSString *objcType = @([propValue objCType]);
    NSArray *array = [objcType componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"{},="]];
    NSString *type = nil;
    for(NSString *string in array) {
      if(![string isEqualToString:@""]) {
        type = [NSString stringWithString:string];
        break;
      }
    }

    NSCAssert(type != nil, @"Type of NSValue was nil");
    
    if([type isEqualToString:@"CGRect"]) {
      CGRect rect;
      [propValue getValue:&rect];
      return HDNSStringFromCGRect(rect);
    } else if([type isEqualToString:@"CGPoint"]) {
      CGPoint point;
      [propValue getValue:&point];
      return HDNSStringFromCGPoint(point);
    } else if([type isEqualToString:@"CGSize"]) {
      CGSize size;
      [propValue getValue:&size];
      return HDNSStringFromCGSize(size);
    } else if([type isEqualToString:@(@encode(NSInteger))]) {
      NSInteger integer;
      [propValue getValue:&integer];
      return @(integer);
    }
    
    NSCAssert(0, @"Unrecognized value type");
  } else if([propValue isKindOfClass:[NSString class]]) {
    return propValue;
  } else if([propValue isKindOfClass:[NSData class]]) {
    return [propValue base64EncodedString];
  } else {
    id returnValue = [propValue performSelector:@selector(toJSONSerializableData)];
    if (returnValue != nil) {
      return returnValue;
    }
  }
  NSCAssert(0, @"Given object of class %s cannot serialize itself", class_getName([propValue class]));
  return nil;
}

static NSObject* HDSerializationGetFoundationObjectFromSerializedValue(NSObject *serializedValue, NSString *typeAsString, UnknownEntityHandler unknownHandler, NSArray* blacklist) {
  if([typeAsString isEqualToString:@"CGRect"]) {
    CGRect rect = HDCGRectFromString((NSString *)serializedValue);
    return [NSValue value:&rect withObjCType:@encode(CGRect)];
  } else if([typeAsString isEqualToString:@"CGPoint"]) {
    CGPoint point = HDCGPointFromString((NSString *)serializedValue);
    return [NSValue value:&point withObjCType:@encode(CGPoint)];
  } else if([typeAsString isEqualToString:@"CGSize"]) {
    CGSize size = HDCGSizeFromString((NSString *)serializedValue);
    return [NSValue value:&size withObjCType:@encode(CGSize)];
  } else if([typeAsString isEqualToString:@"NSInteger"]) {
    NSCAssert([serializedValue isKindOfClass:[NSValue class]], @"Integer should be an NSValue already");
    return serializedValue;
  } else {
    Class type = NSClassFromString(typeAsString);
    if(type == [NSString class]) {
      return serializedValue;
    } else if(type == [NSArray class]) {
      NSCAssert([serializedValue isKindOfClass:[NSArray class]], @"Attempting to decode array values from a non array serialized representation");
      NSArray *serializedArray = (NSArray *)serializedValue;
      NSMutableArray *deserializedArray = [[NSMutableArray alloc] initWithCapacity:serializedArray.count];
      for(id item in serializedArray) {
        NSObject *deserializedValue = HDObjectWithDeserializedHDData(item, unknownHandler, blacklist);
        NSCAssert(deserializedValue != nil, @"Deserialized value of array item was nil");
        [deserializedArray addObject:deserializedValue];
      }
      return deserializedArray;
    } else if(type == [NSData class]) {
      return [NSData dataWithBase64EncodedString:(NSString *)serializedValue];
    } else {
      if (type != nil) {
        return HDObjectWithDeserializedHDData(serializedValue, unknownHandler, blacklist);
      }

      // Type was not known. Look for user provided fallback
      NSCAssert(unknownHandler, @"Need a platform specific alternative for %@ and none provided", typeAsString);
      NSObject* returnValue = HDObjectWithDeserializedHDData(serializedValue, unknownHandler, blacklist);
      NSCAssert1(returnValue, @"Must be able to determine object for %@", typeAsString);
      return returnValue;
    }
  }
  NSCAssert(0, @"WTF. Should never get here!");
  return nil;
}

static NSObject* HDObjectWithDeserializedHDData(NSObject *data, UnknownEntityHandler handler, NSArray* blacklist) {
  if(![data isKindOfClass:[NSDictionary class]]) {
    // The deserialized object is not a dictionary. It is probably a container of primitives (NSString, etc..)
   
    if ([data isKindOfClass:[NSString class]]) {
      return data;
    }
    
    if([data isKindOfClass:[NSArray class]]) {
      NSMutableArray *array = [[NSMutableArray alloc] init];
      for (NSObject *item in (NSArray *)data) {
        [array addObject:HDObjectWithDeserializedHDData(item, handler, blacklist)];
      }
      return array;
    }
    
    NSCAssert(NO, @"If we got here, we probably missed a primitive");
    return nil;
  }
  NSDictionary *dataDictionary = (NSDictionary *)data;
  
  NSString *objectTypeName = dataDictionary[HDSerializationTypeKey];
  
  NSCAssert(objectTypeName != nil, @"Don't know how to deserialize this type");
  
  // Check if the class is blacklisted
  BOOL isBlacklisted = NO;
  for (NSString *item in blacklist) {
    if ([objectTypeName isEqualToString:item]) {
      isBlacklisted = YES;
      break;
    }
  }
  
  id object = nil;
  if (!isBlacklisted) {
    object = [[NSClassFromString(objectTypeName) alloc] init];
  }
  
  if (object == nil) {
    object = handler(objectTypeName);
  }

  NSCAssert(object, @"Must know which class to deserialize. Fallback was nil or could not be used.");
  
  NSArray *properties = dataDictionary[HDSerializationPropertiesKey];
  NSCAssert([properties isKindOfClass:[NSArray class]], @"Properties must be contained in arrays");
  
  for (id property in properties) {
    NSCAssert([property isKindOfClass:[NSDictionary class]], @"A property description must be a dictionary of name, type and value");
    NSDictionary *propertyDictionary = (NSDictionary *) property;
    
    NSString *propertyTypeAsString = [propertyDictionary valueForKey:HDSerializationTypeKey];
    NSString *propertyName = [propertyDictionary valueForKey:HDSerializationNameKey];
    NSObject *propertyValue = HDSerializationGetFoundationObjectFromSerializedValue([propertyDictionary valueForKey:HDSerializationValueKey], propertyTypeAsString, handler, blacklist);
    
    NSCAssert(propertyValue != nil, @"Deserialized property value must not be nil");
    
    @try {
      [object setValue:propertyValue forKey:propertyName];
    } @catch (NSException *exception) {
      SEL alternateSel = @selector(setNonKVCCompliantValue:forKey:);
      NSCAssert([object respondsToSelector:alternateSel], @"Class %@ does not have a non KVC compliant value setter. Implement %s", NSStringFromClass([object class]), sel_getName(alternateSel));
      [object setNonKVCCompliantValue:propertyValue forKey:propertyName];
    }
  }
  
  return object;
}

@implementation NSObject (HDSerialization)

+(id) objectWithJSONData:(NSData *) data unknownEntityHandler:(UnknownEntityHandler) handler {
  return [self objectWithJSONData:data forceAlternativeForAnyIn:@[] unknownEntityHandler:handler];
}

+(id) objectWithJSONData:(NSData *) data forceAlternativeForAnyIn:(NSArray *) blacklist unknownEntityHandler:(UnknownEntityHandler) handler {
  NSError *error  = nil;
  id foundationObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
  if(error != nil)
    return nil;
  
  return HDObjectWithDeserializedHDData((NSDictionary *)foundationObject, handler, blacklist);
}

-(id) serializedProperties {
  if(![self respondsToSelector:@selector(serializableProperties)])
    return nil;

  NSArray *properties = [self performSelector:@selector(serializableProperties)];

  NSMutableArray *dataArray = [[NSMutableArray alloc] init];

  for(NSString *prop in properties) {
    id propValue = [self valueForKey:prop];
    if(propValue == nil)
      continue;
    
    NSMutableDictionary *propDescription = [[NSMutableDictionary alloc] initWithCapacity:3];
    [propDescription setValue:prop forKey:HDSerializationNameKey];
    [propDescription setValue:HDSerializationGetType(propValue) forKey:HDSerializationTypeKey];
    
    // Check is value is actually a container
    if ([propValue isKindOfClass:[NSArray class]]) {
      NSArray *propValues = (NSArray *) propValue;
      NSMutableArray *objectArray = [[NSMutableArray alloc] init];
      for(id value in propValues) {
        id serializedData = HDSerializationGetSerializedValueFromFoundationObject(value);
        if(serializedData != nil) {
          [objectArray addObject:serializedData];
        }
      }
      [propDescription setValue:objectArray forKey:HDSerializationValueKey];
    } else if ([propValue isKindOfClass:[NSDictionary class]]) {
      NSDictionary *propDictionary = (NSDictionary *) propValue;
      NSMutableDictionary *objectDictionary = [[NSMutableDictionary alloc] init];
      for(NSString *dictionaryKey in [propDictionary keyEnumerator]) {
        NSData *serializedData = [propDictionary[dictionaryKey] toJSONSerializableData];
        if(serializedData != nil) {
          [objectDictionary setValue:serializedData forKey:dictionaryKey];
        }
      }
      [propDescription setValue:objectDictionary forKey:HDSerializationValueKey];
    } else {
      [propDescription setValue:HDSerializationGetSerializedValueFromFoundationObject(propValue) forKey:HDSerializationValueKey];
    }
    
    [dataArray addObject:propDescription];
  }

  return dataArray;
}

-(id) toJSONSerializableData {
  // Root can be a primitive type (NSArray, NSDictionary, etc.) or an object with properties
  if([self isKindOfClass:[NSArray class]]) {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSObject *item in (NSArray *)self) {
      [array addObject:[item toJSONSerializableData]];
    }
    return array;
  } else {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:HDSerializationGetType(self) forKey:HDSerializationTypeKey];
    [dictionary setValue:[self serializedProperties] forKey:HDSerializationPropertiesKey];
    return dictionary;
  }
}

-(NSData *) toJSONData {
  NSError *error = nil;
  NSData *data = [NSJSONSerialization dataWithJSONObject:[self toJSONSerializableData] options:0 error:&error];
  return error ? nil : data;
}

@end
