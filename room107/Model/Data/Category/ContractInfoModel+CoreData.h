//
//  ContractInfoModel+CoreData.h
//  room107
//
//  Created by ningxia on 15/8/4.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContractInfoModel.h"

@interface ContractInfoModel (CoreData)

+ (ContractInfoModel *)findContractInfoByContractID:(int64_t)contractID;
+ (NSArray *)deleteContractInfoByContractID:(int64_t)contractID;
+ (NSArray *)deleteContractInfos;

@end

@interface ContractInfoModel (KVO)

@end

@interface ContractInfoModel (CoreDataHelpers)

@end

