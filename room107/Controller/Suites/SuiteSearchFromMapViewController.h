//
//  SuiteSearchFromMapViewController.h
//  room107
//
//  Created by 107间 on 16/1/6.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "Room107ViewController.h"

@interface SuiteSearchFromMapViewController : Room107ViewController
//获取当前搜索地址
- (void)setSearchHistoryPosition:(NSString *)position;
//获取当前搜索条件
- (void)setSearchConditionDic:(NSDictionary *)conditionDic;
//获得当前筛选条件
- (void)setScreeningConditions:(NSString *)conditionString;
@end
