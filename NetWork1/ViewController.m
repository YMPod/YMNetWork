//
//  ViewController.m
//  NetWork1
//
//  Created by TJ on 2017/6/6.
//  Copyright © 2017年 TJ. All rights reserved.
//

#import "ViewController.h"
#import "YMNetWorkManager.h"
#import "T1ApiManager.h"
@interface ViewController ()<YMRequestGeneratorProtocol,YMCallBackDataValidatorProtocol,YMCacheTimeOutProtocol>

@end

@implementation ViewController

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
