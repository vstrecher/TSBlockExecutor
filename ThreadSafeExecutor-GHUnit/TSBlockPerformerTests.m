//
// Created by eugenedymov on 05.02.13.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <GHUnitIOS/GHUnit.h>
#import "TSBlockPerformer.h"
#import "TSRandomOrgClient.h"

@interface TSBlockPerformerTests : GHAsyncTestCase { }
@property (nonatomic, retain)   TSBlockPerformer        *performer;
@property (nonatomic)           dispatch_queue_t        performerQueue;
@end

@implementation TSBlockPerformerTests { }

- (void)setUpClass {
    [super setUpClass];

    self.performerQueue = dispatch_queue_create("performer_queue", NULL);
    dispatch_retain(self.performerQueue);
    self.performer = [[[TSBlockPerformer alloc] initWithQueue:self.performerQueue] autorelease];
}

- (void)tearDownClass {
    dispatch_release(self.performerQueue), self.performerQueue = NULL;

    [super tearDownClass];
}

- (BOOL)shouldRunOnMainThread {
    return YES;
}

- (void)test01PerformingAsync {
    [self prepare];

    dispatch_queue_t callingFromQueue = dispatch_get_current_queue();
    GHTestLog(@"Calling from %@", [self _currentQueueName]);

    [self.performer performBlock:^(NSDictionary *userInfo) {
        [TSRandomOrgClient getRandomNumber:^(NSInteger integer) {
            GHTestLog(@"Got number %d", integer);
            [self.performer performChildBlock:^{
                dispatch_queue_t childQueue = dispatch_get_current_queue();
                if (integer >= 500) {
                    GHTestLog(@"Greater or equal than 500!");
                } else {
                    GHTestLog(@"Less than 500!");
                }
                GHAssertTrue(callingFromQueue == childQueue, @"Child block performed on invalid queue");
                GHTestLog(@"Child block from %@", [self _currentQueueName]);
                [self notify:kGHUnitWaitStatusSuccess];
            } userInfo:userInfo];
        }];
    }];

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:30.0];
}

- (void)test02PerformingSync {
    [self prepare];

    dispatch_queue_t callingFromQueue = dispatch_get_current_queue();
    GHTestLog(@"Calling from %@", [self _currentQueueName]);

    [self.performer performBlock:^(NSDictionary *userInfo) {
        [TSRandomOrgClient getRandomNumber:^(NSInteger integer) {
            GHTestLog(@"Got number %d", integer);
            [self.performer performChildBlock:^{
                dispatch_queue_t childQueue = dispatch_get_current_queue();
                if (integer >= 500) {
                    GHTestLog(@"Greater or equal than 500!");
                } else {
                    GHTestLog(@"Less than 500!");
                }
                GHAssertTrue(callingFromQueue == childQueue, @"Child block performed on invalid queue");
                GHTestLog(@"Child block from %@", [self _currentQueueName]);
                [self notify:kGHUnitWaitStatusSuccess];
            } userInfo:userInfo];
        }];
    } waitUntilDone:YES];

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:30.0];
}

- (void)test03PerformSimultaneouslyFromDifferentQueuesAsync {
}

- (void)test04PerformSimultaneouslyFromDifferentQueuesSync {
}

#pragma mark - Helpers

- (NSString *)_currentQueueName {
    return [self _queueName:dispatch_get_current_queue()];
}

- (NSString *)_queueName:(dispatch_queue_t)queue {
    return [NSString stringWithCString:dispatch_queue_get_label(queue) encoding:NSUTF8StringEncoding];
}


@end