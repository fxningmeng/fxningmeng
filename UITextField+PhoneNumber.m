//
//  UITextField+PhoneNumber.m
//  Ielpm_Wallet
//
//  Created by Cogddo-Lau on 16/3/15.
//  Copyright © 2019年 com.yishicompany.www. All rights reserved.
//

#import "UITextField+PhoneNumber.h"
#import <objc/runtime.h>

@interface __PrivateProcessor : NSObject <UITextFieldDelegate>
- (void)__formatPhoneNumber:(UITextField *)textField;
- (void)__textFieldShouldChange:(UITextField *)textField;
@end

static const void *__PrivateProcessorKey = &__PrivateProcessorKey;

@implementation UITextField (PhoneNumber)

- (void)ieSetPhoneNumberFormater {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(__tfTextDidChange)
                                                 name:UITextFieldTextDidChangeNotification object:self];
    
    __PrivateProcessor *processor = [[__PrivateProcessor alloc] init];
    [self __setProcessor:processor];
    
    if (self.delegate) {
        id delegate = self.delegate;
        SEL selector = @selector(textField:shouldChangeCharactersInRange:replacementString:);

        if (![delegate respondsToSelector:selector]) {
            IMP imp = [self methodForSelector:selector];
            class_addMethod([delegate class], selector, imp, "i@:");
        }
        
        __weak typeof(self) wSelf = self;
        [delegate ie_hookSelector:selector
                           option:AspectPositionAfter
                            block:^(id<AspectInfo> info) {
                                [[wSelf __getProcessor] __textFieldShouldChange:self];
        }];
    } else {
        self.delegate = processor;
    }
}

- (void)ieRemovePhoneNumberFormater {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.delegate = nil;
}

/** self.delegate没有实现该方法时，自动添加到self.delegate中，其他情况没用 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (void)__tfTextDidChange {
    [[self __getProcessor] __formatPhoneNumber:self];
}

- (void)__setProcessor:(__PrivateProcessor *)processor {
    objc_setAssociatedObject(self, __PrivateProcessorKey, processor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (__PrivateProcessor *)__getProcessor {
    return objc_getAssociatedObject(self, __PrivateProcessorKey);
}

@end

@implementation __PrivateProcessor
{
    NSString    *_prevContent;
    UITextRange *_prevSelection;
}

- (void)__textFieldShouldChange:(UITextField *)textField {
    _prevContent = textField.text;
    _prevSelection = textField.selectedTextRange;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    _prevContent = textField.text;
    _prevSelection = textField.selectedTextRange;
    return YES;
}

- (void)__formatPhoneNumber:(UITextField *)textField {
    NSUInteger targetCursorPosition = [textField offsetFromPosition:textField.beginningOfDocument toPosition:textField.selectedTextRange.start];
    
    // nStr表示不带空格的号码
    NSString *nStr = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *preTxt = [_prevContent stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    BOOL isDelete = NO;
    
    if (nStr.length <= preTxt.length) {
        isDelete = YES;
    } else {
        isDelete = NO;
    }
    
    // textField设置text
    if (nStr.length > 11) {
        textField.text = _prevContent;
        textField.selectedTextRange = _prevSelection;
        return;
    }
    
    // 空格
    NSString *spaceStr = @" ";
    
    NSMutableString *mStrTemp = [[NSMutableString alloc] init];
    
    int spaceCount = 0;
    if (nStr.length < 3 && nStr.length > -1) {
        spaceCount = 0;
    } else if (nStr.length < 7 && nStr.length >2) {
        spaceCount = 1;
    } else if (nStr.length < 12 && nStr.length > 6) {
        spaceCount = 2;
    }
    
    for (int i = 0; i < spaceCount; i++) {
        if (i == 0) {
            [mStrTemp appendFormat:@"%@%@", [nStr substringWithRange:NSMakeRange(0, 3)], spaceStr];
        } else if (i == 1) {
            [mStrTemp appendFormat:@"%@%@", [nStr substringWithRange:NSMakeRange(3, 4)], spaceStr];
        } else if (i == 2) {
            [mStrTemp appendFormat:@"%@%@", [nStr substringWithRange:NSMakeRange(7, 4)], spaceStr];
        }
    }
    
    if (nStr.length == 11) {
        [mStrTemp appendFormat:@"%@%@", [nStr substringWithRange:NSMakeRange(7, 4)], spaceStr];
    }
    
    if (nStr.length < 4) {
        [mStrTemp appendString:[nStr substringWithRange:NSMakeRange(nStr.length-nStr.length % 3,
                                                                    nStr.length % 3)]];
    } else if(nStr.length > 3) {
        NSString *str = [nStr substringFromIndex:3];
        [mStrTemp appendString:[str substringWithRange:NSMakeRange(str.length-str.length % 4,
                                                                   str.length % 4)]];
        if (nStr.length == 11) {
            [mStrTemp deleteCharactersInRange:NSMakeRange(13, 1)];
        }
    }
    
    textField.text = mStrTemp;
    
    // textField设置selectedTextRange
    NSUInteger curTargetCursorPosition = targetCursorPosition;// 当前光标的偏移位置
    if (isDelete) { //删除
        if (targetCursorPosition == 9 || targetCursorPosition == 4) {
            curTargetCursorPosition = targetCursorPosition - 1;
        }
    }
    else { //添加
//        if (nStr.length == 8 || nStr.length == 4) {
//            curTargetCursorPosition = targetCursorPosition + 1;
//        }
        if (nStr.length == 4) {
            curTargetCursorPosition = nStr.length + 1;
        }
        else if(nStr.length > 7 && nStr.length < 12){
            curTargetCursorPosition = nStr.length + 2;
        }
    }
    
    UITextPosition *targetPosition = [textField positionFromPosition:[textField beginningOfDocument]
                                                              offset:curTargetCursorPosition];
    [textField setSelectedTextRange:[textField textRangeFromPosition:targetPosition
                                                         toPosition :targetPosition]];
}

@end
