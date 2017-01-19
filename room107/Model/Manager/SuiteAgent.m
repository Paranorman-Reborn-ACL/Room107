//
//  SuiteAgent.m
//  room107
//
//  Created by ningxia on 15/6/24.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "SuiteAgent.h"
#import "HouseModel+CoreData.h"
#import "UserModel+CoreData.h"
#import "RoomModel+CoreData.h"
#import "Room107UserDefaults.h"
#import "InterestListItemModel+CoreData.h"
#import "RentedHouseItemModel+CoreData.h"
#import "RentedHouseListItemModel+CoreData.h"
#import "LandlordHouseListItemModel+CoreData.h"
#import "ContractRequestModel+CoreData.h"
#import "LandlordHouseItemModel+CoreData.h"
#import "HouseListItemModel+CoreData.h"
#import "SubscribeModel+CoreData.h"
#import "NSString+Encoded.h"

@implementation SuiteAgent

+ (instancetype)sharedInstance {
    static SuiteAgent *sharedInstance;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}

- (void)getContactWithHouseID:(NSNumber *)houseID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *contact, NSNumber *authStatus))completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:houseID, @"houseId", nil];
    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/contact") parameters:parameters completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil, nil);
            } else {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body[@"contact"], response.body[@"authStatus"]);
            }
        }
    }];
}

- (void)getSuiteByID:(NSNumber *)ID andRentType:(NSUInteger)type completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, SuiteModel *))completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];

    if (type == 1) {
        if (ID) {
            [parameters setObject:ID forKey:@"roomId"];
        }
        
        RoomModel *room = [RoomModel findRoomByID:[ID longLongValue]];
        if (room) {
            UserModel *landlord = [UserModel findUserByUsername:room.username];
            HouseModel *house = [HouseModel findHouseByHouseID:[room.houseId longLongValue]];
            SuiteModel *suite = [SuiteModel createObject];
            suite.rooms = [RoomModel findRoomsByHouseID:[room.houseId longLongValue]];
            //将此ID的房间置前
            if ([suite.rooms count] > 0) {
                RoomModel *firstRoom = suite.rooms[0];
                if (![firstRoom.id isEqual:ID]) {
                    for (RoomModel *room in suite.rooms) {
                        if ([room.id isEqual:ID]) {
                            NSMutableArray *rooms = [suite.rooms mutableCopy];
                            [rooms replaceObjectAtIndex:0 withObject:room];
                            [rooms replaceObjectAtIndex:[suite.rooms indexOfObject:room] withObject:firstRoom];
                            suite.rooms = [rooms copy];
                            break;
                        }
                    }
                }
            }
            suite.landlord = landlord;
            suite.house = house;
            
            if (completion && suite) {
                completion(nil, nil, nil, suite);
            }
        }
    } else {
        if (ID) {
            [parameters setObject:ID forKey:@"houseId"];
        }
        
        HouseModel *house = [HouseModel findHouseByHouseID:[ID longLongValue]];
        if (house) {
            UserModel *landlord = [UserModel findUserByUsername:house.username];
            SuiteModel *suite = [SuiteModel createObject];
            suite.rooms = [RoomModel findRoomsByHouseID:[house.id longLongValue]];
            suite.landlord = landlord;
            suite.house = house;
            
            if (completion && suite) {
                completion(nil, nil, nil, suite);
            }
        }
    }
    
    NSString *path = RequestPath(@"/house/%@/", type == 1 ? @"roomDetail" : @"houseDetail");
    
    [[Client sharedClient] GETRequestWithPath:path parameters:parameters completion:^(Response *response, NSError *error) {
        SuiteModel *suite = nil;
        
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
        } else {
            HouseModel *house = [HouseModel createObjectWithDictionary:response.body[@"suite"][@"house"]];
            
            UserModel *landlord = [UserModel createObjectWithDictionary:response.body[@"suite"][@"landlord"]];

            suite = [SuiteModel createObject];
            suite.id = house.id;
            
            NSMutableArray *rooms = [[NSMutableArray alloc] init];
            for (NSDictionary *roomDic in response.body[@"suite"][@"rooms"]) {
                [RoomModel deleteRoomByID:[roomDic[@"id"] longLongValue]];
                RoomModel *room = [RoomModel createObjectWithDictionary:roomDic];
                [rooms addObject:room];
            }
            suite.rooms = rooms;
            
            NSMutableArray *recommendHouses = [[NSMutableArray alloc] init];
            for (NSDictionary *recommendHouse in response.body[@"suite"][@"recommendHouses"]) {
                HouseListItemModel *houseListItem = [HouseListItemModel createObjectWithDictionary:recommendHouse];
                //手动标记username
                NSString *username = platformKey;
                if ([[AppClient sharedInstance] isLogin]) {
                    username = [[AppClient sharedInstance] username];
                }
                houseListItem.username = username;
                [houseListItem save];
                [recommendHouses addObject:houseListItem];
            }
            suite.recommendHouses = recommendHouses;
            suite.landlord = landlord;
            suite.house = house;
            suite.isInterest = response.body[@"suite"][@"isInterest"];
            suite.cotenants = response.body[@"suite"][@"cotenants"];
            suite.isCotenant = response.body[@"suite"][@"isCotenant"];
            suite.hasContract = response.body[@"suite"][@"hasContract"];
            
            completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], suite);
        }
    }];
}

