#import <Foundation/Foundation.h>
#import "HDDetective.h"

extern NSString *const HDServerNetServiceTXTRecordKeyMessageBoundary;

@interface HDServer : NSObject <NSNetServiceDelegate>

@property (nonatomic, weak) id<HDDetectiveCommandDelegate> delegate;

-(id) initWithDelegate:(id <HDDetectiveCommandDelegate>) delegate;

@end
