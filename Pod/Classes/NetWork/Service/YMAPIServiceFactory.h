//
//  YMAPIServiceFactory.h
//  NetWork1
//
//  Created by TJ on 2017/6/6.
//  Copyright © 2017年 TJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMAPIService.h"

@interface YMAPIServiceFactory : NSObject

+ (instancetype)sharedInstance;

- (YMAPIService<YMAPIServiceProtocol> *)serviceWithIdentifier:(NSString *)identifier;


@end
