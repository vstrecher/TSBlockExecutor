//
// Created by eugenedymov on 05.02.13.
//
// To change the template use AppCode | Preferences | File Templates.
//

// Same as TSBlockExecutor but GCD only

#import <Foundation/Foundation.h>

#define kCTDispatchrUserInfoQueueKey @"dispatchr_queue"

typedef void (^dispatchr_block_t)(NSDictionary *userInfo);

@interface TSBlockPerformer : NSObject

@property (nonatomic, readonly) dispatch_queue_t queue;

- (id)initWithQueue:(dispatch_queue_t)queue;

- (void)performBlock:(dispatchr_block_t)block;
- (void)performBlock:(dispatchr_block_t)block waitUntilDone:(BOOL)isShouldWaitUntilDone;
- (void)performChildBlock:(dispatch_block_t)block userInfo:(NSDictionary *)userInfo;
- (void)performChildBlock:(dispatch_block_t)block userInfo:(NSDictionary *)userInfo  waitUntilDone:(BOOL)isShouldWaitUntilDone;

@end