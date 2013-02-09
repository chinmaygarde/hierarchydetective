#import "HDQuartzDetective.h"
#import "HDScriptArgument.h"
#import "CALayer+HDHelpers.h"
#import "HDUtils.h"

@implementation HDQuartzDetective

#ifndef HD_MANUAL_LIFECYCLE_MANAGEMENT
+(void) load {
  @autoreleasepool {
    static dispatch_once_t onceToken;
    static HDQuartzDetective *detective = nil;
    dispatch_once(&onceToken, ^{
      detective = [[HDQuartzDetective alloc] init];
    });
  }
}
#endif

-(CALayer *) findLayerInAllWindows:(NSInteger) pointerValue {
  CALayer *selectedLayer = nil;
  for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
    selectedLayer = [window.layer getChildWithPointerValue:pointerValue];
    if(selectedLayer != nil)
      break;
  }
  return selectedLayer;
}

-(void) processCommand:(HDMessage *)message withCompletionHandler:(HDCommandProcessCompletionHandler)handler {
  switch (message.messageType) {
      
    case HDMessageTypeUnknown:
      handler(nil);
      break;
      
    case HDMessageTypeRequestEntireHierarchy:
      {
        NSMutableArray *roots = [[NSMutableArray alloc] init];
        for (UIWindow *window in [UIApplication sharedApplication].windows) {
          [roots addObject:window.layer];
        }
        message.responseData = roots;
      }
      handler(nil);
      break;
      
    case HDMessageTypeUpdatePropertyForNode:
      handler(HDNSErrorWithMessage(@"Unimplemented on server"));
      break;
      
    case HDMessageTypeApplyScriptAtNode:
      handler(HDNSErrorWithMessage(@"Unimplemented on server"));
      break;
      
    case HDMessageTypeGetSufaceForNode:
    {
      if(![message.requestArguments isKindOfClass:[HDArgument class]]) {
        handler(HDNSErrorWithMessage(@"Invalid arguments for command"));
        break;
      }
      
      HDArgument* argument = (HDArgument *)message.requestArguments;
      message.responseData = [[self findLayerInAllWindows:argument.pointerValue]
                              getPNGSurfaceRepresentation:CALayerSurfaceRepresentationTypeSelfOnly];
      handler(nil);
    }
      break;
      
    case HDMessageTypeGetFullSurfaceForNode:
    {
      if(![message.requestArguments isKindOfClass:[HDArgument class]]) {
        handler(HDNSErrorWithMessage(@"Invalid arguments for command"));
        break;
      }
      
      HDArgument* argument = (HDArgument *)message.requestArguments;
      message.responseData = [[self findLayerInAllWindows:argument.pointerValue]
                              getPNGSurfaceRepresentation:CALayerSurfaceRepresentationTypeFull];
      handler(nil);
    }
      break;
      
    default:
      handler(HDNSErrorWithMessage(@"Unknown command"));
      break;
  }
}

-(NSString *) aspectName {
  return @"Quartz Core";
}

@end
