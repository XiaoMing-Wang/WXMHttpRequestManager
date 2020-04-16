//
//  WXMNetworkRespose.m
//  Demo2
//
//  Created by edz on 2019/4/29.
//  Copyright © 2019年 wq. All rights reserved.
//
#import "WXMHttpConfigurationFile.h"
#import "WXMNetworkRespose.h"

@implementation WXMNetworkRespose

+ (instancetype)resposeWithTask:(NSURLSessionTask *)dataTask response:(id)response error:(NSError *)error {
    WXMNetworkRespose *respose = [WXMNetworkRespose new];
    respose.task = dataTask;
    respose.response= response;
    respose.error = error;
    return response;
}

- (void)setTask:(NSURLSessionTask *)task {
    _task = task;
}

- (void)setErrorCodeWithCode:(NSInteger)errorCode {
    _errorCode = errorCode;
}

- (void)setSuccessfulWithDelivery:(BOOL)delivery {
    _successful = delivery;
}

@end

