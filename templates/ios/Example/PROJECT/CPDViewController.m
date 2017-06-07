//
//  CPDViewController.m
//  PROJECT
//
//  Created by PROJECT_OWNER on TODAYS_DATE.
//  Copyright (c) TODAYS_YEAR PROJECT_OWNER. All rights reserved.
//

#import "CPDViewController.h"
#import "YMNetWork.h"
#import "T1ApiManager.h"

@interface CPDViewController ()<YMRequestGeneratorProtocol,YMCallBackDataValidatorProtocol,YMCacheTimeOutProtocol>

@end

@implementation CPDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[YMNetWorkManager manager] setRequestGenAOP:self];
    [[YMNetWorkManager manager] confLogEnable:YES];
    [[YMNetWorkManager manager] setDataValDelegate:self];
    [[YMNetWorkManager manager] setCacheTimeOutDelegate:self];
    
    
    
    T1ApiManager *t1 = [[T1ApiManager alloc] init];
    [t1 loadData];
}

- (NSTimeInterval)globalTimeOutForMethod:(NSString *)method host:(NSString *)host{
    return 10;
}

- (NSDictionary *)globalParamsForMethod:(NSString *)method host:(NSString *)host{
    return @{@"wewe":@"ym"};
}

- (NSDictionary *)globalHeaderFieldsForMethod:(NSString *)method host:(NSString *)host{
    return @{@"fromSource":@"iOS"};
}

- (BOOL)globalRemoteDateValidator:(id)callBackData manager:(YMBaseAPIManager *)apiManager{
    if (![callBackData isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    //系统级别拦截 后台约定
    if (![@"T" isEqualToString: callBackData[@"success"]]) {
        
        //----token 过期 ----
        if ([@"10005" isEqualToString: [callBackData[@"code"] stringValue]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //清空用户信息
                
                //需要重新登录
                
            });
        }
        return NO;
    }
    return YES;
}

- (NSTimeInterval)globalCacheTimeOut{
    return 60*60*10;
}


@end
