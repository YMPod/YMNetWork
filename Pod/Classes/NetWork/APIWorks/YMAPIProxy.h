//
//  YMAPIProxy.h
//  NetWork1
//
//  Created by TJ on 2017/6/6.
//  Copyright © 2017年 TJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMAPIResponse.h"
#import "AFNetWorking.h"


typedef void(^YMAPIProxyCallBack)(YMAPIResponse *response);

@interface YMAPIProxy : NSObject


+ (instancetype)shareInstance;



- (NSInteger)callAPIWithParams:(NSDictionary *)params
             serviceIdentifier:(NSString *)serviceIdentifier
                    methodName:(NSString *)methodName
                   requestType:(NSString * )type
                  headerFields:(NSDictionary *)fields
                       success:(YMAPIProxyCallBack)success
                          fail:(YMAPIProxyCallBack)fail;

- (NSInteger)callUploadAPIWithParams:(NSDictionary *)params
                   serviceIdentifier:(NSString *)serviceIdentifier
                          methodName:(NSString *)methodName
                         requestType:(NSString *)type
                        headerFields:(NSDictionary *)fields
                            progress:(void (^)(NSProgress *))progress
                            fileData:(void (^)(id<AFMultipartFormData>))fileData
                             success:(YMAPIProxyCallBack)success
                                fail:(YMAPIProxyCallBack)fail;


- (void)cancelRequestByRequestID:(NSInteger)requestID;
- (void)cancelRequestByRequestIDList:(NSArray *)requestIDList;


@end
