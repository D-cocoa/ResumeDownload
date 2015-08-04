//
//  ViewController.m
//  ResumeDownload
//
//  Created by YouXianMing on 15/6/30.
//  Copyright (c) 2015年 YouXianMing. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "AFDownloadRequestOperation.h"
#import "GCD.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* 使用NSURLConnection实现大文件断点下载
     * http://www.cnblogs.com/YouXianMing/p/3709409.html
     */
    
    NSLog(@"%@", [NSHomeDirectory() stringByAppendingPathComponent:nil]);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://29.duote.org/antiarp.zip"]];
    AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:request
                                                                                 fileIdentifier:@"network.zip"
                                                                                     targetPath:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Caches/network.zip"]
                                                                                   shouldResume:YES];
    operation.shouldOverwrite = YES;
    
    
    // 开始下载
    [operation start];
    
    // 4s后暂停
    [GCDQueue executeInMainQueue:^{
        NSLog(@"暂停");
        [operation pause];
    } afterDelaySecs:4.f];
    
    // 7s后继续恢复
    [GCDQueue executeInMainQueue:^{
        NSLog(@"开始");
        [operation resume];
    } afterDelaySecs:7.f];
    
    // 查看下载进度
    [operation setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
        
        CGFloat percent = (float)totalBytesReadForFile / (float)totalBytesExpectedToReadForFile;
        NSLog(@"百分比:%.3f%% %ld  %lld  %lld  %lld", percent * 100, (long)bytesRead, totalBytesRead, totalBytesReadForFile, totalBytesExpectedToReadForFile);
    }];
    
    // 结束block
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"下载成功 %@", responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"下载失败 %@", error);
        
    }];
}

@end
