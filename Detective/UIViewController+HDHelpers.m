//
//  UIViewController+HDHelpers.m
//  Detective
//
//  Created by Chinmay Garde on 10/1/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "UIViewController+HDHelpers.h"

@implementation UIViewController (HDHelpers)

-(NSInteger) pointerValue {
    return (NSInteger) self;
}

-(NSArray *) subviews {
    return self.childViewControllers;
}

-(CGRect) frame {
    return CGRectMake(0, 0, 320, 480);
}

-(CGRect) bounds {
    return CGRectMake(0, 0, 320, 480);
}

-(NSArray *) pathToRoot {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    id currentObject = self;
    do {
        [array addObject:NSStringFromClass([currentObject class])];
    } while((currentObject = [currentObject parentViewController]));
    return array;
}

-(NSString *) viewControllerClass {
    NSString *viewClassName = nil;
    if (self.view != nil) {
        viewClassName  = NSStringFromClass([self.view class]);
    }
    return (viewClassName == nil) ? @"" : viewClassName;
}

-(NSArray *) serializableProperties {
    return @[
             @"pointerValue",
             @"bounds",
             @"frame",
             @"subviews",
             @"classHierarchy",
             @"viewControllerClass",
             @"pathToRoot"
             ];
}

@end

typedef void(^UIViewControllerOperationBlock)(UIView *);

@implementation UIView (UIViewControllerAspectHelpers)

-(UIViewController *) associatedViewController {
    UIResponder *responder = self;
    
    while ((responder = [responder nextResponder])) {
        if ([responder isKindOfClass: [UIViewController class]])
            return (UIViewController *)responder;
    }
    
    return nil;
}

-(void) performBlockForAllViewsInHierarchy:(UIViewControllerOperationBlock) block {
    block(self);
    for (UIView *view in self.subviews) {
        [view performBlockForAllViewsInHierarchy:block];
    }
}

-(NSArray *) viewControllerHierarchyRoots {
    NSMutableSet *roots = [[NSMutableSet alloc] init];
    
    [self performBlockForAllViewsInHierarchy:^(UIView * view) {
        UIViewController *controller = [view associatedViewController];
        
        while (controller.parentViewController != nil) {
            controller = controller.parentViewController;
        }
        
        if (controller!= nil) {
            [roots addObject:controller];
        }
    }];
    
    return [roots allObjects];
}

@end
