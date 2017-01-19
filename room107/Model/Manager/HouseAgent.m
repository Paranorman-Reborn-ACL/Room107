//
//  HouseAgent.m
//  room107
//
//  Created by ningxia on 15/6/18.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "HouseAgent.h"
#import "HouseModel+CoreData.h"

@implementation HouseAgent

+ (instancetype)sharedInstance {
    static HouseAgent *sharedInstance;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}


- (void)getHouseByID:(NSUInteger)houseID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, HouseModel *house))completion {
    HouseModel *house = [HouseModel findHouseByHouseID:houseID];
    if (completion && house) {
        completion(nil, nil, nil, house);
    }
    
    [[Client sharedClient] GETRequestWithPath:RequestPath(@"/house/r%lu/", (unsigned long)houseID) parameters:nil completion:^(Response *response, NSError *error) {
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
        } else {
            HouseModel *house = [HouseModel createObjectWithDictionary:response.body[@"suite"][@"house"]];
            completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], house);
        }
    }];
}

@end
