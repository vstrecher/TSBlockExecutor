//
//  TSBlockExecutor.m
//  ThreadSafeBlockExecutor
//
//  Created by Eugene Valeyev on 10.01.13.
//  Copyright (c) 2013 Eugene Valeyev. All rights reserved.
//

#import "TSBlockExecutor.h"


typedef childBlock simpleBlock;
typedef void (*dispatcher_t)(dispatch_queue_t, simpleBlock);

@interface TSBlockExecutor ()

@property (nonatomic, readonly) NSMutableDictionary *threadIds;

- (NSString *)generateThreadId;
- (void)performChildBlockOnItsThread:(childBlock)block;

@end


@implementation TSBlockExecutor

@synthesize queue = _queue;
@synthesize threadIds = _threadIds;

#pragma mark - LifeCycle
- (id)init
{
    dispatch_queue_t queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
    self = [self initWithQueue:queue];
    dispatch_release(queue);
    return self;
}

- (id)initWithQueue:(dispatch_queue_t)queue
{
    if (self = [super init])
    {
        _threadIds = [[NSMutableDictionary alloc] initWithCapacity:10];
        _queue = queue;
        dispatch_retain(_queue);
    }
    return self;
}

- (void)dealloc
{
    dispatch_release(_queue);
    [_threadIds release];
    
    [super dealloc];
}

#pragma mark - Public Methods
- (BOOL)performMainBlock:(mainBlock)block
{
    return [self performMainBlock:block waitUntilDone:NO];
}

- (BOOL)performChildBlock:(childBlock)block onThreadId:(NSString *)threadId
{
    return [self performChildBlock:block onThreadId:threadId waitUntilDone:NO];
}

- (BOOL)performMainBlock:(mainBlock)block waitUntilDone:(BOOL)wait
{
    dispatcher_t dispatcher = dispatch_async;
    NSThread *thread = [NSThread currentThread];
    NSString *threadId = [self generateThreadId];
    [self.threadIds setObject:thread forKey:threadId];
    
    if (YES == wait)
    {
        dispatcher = dispatch_sync;
    }
    
    dispatcher(self.queue, ^{ block(threadId); });
    return YES;
}

- (BOOL)performChildBlock:(childBlock)block onThreadId:(NSString *)threadId waitUntilDone:(BOOL)wait
{
    BOOL result = NO;
    NSThread *thread = [self.threadIds objectForKey:threadId];
    if (nil != thread)
    {
        [self performSelector:@selector(performChildBlockOnItsThread:) onThread:thread withObject:block waitUntilDone:wait];
        result = YES;
    }
    return result;
}

#pragma mark - Private Methods
- (NSString *)generateThreadId
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, uuid);
    NSString *result = [NSString stringWithString:(NSString *)string];
    CFRelease(uuid);
    CFRelease(string);
    
    return result;
}

- (void)performChildBlockOnItsThread:(childBlock)block
{
    block();
}

@end
