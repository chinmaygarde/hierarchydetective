#import "UIView+HDHelpers.h"
#import <objc/runtime.h>

@implementation UIView (HDHelpers)

-(UIView *) getChildWithPointerValue:(NSInteger) pointerValue {

  if((NSInteger)self == pointerValue)
    return self;
  
  for(UIView *view in self.subviews) {
    UIView *foundView = [view getChildWithPointerValue:pointerValue];
    if (foundView != nil) {
      return foundView;
    }
  }
  
  return nil;
}

-(void) executeScript:(NSString *) script withCompletionHandler:(HDScriptExecutionCompletionHandler) handler {
  
}

-(NSInteger) pointerValue {
  // Yuck!
  return (NSInteger)self;
}

-(NSString *) remoteObjectDescription {
    return self.description;
}

-(NSString *) viewControllerClass {
  UIResponder *responder = self;

  while ((responder = [responder nextResponder])) {

    if ([responder isKindOfClass: [UIViewController class]]) {
      return NSStringFromClass([responder class]);
    }
    
  }
  
  return nil;
}

-(NSArray *) pathToRoot {
  NSMutableArray *array = [[NSMutableArray alloc] init];
  id currentObject = self;
  do {
    [array addObject:NSStringFromClass([currentObject class])];
  } while((currentObject = [currentObject superview]));
  return array;
}

-(NSArray *) serializableProperties {
  return @[
    @"pointerValue",
    @"bounds",
    @"center",
    @"subviews",
    @"frame",
    @"classHierarchy",
    @"viewControllerClass",
    @"pathToRoot",
    @"remoteObjectDescription",
  ];
}

-(void) setNonKVCCompliantValue:(id) value forKey:(NSString *) string {
  if (![string isEqualToString:@"subviews"]) {
    return;
  }
  
  NSAssert([value isKindOfClass:[NSArray class]], @"Subview must be arrays");
  
  NSArray *newSubviews = (NSArray *)value;
  
  // Remove all current subviews
  while (self.subviews.count != 0) {
    [(self.subviews)[0] removeFromSuperview];
  }
  
  for(UIView *view in newSubviews) {
    [self addSubview:view];
  }
}

@end
