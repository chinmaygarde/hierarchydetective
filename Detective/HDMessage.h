#import <Foundation/Foundation.h>

typedef enum :NSInteger {
  HDMessageTypeUnknown,
  HDMessageTypeRequestEntireHierarchy,
  HDMessageTypeUpdatePropertyForNode,
  HDMessageTypeApplyScriptAtNode,
  HDMessageTypeGetSufaceForNode,
  HDMessageTypeGetFullSurfaceForNode,
} HDMessageType;

@interface HDMessage : NSObject

-(id) initWithMessageType:(HDMessageType) type;

@property (nonatomic) HDMessageType messageType;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) id requestArguments;
@property (nonatomic, strong) id responseData;

-(NSArray *) serializableProperties;

@end
