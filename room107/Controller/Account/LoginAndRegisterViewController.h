
//
//  LoginAndRegisterViewController.h
//  room107
//
//  Created by 107间 on 16/3/22.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "Room107ViewController.h"

typedef enum {
    LoginAndRegisterViewControllerPushType= 2000, // push操作
    LoginAndRegisterViewControllerPresentType, //
} LoginAndRegisterViewControllerType;

@interface LoginAndRegisterViewController : Room107ViewController

@property (nonatomic, assign) LoginAndRegisterViewControllerType loginAndRegisterViewControllerType;

@end
