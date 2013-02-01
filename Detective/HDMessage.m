#import "HDMessage.h"

@implementation HDMessage

@synthesize uid=_uid;
@synthesize messageType=_messageType;
@synthesize requestArguments=_requestArguments;
@synthesize responseData=_responseData;

-(id) initWithMessageType:(HDMessageType) type {
  self = [super init];
  if (self) {
    _messageType = type;
  }
  return self;
}

-(NSString *) uid {
  if (_uid == nil) {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    _uid = CFBridgingRelease(uuidString);
  }
  return _uid;
}

-(NSArray *) serializableProperties {
  return @[@"messageType", @"requestArguments", @"responseData", @"uid"];
}

@end
