//
//  AppPropertiesModel+CoreData.h
//  room107
//
//  Created by ningxia on 15/9/14.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppPropertiesModel.h"

@interface AppPropertiesModel (CoreData)

+ (AppPropertiesModel *)findAppProperties;
+ (NSArray *)deleteAppProperties;

@end


@interface AppPropertiesModel (KVO)

@end