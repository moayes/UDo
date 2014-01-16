//
//  UIAlertView+RWBlock.h
//  UDo
//
//  Created by Soheil Azarpour on 1/7/14.
//  Copyright (c) 2014 Soheil Azarpour. All rights reserved.
//

@import UIKit;

typedef void (^RWAlertViewCompletionBlock)(UIAlertView *alertView, NSInteger buttonIndex);

@interface UIAlertView (RWBlock) <UIAlertViewDelegate>

- (void)setCompletionBlock:(RWAlertViewCompletionBlock)completionBlock;
- (RWAlertViewCompletionBlock)completionBlock;

@end
