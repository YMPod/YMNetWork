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

@interface YMAPISession : NSURLSession
+ (instancetype)session;
@end
@implementation YMAPISession

+ (instancetype)session{
    static dispatch_once_t onceToken;
    static YMAPISession *session;
    dispatch_once(&onceToken, ^{
        
        //[NSURLSession
        session = (YMAPISession *)[YMAPISession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    });
    return session;
}


@end


@interface YMAPIProxy ()

@property (nonatomic,strong) NSMutableDictionary *dispatchTable;
@property (nonatomic,assign) NSInteger recordedRequestID;

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
    
    NSURLSessionDataTask *task = [[YMAPISession session] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
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
