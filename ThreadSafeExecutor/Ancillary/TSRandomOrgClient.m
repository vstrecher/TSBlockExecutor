//
// Created by eugenedymov on 05.02.13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TSRandomOrgClient.h"
#import "AFNetworking.h"


@implementation TSRandomOrgClient {

}

#pragma mark - Instance Methods

+ (TSRandomOrgClient *)sharedInstance {
    static dispatch_once_t once;
    static TSRandomOrgClient *sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[TSRandomOrgClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.random.org/"]]; });
    return sharedInstance;
}

+ (void)getRandomNumber:(TSRandomOrgClientBlock)block {
    void (^getRandomCH)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger randomInt = operation.responseString.integerValue;
        block(randomInt);
    };

    void (^getRandomFH)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        block(-1);
    };

    [[[self class] sharedInstance] getPath:@"/integers/"
                                parameters:@{@"num" : @1, @"min" : @(arc4random() % 20), @"max" : @1000, @"col" : @1, @"base" : @10, @"format" : @"plain", @"rnd" : @"new"}
                                   success:getRandomCH
                                   failure:getRandomFH];
}

@end