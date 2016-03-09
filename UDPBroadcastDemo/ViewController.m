//
//  ViewController.m
//  UDPBroadcastDemo
//
//  Created by zloffice on 16/3/9.
//  Copyright © 2016年 fljj. All rights reserved.
//

#import "ViewController.h"
#import "AsyncUDPSocket.h"
#define GBK CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)

@interface ViewController ()
{
    AsyncUdpSocket *asyncSocket;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)sendBroadcast:(id)sender
{
    asyncSocket = [[AsyncUdpSocket alloc]initWithDelegate:self];
    NSError *err = nil;
    [asyncSocket enableBroadcast:YES error:&err];
    if (err) {
        NSLog(@"%@",err);
    }
    [asyncSocket bindToPort:8321 error:&err];
    if (err) {
        NSLog(@"%@",err);
    }
    Byte byte[80];
    for (int i = 0 ; i < 80; i++) {
        byte[i] = 0x00;
    }
    byte[0] = 10;
    for (int i = 1; i < 7; i++) {
        byte[i] = 0xff;
    }
    byte[7] = 0x17;
    NSData *data = [[NSData alloc]initWithBytes:byte length:sizeof(byte)];
    [asyncSocket receiveWithTimeout:2 tag:0];
    [asyncSocket sendData:data toHost:@"255.255.255.255" port:8320 withTimeout:200 tag:0];
}

#pragma mark UDPSocket的代理方法
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"已收到消息");
    NSLog(@"%@",host);
    NSData *objData = [data subdataWithRange:NSMakeRange(1, 6)];
    NSString *str = [[NSString alloc]initWithData:objData encoding:GBK];
    NSLog(@"%@",str);
    [asyncSocket receiveWithTimeout:2 tag:0];
    return YES;
}
//没有接受到消息
-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"没收到");
    [asyncSocket close];
}
//没有发送出消息
-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"消息发送失败！");
}
//已发送出消息
-(void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"消息发送成功");
}
//断开连接
-(void)onUdpSocketDidClose:(AsyncUdpSocket *)sock
{
    NSLog(@"停止搜索");
}

@end
