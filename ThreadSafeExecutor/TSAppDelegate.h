//
//  TSAppDelegate.h
//  ThreadSafeExecutor
//
//  Created by Eugene Valeyev on 10.01.13.
//  Copyright (c) 2013 Eugene Valeyev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSViewController;

@interface TSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) TSViewController *viewController;

@end
