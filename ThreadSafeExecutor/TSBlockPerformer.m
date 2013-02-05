//
// Created by eugenedymov on 05.02.13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TSBlockPerformer.h"

static inline NSDictionary * userInfoWithQueue (dispatch_queue_t queue) {
    NSValue *value = [[NSValue alloc] initWithBytes:&queue objCType:@encode(dispatch_queue_t)];
    NSDictionary *dictionary = @{kCTDispatchrUserInfoQueueKey: value};
    [value release];
    return dictionary;
};

static inline dispatch_queue_t queueFromUserInfo(NSDictionary *userInfo) {
    NSValue *queueValue = [userInfo objectForKey:kCTDispatchrUserInfoQueueKey];
    dispatch_queue_t queue;
    [queueValue getValue:&queue];
    return queue;
};

@interface TSBlockPerformer ()
@property (nonatomic) dispatch_queue_t queue;
@end

@implementation TSBlockPerformer { }

#pragma mark - Init/Dealloc Methods

- (id)initWithQueue:(dispatch_queue_t)queue {
    self = [super init];
    if (self) {
        self.queue = queue;
        dispatch_retain(self.queue);
    }
    return self;
}

- (void)dealloc {
    dispatch_release(self.queue);
    [super dealloc];
}

#pragma mark - Interface Methods

- (void)performBlock:(dispatchr_block_t)block {
    [self performBlock:block waitUntilDone:NO];
}

- (void)performChildBlock:(dispatch_block_t)block userInfo:(NSDictionary *)userInfo {
    [self performChildBlock:block userInfo:userInfo waitUntilDone:NO];
}

- (void)performBlock:(dispatchr_block_t)block waitUntilDone:(BOOL)isShouldWaitUntilDone {
    dispatch_queue_t calledFromQueue = dispatch_get_current_queue();
    [self _performBlock:^{ block(userInfoWithQueue(calledFromQueue)); } queue:self.queue sync:isShouldWaitUntilDone];
}

- (void)performChildBlock:(dispatch_block_t)block userInfo:(NSDictionary *)userInfo waitUntilDone:(BOOL)isShouldWaitUntilDone {
    if (userInfo == NULL) return;
    dispatch_queue_t queue = queueFromUserInfo(userInfo);
    [self _performBlock:block queue:queue sync:isShouldWaitUntilDone];
}

#pragma mark - Private Methods

- (void)_performBlock:(dispatch_block_t)block queue:(dispatch_queue_t)queue sync:(BOOL)isSync {
    if (isSync) {
        dispatch_sync(queue, block);
    } else {
        dispatch_async(queue, block);
    }
}


@end