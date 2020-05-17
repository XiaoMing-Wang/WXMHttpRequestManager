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
static NSString *const kURLStringOnline = @"";

/** 测试 */
static NSString *const kURLStringTest = @"";

/** 开发 */
static NSString *const kURLStringDevelopment = @"";

/** 开发环境 */
static inline NSURL *kCurrentEnvironment(void) {
    return [NSURL URLWithString:kURLStringOnline];
    /** return [NSURL URLWithString:KURLStringTest]; */
    /** return [NSURL URLWithString:KURLStringDevelopment]; */
}

/** 默认Manager */
static inline AFHTTPSessionManager *kDefaultManager(void) {
    NSURL * baseUrl = kCurrentEnvironment();
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseUrl
                                                             sessionConfiguration:configuration];
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

/** 判断请求是否成功 例如状态码是否是0 */
/** 判断请求是否成功 例如状态码是否是0 */
/** 判断请求是否成功 例如状态码是否是0 */
- (BOOL)wt_judgeRequestSuccess:(NSDictionary *)responseObj;

/** 返回结果的目标key 例如数据可能存在data字段或者results字段里 */
/** 返回结果的目标key 例如数据可能存在data字段或者results字段里 */
/** 返回结果的目标key 例如数据可能存在data字段或者results字段里 */
- (NSString *)wt_resultSetTarget;

/** errorCode和errorMessage字段 */
- (NSString *)wt_resultSetErrorCode;
- (NSString *)wt_resultSetErrorMessage;

/** 处理异常情况 BOOL代表是否允许block继续回调 */
/** 处理异常情况 BOOL代表是否允许block继续回调 */
/** 处理异常情况 BOOL代表是否允许block继续回调 */
- (BOOL)wt_judgeErrorCodeWithPath:(NSString *)path
                           result:(NSDictionary *)result
                       controller:(UIViewController *)controller;

/** 判断是状态码不为0是否显示toast */
/** 判断是状态码不为0是否显示toast */
/** 判断是状态码不为0是否显示toast */
- (BOOL)wt_judgeErrorMessageWithPath:(nonnull NSString *)path
                              result:(nonnull NSDictionary *)result
                          controller:(nonnull UIViewController *)controller;

/** 判断是断网时是否提示失败 */
/** 判断是断网时是否提示失败 */
/** 判断是断网时是否提示失败 */
- (BOOL)wt_judgeNetworkErrorWithPath:(NSString *)path controller:(UIViewController *)controller;

@end

#endif /* WXMHttpConfigurationFile_h */
