#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HDMessage.h"

typedef void(^HDCommandProcessCompletionHandler)(NSError *);

@protocol HDDetectiveCommandDelegate <NSObject>

-(void) processCommand:(HDMessage *) message withCompletionHandler:(HDCommandProcessCompletionHandler) handler;
-(NSString *) aspectName;

@end

@interface HDDetective : NSObject <HDDetectiveCommandDelegate>

-(void) activate;
-(void) deactive;

@end
