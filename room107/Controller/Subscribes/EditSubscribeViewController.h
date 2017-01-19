//
//  EditSubscribeViewController.h
//  room107
//
//  Created by ningxia on 16/3/18.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "Room107ViewController.h"
#import "SubscribeModel.h"

@interface EditSubscribeViewController : Room107ViewController

- (id)initWithCondition:(NSMutableDictionary *)condition;
- (void)setSubscribeConditionChangeHandler:(void(^)(SubscribeModel *subscribe))handler;

@end
