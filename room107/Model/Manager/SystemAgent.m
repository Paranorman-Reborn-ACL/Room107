//
//  SystemAgent.m
//  room107
//
//  Created by ningxia on 15/7/23.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "SystemAgent.h"
#import "MessageListItemModel+CoreData.h"
#import "SubwayLineModel.h"

@implementation SystemAgent

+ (instancetype)sharedInstance {
    static SystemAgent *sharedInstance;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}

- (void)feedbackWithMessage:(NSString *)message completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion {
    NSDictionary *parameters = @{@"message":message};
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/feedback") parameters:parameters completion:^(Response *response, NSError *error) {
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

- (void)getHomeV3Info:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *cards))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/home/v3") parameters:nil completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil);
                } else {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body[@"cards"]);
                }
            }
        }
    }];
}

- (void)getPersonalInfo:(void(^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *cards))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/personal") parameters:nil completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil);
                } else {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body[@"cards"]);
                }
            }
        }
    }];
}

- (void)getHelpCenter:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *cards))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/helpCenter") parameters:nil completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil);
                } else {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body[@"cards"]);
                }
            }
        }
    }];
}

- (void)getHomeReddieV3 {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/home/v3/reddie") parameters:nil completion:^(Response *response, NSError *error) {
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:HomeReddieDidChangeNotification object:response.body[@"homeReddie"]];
            }
    }];
}

- (void)getHomeReddieV3:(void(^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSDictionary *homeReddie))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/home/v3/reddie") parameters:nil completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:HomeReddieDidChangeNotification object:response.body[@"homeReddie"]];
                
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body[@"homeReddie"]);
            }
        }
    }];
}

- (void)getMessageList:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *messages))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/message/list") parameters:nil completion:^(Response *response, NSError *error) {
        NSArray *messages = nil;
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil);
                } else {
                    [MessageListItemModel deleteAllMessageListItems];
                    
                    messages = [response.body[@"messages"] mappedArrayWithBlock:^id(id dict) {
                        return [MessageListItemModel createObjectWithDictionary:dict];
                    }];
                    
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], messages);
                }
            }
        }
    }];
}

//分页请求消息列表
- (void)getMessageListIndexFrom:(NSNumber *)indexFrom indexTo:(NSNumber *)indexTo completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *messages))completion {
    NSDictionary *parameters = @{@"indexFrom":indexFrom,@"indexTo":indexTo};

    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/message/list") parameters:parameters completion:^(Response *response, NSError *error) {
        NSArray *messages = nil;
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil);
                } else {
                    
                    messages = [response.body[@"messages"] mappedArrayWithBlock:^id(id dict) {
                        return [MessageListItemModel createObjectWithDictionary:dict];
                    }];
                    
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], messages);
                }
            }
        }
    }];

}
- (void)getMessageCenter:(void(^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *cards))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/message/center") parameters:nil completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil);
                } else {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body[@"cards"]);
                }
            }
        }

    }];
}

- (void)getMessageSublistWithParams:(NSDictionary *)params complete:(void(^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *cards))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/message/sublist") parameters:params completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil);
                } else {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body[@"cards"]);
                }
            }
        }
        
    }];
}

- (void)getMessageDetailWithMessageID:(NSNumber *)messageID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, MessageInfoModel *message))completion {
    MessageInfoModel *messageInfo = [MessageInfoModel findMessageInfoByID:[messageID longLongValue]];
    if (completion && messageInfo) {
        completion(nil, nil, nil, messageInfo);
    }
    
    NSDictionary *parameters = @{@"messageId": messageID};
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/message/detail") parameters:parameters completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil);
                } else {
                    [MessageInfoModel deleteMessageInfoByID:[messageID longLongValue]];
                    MessageInfoModel *messageInfo = [MessageInfoModel createObjectWithDictionary:response.body[@"message"]];
                    
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], messageInfo);
                }
            }
        }
    }];
}

- (void)deleteMessageWithMessageID:(NSNumber *)messageID completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion {
    NSDictionary *parameters = @{@"messageId": messageID};
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/message/delete") parameters:parameters completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode]);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
                } else {
                    [MessageListItemModel deleteMessageListItemByID:[messageID longLongValue]];
                    
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
                }
            }
        }
    }];
}

//删除所有消息
- (void)deleteAllMessageWithType:(NSNumber *)type completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion {
    NSDictionary *parameters = @{@"type" : type};
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/message/deleteAll") parameters:parameters completion:^(Response *response, NSError *error) {
        if (completion) {
            if (error) {
                completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode]);
            } else {
                if (![response.body[@"status"] isEqual:@0]) {
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
                } else {
                    [MessageListItemModel deleteAllMessageListItems];
                    completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
                }
            }
        }
    }];
}

