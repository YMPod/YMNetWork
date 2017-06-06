//
//  YMAPIResponse.h
//  NetWork1
//
//  Created by TJ on 2017/6/6.
//  Copyright © 2017年 TJ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, YMAPIResponseStatus) {
    YMAPIResponseStatusSuccess,
    YMAPIResponseStatusErrorTimeOut,
    YMAPIResponseStatusErrorNoNetwork,
};

@interface YMAPIResponse : NSObject

@property (nonatomic, assign, readonly) NSInteger requestId;
@property (nonatomic, copy, readonly) NSURLRequest *request;

@property (nonatomic, copy, readonly) id content;

@property (nonatomic, copy, readonly) NSString *responseString;
@property (nonatomic, copy, readonly) NSURLResponse *response;
@property (nonatomic, copy, readonly) NSData *responseData;
@property (nonatomic, assign, readonly) BOOL isCache;
@property (nonatomic, copy) NSDictionary *requestParams;


@property (nonatomic,assign) YMAPIResponseStatus status;

- (instancetype)initWithResponseString:(NSString *)responseString
                             requsetID:(NSInteger)requestID
                               request:(NSURLRequest *)request
                          responseData:(NSData *)responseData
                                status:(YMAPIResponseStatus)status;

- (instancetype)initWithResponseString:(NSString *)reponseString
                             requsetID:(NSInteger)requestID
                               request:(NSURLRequest *)request
                          responseData:(NSData *)responseData
                                 error:(NSError *)error;

- (instancetype)initWithData:(NSData *)data;


@end
