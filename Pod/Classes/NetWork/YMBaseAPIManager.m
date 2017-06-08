//
//  YMBaseAPIManager.m
//  NetWork1
//
//  Created by TJ on 2017/6/6.
//  Copyright © 2017年 TJ. All rights reserved.
//

#import "YMBaseAPIManager.h"
#import "YMAPICache.h"
#import "YMAPIProxy.h"
#import "YMLog.h"
#import "YMAPIServiceFactory.h"
#import "AFNetworking.h"
#import "YMNetWorkManager.h"
static NSString *const kAPIManagerRequestID = @"kAPIRequestID";


@interface YMBaseAPIManager ()


@property (nonatomic,copy,readwrite) FetchCallBackBlock fetchCallBackBlock;
@property (nonatomic,strong,readwrite) id fetchedRawData;
@property (nonatomic,copy,readwrite) NSString *errorMessage;
@property (nonatomic,readwrite) YMAPIManagerErrorType errorType;
@property (nonatomic,strong) NSMutableArray *requestIDList;
@property (nonatomic,strong) YMAPICache *cache;

@end

@implementation YMBaseAPIManager

#pragma mark - Lift Cycle
- (instancetype)init{
    if (self = [super init]) {
        _delegate       = nil;
        _validator      = nil;
        _interceptor    = nil;
        _paramSource    = nil;
        _fetchedRawData = nil;
        _errorMessage   = nil;
        _errorType      = YMAPIManagerErrorTypeDefault;
        
        if ([self conformsToProtocol:@protocol(YMAPIManagerInfo) ]) {
            self.child = (id <YMAPIManagerInfo>)self;
        }else{
            NSAssert(NO, @"子类必须实现 APIManagerInfo 协议");
        }
    }
    return self;
}

- (void)dealloc{
    [self cancelAllRequests];
    self.requestIDList = nil;
    
    NSLog(@"<<<< %@   dealloc>>>>>",self);
}

#pragma mark - Publich Methods
- (NSInteger)loadData{
    NSDictionary *params    = [self.paramSource paramsForAPi:self];
    NSDictionary *fields    = [self.paramSource headerFieldsForAPi:self];
    NSInteger requestID     = [self loadDataWithParams:params headerFields:fields];
    return requestID;
}

- (NSInteger)loadDataWithParam:(NSDictionary *)params
                  headerFields:(NSDictionary *)headerFields
                      callBack:(FetchCallBackBlock)fetchCallBack;{
    self.fetchCallBackBlock = fetchCallBack;
    return [self loadDataWithParams:params headerFields:headerFields];
}


- (NSInteger)uploadData{
    NSDictionary *params    = [self.paramSource paramsForAPi:self];
    NSDictionary *fields    = [self.paramSource headerFieldsForAPi:self];
    NSInteger requestID     = [self uploadDataWithParams:params headerFields:fields];
    return requestID;
}


- (NSInteger)loadDataWithParams:(NSDictionary *)params
                   headerFields:(NSDictionary *)headerFields{
    
    NSInteger requestID = 0;
    NSDictionary *apiParams = params;
    if ([self shouldCallApiWithParams:apiParams]) {
        if ([self validatorCallApiWithParams:apiParams]) {
            
            //缓存
            if ([self shouldCache] && [self hasCacheParams:params]) {
                return requestID;
            }
            // next
            
            if ([self isReachable]) {
                
                
                requestID = [[YMAPIProxy shareInstance] callAPIWithParams:apiParams
                                                          serviceIdentifier:self.child.serviceType
                                                                 methodName:self.child.methodName
                                                                requestType:self.child.requestType
                                                               headerFields:headerFields
                                                                    success:^(YMAPIResponse *response) {
                                                                        [self successOnCallingAPI:response];
                                                                    }fail:^(YMAPIResponse *response) {
                                                                        [self failedOnCallingAPI:response
                                                                                   withErrorType:YMAPIManagerErrorTypeDefault];
                                                                    }];
                
                [self.requestIDList addObject:@(requestID)];
                NSMutableDictionary *tempParams = [apiParams mutableCopy];
                tempParams[kAPIManagerRequestID] = @(requestID);
                [self afterCallingAPIWithParams:params];
                return requestID;
            }else{
                [self failedOnCallingAPI:nil withErrorType:YMAPIManagerErrorTypeNoNetWork];
                return requestID;
            }
        }else{
            [self failedOnCallingAPI:nil withErrorType:YMAPIManagerErrorTypeParamsError];
            return requestID;
        }
    }
    return requestID;
}

/**
 *  上传数据文件
 */
