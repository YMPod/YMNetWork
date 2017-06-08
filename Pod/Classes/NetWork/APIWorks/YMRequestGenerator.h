//
//  YMRequestGenerator.h
//  NetWork1
//
//  Created by TJ on 2017/6/6.
//  Copyright © 2017年 TJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMRequestGeneratorProtocol.h"
#import "YMMultipartFormData.h"
@interface YMRequestGenerator : NSObject


+ (instancetype)shareInstance;

@property (nonatomic,assign) id<YMRequestGeneratorProtocol> genDelegate;

- (NSURLRequest *)generateRequestWithParams:(NSDictionary *)params
                          serviceIdentifier:(NSString *)identifier
                                 methodName:(NSString *)methodName
                                requestType:(NSString *)type
                               headerFields:(NSDictionary *)fields;

- (NSURLRequest *)generateUploadRequestWithParams:(NSDictionary *)params
                                serviceIdentifier:(NSString *)identifier
                                       methodName:(NSString *)methodName
                                      requestType:(NSString *)type
                                     headerFields:(NSDictionary *)fields
                                         fileData:(void (^)(id<YMMultipartFormData>   formData))block;

@end
