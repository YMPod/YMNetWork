//
//  YMAPIProxy.m
//  NetWork1
//
//  Created by TJ on 2017/6/6.
//  Copyright © 2017年 TJ. All rights reserved.
//

#import "YMAPIProxy.h"
#import "YMNetworkQueue.h"
#import "YMLog.h"
#import "YMRequestGenerator.h"
#import "AFNetWorking.h"

@interface YMAPIProxy ()

@property (nonatomic,strong) NSMutableDictionary *dispatchTable;
@property (nonatomic,assign) NSInteger recordedRequestID;
@property (nonatomic,strong) AFHTTPSessionManager *afSessionManager;
@property (nonatomic,strong) NSURLSession *ymSessionManager;


@end

@implementation YMAPIProxy

#pragma mark - Lift Cycle

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    static YMAPIProxy *proxy = nil;
    dispatch_once(&onceToken, ^{
        proxy = [[YMAPIProxy alloc] init];
    });
    return proxy;
}

- (NSInteger)callAPIWithParams:(NSDictionary *)params
             serviceIdentifier:(NSString *)serviceIdentifier
                    methodName:(NSString *)methodName
                   requestType:(NSString *)type
                  headerFields:(NSDictionary *)fields
                       success:(YMAPIProxyCallBack)success
                          fail:(YMAPIProxyCallBack)fail{
    
    return  [self callNormalAPIWithParams:params
                        serviceIdentifier:serviceIdentifier
                               methodName:methodName
                              requestType:type
                             headerFields:fields
                                  success:success
                                     fail:fail];
    
}

- (NSInteger)callNormalAPIWithParams:(NSDictionary *)params
                   serviceIdentifier:(NSString *)serviceIdentifier
                          methodName:(NSString *)methodName
                         requestType:(NSString *)type
                        headerFields:(NSDictionary *)fields
                             success:(YMAPIProxyCallBack)success
                                fail:(YMAPIProxyCallBack)fail{
    NSURLRequest *request;
    request = [[YMRequestGenerator shareInstance]
               generateRequestWithParams:params
               serviceIdentifier:serviceIdentifier
               methodName:methodName
               requestType:type
               headerFields:fields];
    NSInteger requestID = [self callApiWithRequest:request success:success fail:fail];
    return requestID ;
}

- (NSInteger)callUploadAPIWithParams:(NSDictionary *)params
                   serviceIdentifier:(NSString *)serviceIdentifier
                          methodName:(NSString *)methodName
                         requestType:(NSString *)type
                        headerFields:(NSDictionary *)fields
                            progress:(void (^)(NSProgress *))progress
                            fileData:(void (^)(id<YMMultipartFormData>))fileData
                             success:(YMAPIProxyCallBack)success
                                fail:(YMAPIProxyCallBack)fail{
    
    NSURLRequest *request;
    request = [[YMRequestGenerator shareInstance] 
               generateUploadRequestWithParams:params
               serviceIdentifier:serviceIdentifier
               methodName:methodName
               requestType:type
               headerFields:fields
               fileData:fileData];
    NSInteger requestID = [self callUploadApiWithRequest:request progress:progress  success:success fail:fail];
    return requestID ;
}




#pragma mark - Private Methods

