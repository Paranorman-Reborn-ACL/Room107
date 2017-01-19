//
//  RightMenuView.h
//  room107
//
//  Created by 107间 on 16/3/10.
//  Copyright © 2016年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RightMenuView : UIView

- (instancetype)initWithItems:(NSArray *)itemsArray;
- (instancetype)initWithItems:(NSArray *)itemsArray itemHeight:(CGFloat)itemHeight;
- (void)refreshWithItems:(NSArray *)itemsArray;
- (void)dismissMenuView;
- (void)showMenuView;

@end
