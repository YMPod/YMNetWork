//
//  YMAPICache.m
//  NetWork1
//
//  Created by TJ on 2017/6/6.
//  Copyright © 2017年 TJ. All rights reserved.
//

#import "YMAPICache.h"
#import "YMAPICachedObject.h"
#import "NSDictionary+YMAPITools.h"
@interface YMAPICache ()

@property (nonatomic,strong) NSCache *cache;


@end

@implementation YMAPICache
#pragma mark - lift cycle
+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static YMAPICache *shareInstance;
    dispatch_once(&onceToken, ^{
        shareInstance = [[YMAPICache alloc] init];
    });
    return shareInstance;
}

#pragma mark - Publish Methods
- (NSData *)fetchCachedDataWithServiceIdentifier:(NSString *)serviceIdentifier
                                      methodName:(NSString *)methodName
                                   requestParams:(NSDictionary *)requestParams
{
    return [self fetchCachedDataWithKey:[self keyWithServiceIdentifier:serviceIdentifier
                                                            methodName:methodName
                                                         requsetParams:requestParams]];
}

- (void)saveCacheWithData:(NSData *)cachedData
        serviceIdentifier:(NSString *)serviceIdentifier
               methodName:(NSString *)methodName requestParams:(NSDictionary *)requestParams
{
    [self saveCacheWithData:cachedData key:[self keyWithServiceIdentifier:serviceIdentifier
                                                               methodName:methodName
                                                            requsetParams:requestParams]];
}

- (void)deleteCacheWithKey:(NSString *)key
{
    [self.cache removeObjectForKey:key];
}

- (void)clean
{
    [self.cache removeAllObjects];
}


#pragma mark - Private Methods
- (void)saveCacheWithData:(NSData *)cachedData key:(NSString *)key
{
    YMAPICachedObject *cachedObject = [self.cache objectForKey:key];
    if (cachedObject == nil) {
        cachedObject = [[YMAPICachedObject alloc] init];
    }
    [cachedObject updateContent:cachedData];
    [self.cache setObject:cachedObject forKey:key];
}

- (NSData *)fetchCachedDataWithKey:(NSString *)key
{
    YMAPICachedObject *cachedObject = [self.cache objectForKey:key];
    if (cachedObject.isOutdated || cachedObject.isEmpty) {
        return nil;
    } else {
        return cachedObject.content;
    }
}

- (NSString *)keyWithServiceIdentifier:(NSString *)identifier
                            methodName:(NSString *)methodName
                         requsetParams:(NSDictionary *)requestParams{
    return [NSString stringWithFormat:@"%@%@%@",identifier,methodName,[requestParams YMAPIDicUrlParamsString]];
    
}

#pragma mark - Getter and Setter

- (NSCache *)cache{
    if (!_cache) {
        _cache = [[NSCache alloc] init];
        //缓存最大条数
        _cache.countLimit = 1000;
    }
    return _cache;
}
@end