- (void)getMapItemsWithFilter:(NSMutableDictionary *)filter completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *items, NSString *position, NSString *locationX, NSString *locationY, NSNumber *alert, NSString *alertTitle, NSString *alertContent, NSString *total))completion {
     [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/search") parameters:filter completion:^(Response *response, NSError *error) {
         NSArray *items = nil;
         if (error) {
             completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil, nil, nil, nil, nil, nil, nil, nil);
         } else {
             if ([response.body[@"status"] isEqualToNumber:@-1]) {
                 completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], items, response.body[@"position"], response.body[@"locationX"], response.body[@"locationY"], response.body[@"alert"], response.body[@"alertTitle"], response.body[@"alertContent"], response.body[@"total"]);
             } else {
                 items = [response.body[@"items"] mappedArrayWithBlock:^id(id dict) {
                     //手动标记username
                     NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                     NSString *username = platformKey;
                     if ([[AppClient sharedInstance] isLogin]) {
                         username = [[AppClient sharedInstance] username];
                     }
                     [mutableDict setObject:username ? username : platformKey forKey:@"username"];
                     return [HouseListItemModel createObjectWithDictionary:[mutableDict copy]];
                 }];
                 
                 completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], items, response.body[@"position"], response.body[@"locationX"], response.body[@"locationY"], response.body[@"alert"], response.body[@"alertTitle"], response.body[@"alertContent"], response.body[@"total"]);
             }
         }
     }];
}

- (void)getItemsWithFilter:(NSMutableDictionary *)filter completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *items, NSString *position, NSString *total))completion {
    if (!filter) {
        NSArray *items = [HouseListItemModel findItemsBySubscribe:@0];
        if (completion) {
            completion(nil, nil, nil, items, nil, nil);
        }
    } else {
        [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/search") parameters:filter completion:^(Response *response, NSError *error) {
            NSArray *items = nil;
            
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil, nil, nil);
            } else {
                if ([response.body[@"status"] isEqualToNumber:@-1]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], items, response.body[@"position"], response.body[@"total"]);
                } else {
                    if ([filter[@"indexFrom"] isEqualToNumber:@0]) {
                        [HouseListItemModel deleteAllSearchItems];
                    }
                    
                    items = [response.body[@"items"] mappedArrayWithBlock:^id(id dict) {
                        //手动标记username
                        NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                        NSString *username = platformKey;
                        if ([[AppClient sharedInstance] isLogin]) {
                            username = [[AppClient sharedInstance] username];
                        }
                        [mutableDict setObject:username ? username : platformKey forKey:@"username"];
                        return [HouseListItemModel createObjectWithDictionary:[mutableDict copy]];
                    }];
                    
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], items, response.body[@"position"], response.body[@"total"]);
                }
            }
        }];
    }
}

