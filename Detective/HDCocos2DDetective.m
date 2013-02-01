#import "HDCocos2DDetective.h"
#import "cocos2d.h"
#import "HDScriptArgument.h"
#import "CCNode+HDHelpers.h"
#import "HDUtils.h"

@implementation HDCocos2DDetective

+(void) load {
  static dispatch_once_t onceToken;
  static HDCocos2DDetective *detective = nil;
  dispatch_once(&onceToken, ^{
    detective = [[HDCocos2DDetective alloc] init];
  });
}

-(void) processCommand:(HDMessage *)message withCompletionHandler:(HDCommandProcessCompletionHandler)completionHandler {

  switch (message.messageType) {
      
    case HDMessageTypeUnknown:
      completionHandler(nil);
      break;
      
    case HDMessageTypeRequestEntireHierarchy:
      message.responseData = @[[[CCDirector sharedDirector] runningScene]];
      completionHandler(nil);
      break;
      
    case HDMessageTypeUpdatePropertyForNode:
      completionHandler(HDNSErrorWithMessage(@"Unimplemented on server"));
      break;
      
    case HDMessageTypeApplyScriptAtNode:
      completionHandler(HDNSErrorWithMessage(@"Unimplemented on server"));
      break;
      
    case HDMessageTypeGetSufaceForNode:
    {
      if (![message.requestArguments isKindOfClass:[HDArgument class]]) {
        completionHandler(HDNSErrorWithMessage(@"Arguments invalid"));
        break;
      }
      
      HDArgument *argument = (HDArgument *)message.requestArguments;
      CCNode *node = [[CCDirector sharedDirector].runningScene childByPointerValue:argument.pointerValue];
      message.responseData = [node pngImageRepresentation:CCNodePNGRepresentationTypeShallow];
      completionHandler(nil);
    }
      break;
      
    case HDMessageTypeGetFullSurfaceForNode:
    {
      if (![message.requestArguments isKindOfClass:[HDArgument class]]) {
        completionHandler(HDNSErrorWithMessage(@"Arguments invalid"));
        break;
      }
      
      HDArgument *argument = (HDArgument *)message.requestArguments;
      CCNode *node = [[CCDirector sharedDirector].runningScene childByPointerValue:argument.pointerValue];
      message.responseData = [node pngImageRepresentation:CCNodePNGRepresentationTypeDeep];
      completionHandler(nil);
    }
      break;
      
    default:
      completionHandler(HDNSErrorWithMessage(@"Unknown command"));
      break;
  }
}

-(NSString *) aspectName {
  return @"Cocos2D";
}

@end
