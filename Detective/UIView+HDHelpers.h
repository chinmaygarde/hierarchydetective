#import <UIKit/UIKit.h>
#import "HDScriptRunner.h"
#import "HDProperties.h"

@interface UIView (HDHelpers) <HDProperties>

@property (nonatomic, readonly) NSInteger pointerValue;
@property (nonatomic, readonly) NSString *viewControllerClass;
@property (nonatomic, readonly) NSArray *pathToRoot;

-(UIView *) getChildWithPointerValue:(NSInteger) pointerValue;

-(void) executeScript:(NSString *) script withCompletionHandler:(HDScriptExecutionCompletionHandler) handler;

@end
