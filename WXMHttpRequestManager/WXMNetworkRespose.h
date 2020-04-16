//
//  WXMNetworkRespose.h
//  Demo2
//
//  Created by edz on 2019/4/29.
//  Copyright © 2019年 wq. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@interface WXMNetworkRespose : NSObject
@property (nonatomic, strong, readonly) NSURLSessionTask *task;
@property (nonatomic, assign, readonly) BOOL successful;
@property (nonatomic, assign, readonly) NSInteger errorCode;
@property (nonatomic, strong) id response;
@property (nonatomic, strong) NSError *error;

- (void)setErrorCode:(NSInteger)errorCode;
- (void)setSuccessfulWithDelivery:(BOOL)delivery;

+ (instancetype)resposeWithTask:(NSURLSessionTask *)dataTask
                       response:(id)response
                          error:(NSError *)error;
@end
