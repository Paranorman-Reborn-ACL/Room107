//
//  QiniuFileAgent.m
//  room107
//
//  Created by ningxia on 15/7/23.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "QiniuFileAgent.h"
#import "QiniuSDK.h"

@interface QiniuFileAgent()

@property (nonatomic, strong) QNUploadManager *uploadManager;
@property (nonatomic, strong) void(^dateDidChangeHandler)(NSDate *date);

@end

@implementation QiniuFileAgent

+ (instancetype)sharedInstance {
    static QiniuFileAgent *sharedInstance;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        sharedInstance = [self new];
        sharedInstance.uploadManager = [QNUploadManager sharedInstanceWithConfiguration:nil];
    });
    
    return sharedInstance;
}

- (void)uploadWithData:(NSData *)data key:(NSString *)key token:(NSString *)token completion:(void (^)(NSError *error))completion {
    [_uploadManager putData:data key:key token:token complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        if (completion) {
            if (info.statusCode == 200) {
                completion(nil);
            } else {
                completion(info.error);
            }
        }
    } option:nil];
}

- (void)uploadWithImageDics:(NSMutableArray *)imageDics token:(NSString *)token completion:(void (^)(NSError *error, NSString *errorMsg))completion {
    if (imageDics.count > 0) {
        NSDictionary *imageDic = imageDics[0];
        //图片压缩
        NSData *imageData = UIImageJPEGRepresentation(imageDic[@"image"], 1);
        NSUInteger length = [imageData length] / 1000;
        if (length > 500) {
            imageData = UIImageJPEGRepresentation(imageDic[@"image"], sqrt(500 / length));
        } else if (length > 200) {
            imageData = UIImageJPEGRepresentation(imageDic[@"image"], sqrt(200 / length));
        }
        
        [self uploadWithData:imageData key:imageDic[@"key"] token:token completion:^(NSError *error) {
            if (!error) {
                [imageDics removeObject:imageDic];
                
                [self uploadWithImageDics:imageDics token:token completion:^(NSError *error, NSString *errorMsg) {
                    completion(error, lang(@"UnknownError"));
                }];
            } else {
                completion(error, lang(@"UnknownError"));
            }
        }];
    } else {
        completion(nil, nil);
    }
}

@end
