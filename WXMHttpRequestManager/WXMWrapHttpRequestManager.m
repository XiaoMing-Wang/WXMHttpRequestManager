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
    NSLog(@"-------------->请求接口: %@", path);
#endif
    
    /** 设置请求头 */
    [self configurationNetworkHeader:path];
    
    /** 加密数据 */
    NSDictionary *encry = [self configurationParameters:parameters requestPath:path];
        
    /** 成功回调 */
    NSURLSessionTask *task;
    void (^successBlock)(id) = ^(id response) {
        
#if DEBUG
        NSLog(@"%@ -------->接口返回: \n  %@", path, response);
#endif
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self hidenLoadingWithController:controller];
        
        /** 解密数据 */
        NSDictionary *decrypResponse = [self decryptionResponse:response requestPath:path];
        
        /** 判断请求是否成功(子类实现) */
        BOOL successSign = [self wt_judgeRequestSuccess:decrypResponse];
        
        /** 获取目标key 如data放在data字段里(子类实现) */
        NSString *targetString = [self wt_resultSetTarget];
        
        /** 获取返回的具体参数值 */
        NSDictionary *result = [decrypResponse objectForKey:targetString];
        
        /** 生成Resposeh返回 */
        WXMNetworkRespose *respose = [WXMNetworkRespose resposeWithTask:task response:result error:nil];
        [respose setSuccessfulWithDelivery:successSign];
        
        if (successSign) {
            
            /** 状态码 = 0 */
            [respose setErrorCodeWithCode:0];
            if (success) success(respose);
            
        } else {
            
            /** 设置状态码(子类实现) */
            /** 设置状态码(子类实现) */
            /** 设置状态码(子类实现) */
            NSString *errorCodeKey = [self wt_resultSetErrorCode];
            NSString *errorMessageKey = [self wt_resultSetErrorMessage];
            
            NSString *errorCodeValue = [decrypResponse objectForKey:errorCodeKey ?: @""];
            NSString *errorMessageValue = [decrypResponse objectForKey:errorMessageKey ?: @""];
            [respose setErrorCodeWithCode:errorCodeValue.integerValue];
            [respose setErrorMsg:errorMessageValue];
            
            /** 判断状态码不等于0时是否显示toast(子类实现) */
            /** 判断状态码不等于0时是否显示toast(子类实现) */
            /** 判断状态码不等于0时是否显示toast(子类实现) */
            BOOL disToast = [self wt_judgeErrorMessageWithPath:path result:result controller:controller];
            if (disToast) [self showMessage:controller massage:errorMessageValue];
            
            /** operate表示判断是否回调block(子类实现) */
            /** operate表示判断是否回调block(子类实现) */
            /** operate表示判断是否回调block(子类实现) */
            BOOL operate = [self wt_judgeErrorCodeWithPath:path result:result controller:controller];
            if (failure && operate) failure(respose);
        }
    };
    
    
    /** 失败回调 */
    void (^failBlock)(NSError *) = ^(NSError *error) {
        [self hidenLoadingWithController:controller];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        /** operate判断是否提示网络错误(子类实现) */
        /** operate判断是否提示网络错误(子类实现) */
        /** operate判断是否提示网络错误(子类实现) */
        BOOL operate = [self wt_judgeNetworkErrorWithPath:path controller:controller];
        if (operate) [self showMessage:controller massage:WXMERRORMSG];
        
        WXMNetworkRespose *respose = [WXMNetworkRespose resposeWithTask:task response:nil error:error];
        [respose setErrorCodeWithCode:404];
        if (failure) failure(respose);
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
    
    /** 显示loading */
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
    viewController.view.userInteractionEnabled = YES;
    [self wt_hiddenLoadingWithController:viewController];
    
    if (self.loadingType == WXMHttpLoadingTypeProhibit) {
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
    controller.view.userInteractionEnabled = YES;
    [self wt_showMsgWithController:controller msgl:msg];
}

- (NSMutableDictionary *)gestureDictionary {
    if (!_gestureDictionary) _gestureDictionary = @{}.mutableCopy;
    return _gestureDictionary;
}

@end
