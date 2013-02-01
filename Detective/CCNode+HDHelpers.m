#import "CCNode+HDHelpers.h"
#import "cocos2d.h"
#import <dlfcn.h>

typedef struct {
  void (*PushMatrix) (void);
  void (*PopMatrix) (void);
} HDCompatInfo;

static HDCompatInfo GetCompatInfo() {
  static HDCompatInfo compatInfo;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    void* openHandle = dlopen((const char *)NULL, RTLD_LAZY);
    NSCAssert(openHandle != NULL, @"Could not resolve compat symbols");
    
    compatInfo.PushMatrix = dlsym(openHandle, "kmGLPushMatrix");
    if (compatInfo.PushMatrix == NULL) {
      compatInfo.PushMatrix = dlsym(openHandle, "glPushMatrix");
    }
    NSCAssert(compatInfo.PushMatrix != NULL, @"Could not find pushMatrix symbol");
    
    compatInfo.PopMatrix = dlsym(openHandle, "kmGLPopMatrix");
    if (compatInfo.PopMatrix == NULL) {
      compatInfo.PopMatrix = dlsym(openHandle, "glPopMatrix");
    }
    NSCAssert(compatInfo.PopMatrix != NULL, @"Could not find pushMatrix symbol");
  });
  
  return compatInfo;
}

@implementation CCNode (HDHelpers)

-(NSInteger) pointerValue {
  return (NSInteger)self;
}

-(NSArray *) subviews {
  return [self.children getNSArray];
}

-(CGRect) bounds {
  CGRect rect;
  rect.origin = CGPointMake(0, 0);
  rect.size = self.contentSize;
  return rect;
}

-(CGRect) frame {
  CGRect scaled = CGRectApplyAffineTransform(self.boundingBox, CGAffineTransformMakeScale(1, -1));
  return CGRectApplyAffineTransform(scaled, CGAffineTransformMakeTranslation(0, self.parent.boundingBox.size.height));
}

-(NSArray *) pathToRoot {
  NSMutableArray *array = [[NSMutableArray alloc] init];
  id currentObject = self;
  do {
    [array addObject:NSStringFromClass([currentObject class])];
  } while((currentObject = [currentObject parent]));
  return array;
}

-(NSArray *) serializableProperties {
  return @[
    @"pointerValue",
    @"bounds",
    @"frame",
    @"subviews",
    @"classHierarchy",
    @"pathToRoot"
  ];
}

-(void) visitWithoutDrawingChildren {
  
  HDCompatInfo compat = GetCompatInfo();

  if (!visible_)
		return;
  
  compat.PushMatrix();
  
	[self draw];
  
  compat.PopMatrix();
}

-(NSData *) pngImageRepresentation:(CCNodePNGRepresentationType) type {
  // Dont bother if content size is 0. CCRenderTexture will NOT be created successfully anyway
  if (self.contentSize.width == 0 || self.contentSize.height == 0) {
    return nil;
  }
  
  if ([self respondsToSelector:@selector(usesBatchNode)]) {
    if ((BOOL) [self performSelector:@selector(usesBatchNode)]) {
      return nil;
    }
  }
  
  CCRenderTexture *texture = [CCRenderTexture renderTextureWithWidth: self.contentSize.width height: self.contentSize.height];
  
  [texture begin];
  [self visitWithoutDrawingChildren];
  [texture end];
  
  // FML :'-( http://cdn.memegenerator.net/instances/400x/33048219.jpg
  if ([texture respondsToSelector:@selector(getUIImageFromBuffer)] /* Deprecated in 2.0 but still works. Not so in < 1.0 */) {
    return UIImagePNGRepresentation([texture performSelector:@selector(getUIImageFromBuffer)]);
  } else if([texture respondsToSelector:@selector(getUIImageAsDataFromBuffer:)] /* This causes assertion failures in 2.0 */) {
    int val = kCCImageFormatPNG;
    NSValue *arg = [[NSValue alloc] initWithBytes:&val objCType:@encode(int)];
    return [texture performSelector:@selector(getUIImageAsDataFromBuffer:) withObject:arg];
  }
  
  return nil;
}

-(CCNode *) childByPointerValue:(NSInteger) val {
  if ((NSInteger)self == val) {
    return self;
  }
  
  CCNode *foundNode = nil;
  for (CCNode* node in self.subviews) {
    foundNode = [node childByPointerValue:val];
    if(foundNode != nil)
      break;
  }
  
  return foundNode;
}

@end
