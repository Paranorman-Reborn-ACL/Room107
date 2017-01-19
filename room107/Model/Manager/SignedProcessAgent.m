//
//  SignedProcessAgent.m
//  room107
//
//  Created by ningxia on 15/8/3.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "SignedProcessAgent.h"
#import "RSA.h"

@implementation SignedProcessAgent

+ (instancetype)sharedInstance {
    static SignedProcessAgent *sharedInstance;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}

- (void)tenantGetContractPeriodWithCheckTime:(NSString *)checkTime andExitTime:(NSString *)exitTime completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *contractStatus, NSNumber *year, NSNumber *month, NSNumber *day, NSString *finishDate, NSString *title, NSString *content))completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (checkTime) {
        [parameters setObject:checkTime forKey:@"checkinTime"];
    }
    if (exitTime) {
        [parameters setObject:exitTime forKey:@"exitTime"];
    }
    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/contract/getPeriod") parameters:parameters completion:^(Response *response, NSError *error) {
        NSNumber *status = nil;
        NSNumber *year = nil;
        NSNumber *month = nil;
        NSNumber *day = nil;
        NSString *finishDate = nil;
        NSString *title = nil;
        NSString *content = nil;
        
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], status, year, month, day, finishDate, title, content);
        }else {
            if ([response.body[@"status"] isEqualToNumber:@(-1)]) {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], status, year, month, day, finishDate, title, content);
            } else {
                status = response.body[@"status"];
                title = response.body[@"title"];
                content = response.body[@"content"];
                year = response.body[@"period"][@"year"];
                month = response.body[@"period"][@"month"];
                day = response.body[@"period"][@"day"];
                finishDate = response.body[@"period"][@"finish"];
                
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], status, year, month, day, finishDate, title, content);
            }
        }
    }];

}

- (void)tenantGetContractStatusWithHouseID:(NSNumber *)houseID andRoomID:(NSNumber *)roomID andContractID:(NSNumber *)contractID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *contractStatus, NSNumber *contractEditStatus, UserIdentityModel *userIdentity, ContractInfoModel *contractInfo, NSArray *diff, NSString *auditNote))completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (houseID) {
        [parameters setObject:houseID forKey:@"houseId"];
    }
    if (roomID) {
        [parameters setObject:roomID forKey:@"roomId"];
    }
    if (contractID) {
        [parameters setObject:contractID forKey:@"contractId"];
    }
    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/contract/tenant/status") parameters:parameters completion:^(Response *response, NSError *error) {
        NSNumber *contractStatus = nil;
        NSNumber *contractEditStatus = nil;
        UserIdentityModel *userIdentity = nil;
        ContractInfoModel *contractInfo = nil;
        NSArray *diff = nil;
        NSString *auditNote = nil;
        
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], contractStatus, contractEditStatus, userIdentity, contractInfo, diff, auditNote);
        } else {
            if ([response.body[@"status"] isEqualToNumber:@-1]) {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil, nil, nil, nil, nil, nil);
            } else {
                [UserIdentityModel deleteUserIdentities];
                [ContractInfoModel deleteContractInfos];
                
                contractStatus = response.body[@"contractStatus"];
                contractEditStatus = response.body[@"contractEditStatus"];
                userIdentity = [UserIdentityModel createObjectWithDictionary:response.body[@"identity"]];
                contractInfo = [ContractInfoModel createObjectWithDictionary:response.body[@"contractInfo"]];
                if (!response.body[@"contractInfo"][@"payingType"]) {
                    contractInfo.payingType = @1;//默认为押一付三
                }
                diff = response.body[@"diff"];
                auditNote = response.body[@"auditNote"];
                
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], contractStatus, contractEditStatus, userIdentity, contractInfo, diff, auditNote);
            }
        }
    }];
}

