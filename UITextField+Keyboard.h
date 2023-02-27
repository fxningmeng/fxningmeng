//
//  UITextField+Keyboard.h
//  Ielpm_Wallet
//
//  Created by maxinli on 16/2/19.
//  Copyright © 2016年 com.yishicompany.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyboardNumberPad.h"

@interface UITextField (Keyboard) <KeyboardNumberPadProtocol>

- (void)setTextFieldKeyboardType:(UIKeyboardType)keyboardType;

@end
