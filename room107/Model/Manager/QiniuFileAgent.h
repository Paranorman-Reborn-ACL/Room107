//
//  QiniuFileAgent.h
//  room107
//
//  Created by ningxia on 15/7/23.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QiniuFileAgent : NSObject

+ (instancetype)sharedInstance;

- (void)uploadWithData:(NSData *)data key:(NSString *)key token:(NSString *)token completion:(void (^)(NSError *error))completion;

- (void)uploadWithImageDics:(NSMutableArray *)imageDics token:(NSString *)token completion:(void (^)(NSError *error, NSString *errorMsg))completion;

@end
