#import <QuartzCore/QuartzCore.h>
#import "HDProperties.h"

typedef enum :NSInteger {
  CALayerSurfaceRepresentationTypeSelfOnly,
  CALayerSurfaceRepresentationTypeFull,
} CALayerSurfaceRepresentationType;

@interface CALayer (HDHelpers) <HDProperties>

@property (nonatomic, readonly) NSInteger pointerValue;
@property (nonatomic, readonly) NSArray *subviews;
@property (nonatomic, readonly) NSString *viewControllerClass;
@property (nonatomic, readonly) NSArray *pathToRoot;

-(NSData *) getPNGSurfaceRepresentation:(CALayerSurfaceRepresentationType) type;
-(CALayer *) getChildWithPointerValue:(NSInteger) pointerValue;

@end
