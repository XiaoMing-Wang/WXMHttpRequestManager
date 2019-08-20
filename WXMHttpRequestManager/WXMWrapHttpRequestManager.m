//
//  WXMHttpRequestManager.m
//  ModuleDebugging
//
//  Created by edz on 2019/6/24.
//  Copyright © 2019 wq. All rights reserved.
//
#import "WXMWrapHttpRequestManager.h"
@interface WXMWrapHttpRequestManager () <WXMHttpRequestProtocol>
@property (nonatomic, strong) NSMutableDictionary *gestureDictionary;
@end

@implementation WXMWrapHttpRequestManager

+ (WXMWrapHttpRequestManager *)shareDisplay {
    static WXMWrapHttpRequestManager *manageDisplay = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manageDisplay = [[self alloc] init];
        manageDisplay.loadingType = WXMHttpLoadingTypeDisplay;
    });
    return manageDisplay;
}

+ (WXMWrapHttpRequestManager *)shareNone {
    static WXMWrapHttpRequestManager *manageNone = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manageNone = [[self alloc] init];
        manageNone.loadingType = WXMHttpLoadingTypeNone;
    });
    return manageNone;
}

+ (WXMWrapHttpRequestManager *)shareMandatory {
    static WXMWrapHttpRequestManager *manageMandatory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manageMandatory = [[self alloc] init];
        manageMandatory.loadingType = WXMHttpLoadingTypeMandatory;
    });
    return manageMandatory;
}

+ (WXMWrapHttpRequestManager *)shareProhibit {
    static WXMWrapHttpRequestManager *manageProhibit = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manageProhibit = [[self alloc] init];
        manageProhibit.loadingType = WXMHttpLoadingTypeProhibit;
    });
    return manageProhibit;
}

/** 设置请求头 */
- (void)configurationNetworkHeader:(NSString *)path {
    AFHTTPSessionManager *sessionManager = [[self class] shareAFHTTPSessionManager];
    [sessionManager.requestSerializer setValue:@"" forHTTPHeaderField:@""];
}

/** 参数加密 */
- (NSDictionary *)configurationParameters:(NSDictionary *)parameters path:(NSString *)path {
    return parameters;
}

/** 响应解密 */
- (NSDictionary *)decryptionResponse:(NSDictionary *)parameters path:(NSString *)path {
    return parameters;
}

/** get 直接使用 */
- (void)pullDataWithPath:(NSString *)path
              parameters:(nullable NSDictionary *)parameters
          viewController:(nullable UIViewController *)controller
                 success:(nullable void (^)(WXMNetworkRespose *respose))success
                 failure:(nullable void (^)(WXMNetworkRespose *respose))failure {
    
    [self baseRequestWithPath:path
                  requestType:WXMHttpRequestTypeGet
                   parameters:parameters
               viewController:controller
                      success:success
                      failure:failure];
}

/** post 直接使用 */
- (void)requestWithPath:(NSString *)path
             parameters:(nullable NSDictionary *)parameters
         viewController:(nullable UIViewController *)controller
                success:(nullable void (^)(WXMNetworkRespose *respose))success
                failure:(nullable void (^)(WXMNetworkRespose *respose))failure {
    
    [self baseRequestWithPath:path
                  requestType:WXMHttpRequestTypePost
                   parameters:parameters
               viewController:controller
                      success:success
                      failure:failure];
}

/** 根请求 */
- (void)baseRequestWithPath:(NSString *)path
                requestType:(WXMHttpRequestType)requestType
                 parameters:(nullable NSDictionary *)parameters
             viewController:(nullable UIViewController *)controller
                    success:(nullable void (^)(WXMNetworkRespose *respose))success
                    failure:(nullable void (^)(WXMNetworkRespose *respose))failure {
    
    if (!path) return;
    [self showLoadingWithController:controller];
    
#if DEBUG
    NSLog(@"--------------> %@", path);
#endif
    
    /** 设置请求头 */
    [self configurationNetworkHeader:path];
    
    /** 加密数据 */
    NSDictionary *encry = [self configurationParameters:parameters requestPath:path];
    
    
    /** 成功回调 */
    NSURLSessionTask *task;
    void (^successBlock)(id) = ^(id response) {
        
#if DEBUG
        NSLog(@"%@ --------> \n  %@",path,response);
#endif
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self hidenLoadingWithController:controller];
        
        /** 解密数据 */
        NSDictionary * decrypResponse = [self decryptionResponse:response requestPath:path];
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
    };
    
    
    /** 失败回调 */
    void (^failBlock)(NSError *) = ^(NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self hidenLoadingWithController:controller];
        [self showMessage:controller massage:WXMERRORMSG];
        WXMNetworkRespose *resp = [WXMNetworkRespose resposeWithTask:task response:nil error:error];
        if (failure) failure(resp);
    };
    
    
    /** 不同的请求 */
    if (requestType == WXMHttpRequestTypePost) {
        task = [self.class POST:path parameters:encry success:successBlock failure:failBlock];
    } else if (requestType == WXMHttpRequestTypeGet) {
        task = [self.class GET:path parameters:encry  success:successBlock failure:failBlock];
    }
}

/** 显示弹窗 */
- (void)showLoadingWithController:(UIViewController *)viewController {
    if (!viewController) return;
    if (self.loadingType == WXMHttpLoadingTypeNone) {
        [self hidenLoadingWithController:viewController];
        return;
    }
    
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
    if (!viewController) return;
    if (self.loadingType == WXMHttpLoadingTypeNone) {
        viewController.view.userInteractionEnabled = YES;
        return;
    }
    
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
