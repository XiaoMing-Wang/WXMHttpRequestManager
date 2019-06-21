//
//  WXMHttpRequestManager+Operation.m
//
//  Created by edz on 2019/4/29.
//  Copyright © 2019年 wq. All rights reserved.
//
#define ERRORMSG @"无法连接网络，请检查网络配置"
#import "UIViewController+MBProgressHUD.h"
#import "WXMHttpRequestManager+Operation.h"
#import <objc/runtime.h>

@implementation WXMHttpRequestManager (Operation)

+ (WXMHttpRequestManager *)shareManage {
    static WXMHttpRequestManager *manage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manage = [WXMHttpRequestManager new];
        manage.showMB = YES;
    });
    return manage;
}

+ (WXMHttpRequestManager *)shareNoMB {
    static WXMHttpRequestManager *noMB = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        noMB = [WXMHttpRequestManager new];
        noMB.showMB = NO;
    });
    return noMB;
}

/** 设置请求头 */
- (void)configurationNetworkHeader:(NSString *)path {
    AFHTTPSessionManager *sessionManager = [WXMHttpRequestManager shareAFHTTPSessionManager];
    [sessionManager.requestSerializer setValue:@"" forHTTPHeaderField:@""];
}

/** 参数加密 */
- (NSDictionary *)configurationParameters:(NSDictionary *)parameters {
    return parameters;
}

/** 响应解密 */
- (NSDictionary *)decryptionResponse:(NSDictionary *)parameters {
    return parameters;
}

/** post 直接使用 */
- (void)requestWithPath:(NSString *)path
             parameters:(nullable NSDictionary *)parameters
         viewController:(nullable UIViewController *)controller
                success:(nullable void (^)(WXMNetworkRespose *resposeObj))success
                failure:(nullable void (^)(WXMNetworkRespose *resposeObj))failure {
    NSDictionary * par = parameters;
    UIViewController * vc = controller;
    [self baseRequestWithPath:path parameters:par viewController:vc success:success failure:failure];
}

/** 根请求 */
- (void)baseRequestWithPath:(NSString *)path
                 parameters:(nullable NSDictionary *)parameters
             viewController:(nullable UIViewController *)controller
                    success:(nullable void (^)(WXMNetworkRespose *resposeObj))success
                    failure:(nullable void (^)(WXMNetworkRespose *resposeObj))failure {
    
    if (!path) return;
    if (controller && self.showMB) [controller showLoadingImage];
    
    [self configurationNetworkHeader:path];/** 设置请求头 */
    NSDictionary*encryParameters =  [self configurationParameters:parameters]; /** 加密数据 */
    
    __block NSURLSessionTask *task;
    task = [self.class POST:path parameters:encryParameters success:^(id response) {
        
        NSLog(@"%@ --------> \n  %@",path,response);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (controller && self.showMB) [controller hideLoadingImage];

        /** 自定义判断 */
        id decrypResponse = [self decryptionResponse:response];
        NSDictionary * result = [decrypResponse objectForKey:ResultSet];
        NSString * errorCode = [result objectForKey:ErrorCode];
        
        if ([errorCode isEqualToString:@"0"]) {
            WXMNetworkRespose *res = [[WXMNetworkRespose alloc] initWithTask:task response:result error:nil];
            if (success) success(res);
        } else {
            [self abnormalWithPath:path result:result viewController:controller success:success];
        }
        
    } failure:^(NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (controller && self.showMB) [controller hideLoadingImage];
        if (controller) [controller showMBProgressMessage:ERRORMSG];
        WXMNetworkRespose *resp = [[WXMNetworkRespose alloc] initWithTask:task response:nil error:error];
        if (failure) failure(resp);
    }];
}

/** 异常情况 */
- (void)abnormalWithPath:(NSString *)path
                  result:(NSDictionary *)result
          viewController:(nullable UIViewController *)controller
                 success:(nullable void (^)(WXMNetworkRespose *resposeObj))success {
    
    NSString * errorCode = [result objectForKey:ErrorCode];
    NSString * errorMsg = [result objectForKey:ERRORMSG];
    if ([errorCode isEqualToString:@""]) {
    } else if ([errorCode isEqualToString:@""]) {
    } else {
        if (controller) [controller showMBProgressMessage:errorMsg];
        WXMNetworkRespose *res = [[WXMNetworkRespose alloc] initWithTask:nil response:result error:nil];
        if (success) success(res);
    }
}

#pragma mark____________________________________________________________ Lazy

- (void)setShowMB:(BOOL)showMB {
    objc_setAssociatedObject(self, @selector(showMB), @(showMB), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)showMB {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
@end
