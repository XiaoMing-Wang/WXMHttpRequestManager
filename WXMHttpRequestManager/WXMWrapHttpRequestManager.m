//
//  WXMHttpRequestManager.m
//  ModuleDebugging
//
//  Created by edz on 2019/6/24.
//  Copyright © 2019 wq. All rights reserved.
//
#define WXMERRORMSG @"无法连接网络，请检查网络配置"
#import "WXMWrapHttpRequestManager.h"
@interface WXMWrapHttpRequestManager () <WXMHttpRequestProtocol>
@property (nonatomic, strong) NSMutableDictionary *gestureDictionary;
@end

@implementation WXMWrapHttpRequestManager

+ (WXMWrapHttpRequestManager *)shareDisplay {
    static WXMWrapHttpRequestManager *manage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manage = [[self alloc] init];
        manage.loadingType = WXMHttpLoadingTypeDisplay;
    });
    return manage;
}

+ (WXMWrapHttpRequestManager *)shareNone {
    static WXMWrapHttpRequestManager *manage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manage = [[self alloc] init];
        manage.loadingType = WXMHttpLoadingTypeNone;
    });
    return manage;
}

+ (WXMWrapHttpRequestManager *)shareMandatory {
    static WXMWrapHttpRequestManager *manage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manage = [[self alloc] init];
        manage.loadingType = WXMHttpLoadingTypeMandatory;
    });
    return manage;
}

+ (WXMWrapHttpRequestManager *)shareProhibit {
    static WXMWrapHttpRequestManager *manage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manage = [[self alloc] init];
        manage.loadingType = WXMHttpLoadingTypeProhibit;
    });
    return manage;
}

/** 设置请求头 */
- (void)configurationNetworkHeader:(NSString *)path {
    AFHTTPSessionManager *sessionManager = [[self class] shareAFHTTPSessionManager];
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
    if (controller) [self showLoadingWithController:controller];
    
    /** 设置请求头 */
    [self configurationNetworkHeader:path];
    
    /** 加密数据 */
    NSDictionary*encryParameters =  [self configurationParameters:parameters];
    
    __block NSURLSessionTask *task;
    task = [self.class POST:path parameters:encryParameters success:^(id response) {
        
        NSLog(@"%@ --------> \n  %@",path,response);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (controller) [self hidenLoadingWithController:controller];
        
        /** 解密数据 */
        NSDictionary * decrypResponse = [self decryptionResponse:response];
        BOOL successSign = [self wt_judgeRequestSuccess:decrypResponse];
        NSString *targetString = [self wt_resultSetTarget];
        NSDictionary * result = [decrypResponse objectForKey:targetString];
        WXMNetworkRespose *res = [WXMNetworkRespose resposeWithTask:task response:result error:nil];
        [res setSuccessfulWithDelivery:successSign];
        
        if (successSign) {
            if (success) success(res);
        } else {
            BOOL fee = [self wt_judgeErrorCodeWithPath:path result:result controller:controller];
            if (success && fee) success(res);
        }
        
    } failure:^(NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (controller) [self hidenLoadingWithController:controller];
        if (controller) [self showMessage:controller massage:WXMERRORMSG];
        WXMNetworkRespose *resp = [WXMNetworkRespose resposeWithTask:task
                                                            response:nil
                                                               error:error];
        if (failure) failure(resp);
    }];
}

/** 显示弹窗 */
- (void)showLoadingWithController:(UIViewController *)viewController {
    if (self.loadingType == WXMHttpLoadingTypeNone) return;
    
    [self wt_showLoadingWithController:viewController];
    if (self.loadingType == WXMHttpLoadingTypeMandatory) {
        viewController.view.userInteractionEnabled = NO;
    } else if (self.loadingType == WXMHttpLoadingTypeProhibit) {
        viewController.view.userInteractionEnabled = NO;
        if (!viewController.navigationController) return;
        BOOL inter = viewController.navigationController.interactivePopGestureRecognizer.enabled;
        NSInteger hash = viewController.hash;
        [self.gestureDictionary setObject:@(inter) forKey:@(hash)];
        viewController.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

/** 隐藏弹窗 */
- (void)hidenLoadingWithController:(UIViewController *)viewController {
    if (self.loadingType == WXMHttpLoadingTypeNone) return;
    
    [self wt_hiddenLoadingWithController:viewController];
    if (self.loadingType == WXMHttpLoadingTypeMandatory) {
        viewController.view.userInteractionEnabled = YES;
    } else if (self.loadingType == WXMHttpLoadingTypeProhibit) {
        viewController.view.userInteractionEnabled = YES;
        if (!viewController.navigationController) return;
        NSInteger hash = viewController.hash;
        if ([self.gestureDictionary.allKeys containsObject:@(hash)]) {
            BOOL inter = [[self.gestureDictionary objectForKey:@(hash)] boolValue];
            viewController.navigationController.interactivePopGestureRecognizer.enabled = inter;
        }
    }
}

/** 显示massage */
- (void)showMessage:(UIViewController *)controller massage:(NSString *)msg {
    [self wt_showMsgWithController:controller msgl:msg];
}

- (NSMutableDictionary *)gestureDictionary {
    if (!_gestureDictionary) _gestureDictionary = @{}.mutableCopy;
    return _gestureDictionary;
}

@end
