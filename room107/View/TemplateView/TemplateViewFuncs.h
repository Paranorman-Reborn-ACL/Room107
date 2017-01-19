//
//  TemplateViewFuncs.h
//  room107
//
//  Created by ningxia on 16/3/24.
//  Copyright (c) 2016年 107room. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Room107TableViewCell.h"

/*
typedef enum {
    PORTAL_ONE = 0, //template 1
    PORTAL_TWO, //template 4
    
    LIST_ONE,   //template 2
    LIST_TWO,   //template 9
    LIST_THREE, //template 8
    LIST_FOUR,  //template 7
    LIST_FIVE,  //template 10
    
    IMAGE_ONE,  //template 3
    IMAGE_TWO,  //template 5
    IMAGE_THREE,//template 11
    
    SUITE_ONE,   //template 6
    
    GROUP_ONE,  //template 12
    GROUP_TWO,  //template 13
 
    SEPERATOR_ONE, //template 14
} TemplateType;
 */

typedef enum {
    TemplateTypeOne = 0, //template 1
    TemplateTypeTwo = 2, //template 2
    TemplateTypeThree = 7,   //template 3
    TemplateTypeFour = 1,   //template 4
    TemplateTypeFive = 8, //template 5
    TemplateTypeSix = 10,  //template 6
    TemplateTypeSeven = 5,  //template 7
    TemplateTypeEight = 4,  //template 8
    TemplateTypeNine = 3,  //template 9
    TemplateTypeTen = 6,  //template 10
    TemplateTypeEleven = 9,   //template 11
    TemplateTypeTwelve = 11,  //template 12
    TemplateTypeThirteen = 12,  //template 13
    TemplateTypeFourteen = 13,   //template 14
} TemplateType;

@interface TemplateViewFuncs : NSObject

//模板6的子模板ImageView的Size
+ (CGSize)sixSubTemplateImageViewSize;
//模板6的子模板Cell的Size
+ (CGSize)sixSubTemplateCellSize;
//模板11的Size
+ (CGSize)elevenTemplateTableViewCellWithInfo:(NSDictionary *)info;
//将模板编号为TemplateTypeTwelve与TemplateTypeThirteen的模板数据进行转换
+ (NSMutableArray *)cardsDataConvert:(NSArray *)cards;
//删除指定ID的卡片
+ (void)deleteCardByCardID:(NSNumber *)cardID andTableView:(UITableView *)tableView andData:(id)data;
+ (NSInteger)numberOfRowsByData:(id)data;
+ (Room107TableViewCell *)tableViewCellByData:(id)data atIndex:(NSUInteger)index andTableView:(UITableView *)tableView andViewController:(UIViewController *)viewController;
+ (CGFloat)heightForTableViewCellByData:(id)data atIndex:(NSUInteger)index;
//整个Cell点击的跳转统一处理
+ (void)goToTargetPageByData:(id)data atIndex:(NSUInteger)index andViewController:(UIViewController *)viewController;

@end