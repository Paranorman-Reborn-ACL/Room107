//
//  SubwayLineModel+CoreDataProperties.h
//  room107
//
//  Created by ningxia on 16/1/25.
//  Copyright © 2016年 107room. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SubwayLineModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SubwayLineModel (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) id stations;
@property (nullable, nonatomic, retain) id keywords;

@end

NS_ASSUME_NONNULL_END
