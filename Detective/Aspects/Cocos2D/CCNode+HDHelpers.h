#import "CCNode.h"
#import "HDProperties.h"

typedef enum :NSInteger {
  CCNodePNGRepresentationTypeShallow,
  CCNodePNGRepresentationTypeDeep,
} CCNodePNGRepresentationType;

@interface CCNode (HDHelpers) <HDProperties>

@property (nonatomic, readonly) NSArray *subviews;
@property (nonatomic, readonly) NSInteger pointerValue;
@property (nonatomic, readonly) CGRect bounds;
@property (nonatomic, readonly) CGRect frame;
@property (nonatomic, readonly) NSArray *pathToRoot;

-(NSData *) pngImageRepresentation:(CCNodePNGRepresentationType) type;
-(CCNode *) childByPointerValue:(NSInteger) val;

@end
