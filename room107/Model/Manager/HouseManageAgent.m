//
//  HouseManageAgent.m
//  room107
//
//  Created by ningxia on 15/8/15.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "HouseManageAgent.h"
#import "NSDictionary+JSONString.h"
#import "NSString+Encoded.h"
#import "NSArray+JSONString.h"

@implementation HouseManageAgent

+ (instancetype)sharedInstance {
    static HouseManageAgent *sharedInstance;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}

- (void)getInfoForAddHouseWithCompletion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *district2UserCount, NSString *telephone, NSString *imageToken, NSString *imageKeyPattern))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/manage/add") parameters:nil completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil, nil, nil, nil);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil, nil, nil, nil);
                } else {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body[@"district2UserCount"], response.body[@"telephone"], response.body[@"imageToken"], response.body[@"imageKeyPattern"]);
                }
            }
        }
    }];
}

- (void)getSubscribeNumberWithPosition:(NSString *)position completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *number, NSArray *subscribes, NSNumber *locationX, NSNumber *locationY))completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:position, @"position", nil];
    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/manage/getSubscribeNumber") parameters:parameters completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil, nil, nil, nil);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil, nil, nil, nil);
                } else {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body[@"number"], response.body[@"subscribes"], response.body[@"locationX"], response.body[@"locationY"]);
                }
            }
        }
    }];
}

- (void)getTokenAndImageKeyPatternWithCompletion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *token, NSString *imageKeyPattern))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/manage/getToken") parameters:nil completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil, nil);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil, nil);
                } else {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body[@"token"], response.body[@"imageKeyPattern"]);
                }
            }
        }
    }];
}

- (void)uploadImagesWithImageKeys:(NSArray *)imageKeys completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *imagesString))completion {
    NSString *imagesKey = imageKeys[0];
    for (NSUInteger i = 1; i < imageKeys.count; i++) {
        //注意赋值
        imagesKey = [imagesKey stringByAppendingFormat:@"|%@", imageKeys[i]];
    }
    NSDictionary *parameters = @{@"imageKeys":imagesKey};
    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/manage/uploadImages") parameters:parameters completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil);
                } else {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body[@"images"]);
                }
            }
        }
    }];
}

- (void)submitSuiteWithSuiteInfo:(NSMutableDictionary *)suiteInfo completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *houseID, NSNumber *number, UserIdentityModel *id, NSString *credentialsImages))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/manage/add/submit") parameters:suiteInfo completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil, nil, nil, nil);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil, nil, nil, nil);
                } else {
                    [UserIdentityModel deleteUserIdentities];
                    
                    UserIdentityModel *id = [UserIdentityModel createObjectWithDictionary:response.body[@"id"]];
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body[@"houseId"], response.body[@"number"], id, response.body[@"credentialsImages"]);
                }
            }
        }
    }];
}

- (void)updateAccountInfoWithName:(NSString *)name andIDCard:(NSString *)idCard andDebitCard:(NSString *)debitCard completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion {
    NSMutableDictionary *accountInfo = [[NSMutableDictionary alloc] init];
    [accountInfo setObject:name forKey:@"name"];
    [accountInfo setObject:idCard forKey:@"idCard"];
    [accountInfo setObject:debitCard forKey:@"debitCard"];
    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/account/updateAccountInfo") parameters:accountInfo completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode]);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
                } else {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
                }
            }
        }
    }];
}

- (void)updateCredentialsImagesWithHouseID:(NSNumber *)houseID andCredentialsImages:(NSString *)credentialsImages completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion {
    NSMutableDictionary *credentialInfo = [[NSMutableDictionary alloc] init];
    [credentialInfo setObject:houseID forKey:@"houseId"];
    [credentialInfo setObject:[credentialsImages URLEncodedString] forKey:@"credentialsImages"];
    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/manage/updateCredentialsImages") parameters:credentialInfo completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode]);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
                } else {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
                }
            }
        }
    }];
}

