//
//  SuiteModel.h
//  room107
//
//  Created by ningxia on 15/6/23.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "UserModel.h"
#import "HouseModel.h"
#import "RoomModel.h"

@interface SuiteModel : ManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * isInterest; //表示是否已加入待签约，用来处理收藏按钮
@property (nonatomic, retain) NSNumber * isCotenant; //boolean，表示当前用户是否对该整租房分租有兴趣
@property (nonatomic, retain) id cotenants; //List<Cotenant>，表示对该整租房分租有兴趣的租客，Cotenant有两个字段id和favicon，表示用户id和头像
@property (nonatomic, retain) id rooms;
@property (nonatomic, retain) id recommendHouses;
@property (nonatomic, retain) HouseModel *house;
@property (nonatomic, retain) UserModel *landlord;
@property (nonatomic, retain) NSNumber * hasContract; //该房是否已进入签约流程，1是；0否

@end
