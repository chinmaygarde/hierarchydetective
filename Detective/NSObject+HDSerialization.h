#import <Foundation/Foundation.h>

typedef NSObject *(^UnknownEntityHandler)(NSString *classAsString);

@interface NSObject (HDSerialization)

+(id) objectWithJSONData:(NSData *) data unknownEntityHandler:(UnknownEntityHandler) handler;
+(id) objectWithJSONData:(NSData *) data forceAlternativeForAnyIn:(NSArray *) blacklist unknownEntityHandler:(UnknownEntityHandler) handler;
-(NSData *) toJSONData;

@end
