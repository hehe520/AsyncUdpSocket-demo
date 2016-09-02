//
//  ViewController.m
//  UDPClient
//
//  Created by caokun on 16/8/25.
//  Copyright © 2016年 caokun. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncUdpSocket.h"

@interface ViewController () <GCDAsyncUdpSocketDelegate>

@property (strong, nonatomic) GCDAsyncUdpSocket *socket;
@property (strong, nonatomic) dispatch_queue_t delegateQueue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegateQueue = dispatch_queue_create("socket.com", DISPATCH_QUEUE_CONCURRENT);
    self.socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:self.delegateQueue];
    
    NSError *error = nil;
    // 客户端  127.0.0.1  5555
    if (![self.socket bindToPort:5555 error:&error]) {     // 端口绑定
        NSLog(@"bindToPort: %@", error);
        return ;
    }
    if (![self.socket beginReceiving:&error]) {     // 开始监听
        NSLog(@"beginReceiving: %@", error);
        return ;
    }
    
    // 服务器  127.0.0.1  6666
    if (![self.socket connectToHost:@"127.0.0.1" onPort:6666 error:&error]) {   // 连接服务器
        NSLog(@"连接失败：%@", error);
        return ;
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    NSLog(@"连接成功");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    NSLog(@"发送成功");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    NSLog(@"发送失败 %@", error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSString *dat = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"收到回复：%@", dat);
}

- (IBAction)sendAction:(id)sender {
    NSString *str = @"hello world";
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.socket sendData:data withTimeout:-1 tag:10];      // 发送
}

@end

