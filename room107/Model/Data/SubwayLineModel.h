//
//  SubwayLineModel.h
//  room107
//
//  Created by ningxia on 16/1/25.
//  Copyright © 2016年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface SubwayLineModel : ManagedObject

// Insert code here to declare functionality of your managed object subclass
+ (NSArray *)findSubwayLines;
+ (NSArray *)deleteSubwayLines;

@end

NS_ASSUME_NONNULL_END

#import "SubwayLineModel+CoreDataProperties.h"
