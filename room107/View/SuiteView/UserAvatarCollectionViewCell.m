//
//  UserAvatarCollectionViewCell.m
//  room107
//
//  Created by ningxia on 16/3/3.
//  Copyright © 2016年 107room. All rights reserved.
//

#import "UserAvatarCollectionViewCell.h"
#import "CustomImageView.h"

@interface UserAvatarCollectionViewCell ()

@property (nonatomic, strong) CustomImageView *avatarImageView;

@end

@implementation UserAvatarCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setBackgroundColor:[UIColor clearColor]];
    
    if (self) {
        frame.origin = CGPointMake(0, 0);
        _avatarImageView = [[CustomImageView alloc] initWithFrame:frame];
        [_avatarImageView setBackgroundColor:[UIColor whiteColor]];
        [_avatarImageView setCornerRadius:CGRectGetWidth(frame) / 2];
        [self.contentView addSubview:_avatarImageView];
    }
    
    return self;
}

- (void)setAvatarImageURL:(NSString *)url {
    [_avatarImageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"loginlogo.png"]];
}

@end
