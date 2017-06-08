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
#import "CPDT2APIManager.h"

@interface CPDViewController ()<YMRequestGeneratorProtocol,YMCallBackDataValidatorProtocol,YMCacheTimeOutProtocol,YMAPIManagerParamSourceDelegate,YMAPIManagerDownUploadProtocol>

@end

@implementation CPDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[YMNetWorkManager manager] setRequestGenAOP:self];
    [[YMNetWorkManager manager] confLogEnable:YES];
    [[YMNetWorkManager manager] setDataValDelegate:self];
    [[YMNetWorkManager manager] setCacheTimeOutDelegate:self];
    
    
    
//    T1ApiManager *t1 = [[T1ApiManager alloc] init];
//    [t1 loadData];
    
    CPDT2APIManager *t2 = [[CPDT2APIManager alloc] init];
    t2.paramSource = self;
    t2.downUpAop = self;
    [t2 uploadData];
}

- (NSDictionary *)paramsForAPi:(YMBaseAPIManager *)manager{
    if ([manager isKindOfClass:[CPDT2APIManager class]]) {
        return @{@"bucketName":@"cmVsZWFzZS0xeWQ="};
    }
    return nil;
}

- (void)manager:(YMBaseAPIManager *)manager fileData:(id<AFMultipartFormData>)data{
    if ([manager isKindOfClass:[CPDT2APIManager class]]) {
        
        NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:@"2.png"]);
        
        if (!imageData) {
            return ;
        }
        
    
    NSString * fileName = [NSString stringWithFormat:@"ios%@0%@.png",  @(arc4random()%500),@(arc4random()%100)];
        
        [data appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:@"image/png"];
    }

}

- (void)manager:(YMBaseAPIManager *)manager progress:(NSProgress *)progress{
    if ([manager isKindOfClass:[CPDT2APIManager class]]) {
        NSLog(@"progress ---> %@",progress);
    }
    
}


- (NSDictionary *)headerFieldsForAPi:(YMBaseAPIManager *)manager{
    if ([manager isKindOfClass:[CPDT2APIManager class]]) {
        return @{@"Authorization":@"Bearer 2501e734c67a3bc0911a28e9fd18552b"};
    }
    return nil;
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
