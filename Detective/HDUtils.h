#ifndef DetectiveVO_HDUtils_h
#define DetectiveVO_HDUtils_h

#import <Foundation/Foundation.h>
#import <TargetConditionals.h>

#ifdef BUILDING_LIBRARY
#import <CoreGraphics/CoreGraphics.h>
#endif

NSString *HDNSStringFromCGPoint (CGPoint point);
NSString *HDNSStringFromCGSize  (CGSize size);
NSString *HDNSStringFromCGRect  (CGRect rect);
CGPoint   HDCGPointFromString   (NSString *string);
CGSize    HDCGSizeFromString    (NSString *string);
CGRect    HDCGRectFromString    (NSString *string);
NSError  *HDNSErrorWithMessage  (NSString *message);

#endif //DetectiveVO_HDUtils_h