- (LandlordSuiteItemModel *)saveLandlordSuiteItem:(NSMutableDictionary *)houseJSON {
    [[HouseManageAgent sharedInstance] deleteHouseJSON];
    LandlordSuiteItemModel *landlordSuiteItem = [LandlordSuiteItemModel createObjectWithDictionary:houseJSON];
    
    return landlordSuiteItem;
}

- (void)deleteHouseJSON {
    [LandlordSuiteItemModel deleteSuite];
}

- (NSMutableDictionary *)getHouseJSON {
    NSMutableDictionary *houseJSON = (NSMutableDictionary *)[[[LandlordSuiteItemModel findSuite] dictionaryWithValuesForAllKeys] mutableCopy];
    
    return houseJSON ? houseJSON : [[NSMutableDictionary alloc] init];
}

- (void)manageHouseStatusWithHouseID:(NSNumber *)houseID andRoomID:(NSNumber *)roomID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *imageToken, NSString *imageKeyPattern, NSMutableDictionary *houseJSON))completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:houseID, @"houseId", nil];
    if (roomID) {
        [parameters setObject:roomID forKey:@"roomId"];
    }
    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/manage/status") parameters:parameters completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil, nil, nil);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil, nil, nil);
                } else {
                    NSMutableDictionary *house = [response.body[@"suite"] mutableCopy];
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body[@"imageToken"], response.body[@"imageKeyPattern"], house);
                }
            }
        }
    }];
}

- (void)fillPriceWithUnits:(NSMutableArray *)units completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion {
    //将NSMutableArray序列化为JSON格式
    NSString *unitJSON = [units JSONRepresentationWithPrettyPrint:YES];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:unitJSON, @"units", nil];
    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/manage/fillPrice") parameters:parameters completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode]);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
                } else {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
                }
            }
        }
    }];
}

- (void)updateHouseWithHouseInfo:(NSMutableDictionary *)houseInfo completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/manage/updateHouse") parameters:houseInfo completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode]);
            } else {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
            }
        }
    }];
}

- (void)updateRoomWithHouseID:(NSNumber *)houseID andRoomJSON:(NSMutableDictionary *)roomJSON completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *roomID))completion {
    NSString *encodedHouseJSON = [[roomJSON JSONRepresentationWithPrettyPrint:YES] URLEncodedString];
    NSMutableDictionary *roomInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:encodedHouseJSON, @"room", nil];
    [roomInfo setObject:houseID forKey:@"houseId"];
    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/manage/updateRoom") parameters:roomInfo completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
            } else {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body[@"roomId"]);
            }
        }
    }];
}

- (void)updateHouseStatusWithHouseID:(NSNumber *)houseID andRoomID:(NSNumber *)roomID andStatus:(NSNumber *)status completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (houseID) {
        [parameters setObject:houseID forKey:@"houseId"];
    }
    if (roomID) {
        [parameters setObject:roomID forKey:@"roomId"];
    }
    if (status) {
        [parameters setObject:status forKey:@"status"];
    }
    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/manage/updateStatus") parameters:parameters completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode]);
            } else {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
            }
        }
    }];
}

- (void)getHouseImagesWithHouseID:(NSNumber *)houseID andRoomID:(NSNumber *)roomID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *imageIds, NSString *cover))completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (houseID) {
        [parameters setObject:houseID forKey:@"houseId"];
    }
    if (roomID) {
        [parameters setObject:roomID forKey:@"roomId"];
    }
    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/manage/getImages") parameters:parameters completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil, nil);
            } else {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body[@"imageIds"], response.body[@"cover"]);
            }
        }
    }];
}

- (void)updateHouseCoverWithHouseID:(NSNumber *)houseID andRoomID:(NSNumber *)roomID andImageURL:(NSString *)imageURL completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (houseID) {
        [parameters setObject:houseID forKey:@"houseId"];
    }
    if (roomID) {
        [parameters setObject:roomID forKey:@"roomId"];
    }
    if (imageURL) {
        [parameters setObject:imageURL forKey:@"imageId"];
    }
    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/manage/updateCover") parameters:parameters completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode]);
            } else {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
            }
        }
    }];
}

@end
