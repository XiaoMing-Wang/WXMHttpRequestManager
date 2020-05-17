//
//  WXMHttpRequestManager.h
//  ModuleDebugging
//
//  Created by edz on 2019/6/24.
//  Copyright © 2019 wq. All rights reserved.

#import "WXMNetworkRespose.h"
#import "WXMHttpConfigurationFile.h"
#import "WXMBaseHttpRequestManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WXMHttpRequestType) {
    
    /** GET */
    WXMHttpRequestTypeGet = 0,
    
    /** POST */
    WXMHttpRequestTypePost,
};

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

@interface WXMWrapHttpRequestManager : WXMBaseHttpRequestManager

/** 属性 */
@property (nonatomic, assign) WXMHttpLoadingType loadingType;

/** 没有弹窗 */
+ (__kindof WXMWrapHttpRequestManager *)shareNone;

/** 有弹窗可操作 */
+ (__kindof WXMWrapHttpRequestManager *)shareDisplay;

/** 有弹窗不可操作 */
+ (__kindof WXMWrapHttpRequestManager *)shareMandatory;

/** 有弹窗不可操作(手势也关闭) */
+ (__kindof WXMWrapHttpRequestManager *)shareProhibit;

/** 设置响应头 子类实现 */
- (void)configurationNetworkHeader:(NSString *)path;


/** 参数加密 子类实现 */
- (NSDictionary *)configurationParameters:(NSDictionary *)parameters requestPath:(NSString *)path;


/** 响应解密 子类实现 */
- (NSDictionary *)decryptionResponse:(NSDictionary *)parameters requestPath:(NSString *)path;

/// post 直接使用
/// @param path 请求路径
/// @param parameters 参数
/// @param controller 显示toast的控制器
/// @param success 成功回调(表示网络请求成功 不代表状态码为0)
/// @param failure 断网 失败 404
- (void)requestWithPath:(NSString *)path
             parameters:(nullable NSDictionary *)parameters
         viewController:(nullable UIViewController *)controller
                success:(nullable void (^)(WXMNetworkRespose *respose))success
                failure:(nullable void (^)(WXMNetworkRespose *respose))failure;

/// get 直接使用
/// @param path 请求路径
/// @param parameters 参数
/// @param controller 显示toast的控制器
/// @param success 成功回调(表示网络请求成功 不代表状态码为0)
/// @param failure 断网 失败 404
- (void)pullDataWithPath:(NSString *)path
              parameters:(nullable NSDictionary *)parameters
          viewController:(nullable UIViewController *)controller
                 success:(nullable void (^)(WXMNetworkRespose *respose))success
                 failure:(nullable void (^)(WXMNetworkRespose *respose))failure;

@end

NS_ASSUME_NONNULL_END
