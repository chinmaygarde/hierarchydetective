//
//  HDViewControllerDetective.m
//  Detective
//
//  Created by Chinmay Garde on 10/1/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "HDViewControllerDetective.h"
#import "HDUtils.h"

@implementation HDViewControllerDetective

#ifndef HD_MANUAL_LIFECYCLE_MANAGEMENT
+(void) load {
    static dispatch_once_t onceToken;
    static HDViewControllerDetective *detective = nil;
    dispatch_once(&onceToken, ^{
        detective = [[HDViewControllerDetective alloc] init];
    });
}
#endif

-(void) processCommand:(HDMessage *)message withCompletionHandler:(HDCommandProcessCompletionHandler) completionHandler {
    switch (message.messageType) {
            
        case HDMessageTypeUnknown:
            completionHandler(nil);
            break;
            
        case HDMessageTypeRequestEntireHierarchy:
        {
            NSMutableArray *rootControllers = [[NSMutableArray alloc] init];
            for (UIWindow *window in [UIApplication sharedApplication].windows) {
                UIViewController *controller = window.rootViewController;
                if (controller) {
                    [rootControllers addObject:controller];
                }
            }
            message.responseData = rootControllers;
            completionHandler(nil);
        }
            break;
            
        case HDMessageTypeUpdatePropertyForNode:
        case HDMessageTypeApplyScriptAtNode:
        case HDMessageTypeGetSufaceForNode:
        case HDMessageTypeGetFullSurfaceForNode:
        default:
            completionHandler(HDNSErrorWithMessage(@"Unknown command"));
            break;
    }

}

-(NSString *) aspectName {
    return @"View Controller Containment";
}

@end
