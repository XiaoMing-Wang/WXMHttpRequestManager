//
//  WXMNetworkRespose.h
//  Demo2
//
//  Created by edz on 2019/4/29.
//  Copyright © 2019年 wq. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AFNetworking.h>

static NSString *const KURLString = @""; /** 线上 */
// static NSString *const KURLString = @""; /** 测试 */
// static NSString *const KURLString = @""; /** 开发 */

@interface WXMNetworkRespose : NSObject
@property (nonatomic, strong, readonly) NSURLSessionTask *task;
@property (nonatomic, assign, readonly) BOOL successful;
@property (nonatomic, strong) id response;
@property (nonatomic, strong) NSError *error;

- (instancetype)initWithTask:(NSURLSessionTask *)dataTask
                    response:(id)response
                       error:(NSError *)error;
@end


@interface AFHTTPSessionManager (WXMAFNetworkingConfig)
+ (instancetype)wxmDefaultManager;
@end

