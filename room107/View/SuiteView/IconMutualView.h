//
//  IconMutualView.h
//  room107
//
//  Created by ningxia on 15/11/25.
//  Copyright © 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IconMutualView : UIView

- (instancetype)initWithIcons:(NSArray *)icons;
- (void)setIconButtonDidClickHandler:(void(^)(NSInteger index))handler;

@end
