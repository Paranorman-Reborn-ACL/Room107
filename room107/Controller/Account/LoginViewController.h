//
//  LoginViewController.h
//  room107
//
//  Created by 107间 on 16/3/22.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "Room107ViewController.h"

@interface LoginViewController : Room107ViewController

@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, copy) void(^loginSuccessful)(void);
@end
