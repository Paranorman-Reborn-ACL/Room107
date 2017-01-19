//
//  LandlordSuiteItemModel+CoreData.h
//  room107
//
//  Created by ningxia on 15/8/26.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LandlordSuiteItemModel.h"

@interface LandlordSuiteItemModel (CoreData)

+ (LandlordSuiteItemModel *)findSuite;
+ (NSArray *)deleteSuite;

@end


@interface LandlordSuiteItemModel (KVO)

@end

@interface LandlordSuiteItemModel (CoreDataHelpers)

@end