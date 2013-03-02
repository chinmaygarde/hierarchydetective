#import "HDServer.h"
#import "HDDetective.h"
#import "HDGCDAsyncSocket.h"
#import "NSObject+HDSerialization.h"

NSString *const HDServerNetServiceTXTRecordKeyMessageBoundary = @"messageBoundary";

NSData* GenerateUniqueMessageBoundary() {
  CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
  CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuid);
  CFRelease(uuid);
  NSData *boundary = [[NSString stringWithFormat:@"HIERDET-%@", uuidString] dataUsingEncoding:NSUTF8StringEncoding];
  CFRelease(uuidString);
  return boundary;
}

@implementation HDServer {
  HDGCDAsyncSocket *serverSocket;
  NSNetService *netservice;
  
  NSMutableArray *connectedClients;
  NSData *messageBoundary;
}

@synthesize delegate=_delegate;

+(HDServer *) sharedServer {
  static dispatch_once_t onceToken;
  static HDServer *globalInstance;
  dispatch_once(&onceToken, ^{
    globalInstance = [[HDServer alloc] init];
  });
  return globalInstance;
}

-(id) initWithDelegate:(id <HDDetectiveCommandDelegate>) delegate {
  self = [super init];
  if (self) {
    _delegate = delegate;
    connectedClients = [[NSMutableArray alloc] init];
    serverSocket = [[HDGCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    messageBoundary = GenerateUniqueMessageBoundary();
    
    NSError *error = nil;
    if([serverSocket acceptOnPort:0 error:&error]) {
      [self registerForDiscovery];
    } else {
      NSLog(@"%@", [NSString stringWithFormat:@"Could not setup server socket. No clients can discover or connect to this application. Error is %@", error]);
    }
  }
  return self;
}

-(void) registerForDiscovery {
  NSAssert(serverSocket != nil, @"Async socket must already be setup for discovery");
  
  NSString *serviceName = [NSString stringWithFormat:@"%@ @ %@", [_delegate aspectName], [NSProcessInfo processInfo].hostName];
  netservice = [[NSNetService alloc] initWithDomain:@"local."
                                        type:@"_hierdet._tcp."
                                        name:serviceName
                                        port:[serverSocket localPort]];
  [netservice setDelegate: self];
  
  NSMutableDictionary *txtDict = [NSMutableDictionary dictionaryWithCapacity:1];
  txtDict[HDServerNetServiceTXTRecordKeyMessageBoundary] = messageBoundary;
  NSData *txtData = [NSNetService dataFromTXTRecordDictionary:txtDict];
  [netservice setTXTRecordData:txtData];
  
  [netservice publish];
}

- (void)netServiceDidPublish:(NSNetService *)sender {
  NSLog(@"Hierarchy Detective (%@) is ready!", [_delegate aspectName]);
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
  NSLog(@"Could not register as server for Hierarchy Detective. Check your network settings and relaunch the application.");
}

-(void) dealloc {
  [netservice stop];
  
  for (HDGCDAsyncSocket* socket in connectedClients) {
    [socket disconnect];
  }
  connectedClients = nil;
  
  [serverSocket disconnect];
  serverSocket = nil;
  
}

-(void) readMoreMessages:(HDGCDAsyncSocket *)sock {
  [sock readDataToData:messageBoundary withTimeout:-1.0f tag:0];
}

-(NSData *) wireDataForMessage:(HDMessage *)message {
  NSMutableData *mutableData = [[NSMutableData alloc] init];
  [mutableData appendData:[message toJSONData]];
  [mutableData appendData:messageBoundary];
  return mutableData;
}

#pragma mark -
#pragma mark GCDAsyncSocketDelegate method

- (void)socket:(HDGCDAsyncSocket *)sock didAcceptNewSocket:(HDGCDAsyncSocket *)newSocket {
	NSLog(@"Accepted new socket for aspect %@ from %@:%hu", [_delegate aspectName], [newSocket connectedHost], [newSocket connectedPort]);
  newSocket.delegate = self;
  [self readMoreMessages:newSocket];
	[connectedClients addObject:newSocket];
}

-(void)socket:(HDGCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  [self readMoreMessages:sock];
  
  
  // First get rid of the boundary marker
  NSUInteger actualDataLength = data.length - messageBoundary.length;
  void *dataBytes = calloc(1, actualDataLength);
  [data getBytes:dataBytes range:NSMakeRange(0, actualDataLength)];
  id message = [NSObject objectWithJSONData:[NSData dataWithBytesNoCopy:dataBytes length:actualDataLength freeWhenDone:YES] unknownEntityHandler:nil];

  if (![message isKindOfClass:[HDMessage class]]) {
    NSLog(@"Incoming message is not correctly formatted");
    return;
  }
  
  [_delegate processCommand:(HDMessage *)message withCompletionHandler:^(NSError *error){
    if(error != nil) {
      NSLog(@"Could not process command: %ld", [message messageType]);
      return;
    }
    
    [sock writeData:[self wireDataForMessage:message] withTimeout:-1.0f tag:0];
  }];
}

- (void)socketDidDisconnect:(HDGCDAsyncSocket *)sock withError:(NSError *)err {
  NSLog(@"Disconnected client");
  sock.delegate = nil;
	[connectedClients removeObject:sock];
}

@end
