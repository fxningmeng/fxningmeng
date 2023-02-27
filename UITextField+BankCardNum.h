//
//  UITextField+BankCardNum.h
//  Ielpm_Wallet
//
//  Created by YSHI_LGQ on 16/3/16.
//  Copyright © 2016年 com.yishicompany.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (BankCardNum)
/**
 *  设置银行卡号输入格式化
 *
 *  如果要修改self的delegate，要在调用之前设置
 */
- (void)add__formatBankCardNum;

/**
 *  设置银行卡号输入格式化器
 *
 *  如果要修改self的delegate，要在调用之前设置
 */
- (void)ie_setBankCardNumFormater;

/** 移除格式化器 */
- (void)ie_removeBankCardNumFormater;

@end
