//
//  WXMNetworkRespose.m
//  Demo2
//
//  Created by edz on 2019/4/29.
//  Copyright © 2019年 wq. All rights reserved.
//

#import "WXMNetworkRespose.h"

@implementation WXMNetworkRespose

- (instancetype)initWithTask:(NSURLSessionTask *)dataTask
                    response:(NSData *)response
                       error:(NSError *)error {
    if ([super init]) {
        _task = dataTask;
        _response= response;
        _error = error;
    }
    return self;
}
@end


@implementation AFHTTPSessionManager (WXMAFNetworkingConfig)

+ (instancetype)wxmDefaultManager {
    NSURL * baseUrl = [NSURL URLWithString:KURLString];
    NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseUrl sessionConfiguration:conf];
    manager.operationQueue.maxConcurrentOperationCount = 10;
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setTimeoutInterval:30];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"application/x-protobuf", nil];
    
#if DEBUG
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
#endif
    return manager;
}

@end
