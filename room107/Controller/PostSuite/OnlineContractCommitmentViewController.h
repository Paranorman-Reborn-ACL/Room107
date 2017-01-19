//
//  OnlineContractCommitmentViewController.h
//  room107
//
//  Created by 107间 on 15/12/1.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "Room107ViewController.h"

typedef enum {
    OnlineContractCommitmentViewTypeNew = 2000, //
    OnlineContractCommitmentViewTypeManage, //
} OnlineContractCommitmentViewType;

@interface OnlineContractCommitmentViewController : Room107ViewController

- (id)initWithRootViewController:(UIViewController *)viewController;
- (OnlineContractCommitmentViewType)onlineContractCommitmentViewType;

@end
