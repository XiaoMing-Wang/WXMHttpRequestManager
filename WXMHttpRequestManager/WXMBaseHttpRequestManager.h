//
//  Created by wq on 16/5/31.
//  Copyright © 2016年 wq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class AFHTTPSessionManager;

typedef NS_ENUM(NSUInteger, WXMNetworkStatus) {
    WXMNetworkStatusUnknown,          /**  未知网络 */
    WXMNetworkStatusNotReachable,     /**  无网络 */
    WXMNetworkStatusReachableViaWWAN, /**  手机网络 */
    WXMNetworkStatusReachableViaWiFi  /**  WIFI网络 */
};

@interface WXMBaseHttpRequestManager : NSObject

/** 获取AFHTTPSessionManager对象 */
+ (AFHTTPSessionManager *)shareAFHTTPSessionManager;

/**
 *  GET请求
 *
 *  @param URL        请求地址
 *  @param parameters 请求参数
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法
 */
+ (__kindof NSURLSessionTask *)GET:(NSString *)URL
                        parameters:(NSDictionary *)parameters
                           success:(void(^)(id responseObject))success
                           failure:(void(^)(NSError *error))failure;

/**
 *  POST请求,无缓存
 *
 *  @param URL        请求地址
 *  @param parameters 请求参数
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法
 */
+ (__kindof NSURLSessionTask *)POST:(NSString *)URL
                         parameters:(NSDictionary *)parameters
                            success:(void(^)(id responseObject))success
                            failure:(void(^)(NSError *error))failure;

/**
 *  上传图片文件
 *
 *  @param URL        请求地址
 *  @param parameters 请求参数
 *  @param images     图片数组
 *  @param name       文件对应服务器上的字段
 *  @param fileName   文件名
 *  @param mimeType   图片文件的类型,例:png、jpeg(默认类型)....
 *  @param progress   上传进度信息
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法
 */

+ (__kindof NSURLSessionTask *)uploadWithURL:(NSString *)URL
                                  parameters:(NSDictionary *)parameters
                                      images:(NSArray<UIImage *> *)images
                                        name:(NSString *)name
                                    fileName:(NSString *)fileName
                                    mimeType:(NSString *)mimeType
                                    progress:(void (^)(NSProgress *progress))progress
                                     success:(void (^)(id responseObject))success
                                     failure:(void (^)(NSError *error))failure;

/**
 *  下载文件
 *
 *  @param URL      请求地址
 *  @param fileDir  文件存储目录(默认存储目录为Download)
 *  @param progress 文件下载的进度信息
 *  @param success  下载成功的回调(回调参数filePath:文件的路径)
 *  @param failure  下载失败的回调
 *
 *  @return 返回NSURLSessionDownloadTask实例，可用于暂停继续，暂停调用suspend方法，开始下载调用resume方法
 */
+ (__kindof NSURLSessionTask *)downloadWithURL:(NSString *)URL
                                       fileDir:(NSString *)fileDir
                                      progress:(void (^)(NSProgress *progress))progress
                                       success:(void (^)(NSString *filePath))success
                                       failure:(void (^)(NSError *error))failure;


/** 网络状态 */
+ (void)checkNetworkStatusWithBlock:(void (^)(WXMNetworkStatus status))statuBlock;
+ (BOOL)currentNetworkStatus;
+ (void)cancelAllOperations;
@end

