//
//  TradingAuditStatusViewController.m
//  room107
//
//  Created by ningxia on 15/9/10.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "TradingAuditStatusViewController.h"
#import "SystemAgent.h"
#import "CustomTextView.h"

@interface TradingAuditStatusViewController ()

@property (nonatomic) UILabel *statusLabel;
@property (nonatomic) CustomTextView *detailTextView;
@property (nonatomic, strong) void (^manageButtonHandlerBlock)();
@property (nonatomic, strong) void (^changeContractButtonHandlerBlock)();
@property (nonatomic, strong) NSString *auditNote;
@property (nonatomic, strong) void (^sendContractHandlerBlock)();

@end

@implementation TradingAuditStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setup];
}

- (void)setStatus:(NSInteger)status {
    _status = status;
    NSString *mainButtonTitle = @"";
    NSString *assistantButtonTitle = @"";
    CGRect frame = (CGRect){0, CGRectGetHeight(self.view.bounds) - 150, CGRectGetWidth(self.view.bounds), 100};
    switch (status) {
        case 0:
        case 2:
        {
            if (status == 0) {
                _statusLabel.text = lang(@"107RoomAuditing");
                _detailTextView.text = lang(@"AuditWaitMessage");
            } else {
                _statusLabel.text = lang(@"AuditFailed");
                _detailTextView.text = [lang(@"Reason") stringByAppendingString:_auditNote ? _auditNote : lang(@"AuditRefused")];
            }
            assistantButtonTitle = lang(@"ChangeContractInformation");
            SystemMutualBottomView *mutualBottomView = [[SystemMutualBottomView alloc] initWithFrame:frame andMainButtonTitle:mainButtonTitle andAssistantButtonTitle:assistantButtonTitle];
            [self.view addSubview:mutualBottomView];
            [mutualBottomView setAssistantButtonDidClickHandler:^{
                [self changeContractInformation];
            }];
        }
            break;
        case 1:
        {
            _statusLabel.text = lang(@"AuditSuccess");
            _detailTextView.text = lang(self.isRent ? @"AuditSuccessMessageRent" : @"AuditSuccessMessageLease");
            mainButtonTitle = lang(self.isRent ? @"RentManage" : @"LeaseManage");
            assistantButtonTitle = lang(@"SendPaperContract");
            SystemMutualBottomView *mutualBottomView = [[SystemMutualBottomView alloc] initWithFrame:frame andMainButtonTitle:mainButtonTitle andAssistantButtonTitle:assistantButtonTitle];
            [self.view addSubview:mutualBottomView];
            [mutualBottomView setMainButtonDidClickHandler:^{
                [self manageContract];
            }];
            [mutualBottomView setAssistantButtonDidClickHandler:^{
                [self sendContract];
            }];
        }
            break;
        default:
            _statusLabel.text = lang(@"AuditCompleteFailed");
            NSString *reason = [lang(@"Reason") stringByAppendingFormat:@"%@%@\n%@", _auditNote ? [_auditNote stringByAppendingString:@"，"] : @"", lang(@"Connect107Room"), [[SystemAgent sharedInstance] getPropertiesFromLocal].supportPhone];
            NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithDictionary:[_detailTextView attributes]];
            [(NSMutableParagraphStyle *)attributes[NSParagraphStyleAttributeName] setAlignment:NSTextAlignmentCenter];
            [_detailTextView setAttributedText:[[NSAttributedString alloc] initWithString:reason ? reason : @"" attributes:attributes]];
            break;
    }
}

- (void)setup {
    CGFloat originX = 22;
    CGFloat viewWith = CGRectGetWidth(self.view.bounds) - 2 * originX;
    CGFloat labelHeight = 40;
    CGFloat originY = CGRectGetHeight(self.view.bounds) / 5;
    
    _statusLabel = [[UILabel alloc] initWithFrame:(CGRect){originX, originY, viewWith, labelHeight}];
    _statusLabel.textColor = [UIColor room107GrayColorD];
    _statusLabel.font = [UIFont room107SystemFontFive];
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_statusLabel];
    
    originY += CGRectGetHeight(_statusLabel.bounds);
    _detailTextView = [[CustomTextView alloc] initWithFrame:(CGRect){originX, originY, viewWith, 2 * labelHeight}];
    _detailTextView.dataDetectorTypes = UIDataDetectorTypePhoneNumber; //使用UIDataDetectorTypes自动检测电话
    [_detailTextView setBackgroundColor:[UIColor clearColor]];
    _detailTextView.font = [UIFont room107FontTwo];
    _detailTextView.textColor = [UIColor room107GrayColorC];
    _detailTextView.editable = NO;
    _detailTextView.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_detailTextView];
    
    self.status = 0;
}

- (void)layoutSubviews {
    CGPoint center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
    _statusLabel.center = CGPointMake(center.x, center.y - 82);
    _detailTextView.center = CGPointMake(center.x, center.y - 60);
}

- (void)setAuditNote:(NSString *)auditNote {
    _auditNote = auditNote;
}

- (void)setManageButtonDidClickHandler:(void(^)())handler {
    _manageButtonHandlerBlock = handler;
}

- (void)setChangeContractButtonDidClickHandler:(void(^)())handler {
    _changeContractButtonHandlerBlock = handler;
}

- (void)setSendContractButtonDidClickHandler:(void (^)())handler {
    _sendContractHandlerBlock = handler;
}

- (void)changeContractInformation {
    if (self.changeContractButtonHandlerBlock) {
        self.changeContractButtonHandlerBlock();
    }
}

- (void)manageContract {
    if (self.manageButtonHandlerBlock) {
        self.manageButtonHandlerBlock();
    }
}

- (void)sendContract {
    if (self.sendContractHandlerBlock) {
        self.sendContractHandlerBlock();
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
