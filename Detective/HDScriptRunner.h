#import <Foundation/Foundation.h>

typedef void(^HDScriptExecutionCompletionHandler)(NSError *error);

@interface HDScriptRunner : NSObject

+(HDScriptRunner *) sharedScriptRunner;
-(void) runScript:(NSString *) script;
-(void) runScript:(NSString *) script withCompletionHandler:(HDScriptExecutionCompletionHandler) handler;

@end
