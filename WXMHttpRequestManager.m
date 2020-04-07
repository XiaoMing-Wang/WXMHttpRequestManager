//
//  WXMHttpRequestManager.m
//  ModuleDebugging
//
//  Created by edz on 2019/6/24.
//  Copyright © 2019 wq. All rights reserved.
//

#import "WXMHttpRequestManager.h"

@implementation WXMHttpRequestManager

- (void)wt_showLoadingWithController:(nonnull UIViewController *)controller {
    
}

- (void)wt_showMsgWithController:(nonnull UIViewController *)controller msgl:(nonnull NSString *)msg {
    if (msg.length <= 0) return;
    
}

- (void)wt_hiddenLoadingWithController:(nonnull UIViewController *)controller {
    
}

/** 判断请求是否成功 responseObj为请求返回参数 */
/** 判断请求是否成功 responseObj为请求返回参数 */
/** 判断请求是否成功 responseObj为请求返回参数 */
- (BOOL)wt_judgeRequestSuccess:(nonnull NSDictionary *)responseObj {
    return YES;
}

/** 返回结果的目标key 例如数据可能存在data字段或者results字段里 */
/** 返回结果的目标key 例如数据可能存在data字段或者results字段里 */
/** 返回结果的目标key 例如数据可能存在data字段或者results字段里 */
- (nonnull NSString *)wt_resultSetTarget {
    return @"";
}

/** 处理异常情况 BOOL代表是否允许block继续回调 */
/** 处理异常情况 BOOL代表是否允许block继续回调 */
/** 处理异常情况 BOOL代表是否允许block继续回调 */
- (BOOL)wt_judgeErrorCodeWithPath:(nonnull NSString *)path
                           result:(nonnull NSDictionary *)result
                       controller:(nonnull UIViewController *)controller {
    return YES;
}

/** 判断是断网时是否提示失败 */
/** 判断是断网时是否提示失败 */
/** 判断是断网时是否提示失败 */
- (BOOL)wt_judgeNetworkErrorWithPath:(NSString *)path controller:(UIViewController *)controller {
    return YES;
}

@end