- (void)tenantUpdateContractWithInfo:(NSMutableDictionary *)info completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *contractStatus, NSNumber *contractEditStatus, UserIdentityModel *userIdentity, ContractInfoModel *contractInfo))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/contract/tenant/updateInfo") parameters:info completion:^(Response *response, NSError *error) {
        NSNumber *contractStatus = nil;
        NSNumber *contractEditStatus = nil;
        UserIdentityModel *userIdentity = nil;
        ContractInfoModel *contractInfo = nil;
        
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil, nil, nil, nil);
        } else {
            if ([response.body[@"status"] isEqualToNumber:@-1]) {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], contractStatus, contractEditStatus, userIdentity, contractInfo);
            } else {
                [UserIdentityModel deleteUserIdentities];
                [ContractInfoModel deleteContractInfos];
                
                contractStatus = response.body[@"contractStatus"];
                contractEditStatus = response.body[@"contractEditStatus"];
                userIdentity = [UserIdentityModel createObjectWithDictionary:response.body[@"identity"]];
                contractInfo = [ContractInfoModel createObjectWithDictionary:response.body[@"contractInfo"]];
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], contractStatus, contractEditStatus, userIdentity, contractInfo);
            }
        }
    }];
}

- (void)tenantConfirmContractWithContractID:(NSNumber *)contractID andPassword:(NSString *)password completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *contractStatus, NSNumber *contractEditStatus, UserIdentityModel *userIdentity, ContractInfoModel *contractInfo))completion {
    password = [RSA encryptString:password publicKey:[Room107UserDefaults getPublicKeyString]];
    NSDictionary *parameters = @{@"contractId":contractID, @"password":password, @"timestamp":[NSString stringWithFormat:@"%.f000", [NSDate date].timeIntervalSince1970]};
    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/contract/tenant/confirm") parameters:parameters completion:^(Response *response, NSError *error) {
        NSNumber *contractStatus = nil;
        NSNumber *contractEditStatus = nil;
        UserIdentityModel *userIdentity = nil;
        ContractInfoModel *contractInfo = nil;
        
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil, nil, nil, nil);
        } else {
            if ([response.body[@"status"] isEqualToNumber:@-1]) {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], contractStatus, contractEditStatus, userIdentity, contractInfo);
            } else {
                [UserIdentityModel deleteUserIdentities];
                [ContractInfoModel deleteContractInfos];
                
                contractStatus = response.body[@"contractStatus"];
                contractEditStatus = response.body[@"contractEditStatus"];
                userIdentity = [UserIdentityModel createObjectWithDictionary:response.body[@"identity"]];
                contractInfo = [ContractInfoModel createObjectWithDictionary:response.body[@"contractInfo"]];
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], contractStatus, contractEditStatus, userIdentity, contractInfo);
            }
        }
    }];
}

- (void)tenantReletContractWithContractID:(NSNumber *)contractID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *contractStatus, NSNumber *contractEditStatus, UserIdentityModel *userIdentity, ContractInfoModel *contractInfo))completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:contractID, @"contractId", nil];
    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/contract/relet") parameters:parameters completion:^(Response *response, NSError *error) {
        NSNumber *contractStatus = nil;
        NSNumber *contractEditStatus = nil;
        UserIdentityModel *userIdentity = nil;
        ContractInfoModel *contractInfo = nil;
        
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil, nil, nil, nil);
        } else {
            if ([response.body[@"status"] isEqualToNumber:@-1]) {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], contractStatus, contractEditStatus, userIdentity, contractInfo);
            } else {
                [UserIdentityModel deleteUserIdentities];
                [ContractInfoModel deleteContractInfos];
                
                contractStatus = response.body[@"contractStatus"];
                contractEditStatus = response.body[@"contractEditStatus"];
                userIdentity = [UserIdentityModel createObjectWithDictionary:response.body[@"identity"]];
                contractInfo = [ContractInfoModel createObjectWithDictionary:response.body[@"contractInfo"]];
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], contractStatus, contractEditStatus, userIdentity, contractInfo);
            }
        }
    }];
}

