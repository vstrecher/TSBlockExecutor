//
//  TSViewController.m
//  ThreadSafeExecutor
//
//  Created by Eugene Valeyev on 10.01.13.
//  Copyright (c) 2013 Eugene Valeyev. All rights reserved.
//

#import "TSViewController.h"
#import "TSBlockExecutor.h"
#import "AFHTTPClient.h"

@interface TSViewController ()
{
    TSBlockExecutor *_exec;
    AFHTTPClient *_http;
    NSPort *_port;
}
@end

@implementation TSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _exec = [[TSBlockExecutor alloc] init];
    _http = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://mail.ru"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_exec release];
    [_http release];
    [super dealloc];
}


- (IBAction)btnAPressed:(id)sender
{
    NSLog(@">>>btn A %@", [NSThread currentThread]);
    [_exec performMainBlock:^(NSString *threadId) {
        for (int i = 0; i < 3; ++i) {
            NSLog(@"exec (%i) %@", i + 1, [NSThread currentThread]);
            [_exec performChildBlock:^{
                NSLog(@"subexec (%i) %@", 0 + 1, [NSThread currentThread]);
            } onThreadId:threadId waitUntilDone:NO];
            [NSThread sleepForTimeInterval:1];
        }
    } waitUntilDone:NO];
    NSLog(@"<<<btn A %@", [NSThread currentThread]);
}

- (IBAction)btnBPressed:(id)sender
{
#pragma mark - Main Thread
    NSLog(@"main thread %@", [NSThread currentThread]);
//    [self performSelectorInBackground:@selector(act) withObject:nil];
//    NSThread *t = [[NSThread alloc] initWithTarget:self selector:@selector(task) object:nil];
//    [t start];
//    [t release];
    
    [self act];
}

- (void)task
{
#pragma mark - Created Thread
    if (nil == _port)
    {
        _port = [NSPort port];
    }
    
    NSLog(@"task %@", [NSThread currentThread]);
    //NSRunLoop *loop = [NSRunLoop currentRunLoop];
    //[loop addPort:_port forMode:(NSString*)kCFRunLoopDefaultMode];
    [self act];
    NSLog(@"--=====--");
}

- (void)act
{
#pragma mark - Created Thread
    NSLog(@">>>btn B %@", [NSThread currentThread]);
    
    [_exec performMainBlock:^(NSString *threadId) {
#pragma mark - Queue Thread
        NSLog(@"in main block");
        [_http getPath:@"" parameters:nil success:^(AFHTTPRequestOperation *op, NSData *obj) {

#pragma mark - Main Thread
            NSLog(@"---> %@", [NSThread currentThread]);
            
            [_exec performChildBlock:^{
#pragma mark - Created Thread
                NSLog(@"result (%@)", [NSThread currentThread]/*, [NSString stringWithCString:obj.bytes encoding:NSASCIIStringEncoding]*/);
                //NSRunLoop *loop = [NSRunLoop currentRunLoop];
                //NSLog(@"%@", loop);
                //[loop removePort:_port forMode:(NSString*)kCFRunLoopDefaultMode];
                //NSLog(@"%@", loop);
#pragma mark - End of Created Thread
            } onThreadId:threadId waitUntilDone:NO];

            NSLog(@"<---");
#pragma mark - End of Main Thread
        } failure:^(AFHTTPRequestOperation *op, NSError *er) {
            NSLog(@"%@", er);
        }];
        [NSThread sleepForTimeInterval:2];
    } waitUntilDone:NO];
    
    NSLog(@"<<<btn B %@", [NSThread currentThread]);
#pragma mark - End of Created Thread
}

@end
