#import "HDArgument.h"

@implementation HDArgument

@synthesize pointerValue=_pointerValue;

-(NSArray *) serializableProperties {
  return @[@"pointerValue"];
}

@end