- (void)landlordGetContractStatusWithContractID:(NSNumber *)contractID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *contractStatus, NSNumber *contractEditStatus, UserIdentityModel *userIdentity, ContractInfoModel *contractInfo, NSArray *diff, NSString *auditNote))completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:contractID ? contractID : @0, @"contractId", nil];
    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/contract/landlord/status") parameters:parameters completion:^(Response *response, NSError *error) {
        NSNumber *contractStatus = nil;
        NSNumber *contractEditStatus = nil;
        UserIdentityModel *userIdentity = nil;
        ContractInfoModel *contractInfo = nil;
        NSArray *diff = nil;
        NSString *auditNote = nil;
        
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil, nil, nil, nil, nil, nil);
        } else {
            if ([response.body[@"status"] isEqualToNumber:@-1]) {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], contractStatus, contractEditStatus, userIdentity, contractInfo, diff, auditNote);
            } else {
                [UserIdentityModel deleteUserIdentities];
                [ContractInfoModel deleteContractInfos];
                
                contractStatus = response.body[@"contractStatus"];
                contractEditStatus = response.body[@"contractEditStatus"];
                userIdentity = [UserIdentityModel createObjectWithDictionary:response.body[@"identity"]];
                contractInfo = [ContractInfoModel createObjectWithDictionary:response.body[@"contractInfo"]];
                diff = response.body[@"diff"];
                auditNote = response.body[@"auditNote"];
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], contractStatus, contractEditStatus, userIdentity, contractInfo, diff, auditNote);
            }
        }
    }];
}

- (void)landlordUpdateContractWithInfo:(NSMutableDictionary *)info completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *contractStatus, NSNumber *contractEditStatus, UserIdentityModel *userIdentity, ContractInfoModel *contractInfo))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/contract/landlord/updateInfo") parameters:info completion:^(Response *response, NSError *error) {
        NSNumber *contractStatus = nil;
        NSNumber *contractEditStatus = nil;
        UserIdentityModel *userIdentity = nil;
        ContractInfoModel *contractInfo = nil;
        
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil, nil, nil, nil);
        } else {
            if ([response.body[@"status"] isEqualToNumber:@-1]) {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], contractStatus, contractEditStatus, userIdentity, contractInfo);
            } else {
                [UserIdentityModel deleteUserIdentities];
                [ContractInfoModel deleteContractInfos];
                
                contractStatus = response.body[@"contractStatus"];
                contractEditStatus = response.body[@"contractEditStatus"];
                userIdentity = [UserIdentityModel createObjectWithDictionary:response.body[@"identity"]];
                contractInfo = [ContractInfoModel createObjectWithDictionary:response.body[@"contractInfo"]];
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], contractStatus, contractEditStatus, userIdentity, contractInfo);
            }
        }
    }];
}

- (void)landlordConfirmContractWithContractID:(NSNumber *)contractID andPassword:(NSString *)password andInfo:(NSMutableDictionary *)info completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSNumber *contractStatus, NSNumber *contractEditStatus, UserIdentityModel *userIdentity, ContractInfoModel *contractInfo))completion {
    password = [RSA encryptString:password publicKey:[Room107UserDefaults getPublicKeyString]];
    [info setObject:[NSString stringWithFormat:@"%.f000", [NSDate date].timeIntervalSince1970] forKey:@"timestamp"];
    [info setObject:contractID forKey:@"contractId"];
    [info setObject:password forKey:@"password"];
    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/contract/landlord/confirm") parameters:info completion:^(Response *response, NSError *error) {
        NSNumber *contractStatus = nil;
        NSNumber *contractEditStatus = nil;
        UserIdentityModel *userIdentity = nil;
        ContractInfoModel *contractInfo = nil;
        
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil, nil, nil, nil);
        } else {
            if ([response.body[@"status"] isEqualToNumber:@-1]) {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], contractStatus, contractEditStatus, userIdentity, contractInfo);
            } else {
                [UserIdentityModel deleteUserIdentities];
                [ContractInfoModel deleteContractInfos];
                
                contractStatus = response.body[@"contractStatus"];
                contractEditStatus = response.body[@"contractEditStatus"];
                userIdentity = [UserIdentityModel createObjectWithDictionary:response.body[@"identity"]];
                contractInfo = [ContractInfoModel createObjectWithDictionary:response.body[@"contractInfo"]];
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], contractStatus, contractEditStatus, userIdentity, contractInfo);
            }
        }
    }];
}

- (void)landlordDiscardContractWithContractID:(NSNumber *)contractID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:contractID ? contractID : @0, @"contractId", nil];
    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/contract/landlord/discard") parameters:parameters completion:^(Response *response, NSError *error) {
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
