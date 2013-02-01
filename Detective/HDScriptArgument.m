#import "HDScriptArgument.h"

@implementation HDScriptArgument

@synthesize script=_script;

-(NSArray *) serializableProperties {
  // TODO: Should probably make this so that serializable properties of
  // superclasses are automatically detected.
  NSMutableArray* array = [[super serializableProperties] mutableCopy];
  [array addObject:@"script"];
  return array;
}

@end
