//
//  UserInfoModel+CoreData.h
//  room107
//
//  Created by ningxia on 15/8/8.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfoModel.h"

@interface UserInfoModel (CoreData)

+ (UserInfoModel *)findUserInfo;
+ (NSArray *)deleteUserInfo;
+ (UserInfoModel *)findUserByID:(int64_t)ID;
+ (NSArray *)deleteUserByID:(int64_t)ID;
+ (void)updateUserSetFaviconURL:(NSString *)url byID:(int64_t)ID;

@end

@interface UserInfoModel (KVO)

@end

@interface UserInfoModel (CoreDataHelpers)

@end
