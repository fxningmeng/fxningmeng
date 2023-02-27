//
//  UITextField+Keyboard.m
//  Ielpm_Wallet
//
//  Created by maxinli on 16/2/19.
//  Copyright © 2016年 com.yishicompany.www. All rights reserved.
//

#import "UITextField+Keyboard.h"

@implementation UITextField (Keyboard)
- (void)setTextFieldKeyboardType:(UIKeyboardType)keyboardType
{
    if (keyboardType != UIKeyboardTypePhonePad) {
        if (![self hasExtensionInputMode]) {
            [self addToolBarForKeyboard];
        }
        self.inputView = nil;
        [self setKeyboardType:keyboardType];
        return;
    }
    CGFloat bottomSpace = BOTTOM_SAFE_SPACE;
    if (bottomSpace != 0) {
        bottomSpace += 40;
    }
    KeyboardNumberPad *view = [[KeyboardNumberPad alloc] initWithFrame:CGRectMake(0, 0, SCREENT_WIDTH, 216 + BOTTOM_SAFE_SPACE)];
    self.inputView = view;
    self.inputAccessoryView = nil;
    view.delegate = self;
}

- (BOOL)hasExtensionInputMode{
    NSArray *models = [UITextInputMode activeInputModes];
    for (UITextInputMode *model in models) {
        if ([NSStringFromClass([model class]) isEqualToString:@"UIKeyboardExtensionInputMode"]) {
            return YES;
        }
    }
    return NO;
}

- (void)resetView
{
    [self endEditing:YES];
}

- (void)addToolBarForKeyboard
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, SCREENT_WIDTH, 44.0f)];
    toolbar.barStyle=UIBarStyleDefault;
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resetView)];
    [toolbar setItems:[NSArray arrayWithObjects:flexibleSpace, barButtonItem, nil]];
    
    self.inputAccessoryView = toolbar;
}

- (NSRange)selectedNSRange
{
    UITextPosition *beginning = self.beginningOfDocument;
    
    UITextRange *selectedRange = self.selectedTextRange;
    UITextPosition *selectionStart = selectedRange.start;
    UITextPosition *selectionEnd = selectedRange.end;
    
    NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
    NSInteger length = [self offsetFromPosition:selectionStart toPosition:selectionEnd];
    
    return NSMakeRange(location, length);
}

#pragma mark KeyboardNumberPadProtocol
- (void)keyBoardTapWithContent:(NSString *)content
{
    if ([content isEqualToString:@"finish"]) {
        [self resignFirstResponder];
        return;
    }

    BOOL allowToHandel = YES;
    if ([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        NSRange range = [self selectedNSRange];
        allowToHandel = [self.delegate textField:self shouldChangeCharactersInRange:range replacementString:content];
    }
    
    if (allowToHandel) {
        if ([content isEqualToString:@""]) {
            [self deleteBackward];
        }else {
            [self insertText:content];
        }
    }
}


@end
