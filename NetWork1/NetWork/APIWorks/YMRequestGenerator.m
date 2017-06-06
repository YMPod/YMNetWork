//
//  YMRequestGenerator.m
//  NetWork1
//
//  Created by TJ on 2017/6/6.
//  Copyright © 2017年 TJ. All rights reserved.
//

#import "YMRequestGenerator.h"
#import <AFNetworking.h>
#import "YMAPIService.h"
#import "YMAPIServiceFactory.h"
#import "NSURLRequest+ymRequestParams.h"
@interface YMRequestGenerator ()

@property (nonatomic,strong) AFHTTPRequestSerializer *formSerializer;
@property (nonatomic,strong) AFHTTPRequestSerializer *jsonSerializer;

@end

@implementation YMRequestGenerator

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    static YMRequestGenerator *generator = nil;
    dispatch_once(&onceToken, ^{
        generator = [[YMRequestGenerator alloc] init];
    });
    return generator;
}

- (NSURLRequest *)generateRequestWithParams:(NSDictionary *)params serviceIdentifier:(NSString *)identifier methodName:(NSString *)methodName requestType:(NSString *)type headerFields:(NSDictionary *)fields{
    
    AFHTTPRequestSerializer *serializer = self.jsonSerializer;
    if (fields) {
        if ([@"application/x-www-form-urlencoded" isEqualToString: fields[@"Content-Type"]]) {
            serializer = self.formSerializer;
        }
    }
    
    YMAPIService *service = [[YMAPIServiceFactory sharedInstance]
                           serviceWithIdentifier:identifier];
    
    NSString *urlString = [[NSString stringWithFormat:@"%@%@",service.apiBaseUrl,methodName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //全局配置变量
    
    //设置请求参数
    NSDictionary *tempParamDic = nil;
    
    if (self.genDelegate && [self.genDelegate respondsToSelector:@selector(globalParamsForMethod:host:)]) {
        tempParamDic = [self.genDelegate globalParamsForMethod:type
                                                                host:service.apiBaseUrl];
    }
    
    NSMutableDictionary *requestParams = [@{} mutableCopy];
    [requestParams setValuesForKeysWithDictionary:params];
    [requestParams setValuesForKeysWithDictionary:tempParamDic];

    NSMutableURLRequest *request = [serializer requestWithMethod:type
                                                       URLString:urlString
                                                      parameters:requestParams
                                                           error:NULL];
    request.requestParams = requestParams;
    
    //设置请求头
    NSMutableDictionary *requestHeader = [@{} mutableCopy];
    NSDictionary *tempHeaderDic = nil;
    if (self.genDelegate && [self.genDelegate respondsToSelector:@selector(globalHeaderFieldsForMethod:host:)]) {
        tempHeaderDic = [self.genDelegate globalHeaderFieldsForMethod:type
                                                           host:service.apiBaseUrl];
    }
    [requestParams setValuesForKeysWithDictionary:fields];
    [requestHeader setValuesForKeysWithDictionary:tempHeaderDic];
    [requestHeader enumerateKeysAndObjectsUsingBlock:^(NSString  * _Nonnull  key, NSString   * _Nonnull obj, BOOL * _Nonnull stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    
    //设置超时时间
    NSTimeInterval globalTimeout = 60;
    if (self.genDelegate && [self.genDelegate respondsToSelector:@selector(globalTimeOutForMethod:host:)]) {
        globalTimeout = [self.genDelegate globalTimeOutForMethod:type
                                                            host:service.apiBaseUrl];
    }
    request.timeoutInterval = globalTimeout;
    
    return request;
}

#pragma mark - Getters and Setters
- (AFHTTPRequestSerializer *)formSerializer{
    if (!_formSerializer) {
        _formSerializer = [AFHTTPRequestSerializer serializer];
    }
    return _formSerializer;
}


- (AFHTTPRequestSerializer *)jsonSerializer{
    if (!_jsonSerializer) {
        _jsonSerializer = [AFJSONRequestSerializer serializer];
    }
    return _jsonSerializer;
}

@end
