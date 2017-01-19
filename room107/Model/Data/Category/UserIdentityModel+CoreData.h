//
//  UserIdentityModel+CoreData.h
//  room107
//
//  Created by ningxia on 15/8/4.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserIdentityModel.h"

@interface UserIdentityModel (CoreData)

+ (UserIdentityModel *)findUserIdentityByidCard:(NSString *)idCard;
+ (NSArray *)deleteUserIdentityByidCard:(NSString *)idCard;
+ (NSArray *)deleteUserIdentities;

@end

@interface UserIdentityModel (KVO)

@end

@interface UserIdentityModel (CoreDataHelpers)

@end
