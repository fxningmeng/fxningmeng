//
//  UITextField+PhoneNumber.h
//  Ielpm_Wallet
//
//  Created by Cogddo-Lau on 16/3/15.
//  Copyright © 2019年 com.yishicompany.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (PhoneNumber)

/**
 *  设置手机号输入格式化器
 *
 *  如果要修改self的delegate，要在调用之前设置
 */
- (void)ieSetPhoneNumberFormater;

/** 移除格式化器 */
- (void)ieRemovePhoneNumberFormater;

@end
