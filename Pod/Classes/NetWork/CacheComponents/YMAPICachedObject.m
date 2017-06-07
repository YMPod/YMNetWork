//
//  YMAPICachedObject.m
//  NetWork1
//
//  Created by TJ on 2017/6/6.
//  Copyright © 2017年 TJ. All rights reserved.
//

#import "YMAPICachedObject.h"
#import "YMNetWorkManager.h"
@interface  YMAPICachedObject()

@property (nonatomic, copy, readwrite) NSData *content;
@property (nonatomic, copy, readwrite) NSDate *lastUpdateTime;

@end

@implementation YMAPICachedObject
#pragma mark - life cycle
- (instancetype)initWithContent:(NSData *)content
{
    self = [super init];
    if (self) {
        self.content = content;
    }
    return self;
}

#pragma mark - public method
- (void)updateContent:(NSData *)content
{
    self.content = content;
}
#pragma mark - getters and setters
- (BOOL)isEmpty
{
    return self.content == nil;
}

- (BOOL)isOutdated
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastUpdateTime];
    NSTimeInterval maxTimeInterval = 20;
    if ([YMNetWorkManager manager].cacheTimeOutDelegate && [[YMNetWorkManager manager].cacheTimeOutDelegate respondsToSelector:@selector(globalCacheTimeOut)]) {
        maxTimeInterval = [[YMNetWorkManager manager].cacheTimeOutDelegate globalCacheTimeOut];
    }
    return timeInterval > maxTimeInterval;
}

- (void)setContent:(NSData *)content
{
    _content = [content copy];
    self.lastUpdateTime = [NSDate dateWithTimeIntervalSinceNow:0];
}

@end
