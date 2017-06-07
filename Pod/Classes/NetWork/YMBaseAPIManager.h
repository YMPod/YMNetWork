//
//  YMBaseAPIManager.h
//  NetWork1
//
//  Created by TJ on 2017/6/6.
//  Copyright © 2017年 TJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YMBaseAPIManager;
@class YMAPIResponse;

typedef NS_ENUM(NSUInteger, YMAPIManagerErrorType) {
    YMAPIManagerErrorTypeDefault,     //没有产生过API请求，这个是manager的默认状态。
    YMAPIManagerErrorTypeSuccess,     //API请求成功且返回数据正确，此时manager的数据是可以直接拿来使用的。
    
    YMAPIManagerErrorTypeNoContent,   //API请求成功但返回数据不正确。如果回调数据验证函数返回值为NO，manager的状态就会是这个。
    YMAPIManagerErrorTypeParamsError, //参数错误，此时manager不会调用API，因为参数验证是在调用API之前做的。
    
    YMAPIManagerErrorTypeTimeOut,     //请求超时。RTApiProxy设置的是20秒超时，具体超时时间的设置
    YMAPIManagerErrorTypeNoNetWork    //网络不通。在调用API之前会判断一下当前网络是否通畅，这个也是在调用API之前验证的，和上面超时的状态是有区别的。
};

typedef void(^FetchCallBackBlock)(Boolean isSuccess,id responseData,YMBaseAPIManager *manager);

/************************************************
        YMAPIManagerInfo
        API基本信息协议
 ************************************************/
@protocol YMAPIManagerInfo <NSObject>

@required
- (NSString *)methodName;
- (NSString *)serviceType;
- (NSString *)requestType;
@optional
- (BOOL)shouldCache;

- (NSDictionary *)reformParams:(NSDictionary *)params;
- (NSInteger)loadDataWithParams:(NSDictionary *)params;

@end

/************************************************
 APIManagerCallBackDelegate
 回调协议
 ************************************************/

@protocol YMAPIManagerCallBackDelegate <NSObject>

@required
- (void)apiManagerCallBackDidSuccess:(YMBaseAPIManager *)manager;
- (void)apiManagerCallBackDidFailed:(YMBaseAPIManager *)manager;

@end

/************************************************
 YMAPIManagerCallBackDateReformer
 DateReformer协议
 ************************************************/

@protocol YMAPIManagerCallBackDateReformer <NSObject>

@required
- (id)manager:(YMBaseAPIManager *)manager reformData:(NSObject *)data;

@end

/************************************************
 YMAPIManagerParamSourceDelegate
 参数源
 ************************************************/
@protocol YMAPIManagerParamSourceDelegate <NSObject>

@required
- (NSDictionary *)paramsForAPi:(YMBaseAPIManager *)manager;

- (NSDictionary *)headerFieldsForAPi:(YMBaseAPIManager *)manager;

@end

/************************************************
 YMAPIManagerValidator
 验证协议
 ************************************************/
@protocol YMAPIManagerValidator <NSObject>

@required
- (BOOL)manager:(YMBaseAPIManager *)manager isCorrectWithCallBackData:(id)data;
- (BOOL)manager:(YMBaseAPIManager *)manager isCorrectWithParamsData:(NSDictionary *)data;

@end

/************************************************
 YMAPIManagerInterceptor
 拦截器协议
 ************************************************/
@protocol YMAPIManagerInterceptor <NSObject>

@optional
- (void)manager:(YMBaseAPIManager *)manager beforePerformSuccessWithResponse:(YMAPIResponse *)response;

- (void)manager:(YMBaseAPIManager *)manager afterPerformSuccessWithResponse:(YMAPIResponse *)response;

- (void)manager:(YMBaseAPIManager *)manager beforePerformFailWithResponse:(YMAPIResponse *)response;

- (void)manager:(YMBaseAPIManager *)manager afterPerformFailWithResponse:(YMAPIResponse *)response;

- (BOOL)manager:(YMBaseAPIManager *)manager shouldCallAPIWithParams:(NSDictionary *)params;
- (void)manager:(YMBaseAPIManager *)manager afterCallingAPIWithParams:(NSDictionary *)params;

@end


/************************************************
 BaseAPIManager
 ************************************************/
@interface YMBaseAPIManager : NSObject

@property (nonatomic,weak) id<YMAPIManagerParamSourceDelegate> paramSource;
@property (nonatomic,weak) id<YMAPIManagerCallBackDelegate> delegate;
@property (nonatomic,weak) id<YMAPIManagerValidator> validator;
@property (nonatomic,weak) id<YMAPIManagerInterceptor> interceptor;

@property (nonatomic,weak) NSObject<YMAPIManagerInfo> *child;
@property (nonatomic,copy,readonly) NSString *errorMessage;
@property (nonatomic,readonly) YMAPIManagerErrorType errorType;

@property (nonatomic,assign,readonly) BOOL isReachable;
@property (nonatomic,assign,readonly) BOOL isLoading;

- (id)fetchDataWithReformer:(id<YMAPIManagerCallBackDateReformer>) reformer;

- (NSInteger)loadData;

- (void)cancelAllRequests;
- (void)cancelRequestByRequsetID:(NSInteger)requestID;

- (BOOL)shouldCache;



@end
