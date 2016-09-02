//
//  ViewController.m
//  UDPServer
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
    // 服务器  127.0.0.1  6666
    if (![self.socket bindToPort:6666 error:&error]) {     // 端口绑定
        NSLog(@"bindToPort: %@", error);
        return ;
    }
    if (![self.socket beginReceiving:&error]) {     // 开始监听
        NSLog(@"beginReceiving: %@", error);
        return ;
    }
    NSLog(@"开启成功");

    // 客户端  127.0.0.1  5555
    if (![self.socket connectToHost:@"127.0.0.1" onPort:5555 error:&error]) {   // 连接客户端
        NSLog(@"连接失败：%@", error);
        return ;
    }
}

// 发送
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    NSLog(@"发送成功");
}

// 收到
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(nullable id)filterContext {
    NSString *dat = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"收到：%@", dat);
    
    // 回复消息
    NSString *str = @"服务器收到你的消息";
    NSData *d = [str dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket sendData:d withTimeout:-1 tag:10];
    [self.socket sendData:d withTimeout:-1 tag:10];
    [self.socket sendData:d withTimeout:-1 tag:10];
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error {
    NSLog(@"关闭连接");
}

- (void)dealloc {
    [self.socket close];
}

@end

