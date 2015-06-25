//
//  UIViewController+BMSlideMenu.m
//  BMSlideMenu
//
//  Created by Bogdan Matveev on 24.06.15.
//  Copyright (c) 2015 BOGDAN MATVEEV. All rights reserved.
//

#import "UIViewController+BMSlideMenu.h"
#import <objc/runtime.h>

const char *const key = "slideMenu";
@implementation UIViewController(BMSlideMenu)
@dynamic slideMenu;

- (void)setSlideMenu:(BMSlideMenu *)slideMenu
{
    objc_setAssociatedObject(self, key, slideMenu, OBJC_ASSOCIATION_ASSIGN);
}

- (BMSlideMenu *)slideMenu
{
    return objc_getAssociatedObject(self, key);
}

- (void)showLeftMenu:(id)sender
{
    [self.slideMenu showLeftMenu];
}

- (void)showRightMenu:(id)sender
{
    [self.slideMenu showRightMenu];
}
@end
