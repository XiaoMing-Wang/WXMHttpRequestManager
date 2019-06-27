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

- (void)wt_showMsgWithController:(nonnull UIViewController *)controller
                            msgl:(nonnull NSString *)msg {
    
}

- (void)wt_hiddenLoadingWithController:(nonnull UIViewController *)controller {
    
}

- (BOOL)wt_judgeErrorCodeWithPath:(nonnull NSString *)path
                           result:(nonnull NSDictionary *)result
                       controller:(nonnull UIViewController *)controller {
    return YES;
}

- (BOOL)wt_judgeRequestSuccess:(nonnull NSDictionary *)responseObj {
    return YES;
}

- (nonnull NSString *)wt_resultSetTarget {
    return @"";
}


@end
