//
//  ContractRequestModel+CoreData.h
//  room107
//
//  Created by ningxia on 15/8/6.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContractRequestModel.h"

@interface ContractRequestModel (CoreData)

+ (NSArray *)findAllContractRequests;
+ (NSArray *)deleteAllContractRequests;

@end

@interface ContractRequestModel (KVO)

@end

@interface ContractRequestModel (CoreDataHelpers)

@end
