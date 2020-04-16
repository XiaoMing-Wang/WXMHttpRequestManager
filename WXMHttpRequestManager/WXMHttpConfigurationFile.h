//
//  WXMHttpConfigurationFile.h
//  ModuleDebugging
//
//  Created by edz on 2019/6/24.
//  Copyright © 2019 wq. All rights reserved.
//

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

#endif /* WXMHttpConfigurationFile_h */