- (NSInteger)uploadDataWithParams:(NSDictionary *)params
                   headerFields:(NSDictionary *)headerFields{
    
    NSInteger requestID = 0;
    NSDictionary *apiParams = params;
    if ([self shouldCallApiWithParams:apiParams]) {
        if ([self validatorCallApiWithParams:apiParams]) {
            
            //缓存
            //上传不适用缓存
            
            if ([self isReachable]) {
                
                
                [[YMAPIProxy shareInstance] callUploadAPIWithParams:apiParams serviceIdentifier: self.child.serviceType
                                                         methodName:self.child.methodName
                                                        requestType:self.child.requestType
                                                       headerFields:headerFields
                                                           progress:^(NSProgress *progress) {
                                                               if (self.downUpAop) {
                                                                   [self.downUpAop manager:self progress:progress];
                                                               }
                                                           } fileData:^(id<AFMultipartFormData> fileData) {
                                                               if (self.downUpAop && [self.downUpAop respondsToSelector:@selector(manager:fileData:)]) {
                                                                   [self.downUpAop manager:self fileData:fileData];
                                                               }
                                                           }
                 
                 
                                                            success:^(YMAPIResponse *response) {
                                                                [self successOnCallingAPI:response];
                                                            }fail:^(YMAPIResponse *response) {
                                                                [self failedOnCallingAPI:response
                                                                           withErrorType:YMAPIManagerErrorTypeDefault];
                                                            }];
                
                [self.requestIDList addObject:@(requestID)];
                NSMutableDictionary *tempParams = [apiParams mutableCopy];
                tempParams[kAPIManagerRequestID] = @(requestID);
                [self afterCallingAPIWithParams:params];
                return requestID;
            }else{
                [self failedOnCallingAPI:nil withErrorType:YMAPIManagerErrorTypeNoNetWork];
                return requestID;
            }
        }else{
            [self failedOnCallingAPI:nil withErrorType:YMAPIManagerErrorTypeParamsError];
            return requestID;
        }
    }
    return requestID;
}

- (void)cancelAllRequests{
    [[YMAPIProxy shareInstance] cancelRequestByRequestIDList:self.requestIDList];
    [self.requestIDList removeAllObjects];
}

- (void)cancelRequestByRequsetID:(NSInteger)requestID{
    [self.requestIDList removeObject:@(requestID)];
    [[YMAPIProxy shareInstance] cancelRequestByRequestID:requestID];
}

- (id)fetchDataWithReformer:(id<YMAPIManagerCallBackDateReformer>)reformer{
    id resultData = nil;
    if ([reformer respondsToSelector:@selector(manager:reformData:)]) {
        if ([self.fetchedRawData isKindOfClass:[NSDictionary class]] ||
            [self.fetchedRawData isKindOfClass:[NSArray class]] ||
            [self.fetchedRawData isKindOfClass:[NSString class]] ||
            self.fetchedRawData == nil) {
            resultData = [reformer manager:self reformData:self.fetchedRawData];
        }else{
            resultData = [reformer manager:self reformData:nil];
        }
    } else {
        resultData = [self.fetchedRawData mutableCopy];
    }
    return resultData;
}


#pragma mark - Private Methods

- (void)successOnCallingAPI:(YMAPIResponse *)response
{
    
    if (response.content) {
        self.fetchedRawData = [response.content copy];
    }else{
        self.fetchedRawData = [response.responseData copy];
    }
    
    
    [self removeRequestID:response.requestId];
    
    NSError *err = nil;
    id jsonObj = [NSJSONSerialization JSONObjectWithData:response.responseData options:(NSJSONReadingAllowFragments) error:&err];
    
    if ([self validatorCallApiWithCallBackData:jsonObj] && !err) {
        
        if ([self shouldCache] && !response.isCache) {
            // 缓存 。。。。。。。。
            [self.cache saveCacheWithData:response.responseData serviceIdentifier:self.child.serviceType methodName:self.child.methodName requestParams:response.requestParams];
        }
        
        [self beforPerformSuccessWithResponse:response];
        [self.delegate apiManagerCallBackDidSuccess:self];
        if (self.fetchCallBackBlock) {
            __weak typeof(self) weakSelf = self;
            NSDictionary *tempDataDic = [self.fetchedRawData[@"data"] copy];
            
            self.fetchCallBackBlock(YES,tempDataDic,weakSelf);
            self.fetchCallBackBlock = nil;
        }
        
        [self afterPerformSuccessWithResponse:response];
        
    }else{
        
        [self failedOnCallingAPI:response withErrorType:YMAPIManagerErrorTypeNoContent];
    }
}