/**起飞*/
- (NSInteger )callApiWithRequest:(NSURLRequest *)request
                         success:(YMAPIProxyCallBack)success
                            fail:(YMAPIProxyCallBack)fail
{
    NSAssert(request, @"Request 不能为空");
    __block NSInteger requestID = [self generateRequestID];
    //request 发送
    __weak typeof(self)  weakSelf = self;
    
    NSURLSessionDataTask *task = [self.ymSessionManager dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSURLSessionDataTask *storedTask = strongSelf.dispatchTable[@(requestID)];
        
        if (storedTask == nil) {
            return ;
        }else{
            [strongSelf.dispatchTable removeObjectForKey:@(requestID)];
        }
        
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (!error) {
            
            [YMLog logDebugInfoWithResponse:(NSHTTPURLResponse *)response resposeString:responseString request:request error:NULL ];
            
            YMAPIResponse *response = [[YMAPIResponse alloc]
                                        initWithResponseString:responseString
                                        requsetID:requestID
                                        request:request
                                        responseData:data
                                        status:YMAPIResponseStatusSuccess];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                success?success(response):nil;
            });
        }else{
            [YMLog logDebugInfoWithResponse:(NSHTTPURLResponse *)response resposeString:responseString request:request error:error ];
            YMAPIResponse *response = [[YMAPIResponse alloc]
                                        initWithResponseString:responseString
                                        requsetID:requestID
                                        request:request
                                        responseData:data
                                        error:error];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                fail?fail(response):nil;
            });
        }
    }];
    self.dispatchTable[@(requestID)] = task;
    [YMNetworkQueue addTask:task];
    
    return requestID;
}

/**起飞*/
- (NSInteger )callUploadApiWithRequest:(NSURLRequest *)request
                                 progress:(void(^)(NSProgress *))progress
                         success:(YMAPIProxyCallBack)success
                            fail:(YMAPIProxyCallBack)fail
{
    NSAssert(request, @"Request 不能为空");
    __block NSInteger requestID = [self generateRequestID];
    //request 发送
    __weak typeof(self)  weakSelf = self;
    
    NSURLSessionTask *task = [self.afSessionManager uploadTaskWithStreamedRequest:request progress:progress completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSURLSessionDataTask *storedTask = strongSelf.dispatchTable[@(requestID)];
        
        if (storedTask == nil) {
            return ;
        }else{
            [strongSelf.dispatchTable removeObjectForKey:@(requestID)];
        }
        

        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if (!error) {
            
            [YMLog logDebugInfoWithResponse:(NSHTTPURLResponse *)response resposeString:responseString request:request error:NULL ];
            
            YMAPIResponse *response = [[YMAPIResponse alloc]
                                       initWithResponseString:responseString
                                       requsetID:requestID
                                       request:request
                                       responseData:responseObject
                                       status:YMAPIResponseStatusSuccess];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                success?success(response):nil;
            });
        }else{
            [YMLog logDebugInfoWithResponse:(NSHTTPURLResponse *)response resposeString:responseString request:request error:error ];
            YMAPIResponse *response = [[YMAPIResponse alloc]
                                       initWithResponseString:responseString
                                       requsetID:requestID
                                       request:request
                                       responseData:responseObject
                                       error:error];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                fail?fail(response):nil;
            });
        }
    }];
    self.dispatchTable[@(requestID)] = task;
    [YMNetworkQueue addTask:task];
    
    return requestID;
}

- (void)cancelRequestByRequestID:(NSInteger)requestID{
    NSURLSessionTask *task = self.dispatchTable[@(requestID)];
    [task cancel];
    [self.dispatchTable removeObjectForKey:@(requestID)];
}

- (void)cancelRequestByRequestIDList:(NSArray *)requestIDList{
    for (NSNumber * requestID in requestIDList) {
        [self cancelRequestByRequestID:[requestID integerValue]];
    }
}

#pragma mark - Getters and Setters
- (NSMutableDictionary *)dispatchTable{
    if(!_dispatchTable){
        _dispatchTable = [[NSMutableDictionary alloc] init];
    }
    return _dispatchTable;
}

- (AFHTTPSessionManager *)afSessionManager{
    if (!_afSessionManager) {
        _afSessionManager = [AFHTTPSessionManager manager];
        _afSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return _afSessionManager;
}

- (NSURLSession *)ymSessionManager{
    if (!_ymSessionManager) {
        _ymSessionManager = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return _ymSessionManager;
}



- (NSInteger )generateRequestID{
    if (!_recordedRequestID) {
        _recordedRequestID = 1;
    }else{
        if (_recordedRequestID == NSIntegerMax) {
            _recordedRequestID = 1;
        }else{
            _recordedRequestID = _recordedRequestID  + 1;
        }
    }
    return _recordedRequestID;
}



@end
