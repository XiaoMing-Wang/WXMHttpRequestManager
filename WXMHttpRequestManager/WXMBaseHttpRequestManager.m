//
//  Created by wq on 16/5/31.
//  Copyright © 2016年 wq. All rights reserved.
//
#define STask NSURLSessionDataTask
#define KLibraryboxPath \
NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject

#import "AFNetworking.h"
#import "WXMNetworkRespose.h"
#import "WXMWrapHttpRequestManager.h"
#import "WXMHttpConfigurationFile.h"

/** 是否有网 */
static BOOL _isNetwork;
static AFHTTPSessionManager *_manager;
@implementation WXMBaseHttpRequestManager

/* get */
+ (__kindof NSURLSessionTask *)GET:(NSString *)URL
                        parameters:(NSDictionary *)parameters
                           success:(void(^)(id responseObject))success
                           failure:(void(^)(NSError *error))failure {
    
    AFHTTPSessionManager *manager = [self shareAFHTTPSessionManager];
    return [manager GET:URL parameters:parameters progress:nil success:^(STask *task, id resp) {
        
        if (success) success([self jsonObjectWithData:resp]);
        
    } failure:^(NSURLSessionDataTask *task, NSError * error) { if (failure) failure(error);}];
}

/* post */
+ (__kindof NSURLSessionTask *)POST:(NSString *)URL
                         parameters:(NSDictionary *)parameters
                            success:(void(^)(id responseObject))success
                            failure:(void(^)(NSError *error))failure {
    AFHTTPSessionManager *manager = [self shareAFHTTPSessionManager];
    return [manager POST:URL parameters:parameters progress:nil success:^(STask *task, id resp) {
        
        if (success) success([self jsonObjectWithData:resp]);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) { if (failure) failure(error); }];
}

/** 转换 */
+ (id)jsonObjectWithData:(id)response {
    return [NSJSONSerialization JSONObjectWithData:response
                                           options:NSJSONReadingMutableContainers
                                             error:nil];
}

#pragma mark _________________________________________________________ 上传图片

+ (__kindof NSURLSessionTask *)uploadWithURL:(NSString *)URL
                                  parameters:(NSDictionary *)parameters
                                      images:(NSArray<UIImage *> *)images
                                        name:(NSString *)name
                                    fileName:(NSString *)fileName
                                    mimeType:(NSString *)mimeType
                                    progress:(void (^)(double progress))progress
                                     success:(void (^)(id responseObject))success
                                     failure:(void (^)(NSError *error))failure {
    
    AFHTTPSessionManager *manager = [self shareAFHTTPSessionManager];
    return [manager POST:URL parameters:parameters  constructingBodyWithBlock:^( id<AFMultipartFormData>formData) {
        
        NSString *mimeT = [NSString stringWithFormat:@"image/%@", mimeType ?: @"jpeg"];
        NSString *mimeF = mimeType ?: @"jpeg";
        [images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL *stop) {
            NSString *files = [NSString stringWithFormat:@"%@%zd.%@", fileName, idx,mimeF];
            NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
            [formData appendPartWithFileData:imageData
                                        name:name
                                    fileName:files
                                    mimeType:mimeT];
        }];
        
    } progress:^(NSProgress *_Nonnull uploadProgress) {
        
        if (progress) progress(uploadProgress.fractionCompleted * 100);
        
    } success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
        
        if (success) success(responseObject);
        
    } failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        
        if (failure) failure(error);
    }];
}

#pragma mark _________________________________________________________ 下载
#pragma mark _________________________________________________________ 下载
#pragma mark _________________________________________________________ 下载

+ (__kindof NSURLSessionTask *)downloadWithURL:(NSString *)URL
                                       fileDir:(NSString *)fileDir
                                      progress:(void (^)(double progress))progress
                                       success:(void (^)(NSString *filePath))success
                                       failure:(void (^)(NSError *error))failure {

    NSURLSessionDownloadTask *task = nil;
    AFHTTPSessionManager *manager = [self shareAFHTTPSessionManager];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    task = [manager downloadTaskWithRequest:request progress:^(NSProgress *pro) {
        
        if (progress) progress(pro.fractionCompleted * 100);
    } destination:^NSURL *_Nonnull(NSURL *_Nonnull targetPath, NSURLResponse *_Nonnull response) {
        
        NSString *path = [KLibraryboxPath stringByAppendingPathComponent:fileDir ?: @"Download"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *filePath = [path stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * response, NSURL *filePath, NSError *error) {

        if (success && !error) success(filePath.absoluteString);
        if (failure && error) failure(error);
    }];
    
    [task resume];
    return task;
}

#pragma mark _________________________________________________________ 单例

+ (AFHTTPSessionManager *)shareAFHTTPSessionManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = kDefaultManager();
    });
    return _manager;
}

#pragma mark _________________________________________________________ 监听网络

+ (void)checkNetworkStatusWithBlock:(void (^)(WXMNetworkStatus status))statuBlock {
    
    _isNetwork = NO;
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                !statuBlock ?: statuBlock(WXMNetworkStatusUnknown);
                // NSLog(@"未知网络");
                _isNetwork = NO;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                !statuBlock ?: statuBlock(WXMNetworkStatusNotReachable);
                // NSLog(@"无网络");
                _isNetwork = NO;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                !statuBlock ?: statuBlock(WXMNetworkStatusReachableViaWWAN);
                // NSLog(@"手机网络");
                _isNetwork = YES;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                !statuBlock ?: statuBlock(WXMNetworkStatusReachableViaWiFi);
                // NSLog(@"WIFI");
                _isNetwork = YES;
                break;
        }
    }];
    [manager startMonitoring];
}

+ (BOOL)currentNetworkStatus {
    return _isNetwork;
}

+ (void)cancelAllOperations {
    [[self shareAFHTTPSessionManager].operationQueue cancelAllOperations];
}

@end
