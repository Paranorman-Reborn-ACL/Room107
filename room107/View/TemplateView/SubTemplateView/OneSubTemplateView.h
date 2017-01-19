//
//  OneSubTemplateView.h
//  room107
//
//  Created by 107间 on 16/4/8.
//  Copyright © 2016年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OneSubTemplateView : UIView

@property (nonatomic, copy) void(^ buttonClickHandlerBlock)(NSArray *targetURLs);
@property (nonatomic, copy) void(^ buttonDidLongPressHandlerBlock)(NSArray *targetURLs);

- (void)setSubTemplateInfo:(NSDictionary *)dataDict;

@end
