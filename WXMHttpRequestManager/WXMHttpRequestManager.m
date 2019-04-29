//
//  Created by wq on 16/5/31.
//  Copyright © 2016年 wq. All rights reserved.
//

#import "AFNetworking.h"
#import "WXMHttpRequestManager.h"
#import "WXMNetworkRespose.h"

/** 是否有网 */
static BOOL _isNetwork;
static AFHTTPSessionManager *_manager;

@implementation WXMHttpRequestManager

/* get */
+ (__kindof NSURLSessionTask *)GET:(NSString *)URL
                        parameters:(NSDictionary *)parameters
                           success:(void(^)(id responseObject))success
                           failure:(void(^)(NSError *error))failure {
    AFHTTPSessionManager *mg = [self shareAFHTTPSessionManager];
    return [mg GET:URL parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id resp) {
        
        if (success) success([self JSONObjectWithData:resp]);
        
    } failure:^(NSURLSessionDataTask *task, NSError * error) { if(failure) failure(error);}];
}

/* post */
+ (__kindof NSURLSessionTask *)POST:(NSString *)URL
                         parameters:(NSDictionary *)parameters
                            success:(void(^)(id responseObject))success
                            failure:(void(^)(NSError *error))failure {
    AFHTTPSessionManager *mg = [self shareAFHTTPSessionManager];
    return [mg POST:URL parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id resp) {
        
        if (success) success([self JSONObjectWithData:resp]);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) { if (failure) failure(error);}];
}
/** 转换 */
+ (id)JSONObjectWithData:(id)response {
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
                                    progress:(void(^)(NSProgress *progress))progress
                                     success:(void(^)(id responseObject))success
                                     failure:(void(^)(NSError *error))failure {
    
    AFHTTPSessionManager *mg = [self shareAFHTTPSessionManager];
    return [mg POST:URL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>formData) {
        
        [images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL *stop) {
            
            NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
            [formData appendPartWithFileData:imageData
                                        name:name
                                    fileName:[NSString stringWithFormat:@"%@%lu.%@", fileName, (unsigned long) idx, mimeType ?: @"jpeg"]
                                    mimeType:[NSString stringWithFormat:@"image/%@", mimeType ?: @"jpeg"]];
        }];
    } progress:^(NSProgress *_Nonnull uploadProgress) {
        if (progress) progress(uploadProgress);
    } success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
        if (success) success(responseObject);
    } failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        if (failure) failure(error);
    }];
}
#pragma mark _________________________________________________________ 下载

+ (__kindof NSURLSessionTask *)downloadWithURL:(NSString *)URL
                                       fileDir:(NSString *)fileDir
                                      progress:(void (^)(NSProgress *progress))progress
                                       success:(void (^)(NSString *filePath))success
                                       failure:(void (^)(NSError *error))failure {

    AFHTTPSessionManager *mg = [self shareAFHTTPSessionManager];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    NSURLSessionDownloadTask *task = [mg downloadTaskWithRequest:request progress:^(NSProgress *pro) {
      
        if (progress) progress(pro);

    } destination:^NSURL *_Nonnull(NSURL *_Nonnull targetPath, NSURLResponse *_Nonnull response) {
        
        NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileDir ?: @"Download"];
        
        NSFileManager *fmg = [NSFileManager defaultManager];
        [fmg createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *filePath = [downloadDir stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse *_Nonnull response, NSURL *_Nullable filePath, NSError *error) {
        if (success) success(filePath.absoluteString);
        if (failure && !error) failure(error);
    }];
    [task resume];
    return task;
}
#pragma mark _________________________________________________________ 单例

+ (AFHTTPSessionManager *)shareAFHTTPSessionManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [AFHTTPSessionManager wxmDefaultManager];
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
