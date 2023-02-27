//
//  UITextField+BankCardNum.m
//  Ielpm_Wallet
//
//  Created by YSHI_LGQ on 16/3/16.
//  Copyright © 2016年 com.yishicompany.www. All rights reserved.
//

#import "UITextField+BankCardNum.h"
#import <objc/runtime.h>

static const void *__CardPrivateProcessorKey = &__CardPrivateProcessorKey;

@interface __CardPrivateProcessor :NSObject<UITextFieldDelegate>
- (void)__reformatAsBankCardNumber:(UITextField *)textField;
- (void)__cardTextFieldShouldChange:(UITextField *)textField;
@end

@implementation UITextField (BankCardNum)

- (void)add__formatBankCardNum
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(__tfCardTextDidChange)
                                                 name:UITextFieldTextDidChangeNotification object:self];
    
    __CardPrivateProcessor *processor = [[__CardPrivateProcessor alloc] init];
    [self __setCardProcessor:processor];
    
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
                                DLog(@"======ie_hookSelector======");
                                [[wSelf __getCardProcessor] __cardTextFieldShouldChange:self];
                            }];
    } else {
        self.delegate = processor;
    }
}

- (void)ie_setBankCardNumFormater {
    [self add__formatBankCardNum];
}

- (void)ie_removeBankCardNumFormater {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.delegate = nil;
}

/** self.delegate没有实现该方法时，自动添加到self.delegate中，其他情况没用 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (void)__tfCardTextDidChange {
    [[self __getCardProcessor] __reformatAsBankCardNumber:self];
}

- (void)__setCardProcessor:(__CardPrivateProcessor *)processor {
    objc_setAssociatedObject(self, __CardPrivateProcessorKey, processor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (__CardPrivateProcessor *)__getCardProcessor {
    return objc_getAssociatedObject(self, __CardPrivateProcessorKey);
}

@end

@implementation __CardPrivateProcessor
{
    NSString    *_previousTextFieldContent;
    UITextRange *_previousSelection;
}

- (void)__cardTextFieldShouldChange:(UITextField *)textField {
    _previousSelection = textField.selectedTextRange;
    _previousTextFieldContent = textField.text;
}

#pragma mark - UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    _previousSelection = textField.selectedTextRange;
    _previousTextFieldContent = textField.text;
    return YES;
}

-(void)__reformatAsBankCardNumber:(UITextField *)textField
{
    // 判断正确的光标位置
    NSUInteger targetCursorPostion = [textField offsetFromPosition:textField.beginningOfDocument toPosition:textField.selectedTextRange.start];
    // 没有插入空格的银行卡号
    NSString *bankCardNumberWithoutSpaces = [self removeNonDigits:textField.text andPreserveCursorPosition:&targetCursorPostion];

    if(bankCardNumberWithoutSpaces.length > 19) {
        [textField setText:_previousTextFieldContent];
        textField.selectedTextRange = _previousSelection;
        return;
    }
    // 获取插入空格后的银行卡号
    NSString *bankCardNumberWithSpaces = [self insertSpacesEveryFourDigitsIntoString:bankCardNumberWithoutSpaces andPreserveCursorPosition:&targetCursorPostion];

    textField.text = bankCardNumberWithSpaces;

    UITextPosition *targetPostion = [textField positionFromPosition:textField.beginningOfDocument offset:targetCursorPostion];
    [textField setSelectedTextRange:[textField textRangeFromPosition:targetPostion toPosition:targetPostion]];
}

/**
 *  除去非数字字符(空格)，确定光标正确位置
 *
 *  @param string         当前的string
 *  @param cursorPosition 光标位置
 *
 *  @return 处理过后的string
 */
- (NSString *)removeNonDigits:(NSString *)string andPreserveCursorPosition:(NSUInteger *)cursorPosition
{
    NSUInteger originalCursorPosition =*cursorPosition;
    NSMutableString *digitsOnlyString = [NSMutableString new];

    for (NSUInteger i=0; i<string.length; i++) {
        unichar characterToAdd = [string characterAtIndex:i];
        if(isdigit(characterToAdd)) {
            NSString *stringToAdd = [NSString stringWithCharacters:&characterToAdd length:1];
            [digitsOnlyString appendString:stringToAdd];
        }
        else {
            if(i<originalCursorPosition) {
                (*cursorPosition)--;
            }
        }
    }
    return digitsOnlyString;
}

/**
 *  将空格插入我们现在的string 中，并确定光标的正确位置，防止在空格中出现问题
 *
 *  @param string         当前的string
 *  @param cursorPosition 光标位置
 *
 *  @return 处理后有空格的string
 */
- (NSString *)insertSpacesEveryFourDigitsIntoString:(NSString *)string andPreserveCursorPosition:(NSUInteger *)cursorPosition
{
    NSMutableString *stringWithAddedSpaces = [NSMutableString new];
    NSUInteger cursorPositionInSpacelessString = *cursorPosition;
    for (NSUInteger i=0; i<string.length; i++) {
        if ( i > 0 ){
            if(i%4 == 0) {
                [stringWithAddedSpaces appendString:@" "];
                if(i < cursorPositionInSpacelessString) {
                    (*cursorPosition)++;
                }
            }
        }
        unichar characterToAdd = [string characterAtIndex:i];
        NSString *stringToAdd = [NSString stringWithCharacters:&characterToAdd length:1];
        
        [stringWithAddedSpaces appendString:stringToAdd];
    }
    return stringWithAddedSpaces;
}

@end
