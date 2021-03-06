//
//  SCMerchantDetail.h
//  MaintenanceCar
//
//  Created by ShiCang on 14/12/26.
//  Copyright (c) 2014年 MaintenanceCar. All rights reserved.
//

#import "SCGroupProduct.h"
#import "SCMerchantSummary.h"
#import "SCMerchantProductGroup.h"
#import "SCQuotedPriceGroup.h"
#import "SCMerchantInfo.h"
#import "SCCommentGroup.h"
#import "SCComment.h"

// 商家详情Model
@interface SCMerchantDetail : JSONModel

@property (nonatomic, strong) NSString <Optional>*address;              // 商家地址
@property (nonatomic, strong) NSString <Optional>*company_id;           // 商家ID
@property (nonatomic, strong) NSString <Optional>*latitude;             // 商家地理位置 - 纬度
@property (nonatomic, strong) NSString <Optional>*longtitude;           // 商家地理位置 - 经度
@property (nonatomic, strong) NSString <Optional>*memo;                 // 商家备注
@property (nonatomic, strong) NSString <Optional>*name;                 // 商家名称
@property (nonatomic, strong) NSString <Optional>*service;              // 服务内容
@property (nonatomic, strong) NSString <Optional>*short_name;           // 简称
@property (nonatomic, strong) NSString <Optional>*telephone;            // 联系电话
@property (nonatomic, strong) NSString <Optional>*flags;                // 商家标签
@property (nonatomic, strong) NSString <Optional>*tags;                 // 商家特色
@property (nonatomic, strong) NSString <Optional>*inspect_free;         // 能否免费检测
@property (nonatomic, strong) NSString <Optional>*time_open;            // 商家营业时间
@property (nonatomic, strong) NSString <Optional>*time_closed;          // 商家打样时间
@property (nonatomic, strong) NSString <Optional>*majors;               // 专修品牌
@property (nonatomic, strong) NSString <Optional>*star;                 // 商家星级
@property (nonatomic, strong) NSString <Optional>*now;
@property (nonatomic, strong) NSString <Optional>*have_comment;
@property (nonatomic, assign) NSInteger           comments_num;         // 评价数量

@property (nonatomic, strong)            NSDictionary <Optional>*service_items;   // 服务项目
@property (nonatomic, strong) NSArray <Optional, SCGroupProduct>*products;        // 团购项目
@property (nonatomic, strong)  NSArray <Optional, SCQuotedPrice>*normal_products; // 项目报价
@property (nonatomic, strong)      NSArray <Optional, SCComment>*comments;        // 用户评价
@property (nonatomic, strong)                 NSArray <Optional>*images;          // 商家图片
@property (nonatomic, assign)                              BOOL collected;        // 收藏状态

@property (nonatomic, strong, readonly)     NSString <Ignore>*distance;           // 手机当前位置与商家的距离
@property (nonatomic, strong, readonly)     NSString <Ignore>*serverItemsPrompt;  // 商家服务描述
@property (nonatomic, strong, readonly)      NSArray <Ignore>*merchantImages;     // 商家图片集合
@property (nonatomic, strong, readonly) NSDictionary <Ignore>*serviceItems;       // 商家服务项目


@property (nonatomic, strong, readonly)      SCMerchantSummary <Ignore>*summary;
@property (nonatomic, strong, readonly) SCMerchantProductGroup <Ignore>*productGroup;
@property (nonatomic, strong, readonly)     SCQuotedPriceGroup <Ignore>*quotedPriceGroup;
@property (nonatomic, strong, readonly)         SCMerchantInfo <Ignore>*info;
@property (nonatomic, strong, readonly)          SCCommentMore <Ignore>*commentMore;
@property (nonatomic, strong, readonly)         SCCommentGroup <Ignore>*commentGroup;

@property (nonatomic, strong, readonly) NSArray <Ignore>*cellDisplayData;

@end
