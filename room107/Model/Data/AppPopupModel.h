//
//  AppPopupModel.h
//  room107
//
//  Created by ningxia on 15/10/12.
//  Copyright © 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppPopupModel : ManagedObject

// Insert code here to declare functionality of your managed object subclass
+ (NSArray *)findAppPopups;
+ (NSArray *)deleteAppPopups;

@end

NS_ASSUME_NONNULL_END

#import "AppPopupModel+CoreDataProperties.h"
