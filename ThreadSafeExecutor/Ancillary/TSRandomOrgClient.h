//
// Created by eugenedymov on 05.02.13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

typedef void (^TSRandomOrgClientBlock)(NSInteger integer);

@interface TSRandomOrgClient : AFHTTPClient


+ (TSRandomOrgClient *)sharedInstance;
+ (void)getRandomNumber:(TSRandomOrgClientBlock)block;

@end