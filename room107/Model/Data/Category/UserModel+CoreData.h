//
//  UserModel+CoreData.h
//  room107
//
//  Created by ningxia on 15/6/24.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "UserModel.h"

@interface UserModel (CoreData)

+ (UserModel *)findUserByUsername:(NSString *)username;

@end

@interface UserModel (KVO)

@end

@interface UserModel (CoreDataHelpers)

@end
