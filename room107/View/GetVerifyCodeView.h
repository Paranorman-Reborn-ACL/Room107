//
//  GetVerifyCodeView.h
//  room107
//
//  Created by 107间 on 16/3/22.
//  Copyright © 2016年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GetVerifyCodeView;

@protocol GetVerifyCodeViewDelegate <NSObject>

- (void)getVerifyCodeViewDidClick:(GetVerifyCodeView *)getVerifyCodeView;

@end

@interface GetVerifyCodeView : UIView

@property (nonatomic, assign) id<GetVerifyCodeViewDelegate> delegate;
- (void)stopCountdown; //停止倒计时
@end
