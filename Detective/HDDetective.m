#import <objc/runtime.h>

#import "HDServer.h"
#import "HDDetective.h"

@implementation HDDetective {
  HDServer *server;
}

-(id) init {
  self = [super init];
  if (self) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationInactive:) name:UIApplicationWillResignActiveNotification object:nil];
  }
  return self;
}

-(void) applicationActive:(NSNotification *) notification {
  server = [[HDServer alloc] initWithDelegate:self];
}

-(void) applicationInactive:(NSNotification *) notification {
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
