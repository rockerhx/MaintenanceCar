//
//  SCCommentCell.m
//  MaintenanceCar
//
//  Created by ShiCang on 15/3/15.
//  Copyright (c) 2015年 MaintenanceCar. All rights reserved.
//

#import "SCCommentCell.h"
#import "UIConstants.h"

@implementation SCCommentCell

- (void)awakeFromNib
{
    _commentDateLabel.layer.borderColor = [UIColor orangeColor].CGColor;
    _commentDateLabel.layer.borderWidth = 1.0f;
    
    _contentLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 23.0f;
}

#pragma mark - Public Methods
- (void)displayCellWithComment:(SCComment *)comment
{
    _userNameLabel.text    = [NSString stringWithFormat:@"修养车主（%@）", comment.phone];
    _starView.value        = comment.star;
    _commentDateLabel.text = comment.create_time;
    _contentLabel.text     = comment.detail;
    
    [self.contentView updateConstraintsIfNeeded];
    [self.contentView layoutIfNeeded];
}
@end
