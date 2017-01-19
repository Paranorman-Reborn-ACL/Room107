//
//  ChangeBindingViewController.h
//  room107
//
//  Created by 107间 on 16/3/18.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "Room107ViewController.h"

@interface ChangeBindingViewController : Room107ViewController

- (void)setCurrentTelephoneNumber:(NSString *)telephoneNumber;
@property (nonatomic, copy) void(^bindingSuccessful)(NSString *);

@end
