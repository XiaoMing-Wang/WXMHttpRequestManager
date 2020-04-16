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

/** 获取对象 WXMWrapHttpRequestManager不是单例 持有的AFHTTPSessionManager才是单例 */
+ (__kindof WXMWrapHttpRequestManager *)shareNone;
+ (__kindof WXMWrapHttpRequestManager *)shareDisplay;
+ (__kindof WXMWrapHttpRequestManager *)shareMandatory;
+ (__kindof WXMWrapHttpRequestManager *)shareProhibit;

/** 设置响应头 */
- (void)configurationNetworkHeader:(NSString *)path;


/** 参数加密 */
- (NSDictionary *)configurationParameters:(NSDictionary *)parameters requestPath:(NSString *)path;


/** 响应解密 */
- (NSDictionary *)decryptionResponse:(NSDictionary *)parameters requestPath:(NSString *)path;


/** post 直接使用 */
- (void)requestWithPath:(NSString *)path
             parameters:(nullable NSDictionary *)parameters
         viewController:(nullable UIViewController *)controller
                success:(nullable void (^)(WXMNetworkRespose *respose))success
                failure:(nullable void (^)(WXMNetworkRespose *respose))failure;


/** get 直接使用 */
- (void)pullDataWithPath:(NSString *)path
              parameters:(nullable NSDictionary *)parameters
          viewController:(nullable UIViewController *)controller
                 success:(nullable void (^)(WXMNetworkRespose *respose))success
                 failure:(nullable void (^)(WXMNetworkRespose *respose))failure;

@end

NS_ASSUME_NONNULL_END
