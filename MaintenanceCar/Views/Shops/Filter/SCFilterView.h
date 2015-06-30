//
//  SCFilterView.h
//  MaintenanceCar
//
//  Created by ShiCang on 15/6/23.
//  Copyright (c) 2015年 MaintenanceCar. All rights reserved.
//

#import "SCViewCategory.h"

@class SCFilterCategory;
@class SCFilterViewModel;
@class SCListFilterView;
@class SCSubListFilterView;
@class SCCarModelFilterView;

@interface SCFilterView : UIView
{
    BOOL _canSelected;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainFilterViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBarHeightConstraint;

@property (weak, nonatomic) IBOutlet               UIView *containerView;
@property (weak, nonatomic) IBOutlet               UIView *popUpView;
@property (weak, nonatomic) IBOutlet     SCListFilterView *listFilterView;
@property (weak, nonatomic) IBOutlet  SCSubListFilterView *subListFilterView;
@property (weak, nonatomic) IBOutlet SCCarModelFilterView *carModelView;

@property (weak, nonatomic) IBOutlet UIButton *seviceFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *regionFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *modelFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *sortFilterButton;

@property (nonatomic, assign, readonly) NSInteger  selectedIndex;
@property (nonatomic, strong)             NSArray *mainFilters;
@property (nonatomic, strong)             NSArray *subFilters;
@property (nonatomic, strong)   SCFilterViewModel *filterViewModel;

- (IBAction)filterButtonPressed:(UIButton *)button;

- (void)filterCompleted:(void(^)(NSString *param, NSString *value))block;

@end