//已读所有消息
- (void)cleanAllMessageWithType:(NSNumber *)type completion:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode))completion {
    NSDictionary *parameters = @{@"type" : type};
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/message/cleanAll") parameters:parameters completion:^(Response *response, NSError *error) {
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

- (void)getPropertiesFromServer {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/properties") parameters:nil completion:^(Response *response, NSError *error) {
        if (error) {
            LogError(@"error:%@", error);
        } else {
            if (![response.body[@"status"] isEqual:@0]) {
                LogError(@"error:%@", response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
            } else {
                //清空数据表
                [AppPropertiesModel deleteAppProperties];
                
                [AppPropertiesModel createObjectWithDictionary:response.body[@"properties"]];
            }
        }
    }];
}

- (void)getPropertiesFromServer:(void(^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, AppPropertiesModel *model))completion {
//    AppPropertiesModel *appProperties = [AppPropertiesModel findAppProperties];
//    if (completion && appProperties) {
//        completion(nil, nil, appProperties);
//    }
    
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/properties") parameters:nil completion:^(Response *response, NSError *error) {
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
        } else {
            if (![response.body[@"status"] isEqual:@0]) {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil);
            } else {
                AppPropertiesModel *appProperties = [self getPropertiesFromLocal];
                if (![appProperties.subwayVersion isEqualToString:response.body[@"properties"][@"subwayVersion"]]) {
                    [self getSubwayLines:^(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *subwayLines) {
                        
                    }];
                }
                //清空数据表
                [AppPropertiesModel deleteAppProperties];
                [AppPropertiesModel createObjectWithDictionary:response.body[@"properties"]];
                appProperties = [self getPropertiesFromLocal];
                
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], appProperties);
            }
        }
    }];
}

- (AppPropertiesModel *)getPropertiesFromLocal {
    return [AppPropertiesModel findAppProperties];
}

- (void)getTextPropertiesFromServer {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/properties/text") parameters:nil completion:^(Response *response, NSError *error) {
        if (error) {
            LogError(@"error:%@", error);
        } else {
            if (![response.body[@"status"] isEqual:@0]) {
                LogError(@"error:%@", response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
            } else {
                [AppTextModel deleteAppTexts];
                
                [response.body[@"text"] mappedArrayWithBlock:^id(id dict) {
                    return [AppTextModel createObjectWithDictionary:dict];
                }];
                
//                NSArray *texts = [self getTextPropertiesFromLocal];
            }
        }
    }];
}

- (NSArray *)getTextPropertiesFromLocal {
    return [AppTextModel findAppTexts];
}

- (AppTextModel *)getTextPropertyByID:(NSNumber *)ID {
    return [AppTextModel findAppTextByID:ID];
}

/// 获取弹窗配置数据
- (void)getPopupPropertiesFromServer {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/properties/popup") parameters:nil completion:^(Response *response, NSError *error) {
        if (error) {
            LogError(@"error:%@", error);
        } else {
            if (![response.body[@"status"] isEqual:@0]) {
                LogError(@"error:%@", response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"]);
            } else {
                [AppPopupModel deleteAppPopups];
                
                [response.body[@"popup"] mappedArrayWithBlock:^id(id dict) {
                    return [AppPopupModel createObjectWithDictionary:dict];
                }];
                
//                NSArray *popups = [self getPopupPropertiesFromLocal];
            }
        }
    }];
}

- (NSArray *)getPopupPropertiesFromLocal {
    return [AppPopupModel findAppPopups];
}

- (void)getAppMenuReddies:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *reddies))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/menu/reddie") parameters:nil completion:^(Response *response, NSError *error) {
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
        } else {
            if (![response.body[@"status"] isEqual:@0]) {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil);
            } else {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], response.body[@"reddies"]);
            }
        }
    }];
}

- (void)getSubwayLines:(void (^)(NSString *errorTitle, NSString *errorMsg, NSNumber *errorCode, NSArray *subwayLines))completion {
    [[Client sharedClient] POSTRequestWithPath:RequestPath(@"/properties/subway") parameters:nil completion:^(Response *response, NSError *error) {
        if (error) {
            completion(lang(@"UnknownError"), nil, [NSNumber numberWithUnsignedInteger:networkErrorCode], nil);
        } else {
            if (![response.body[@"status"] isEqual:@0]) {
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], nil);
            } else {
                //清空数据表
                [SubwayLineModel deleteSubwayLines];
                NSArray *subwayLines = [response.body[@"subway"] mappedArrayWithBlock:^id(id dict) {
                    return [SubwayLineModel createObjectWithDictionary:dict];
                }];
                
                completion(response.body[@"errorTitle"], response.body[@"errorMsg"], response.body[@"errorCode"], subwayLines);
            }
        }
    }];
}

- (NSArray *)getSubwayLinesFromLocal {
    NSArray *subwayLines = [SubwayLineModel findSubwayLines];
    return subwayLines;
}

@end
