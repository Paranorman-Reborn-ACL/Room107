//
//  CredentialsAuthenticateView.h
//  room107
//
//  Created by ningxia on 15/7/22.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CredentialsAuthenticateViewDelegate;

@interface CredentialsAuthenticateView : UIView

@property (nonatomic, weak) id<CredentialsAuthenticateViewDelegate> delegate;
- (void)setCredentialsPhoto:(UIImage *)photo;
- (UIImage *)IDPhoto;
- (UIImage *)studentcardOrWorkpermitPhoto;
- (void)setIDCareImageURL:(NSString *)idCardImageURL andWorkCardImageURL:(NSString *)workCardImageURL;
- (void)showStep:(NSUInteger)step;

@end

@protocol CredentialsAuthenticateViewDelegate <NSObject>

- (void)confirmAuthenticateButtonDidClick:(CredentialsAuthenticateView *)credentialsAuthenticateView;
- (void)selectCredentialsButtonDidClick:(CredentialsAuthenticateView *)credentialsAuthenticateView;
- (void)reuploadButtonDidClick:(CredentialsAuthenticateView *)credentialsAuthenticateView;

@end
