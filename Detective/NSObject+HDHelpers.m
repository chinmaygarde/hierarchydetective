#import "NSObject+HDHelpers.h"
#import <objc/runtime.h>

@implementation NSObject (HDHelpers)

-(NSArray *) classHierarchy {
  NSMutableArray *hierarchy = [[NSMutableArray alloc] init];
  Class clasz = [self class];
  while(clasz != [NSObject class]) {
    [hierarchy addObject:NSStringFromClass(clasz)];
    clasz = class_getSuperclass(clasz);
  }
  return hierarchy;
}
@end
