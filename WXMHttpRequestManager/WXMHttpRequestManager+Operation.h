//
//  WXMHttpRequestManager+Operation.h
//
//  Created by edz on 2019/4/29.
//  Copyright © 2019年 wq. All rights reserved.
//
#define HaveMB 0
#define ResultSet @"dataContent"
#define ErrorCode @"errorCode"
#define ErrorMsg @"errorMsg"

#import "WXMHttpRequestManager.h"
#import "WXMNetworkRespose.h"

@interface WXMHttpRequestManager (Operation)

/** 属性 */
@property (nonatomic, assign) BOOL showMB;

/** 单例 */
+ (WXMHttpRequestManager *)shareManage;
+ (WXMHttpRequestManager *)shareNoMB;

/** post 直接使用 */
- (void)requestWithPath:(NSString *)path
             parameters:(nullable NSDictionary *)parameters
         viewController:(nullable UIViewController *)controller
                success:(nullable void (^)(WXMNetworkRespose *resposeObj))success
                failure:(nullable void (^)(WXMNetworkRespose *resposeObj))failure;


@end
