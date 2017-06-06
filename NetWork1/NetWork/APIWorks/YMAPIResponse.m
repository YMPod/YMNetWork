//
//  YMAPIResponse.m
//  NetWork1
//
//  Created by TJ on 2017/6/6.
//  Copyright © 2017年 TJ. All rights reserved.
//

#import "YMAPIResponse.h"
#import "NSURLRequest+ymRequestParams.h"

@interface YMAPIResponse ()

@property (nonatomic, assign, readwrite) NSInteger requestId;
@property (nonatomic, copy, readwrite) NSURLRequest *request;
@property (nonatomic, copy, readwrite) NSData *responseData;
@property (nonatomic, copy, readwrite) NSString *responseString;
@property (nonatomic, copy, readwrite) NSURLResponse *response;
@property (nonatomic, assign, readwrite) BOOL isCache;
@property (nonatomic, copy, readwrite) id content;

@end

/** 复制 AF 的解决方法，替换掉 Json 对象中的 null */
static id AFJSONObjectByRemovingKeysWithNullValuesCopy(id JSONObject, NSJSONReadingOptions readingOptions) {
    if ([JSONObject isKindOfClass:[NSArray class]]) {
        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[(NSArray *)JSONObject count]];
        for (id value in (NSArray *)JSONObject) {
            [mutableArray addObject:AFJSONObjectByRemovingKeysWithNullValuesCopy(value, readingOptions)];
        }
        
        return (readingOptions & NSJSONReadingMutableContainers) ? mutableArray : [NSArray arrayWithArray:mutableArray];
    } else if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:JSONObject];
        for (id <NSCopying> key in [(NSDictionary *)JSONObject allKeys]) {
            id value = (NSDictionary *)JSONObject[key];
            if (!value || [value isEqual:[NSNull null]]) {
                [mutableDictionary removeObjectForKey:key];
            } else if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
                mutableDictionary[key] = AFJSONObjectByRemovingKeysWithNullValuesCopy(value, readingOptions);
            }
        }
        
        return (readingOptions & NSJSONReadingMutableContainers) ? mutableDictionary : [NSDictionary dictionaryWithDictionary:mutableDictionary];
    }
    
    return JSONObject;
}


@implementation YMAPIResponse

- (instancetype)initWithResponseString:(NSString *)responseString
                             requsetID:(NSInteger)requestID
                               request:(NSURLRequest *)request
                          responseData:(NSData *)responseData
                                status:(YMAPIResponseStatus)status
{
    if (self = [super init]) {
        self.responseString = responseString;
        self.content = [self conversationData:responseData];
        self.request = request;
        self.requestId = requestID;
        self.responseData = responseData;
        self.status = status;
        self.isCache = NO;
        self.requestParams = request.requestParams;
    }
    return self;
}

- (instancetype)initWithResponseString:(NSString *)responseString
                             requsetID:(NSInteger)requestID
                               request:(NSURLRequest *)request
                          responseData:(NSData *)responseData
                                 error:(NSError *)error
{
    if (self = [super init]) {
        self.responseString = responseString;
        self.request = request;
        self.requestId = requestID;
        self.responseData = responseData;
        self.status = [self responseStatusWithError:error];
        self.isCache = NO;
        self.requestParams = request.requestParams;
        if (responseData) {
            self.content = [self conversationData:responseData];
        } else {
            self.content = nil;
        }
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data{
    if (self = [super init]) {
        
        self.responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        self.status = [self responseStatusWithError:nil];
        self.requestId = 0;
        self.request = nil;
        self.responseData = [data copy];
        self.content = [self conversationData:data];
        self.isCache = YES;
        
    }
    return self;
}


- (YMAPIResponseStatus)responseStatusWithError:(NSError *)error{
    if (error) {
        YMAPIResponseStatus result = YMAPIResponseStatusErrorNoNetwork;
        if (error.code == NSURLErrorTimedOut) {
            result = YMAPIResponseStatusErrorTimeOut;
        }
        return result;
    }else {
        return YMAPIResponseStatusSuccess;
    }
}

/** AF 解决null方法 */
- (NSDictionary *)conversationData:(NSData *)rowData{
    id responseObject = nil;
    NSError *serializationError = nil;
    BOOL isSpace = [rowData isEqualToData:[NSData dataWithBytes:" " length:1]];
    if (rowData.length > 0 && !isSpace) {
        responseObject = [NSJSONSerialization JSONObjectWithData:rowData options:NSJSONReadingMutableContainers
                                                           error:&serializationError];
    } else {
        return nil;
    }
    responseObject = AFJSONObjectByRemovingKeysWithNullValuesCopy(responseObject, NSJSONReadingMutableContainers);
    return responseObject;
}


@end
