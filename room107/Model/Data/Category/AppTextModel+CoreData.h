//
//  AppTextModel+CoreData.h
//  room107
//
//  Created by ningxia on 15/10/14.
//  Copyright © 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppTextModel.h"

@interface AppTextModel (CoreData)

+ (AppTextModel *)findAppTextByID:(NSNumber *)ID;
+ (NSArray *)findAppTexts;
+ (NSArray *)deleteAppTexts;

@end


@interface AppTextModel (KVO)

@end