- (void)getRecommends:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *items))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/recommend") parameters:nil completion:^(Response *response, NSError *error) {
        NSArray *items = nil;
        
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
        } else {
            if ([response.body[@"status"] isEqualToNumber:@-1]) {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], items);
            } else {
                items = [response.body[@"items"] mappedArrayWithBlock:^id(id dict) {
                    //手动标记username
                    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                    NSString *username = platformKey;
                    if ([[AppClient sharedInstance] isLogin]) {
                        username = [[AppClient sharedInstance] username];
                    }
                    [mutableDict setObject:username ? username : platformKey forKey:@"username"];
                    return [HouseListItemModel createObjectWithDictionary:[mutableDict copy]];
                }];
                
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], items);
            }
        }
    }];
}

- (void)getSubscribes:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *items))completion {
    NSArray *items = [HouseListItemModel findItemsBySubscribe:@1];
    if (completion && items.count > 0) {
        completion(nil, nil, nil, items);
    }
    
    //传入时间戳，获取最近的新房推送
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if ([Room107UserDefaults subscribeTimestamp]) {
        [parameters setObject:[Room107UserDefaults subscribeTimestamp] forKey:@"timestamp"];
    }
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/getSubscribes") parameters:parameters completion:^(Response *response, NSError *error) {
        NSArray *items = nil;
        
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
        } else {
            if ([response.body[@"status"] isEqualToNumber:@-1]) {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], items);
            } else {
                [Room107UserDefaults saveSubscribeTimestamp:response.body[@"timestamp"]];
                
                items = [response.body[@"items"] mappedArrayWithBlock:^id(id dict) {
                    //手动标记isSubscribe值为1
                    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                    NSString *username = platformKey;
                    if ([[AppClient sharedInstance] isLogin]) {
                        username = [[AppClient sharedInstance] username];
                    }
                    [mutableDict setObject:@1 forKey:@"isSubscribe"];
                    [mutableDict setObject:username ? username : platformKey forKey:@"username"];
                    return [HouseListItemModel createObjectWithDictionary:[mutableDict copy]];
                }];
                
                items = [HouseListItemModel findItemsBySubscribe:@1];
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], items);
            }
        }
    }];
}

- (NSArray *)getSubscribesFromLocal {
    return [HouseListItemModel findItemsBySubscribe:@1];
}

- (void)updateSubscribeItemToReadByHouseID:(NSNumber *)houseID andRoomID:(NSNumber *)roomID {
    [HouseListItemModel updateItemToReadByID:houseID andRoomID:roomID];
}

- (void)clearAllReadSubscribes {
    [HouseListItemModel clearAllReadSubscribes];
}

- (void)getSubscribeConditions:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *subscribes))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/getSubscribeConditions") parameters:nil completion:^(Response *response, NSError *error) {
        NSArray *subscribes = nil;
        
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
        } else {
            if ([response.body[@"status"] isEqualToNumber:@-1]) {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], subscribes);
            } else {
                subscribes = [response.body[@"subscribes"] mappedArrayWithBlock:^id(id dict) {
                    return [SubscribeModel createObjectWithDictionary:dict];
                }];
                
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], subscribes);
            }
        }
    }];
}

- (void)cancelSubscribeWithID:(NSNumber *)ID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (ID) {
        [parameters setObject:ID forKey:@"id"];
    }
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/cancelSubscribe") parameters:parameters completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode]);
            } else {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
            }
        }
    }];
}

- (void)updateSubscribeWithFilter:(NSMutableDictionary *)filter completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, SubscribeModel *subscribe))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/updateSubscribe") parameters:filter completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
            } else {
                SubscribeModel *subscribe = [SubscribeModel createObjectWithDictionary:response.body[@"subscribe"]];
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], subscribe);
            }
        }
    }];
}

- (void)addInterestWithHouseID:(NSNumber *)houseID andRoomID:(NSNumber *)roomID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:houseID, @"houseId", nil];
    if (roomID) {
        [parameters setObject:roomID forKey:@"roomId"];
    }
    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/addInterest") parameters:parameters completion:^(Response *response, NSError *error) {
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode]);
        } else {
            completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
        }
    }];
}

