//
//  WXMHttpConfigurationFile.h
//  ModuleDebugging
//
//  Created by edz on 2019/6/24.
//  Copyright © 2019 wq. All rights reserved.
//
#define WXMERRORMSG @"无法连接网络，请检查网络配置"
#ifndef WXMHttpConfigurationFile_h
#define WXMHttpConfigurationFile_h
#import <AFNetworking.h>
#import <Foundation/Foundation.h>

/** 线上 */
static NSString *const KURLStringOnline = @"";

/** 测试 */
static NSString *const KURLStringTest = @"";

/** 开发 */
static NSString *const KURLStringDevelopment = @"";


/** 开发环境 */
static inline NSURL *WXMCurrentEnvironment(void) {
    return [NSURL URLWithString:KURLStringOnline];
    /** return [NSURL URLWithString:KURLStringTest]; */
    /** return [NSURL URLWithString:KURLStringDevelopment]; */
}


/** 默认Manager */
static inline AFHTTPSessionManager *WXMDefaultManager() {
    NSURL * baseUrl = WXMCurrentEnvironment();
    NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseUrl
                                                             sessionConfiguration:conf];
    manager.operationQueue.maxConcurrentOperationCount = 10;
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setTimeoutInterval:30];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                         @"application/json",
                                                         @"text/json",
                                                         @"text/javascript",
                                                         @"text/html",
                                                         @"text/plain", nil];
    
#if DEBUG
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
#endif
    return manager;
}


/** 子类必须实现 */
@protocol WXMHttpRequestProtocol <NSObject>
@required

/** 显示弹窗 */
- (void)wt_showLoadingWithController:(UIViewController *)controller;
- (void)wt_hiddenLoadingWithController:(UIViewController *)controller;
- (void)wt_showMsgWithController:(UIViewController *)controller msgl:(NSString *)msg;

/** 判断请求是否成功 状态码是否是0 */
- (BOOL)wt_judgeRequestSuccess:(NSDictionary *)responseObj;

/** 返回结果的目标key */
- (NSString *)wt_resultSetTarget;

/** 处理异常情况 BOOL代表是否允许block继续回调 */
- (BOOL)wt_judgeErrorCodeWithPath:(NSString *)path
                           result:(NSDictionary *)result
                       controller:(UIViewController *)controller;
@end

#endif /* WXMHttpConfigurationFile_h */
