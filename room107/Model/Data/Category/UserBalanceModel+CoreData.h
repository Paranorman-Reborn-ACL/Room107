//
//  UserBalanceModel+CoreData.h
//  room107
//
//  Created by ningxia on 15/8/5.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserBalanceModel.h"

@interface UserBalanceModel (CoreData)

+ (NSArray *)findAllUserBalances;
+ (NSArray *)deleteAllUserBalances;

@end

@interface UserBalanceModel (KVO)

@end

@interface UserBalanceModel (CoreDataHelpers)

@end