- (void)failedOnCallingAPI:(YMAPIResponse *)response
             withErrorType:(YMAPIManagerErrorType)errorType
{
    self.errorType = errorType;
    [self removeRequestID:response.requestId];
    [self beforPerformFailWithResponse:response];
    [self.delegate apiManagerCallBackDidFailed:self];
    if (self.fetchCallBackBlock) {
        self.fetchCallBackBlock(NO,[self.fetchedRawData valueForKey:@"message"]?self.fetchedRawData:@{@"message":@"网络异常"},self);
        self.fetchCallBackBlock = nil;
    }
    [self afterPerformFailWithResponse:response];
}

- (BOOL)hasCacheParams:(NSDictionary *)params{
    NSMutableDictionary *tempParams = [params mutableCopy];
    NSString *serviceIdentifier = self.child.serviceType;
    NSString *methodName = self.child.methodName;
    NSData *result = [self.cache fetchCachedDataWithServiceIdentifier:serviceIdentifier methodName:methodName requestParams:tempParams];
    
    if (result == nil) {
        return NO;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        YMAPIResponse *response = [[YMAPIResponse alloc] initWithData:result];
        response.requestParams = params;
        [YMLog logDebugInfoWithCachedResponse:response methodName:methodName serviceIdentifier:[[YMAPIServiceFactory sharedInstance] serviceWithIdentifier:serviceIdentifier]];
        [self successOnCallingAPI:response];
    });
    return YES;
}


- (void)removeRequestID:(NSInteger)requestID{
    [self.requestIDList removeObject:@(requestID)];
}
#pragma mark - method for interceptor
- (BOOL)shouldCallApiWithParams:(NSDictionary *)parmas
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:shouldCallAPIWithParams:)]) {
        return [self.interceptor manager:self shouldCallAPIWithParams:parmas];
    }
    return YES;
}

- (BOOL)validatorCallApiWithParams:(NSDictionary *)responseString
{
    
    
    if (self != self.validator && [self.validator respondsToSelector:@selector(manager:isCorrectWithParamsData:)]) {
        return [self.validator manager:self isCorrectWithParamsData:responseString];
    }
    return YES;
}


- (BOOL)validatorCallApiWithCallBackData:(id)callBackData
{
    //添加全局
    if ([YMNetWorkManager manager].dataValDelegate && [[YMNetWorkManager manager].dataValDelegate respondsToSelector:@selector(globalRemoteDateValidator:manager:)]) {
        BOOL globalVal = [[YMNetWorkManager manager].dataValDelegate globalRemoteDateValidator:callBackData manager:self];
        if (!globalVal) {
            return globalVal;
        }
    }
    
    if (self != self.validator && [self.validator respondsToSelector:@selector(manager:isCorrectWithCallBackData:)]) {
        return [self.validator manager:self isCorrectWithCallBackData:callBackData];
    }
    return YES;
}

- (void)afterCallingAPIWithParams:(NSDictionary *)params{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterCallingAPIWithParams:)]) {
        [self.interceptor manager:self afterCallingAPIWithParams:params];
    }
}

- (void)beforPerformSuccessWithResponse:(YMAPIResponse *)response{
    self.errorType = YMAPIManagerErrorTypeSuccess;
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:beforePerformSuccessWithResponse:)]) {
        [self.interceptor manager:self beforePerformSuccessWithResponse:response];
    }
}

- (void)afterPerformSuccessWithResponse:(YMAPIResponse *)response{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterPerformSuccessWithResponse:)]) {
        [self.interceptor manager:self afterPerformSuccessWithResponse:response];
    }
}

- (void)beforPerformFailWithResponse:(YMAPIResponse *)response{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:beforePerformFailWithResponse:)]) {
        [self.interceptor manager:self beforePerformFailWithResponse:response];
    }
}

- (void)afterPerformFailWithResponse:(YMAPIResponse *)response{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterPerformFailWithResponse:)]) {
        [self.interceptor manager:self afterPerformFailWithResponse:response];
    }
}

- (BOOL)shouldCache{
    return NO;
}
#pragma mark - Getters and Setters
- (NSMutableArray *)requestIDList{
    if (!_requestIDList) {
        _requestIDList = [[NSMutableArray alloc] init];
    }
    return _requestIDList;
}

- (BOOL)isReachable{
    /** 网络的判断 */
    BOOL reachability = YES;
    

    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        reachability = YES;
    } else {
        reachability = [[AFNetworkReachabilityManager sharedManager] isReachable];
    }
    
    if (!reachability) {
        self.errorType = YMAPIManagerErrorTypeNoNetWork;
    }
    return reachability;
}

- (BOOL)isLoading{
    return self.requestIDList.count;
}

- (YMAPICache *)cache
{
    if (_cache == nil) {
        _cache = [YMAPICache sharedInstance];
    }
    return _cache;
}


@end
