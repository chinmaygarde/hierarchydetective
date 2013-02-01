#import "HDUIKitDetective.h"
#import "NSObject+HDSerialization.h"
#import "HDScriptArgument.h"
#import "UIView+HDHelpers.h"
#import "CALayer+HDHelpers.h"
#import "HDUtils.h"

@implementation HDUIKitDetective

+(void) load {
  @autoreleasepool {
    static dispatch_once_t onceToken;
    static HDUIKitDetective *detective = nil;
    dispatch_once(&onceToken, ^{
      detective = [[HDUIKitDetective alloc] init];
    });
  }
}

-(UIView *) findViewInAllWindows:(NSInteger) pointerValue {
  UIView *selectedView = nil;
  for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
    selectedView = [window getChildWithPointerValue:pointerValue];
    if(selectedView != nil)
      break;
  }
  return selectedView;
}

-(void) processCommand:(HDMessage *)message withCompletionHandler:(HDCommandProcessCompletionHandler) completionHandler {
  switch (message.messageType) {
    
    case HDMessageTypeRequestEntireHierarchy:
      message.responseData = (id)[[UIApplication sharedApplication] windows];
      completionHandler(nil);
      break;
    
    case HDMessageTypeGetSufaceForNode:
    {
      if (![message.requestArguments isKindOfClass:[HDArgument class]]) {
        completionHandler(HDNSErrorWithMessage(@"Request arguments invalid"));
        break;
      }
      
      HDArgument* argument = (HDArgument *)message.requestArguments;
      message.responseData = [[self findViewInAllWindows:argument.pointerValue].layer
                              getPNGSurfaceRepresentation:CALayerSurfaceRepresentationTypeSelfOnly];
      completionHandler(nil);
    }
      break;
      
    case HDMessageTypeGetFullSurfaceForNode:
    {
      if (![message.requestArguments isKindOfClass:[HDArgument class]]) {
        completionHandler(HDNSErrorWithMessage(@"Request arguments invalid"));
        break;
      }
      
      HDArgument* argument = (HDArgument *)message.requestArguments;
      message.responseData = [[self findViewInAllWindows:argument.pointerValue].layer
                              getPNGSurfaceRepresentation:CALayerSurfaceRepresentationTypeFull];
      completionHandler(nil);
    }
      break;
      
    case HDMessageTypeUpdatePropertyForNode:
      completionHandler(HDNSErrorWithMessage(@"Unimplemented on the server"));
      break;
    
    case HDMessageTypeApplyScriptAtNode:
    {
      
      if (![message.requestArguments isKindOfClass:[HDScriptArgument class]]) {
        completionHandler(HDNSErrorWithMessage(@"Request arguments invalid"));
        break;
      }

      HDScriptArgument* argument = (HDScriptArgument *)message.requestArguments;
      [[self findViewInAllWindows:argument.pointerValue] executeScript:argument.script withCompletionHandler:^(NSError *error) {
        message.responseData =  (error == nil) ? @"Success" : error.domain;
        completionHandler(nil);
      }];
      
    }
      break;
    
    case HDMessageTypeUnknown:
      completionHandler(nil);
      break;
      
    default:
      completionHandler(HDNSErrorWithMessage(@"Unknown command"));
      break;
  }
}

-(NSString *) aspectName {
  return @"UIKit";
}

@end
