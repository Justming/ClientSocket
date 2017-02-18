//
//  ViewController.m
//  ClientSocket
//
//  Created by Huasheng on 2017/2/18.
//  Copyright © 2017年 Huasheng. All rights reserved.
//

#import "ViewController.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

#define HOST @"127.0.0.1"
#define PORT 6666

@interface ViewController ()

@property (nonatomic, assign) int clientSocket;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    [self createUI];
    
    
    //创建socket，建立连接
    //发送数据
    //接收数据
    //关闭连接
    
    
}

- (void)createUI{
    
    UIButton * connect = [UIButton buttonWithType:UIButtonTypeSystem];
    connect.frame = CGRectMake(100, 100, 100, 50);
    connect.center = CGPointMake(self.view.bounds.size.width/2, 100);
    [connect setTitle:@"连接" forState:UIControlStateNormal];
    [connect addTarget:self action:@selector(connect:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:connect];
    
    
    UIButton * send = [UIButton buttonWithType:UIButtonTypeSystem];
    send.frame = CGRectMake(100, 200, 100, 50);
    send.center = CGPointMake(self.view.bounds.size.width/2, 200);
    [send setTitle:@"发送" forState:UIControlStateNormal];
    [send addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:send];

    UIButton * receive = [UIButton buttonWithType:UIButtonTypeSystem];
    receive.frame = CGRectMake(100, 300, 100, 50);
    receive.center = CGPointMake(self.view.bounds.size.width/2, 300);
    [receive setTitle:@"接收" forState:UIControlStateNormal];
    [receive addTarget:self action:@selector(receiveMessage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:receive];
    
    
    UIButton * close = [UIButton buttonWithType:UIButtonTypeSystem];
    close.frame = CGRectMake(100, 400, 100, 50);
    close.center = CGPointMake(self.view.bounds.size.width/2, 400);
    [close setTitle:@"关闭" forState:UIControlStateNormal];
    [close addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:close];
    

}
//连接
- (void)connect:(UIButton *)btn{
    
    if([self createSocketAndConnection:HOST port:PORT]){
        [self send:@"first send"];
    }
}
//发送
- (void)sendMessage:(UIButton *)btn{
    
    [self send:@"hello"];
}
//接收（阻塞式，一直等待服务器端数据）
- (void)receiveMessage:(UIButton *)btn{
   
    NSLog(@"%@", [self receive]);
    
}
//关闭
- (void)close:(UIButton *)btn{
    
    [self closeConnection];
}

//创建socket，建立连接
- (BOOL)createSocketAndConnection:(NSString *)host port:(int)port
{
    // socket
    /**
     参数
     domain:    协议域，AF_INET（IPV4的网络开发）
     type:      Socket 类型，SOCK_STREAM(TCP)/SOCK_DGRAM(UDP，报文)
     protocol:  IPPROTO_TCP，协议，如果输入0，可以根据第二个参数，自动选择协议
     
     返回值
     socket，如果 > 0 就表示成功
     */
    self.clientSocket = socket(AF_INET, SOCK_STREAM, 0);
    if (self.clientSocket > 0) {
        NSLog(@"客户端socket创建成功，%d", self.clientSocket);
    }else{
        NSLog(@"socket创建失败");
    }
    
    
    //connection 连接到“服务器”
    /**
     参数
     1> 客户端socket
     2> 指向数据结构sockaddr的指针，其中包括目的端口和IP地址
     服务器的"结构体"地址，C语言没有对象
     3> 结构体数据长度
     返回值
     0 成功/其他 错误代号，非0即真
     */
    
    struct sockaddr_in serverAddress;
    //IPV4协议
    serverAddress.sin_family = AF_INET;
    // inet_addr函数可以把ip地址转换成一个整数
    serverAddress.sin_addr.s_addr = inet_addr(host.UTF8String);
    // 端口小端存储
    serverAddress.sin_port = htons(port);
    
    int result = connect(self.clientSocket, (const struct sockaddr *)&serverAddress, sizeof(serverAddress));
    
    NSLog(@"%d", result);
    
    
    return (result == 0);
}
//发送数据
- (void)send:(NSString *)message {
    
    // send发送
    /**
     参数
     1> 客户端socket
     2> 发送内容地址 void * == id
     3> 发送内容长度
     4> 发送方式标志，一般为0
     返回值
     如果成功，则返回发送的字节数，失败则返回SOCKET_ERROR
     */
    ssize_t sendLen = send(self.clientSocket, message.UTF8String, strlen(message.UTF8String), 0);
    NSLog(@"%ld", sendLen);

}
//接收数据
- (NSString *)receive{
    
    // recv 接收 - 几乎所有的网络访问，都是有来有往的
    /**
     参数
     第一个int :创建的socket
     void *：接收内容的地址
     size_t：接收内容的长度
     第二个int.：接收数据的标记 0，就是阻塞式，一直等待服务器的数据
     返回值 接收到的数据长度
     */
    // unsigned char 字符串数组，接收信息
    uint8_t buffer[1024];
    
    ssize_t recvLen = recv(self.clientSocket, buffer, sizeof(buffer), 0);
    
    // 从buffer中读取服务器发回的数据
    // 按照服务器返回的长度，从 buffer 中，读取二进制数据，建立 NSData 对象
    NSData * data = [NSData dataWithBytes:buffer length:recvLen];
    NSString * str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}
//关闭连接
- (void)closeConnection{
    close(self.clientSocket);
}


@end
