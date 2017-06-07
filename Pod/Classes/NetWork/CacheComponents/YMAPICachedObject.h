//
//  YMAPICachedObject.h
//  NetWork1
//
//  Created by TJ on 2017/6/6.
//  Copyright © 2017年 TJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMCacheTimeOutProtocol.h"

@interface YMAPICachedObject : NSObject

@property (nonatomic, copy, readonly) NSData *content;
@property (nonatomic, copy, readonly) NSDate *lastUpdateTime;

@property (nonatomic, assign, readonly) BOOL isOutdated;
@property (nonatomic, assign, readonly) BOOL isEmpty;


- (instancetype)initWithContent:(NSData *)content;
- (void)updateContent:(NSData *)content;

@end