- (void)getInterest:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *interestItems, NSDictionary *bottomAd))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/getInterest") parameters:nil completion:^(Response *response, NSError *error) {
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil, nil);
        } else {
            if ([response.body[@"status"] isEqualToNumber:@-1]) {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil, response.body[@"bottomAd"]);
            } else {
                [InterestListItemModel deleteAllInterestItems];
                NSMutableArray *items = [[NSMutableArray alloc] init];
                InterestListItemModel *interestListItem = nil;
                for (NSDictionary *itemDic in response.body[@"interestHouses"]) {
                    interestListItem = [InterestListItemModel createObjectWithDictionary:itemDic[@"houseListItem"]];
                    interestListItem.buttonType = itemDic[@"buttonType"];
                    interestListItem.hasNewUpdate = itemDic[@"newUpdate"];
                    interestListItem.hasContract = itemDic[@"hasContract"];
                    [items addObject:interestListItem];
                }
                
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], items, response.body[@"bottomAd"]);
            }
        }
    }];
}

- (void)reportSuiteWithContent:(NSMutableDictionary *)content completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/report") parameters:content completion:^(Response *response, NSError *error) {
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode]);
        } else {
            completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
        }
    }];
}

- (void)removeInterestWithHouseID:(NSNumber *)houseID andRoomID:(NSNumber *)roomID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:houseID, @"houseId", nil];
    if (roomID) {
        [parameters setObject:roomID forKey:@"roomId"];
    }
    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/removeInterest") parameters:parameters completion:^(Response *response, NSError *error) {
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode]);
        } else {
            completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
        }
    }];
}

- (void)getTenantHouseList:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *items))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/tenant/list") parameters:nil completion:^(Response *response, NSError *error) {
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
        } else {
            if ([response.body[@"status"] isEqualToNumber:@-1]) {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil);
            } else {
                [RentedHouseListItemModel deleteAllRentedHouseListItems];
                
                NSMutableArray *items = [[NSMutableArray alloc] init];
                items = [response.body[@"items"] mappedArrayWithBlock:^id(id dict) {
                    return [RentedHouseListItemModel createObjectWithDictionary:dict];
                }];
                
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], items);
            }
        }
    }];
}

- (void)getTenantHouseManageWithContractID:(NSNumber *)contractID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, RentedHouseItemModel *item))completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:contractID, @"contractId", nil];
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/tenant/manage") parameters:parameters completion:^(Response *response, NSError *error) {
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
        } else {
            if ([response.body[@"status"] isEqualToNumber:@-1]) {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil);
            } else {
                RentedHouseItemModel *item = [RentedHouseItemModel createObjectWithDictionary:response.body[@"item"]];
                item.username = response.body[@"item"][@"payment"][@"balance"][@"username"];
                item.coupon = response.body[@"item"][@"payment"][@"balance"][@"coupon"];
                item.balance = response.body[@"item"][@"payment"][@"balance"][@"balance"];
                item.expenseOrders = response.body[@"item"][@"payment"][@"expenseOrders"];
                item.balanceCost = response.body[@"item"][@"payment"][@"balanceCost"];
                item.couponCost = response.body[@"item"][@"payment"][@"couponCost"];
                item.paymentCost = response.body[@"item"][@"payment"][@"paymentCost"];
                item.paymentId = response.body[@"item"][@"payment"][@"paymentId"];
                item.status = response.body[@"item"][@"payment"][@"status"];
                item.historyOrders = response.body[@"item"][@"payment"][@"historyOrders"];
                item.incomeOrders = response.body[@"item"][@"payment"][@"incomeOrders"];
                item.deadline = response.body[@"item"][@"payment"][@"deadline"];
                
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], item);
            }
        }
    }];
}

- (void)getLandlordHouseList:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *items))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/landlord/list/v2") parameters:nil completion:^(Response *response, NSError *error) {
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
        } else {
            if ([response.body[@"status"] isEqualToNumber:@-1]) {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil);
            } else {                
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body[@"items"]);
            }
        }
    }];
}

