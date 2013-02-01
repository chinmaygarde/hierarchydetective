#import "HDUtils.h"

#pragma mark -
#pragma iPhone Only Utils


#pragma mark -
#pragma Common Utils

static NSArray *NumberArrayFromString(NSString *pString) {
  NSString *string = [pString stringByReplacingOccurrencesOfString:@"{" withString:@""];
  string = [string stringByReplacingOccurrencesOfString:@"}" withString:@""];
  return [string componentsSeparatedByString:@","];
}

NSString *HDNSStringFromCGPoint(CGPoint point) {
  return [NSString stringWithFormat:@"{%f,%f}", point.x, point.y];  
}

NSString *HDNSStringFromCGSize(CGSize size) {
  return [NSString stringWithFormat:@"{%f,%f}", size.width, size.height];
}

NSString *HDNSStringFromCGRect(CGRect rect) {
	return [NSString stringWithFormat:@"{{%f,%f},{%f,%f}}", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];
}

CGPoint HDCGPointFromString(NSString *string) {
  NSArray* components = NumberArrayFromString(string);
  if(components.count != 2)
    return CGPointZero;
  
  CGPoint point;
  
  point.x = [components[0] floatValue];
  point.y = [components[1] floatValue];
  
  return point;
}

CGSize HDCGSizeFromString(NSString *string) {
  NSArray *components = NumberArrayFromString(string);
  if (components.count != 2)
    return CGSizeZero;
  
  CGSize size;
  
  size.width = [components[0] floatValue];
  size.height = [components[1] floatValue];
  
  return size;
}

CGRect HDCGRectFromString(NSString *string) {
	NSArray *components = NumberArrayFromString(string);
  if(components.count != 4)
    return CGRectZero;
  
  CGRect rect;
  
  rect.origin.x = [components[0] floatValue];
  rect.origin.y = [components[1] floatValue];
  rect.size.width = [components[2] floatValue];
  rect.size.height = [components[3] floatValue];
  
  return rect;
}

NSError* HDNSErrorWithMessage(NSString* message) {
  return [NSError errorWithDomain:message code:0 userInfo:nil];
}
