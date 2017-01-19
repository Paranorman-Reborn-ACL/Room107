//
//  HomeInfoModel+CoreData.h
//  room107
//
//  Created by ningxia on 15/9/16.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HomeInfoModel.h"

@interface HomeInfoModel (CoreData)

+ (HomeInfoModel *)findHomeInfo;
+ (NSArray *)deleteHomeInfo;

@end


@interface HomeInfoModel (KVO)

@end
