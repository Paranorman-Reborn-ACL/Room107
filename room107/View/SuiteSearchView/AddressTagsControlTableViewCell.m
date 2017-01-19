//
//  AddressTagsControlTableViewCell.m
//  room107
//
//  Created by ningxia on 15/12/21.
//  Copyright © 2015年 107room. All rights reserved.
//

#import "AddressTagsControlTableViewCell.h"
#import "TLTagsControl.h"
#import "CustomButton.h"

@interface AddressTagsControlTableViewCell ()

@property (nonatomic, strong) TLTagsControl *addressTagsControl;
@property (nonatomic, strong) void (^quickSearchHandler)(NSMutableArray *tags);

@end

@implementation AddressTagsControlTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat originX = 22;
        CGFloat originY = 5;
        UIView *backgroundView = [[UIView alloc] initWithFrame:(CGRect){originX, originY, [self cellFrame].size.width - 2 * originX, [self cellFrame].size.height}];
        [backgroundView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:backgroundView];
        originY += CGRectGetHeight(backgroundView.bounds);
        
        CGFloat buttonWidth = CGRectGetHeight(backgroundView.bounds) / 2;
        CGFloat spacingX = 5;
        CustomButton *clearButton = [[CustomButton alloc] initWithFrame:(CGRect){CGRectGetWidth(backgroundView.bounds) - buttonWidth - spacingX, (CGRectGetHeight(backgroundView.bounds) - buttonWidth) / 2, buttonWidth, buttonWidth}];
        [clearButton.titleLabel setFont:[UIFont room107FontThree]];
        [clearButton setTitle:@"\ue627" forState:UIControlStateNormal];
        [clearButton setTitleColor:[UIColor room107GrayColorD] forState:UIControlStateNormal];
        [clearButton addTarget:self action:@selector(clearButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundView addSubview:clearButton];
        
        _addressTagsControl = [[TLTagsControl alloc] initWithFrame:CGRectMake(spacingX, 10, backgroundView.frame.size.width - 2 * spacingX - buttonWidth, backgroundView.frame.size.height - 2 * 10) andTags:@[] andPlaceholder:lang(@"MaxAddressesNum") withTagsControlMode:TLTagsControlModeEdit];
        _addressTagsControl.showsHorizontalScrollIndicator = NO;
        _addressTagsControl.showsVerticalScrollIndicator = NO;
        [_addressTagsControl setMaxTagsNum:5];
        _addressTagsControl.tagsTextFont = [UIFont room107SystemFontTwo];
        _addressTagsControl.cursorColor = [UIColor room107GreenColor];
        [_addressTagsControl reloadTagSubviews];
        [backgroundView addSubview:_addressTagsControl];
        WEAK_SELF weakSelf = self;
        [_addressTagsControl addSearchHandler:^{
            if (weakSelf.quickSearchHandler) {
                weakSelf.quickSearchHandler(weakSelf.addressTagsControl.tags);
            }
        }];
    }
    
    return self;
}

- (CGRect)cellFrame {
    return CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, addressTagsControlTableViewCellHeight);
}

- (IBAction)clearButtonDidClick:(id)sender {
    [_addressTagsControl clearAllTags];
}

- (void)setAddressTags:(NSMutableArray *)tags {
    [_addressTagsControl setTags:tags];
}

- (void)setQuickSearchHandler:(void(^)(NSMutableArray *tags))handler {
    _quickSearchHandler = handler;
}

- (void)addNewTag {
    [_addressTagsControl addNewTag];
    if (_addressTagsControl.tags.count > 0) {
        [_addressTagsControl resignFirstResponder];
    }
}

- (void)resignFirstResponder {
    [_addressTagsControl resignFirstResponder];
}

@end
