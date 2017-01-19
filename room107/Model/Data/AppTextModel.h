//
//  AppTextModel.h
//  room107
//
//  Created by ningxia on 15/10/12.
//  Copyright © 2015年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface AppTextModel : ManagedObject

@property (nonatomic, retain) NSNumber *id;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *text;

@end
