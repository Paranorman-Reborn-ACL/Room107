//
//  HTTPClient.h
//  room107
//
//  Created by ningxia on 15/6/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "Request.h"
#import "Response.h"

extern NSString * const kDefaultAPIVerson;

typedef void(^RequestCompletionBlock)(Response *response, NSError *error);

@interface HTTPClient : AFHTTPRequestOperationManager

/// 退出登录时，重置缓存的请求ETags
- (void)resetRequestETags;

/// 切换域名
- (void)changeBaseDomain:(NSString *)domain;

- (NSString *)baseDomain;

- (void)setValue:(NSString *)value forHTTPHeader:(NSString *)header;
- (void)setCookieValue:(NSString *)value forName:(NSString *)name;
- (void)setAuthorizationHeaderWithOAuth2AccessToken:(NSString *)accessToken;
- (void)setAuthorizationHeaderWithAPIKey:(NSString *)key secret:(NSString *)secret;

- (AFHTTPRequestOperation *)operationWithRequest:(Request *)request completion:(RequestCompletionBlock)completion;

@end
