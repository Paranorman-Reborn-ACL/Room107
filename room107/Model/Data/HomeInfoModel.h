//
//  HomeInfoModel.h
//  room107
//
//  Created by ningxia on 15/9/16.
//  Copyright (c) 2015年 107room. All rights reserved.
//

@interface HomeInfoModel : ManagedObject

/*
 HomeCardType {
 NUMBER, MONEY, NONE
 }
 */
@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) id groups;

@end
