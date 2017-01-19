//
//  NXURLHandler.h
//  room107
//
//  Created by ningxia on 15/9/9.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NXURLHandler : NSObject

+ (NXURLHandler *)sharedInstance;

- (BOOL)handleOpenURL:(NSString *)targetURL params:(NSDictionary *)params context:(id)context;
- (UIViewController *)viewControllerFromModule:(NSString *)name;

@end
