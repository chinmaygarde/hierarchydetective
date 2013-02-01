#import "NSMutableArray+Queue.h"

@implementation NSMutableArray (Queue)

- (id) dequeue {
  if(self.count == 0)
    return nil;
  
  id object = self[0];
  [self removeObjectAtIndex:0];
  return object;
}

- (void) enqueue:(id)object {
  [self addObject:object];
}

@end
