//
//  UIAlertView+RWBlock.m
//  UDo
//
//  Created by Soheil Azarpour on 1/7/14.
//  Copyright (c) 2014 Soheil Azarpour. All rights reserved.
//

#import "UIAlertView+RWBlock.h"
#import <objc/runtime.h>

@implementation UIAlertView (RWBlock)

- (void)setCompletionBlock:(RWAlertViewCompletionBlock)completionBlock {
  objc_setAssociatedObject(self, @selector(completionBlock), completionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
  if (completionBlock == NULL) {
    self.delegate = nil;
  }
  else {
    self.delegate = self;
  }
}

- (RWAlertViewCompletionBlock)completionBlock {
  return objc_getAssociatedObject(self, @selector(completionBlock));
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
  if (self.completionBlock) {
    self.completionBlock(self, buttonIndex);
  }
}

@end
