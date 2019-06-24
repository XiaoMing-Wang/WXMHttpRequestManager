//
//  WXMHttpRequestManager.h
//  ModuleDebugging
//
//  Created by edz on 2019/6/24.
//  Copyright © 2019 wq. All rights reserved.

#import "WXMHttpRequestHeader.h"
#import "WXMBaseHttpRequestManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WXMHttpLoadingType) {
    
    /** 显示可交互 */
    WXMHttpLoadingTypeDisplay = 0,
    
    /** 不显示 */
    WXMHttpLoadingTypeNone,
    
    /** 显示不可交互 */
    WXMHttpLoadingTypeMandatory,
    
    /** 显示不可交互且关闭手势 */
    WXMHttpLoadingTypeProhibit,
};

/** 子类必须实现这几个协议 */
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


@interface WXMWrapHttpRequestManager : WXMBaseHttpRequestManager

/** 属性 */
@property (nonatomic, assign) WXMHttpLoadingType loadingType;

/** 单例 */
+ (__kindof WXMWrapHttpRequestManager *)shareNone;
+ (__kindof WXMWrapHttpRequestManager *)shareDisplay;
+ (__kindof WXMWrapHttpRequestManager *)shareMandatory;
+ (__kindof WXMWrapHttpRequestManager *)shareProhibit;

/** 设置响应头 */
- (void)configurationNetworkHeader:(NSString *)path;

/** 参数加密 */
- (NSDictionary *)configurationParameters:(NSDictionary *)parameters;

/** 响应解密 */
- (NSDictionary *)decryptionResponse:(NSDictionary *)parameters;

/** post 直接使用 */
- (void)requestWithPath:(NSString *)path
             parameters:(nullable NSDictionary *)parameters
         viewController:(nullable UIViewController *)controller
                success:(nullable void (^)(WXMNetworkRespose *resposeObj))success
                failure:(nullable void (^)(WXMNetworkRespose *resposeObj))failure;
@end

NS_ASSUME_NONNULL_END
