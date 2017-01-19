//
//  Client.h
//  room107
//
//  Created by ningxia on 15/6/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPClient.h"

@class OAuth2Token;
@protocol TokenStore;

@interface Client : NSObject

+ (instancetype)sharedClient;

- (NSMutableDictionary *)baseParameters;

@property (nonatomic, copy, readonly) NSString *apiKey;
@property (nonatomic, copy, readonly) NSString *apiSecret;
@property (nonatomic, strong, readonly) HTTPClient *HTTPClient;
@property (nonatomic, strong, readwrite) OAuth2Token *oauthToken;
@property (nonatomic, assign, readonly) BOOL isAuthenticated;
@property (nonatomic, strong) id<TokenStore> tokenStore;

- (instancetype)initWithHTTPClient:(HTTPClient *)client;

- (void)setupWithAPIKey:(NSString *)key secret:(NSString *)secret;

-(AFHTTPRequestOperation *)authenticateAsClientCredentialsTokenWithCompletion:(RequestCompletionBlock)completion;
- (AFHTTPRequestOperation *)authenticateAsUserWithEmail:(NSString *)email password:(NSString *)password completion:(RequestCompletionBlock)completion;
- (AFHTTPRequestOperation *)authenticateAsAppWithID:(NSUInteger)appID token:(NSString *)appToken completion:(RequestCompletionBlock)completion;
- (void)authenticateAutomaticallyAsAppWithID:(NSUInteger)appID token:(NSString *)appToken;

- (AFHTTPRequestOperation *)performRequest:(Request *)request completion:(RequestCompletionBlock)completion;

- (AFHTTPRequestOperation *)GETRequestWithPath:(NSString *)path parameters:(NSDictionary *)parameters completion:(RequestCompletionBlock)completion;
- (AFHTTPRequestOperation *)POSTRequestWithPath:(NSString *)path parameters:(NSDictionary *)parameters completion:(RequestCompletionBlock)completion;
- (AFHTTPRequestOperation *)PUTRequestWithPath:(NSString *)path parameters:(NSDictionary *)parameters completion:(RequestCompletionBlock)completion;
- (AFHTTPRequestOperation *)DELETERequestWithPath:(NSString *)path parameters:(NSDictionary *)parameters completion:(RequestCompletionBlock)completion;

- (AFHTTPRequestOperation *)GETRequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters completion:(RequestCompletionBlock)completion;
- (AFHTTPRequestOperation *)POSTRequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters completion:(RequestCompletionBlock)completion;
- (AFHTTPRequestOperation *)PUTRequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters completion:(RequestCompletionBlock)completion;
- (AFHTTPRequestOperation *)DELETERequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters completion:(RequestCompletionBlock)completion;

- (void)restoreTokenIfNeeded;

@end
