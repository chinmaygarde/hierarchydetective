#import "DetectiveTest.h"
#import "HDDetective.h"
#import "NSObject+HDSerialization.h"
#import "TestAssertionHandler.h"

@implementation DetectiveTest

- (void)setUp
{
  [super setUp];
  [[NSThread currentThread].threadDictionary setObject:[[TestAssertionHandler alloc] init]forKey:NSAssertionHandlerKey];
}

- (void)tearDown
{
  // Tear-down code here.  
  [super tearDown];
}

-(UIView *) makeSimpleView {
  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
  view.backgroundColor = [UIColor blackColor];
  
  UIView *subview = [[UIView alloc] initWithFrame:CGRectMake(20, 12, 100, 200)];
  subview.backgroundColor = [UIColor greenColor];
  [view addSubview:subview];
  return view;
}

- (void)testSerialization
{
  NSData *data = [[self makeSimpleView] toJSONData];
  
  STAssertTrue(data != nil, @"JSON data should not be nil");
}

- (void)testDeserialization
{
  NSData *data = [[self makeSimpleView] toJSONData];
  
  NSObject *object = [NSObject objectWithJSONData:data unknownEntityHandler:^(NSString *classAsString) {
    STAssertTrue(NO, @"Should never get here");
    return (NSObject *)nil;
  }];
  
  STAssertTrue(object != nil, @"Deserialized object should not be nil");
  UIView *view = (UIView *)object;
  STAssertTrue(view.subviews.count == 1, @"Must have one subview");
  STAssertTrue(CGRectEqualToRect(view.frame, CGRectMake(0, 0, 320, 480)), @"Frame must be correct");
  
  UIView *subview = [view.subviews objectAtIndex:0];
  STAssertTrue(subview.subviews.count == 0, @"Must have no subviews");
  STAssertTrue(CGRectEqualToRect(subview.frame, CGRectMake(20, 12, 100, 200)), @"Subview frame must be correct");
}

- (void)testNSArrayAsRootSerialization {
  NSArray *array = @[[self makeSimpleView], [self makeSimpleView]];
  
  NSData *data = [array toJSONData];
  STAssertTrue(data != nil, @"Array should serialize correctly");
  
  NSObject* object = [NSObject objectWithJSONData:data unknownEntityHandler:^(NSString *classAsString){
    STAssertTrue(NO, @"Should never get here");
    return (NSObject *)nil;
  }];
  
  STAssertTrue([object isKindOfClass:[NSArray class]], @"Decoded object should be an array");
  STAssertTrue([(NSArray *)object count], @"Decoded array should have two elements");  
}

@end
