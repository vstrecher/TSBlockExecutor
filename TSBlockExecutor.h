//
//  TSBlockExecutor.h
//  ThreadSafeBlockExecutor
//
//  Created by Eugene Valeyev on 10.01.13.
//  Copyright (c) 2013 Eugene Valeyev. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^mainBlock)(NSString * const threadId);
typedef void (^childBlock)();

@interface TSBlockExecutor : NSObject

@property (nonatomic, readonly) dispatch_queue_t queue;

- (id)init;
- (id)initWithQueue:(dispatch_queue_t)queue;
- (BOOL)performMainBlock:(mainBlock)block;
- (BOOL)performChildBlock:(childBlock)block onThreadId:(NSString *)threadId;
- (BOOL)performMainBlock:(mainBlock)block waitUntilDone:(BOOL)wait;
- (BOOL)performChildBlock:(childBlock)block onThreadId:(NSString *)threadId waitUntilDone:(BOOL)wait;

@end