- (void)getLandlordHouseSuiteByHouseID:houseID andRoomID:roomID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *item, NSArray *requests))completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (houseID) {
        [parameters setObject:houseID forKey:@"houseId"];
    }
    if (roomID) {
        [parameters setObject:roomID forKey:@"roomId"];
    }
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/landlord/suite") parameters:parameters completion:^(Response *response, NSError *error) {
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil, nil);
        } else {
            completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body[@"item"], response.body[@"requests"]);
        }
    }];
}

- (void)getLandlordContractListWithHouseID:(NSNumber *)houseID andRoomID:(NSNumber *)roomID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *items, NSArray *expiredItems))completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:houseID, @"houseId", nil];
    if (roomID) {
        [parameters setObject:roomID forKey:@"roomId"];
    }
    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/contract/landlord/list") parameters:parameters completion:^(Response *response, NSError *error) {
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil, nil);
        } else {
            NSMutableArray *items = [[NSMutableArray alloc] init];
            NSMutableArray *expiredItems = [[NSMutableArray alloc] init];
            
            if ([response.body[@"status"] isEqualToNumber:@-1]) {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil, nil);
            } else {
                [ContractRequestModel deleteAllContractRequests];
                
                items = [response.body[@"requests"] mappedArrayWithBlock:^id(id dict) {
                    return [ContractRequestModel createObjectWithDictionary:dict];
                }];
                expiredItems = [response.body[@"expiredRequests"] mappedArrayWithBlock:^id(id dict) {
                    return [ContractRequestModel createObjectWithDictionary:dict];
                }];
                
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], items, expiredItems);
            }
        }
    }];
}

- (void)getLandlordHouseManageWithContractID:(NSNumber *)contractID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, LandlordHouseItemModel *item))completion {    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:contractID ? contractID : @0, @"contractId", nil];
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/landlord/manage") parameters:parameters completion:^(Response *response, NSError *error) {
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
        } else {
            if (![response.body[@"status"] isEqualToNumber:@0]) {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil);
            } else {
                LandlordHouseItemModel *item = [LandlordHouseItemModel createObjectWithDictionary:response.body[@"item"]];
                item.username = response.body[@"item"][@"payment"][@"balance"][@"username"];
                item.coupon = response.body[@"item"][@"payment"][@"balance"][@"coupon"];
                item.balance = response.body[@"item"][@"payment"][@"balance"][@"balance"];
                item.expenseOrders = response.body[@"item"][@"payment"][@"expenseOrders"];
                item.balanceCost = response.body[@"item"][@"payment"][@"balanceCost"];
                item.couponCost = response.body[@"item"][@"payment"][@"couponCost"];
                item.paymentCost = response.body[@"item"][@"payment"][@"paymentCost"];
                item.paymentId = response.body[@"item"][@"payment"][@"paymentId"];
                item.status = response.body[@"item"][@"payment"][@"status"];
                item.historyOrders = response.body[@"item"][@"payment"][@"historyOrders"];
                item.incomeOrders = response.body[@"item"][@"payment"][@"incomeOrders"];
                item.deadline = response.body[@"item"][@"payment"][@"deadline"];
                
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], item);
            }
        }
    }];
}

/// 添加合租意向
- (void)addCotenantWithHouseID:(NSNumber *)houseID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (houseID) {
        [parameters setObject:houseID forKey:@"houseId"];
    }
    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/addCotenant") parameters:parameters completion:^(Response *response, NSError *error) {
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode]);
        } else {
            completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
        }
    }];
}

/// 删除合租意向
- (void)removeCotenantWithHouseID:(NSNumber *)houseID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (houseID) {
        [parameters setObject:houseID forKey:@"houseId"];
    }
    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/removeCotenant") parameters:parameters completion:^(Response *response, NSError *error) {
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode]);
        } else {
            completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
        }
    }];
}

/// 获取合租人的手机号
- (void)contactCotenantWithHouseID:(NSNumber *)houseID andUserID:(NSNumber *)userID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSString *telephone))completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (houseID) {
        [parameters setObject:houseID forKey:@"houseId"];
    }
    if (userID) {
        [parameters setObject:userID forKey:@"userId"];
    }
    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/house/contactCotenant") parameters:parameters completion:^(Response *response, NSError *error) {
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
        } else {
            completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body[@"telephone"]);
        }
    }];
}

@end
