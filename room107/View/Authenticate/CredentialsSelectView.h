//
//  CredentialsSelectView.h
//  room107
//
//  Created by ningxia on 15/7/22.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CredentialsSelectViewDelegate;

@interface CredentialsSelectView : UIView

@property (nonatomic, weak) id<CredentialsSelectViewDelegate> delegate;
- (void)setUpExampleImage:(NSString *)upimageName downExampleImage:(NSString *)downimageName;
- (void)setCredentialsSelectTips:(NSString *)tips andCredentialsImage:(UIImage *)image;
- (UIImage *)getCredentialsPhoto;

@end

@protocol CredentialsSelectViewDelegate <NSObject>

- (void)credentialsButtonDidClick:(CredentialsSelectView *)credentialsSelectView;

@end