//
//  HTTPClient.m
//  room107
//
//  Created by ningxia on 15/6/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "HTTPClient.h"
#import "RequestSerializer.h"
#import "Client.h"

#import "NSURLRequest+Description.h"

//static NSString * const kDefaultBaseURLString = ConfigBaseDomain;
NSString * kDefaultBaseURLString = ConfigBaseDomain;
NSString * const kDefaultAPIVerson = @"/app";
static NSTimeInterval timeoutInterval = 10; //超时时间 单位 秒


@interface HTTPClient ()
@property (nonatomic, strong) NSMutableDictionary *requestEtagsDictionary;
@end

@implementation HTTPClient

- (instancetype)init {
    id object = [Room107UserDefaults getValueFromUserDefaultsWithKey:KEY_BASEURL];
    if (object) {
        kDefaultBaseURLString = object;
    }
    NSURL *baseURL = [[NSURL alloc] initWithString:kDefaultBaseURLString];
    self = [super initWithBaseURL:baseURL];
    if (!self) return nil;
    
    self.requestSerializer = [RequestSerializer serializer];
    
    // We need to provide a fallback response serializer if the response is not of JSON content type.
    // The regular AFHTTPResponseSerializer will simply return the raw NSData of the response.
    NSArray *responseSerializers = @[[AFJSONResponseSerializer serializer],
                                     [AFHTTPResponseSerializer serializer]];
    self.responseSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:responseSerializers];
    
    [self loadRequestEtags];
    
    return self;
}

- (void)loadRequestEtags {
    NSDictionary *requestEtags = [NSKeyedUnarchiver unarchiveObjectWithFile:[AppConfig requestEtagsCachePath]];
    self.requestEtagsDictionary = [requestEtags mutableCopy];
    if (self.requestEtagsDictionary == nil) {
        self.requestEtagsDictionary = [NSMutableDictionary dictionary];
    }
}

- (void)saveRequestEtags {
    if ([NSKeyedArchiver archiveRootObject: self.requestEtagsDictionary toFile:[AppConfig requestEtagsCachePath]]) {
        LogDebug(@"Archiver  success");
    }
}

#pragma mark - Public

- (void)resetRequestETags {
    self.requestEtagsDictionary = [NSMutableDictionary dictionary];
}

- (void)changeBaseDomain:(NSString *)domain {
    kDefaultBaseURLString = domain;
    NSURL *baseURL = [[NSURL alloc] initWithString:kDefaultBaseURLString];
    [super changeBaseURL:baseURL];
}

- (NSString *)baseDomain {
    return kDefaultBaseURLString;
}

- (void)setValue:(NSString *)value forHTTPHeader:(NSString *)header {
    [self.requestSerializer setValue:value forHTTPHeaderField:header];
}

- (void)setCookieValue:(NSString *)value forName:(NSString *)name {
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:name forKey:NSHTTPCookieName];
    [cookieProperties setObject:value forKey:NSHTTPCookieValue];
    [cookieProperties setObject:@".107room.com" forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:@".107room.com" forKey:NSHTTPCookieOriginURL];
    [cookieProperties setObject:[NSDate dateWithTimeIntervalSinceNow:3600 * 24] forKey:NSHTTPCookieExpires];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
}

- (void)setAuthorizationHeaderWithOAuth2AccessToken:(NSString *)accessToken {
    NSParameterAssert(accessToken);
    [(RequestSerializer *)self.requestSerializer setAuthorizationHeaderFieldWithOAuth2AccessToken:accessToken];
}

- (void)setAuthorizationHeaderWithAPIKey:(NSString *)key secret:(NSString *)secret {
    [self.requestSerializer setAuthorizationHeaderFieldWithUsername:key password:secret];
}

- (AFHTTPRequestOperation *)operationWithRequest:(Request *)request completion:(RequestCompletionBlock)completion {
    // 设置超时时间
    [self.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    self.requestSerializer.timeoutInterval = timeoutInterval;
    [self.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    if (request.method == RequestMethodGET) {
        NSString *etag = [self.requestEtagsDictionary objectForKey:request.path];
        [self setValue:etag forHTTPHeader:@"If-None-Match"];
    }
    NSURLRequest *urlRequest = [(RequestSerializer *)self.requestSerializer URLRequestForRequest:request relativeToURL:self.baseURL];
    LogDebug(@"urlRequest = %@", [urlRequest description]);
    WEAK_SELF weakSelf = self;
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:urlRequest success:^(AFHTTPRequestOperation *operation, id responseObject) {
        STRONG(weakSelf) strongSelf = weakSelf;
        NSUInteger statusCode = operation.response.statusCode;
        //将NSData格式的数据解析为JSON格式
        responseObject = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        Response * response = [[Response alloc] initWithStatusCode:statusCode body:responseObject];
        NSString *etag = [operation.response.allHeaderFields objectForKey:@"ETag"];
        if (etag) {
            [strongSelf.requestEtagsDictionary setObject:etag forKey:request.path];
            [strongSelf saveRequestEtags];
        }
        if (completion) completion(response, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSUInteger statusCode = operation.response.statusCode;
        Response *response = [[Response alloc] initWithStatusCode:statusCode body:operation.responseObject];
        
        if (completion) completion(response, error);
    }];
    
    // If this is a download request with a provided local file path, configure an output stream instead
    // of buffering the data in memory.
    if (request.method == RequestMethodGET && request.fileData.filePath) {
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:request.fileData.filePath append:NO];
    }
    
    return operation;
}

@end
