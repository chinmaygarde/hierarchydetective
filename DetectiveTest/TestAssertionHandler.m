#import "TestAssertionHandler.h"

@implementation TestAssertionHandler
- (void)handleFailureInFunction:(NSString *)functionName file:(NSString *)fileName lineNumber:(NSInteger)line description:(NSString *)format, ... {
  va_list args;
  va_start(args, format);
  [super handleFailureInFunction:functionName file:fileName lineNumber:line description:format, args];
  va_end(args);
}

- (void)handleFailureInMethod:(SEL)selector object:(id)object file:(NSString *)fileName lineNumber:(NSInteger)line description:(NSString *)format, ... {
  va_list args;
  va_start(args, format);
  [super handleFailureInMethod:selector object:object file:fileName lineNumber:line description:format, args];
  va_end(args);
}
@end
