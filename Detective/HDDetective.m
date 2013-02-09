#import <objc/runtime.h>

#import "HDServer.h"
#import "HDDetective.h"

@implementation HDDetective {
  HDServer *server;
}

-(id) init {
  self = [super init];
  if (self) {
#ifndef HD_MANUAL_LIFECYCLE_MANAGEMENT
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationInactive:) name:UIApplicationWillResignActiveNotification object:nil];
#endif
  }
  return self;
}

#ifndef HD_MANUAL_LIFECYCLE_MANAGEMENT
-(void) applicationActive:(NSNotification *) notification {
  [self activate];
}

-(void) applicationInactive:(NSNotification *) notification {
  [self deactive];
}
#endif

-(void) activate {
  server = [[HDServer alloc] initWithDelegate:self];
}

-(void) deactive {
  server = nil;
}

-(void) processCommand:(HDMessage *)message withCompletionHandler:(HDCommandProcessCompletionHandler) completionHandler {
  NSAssert(NO, @"Subclass responsibility");
}

-(NSString *) aspectName {
  NSAssert(NO, @"Subclass responsibility");
  return @"";
}

-(void) dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
