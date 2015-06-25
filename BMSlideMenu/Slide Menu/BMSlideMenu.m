//
//  BMSlideMenu.m
//  BMSlideMenu
//
//  Created by Bogdan Matveev on 24.06.15.
//  Copyright (c) 2015 BOGDAN MATVEEV. All rights reserved.
//

#import "BMSlideMenu.h"
#import "UIViewController+BMSlideMenu.h"

const NSTimeInterval kAnimationDuration = .2f;

typedef NS_ENUM(NSUInteger, BMSliderType)
{
    BMSliderTypeLeft,
    BMSliderTypeRight
};

@interface BMSlideMenu () <UIGestureRecognizerDelegate>

@property (nonatomic) IBInspectable NSString *centerViewStoryboardID;
@property (nonatomic) IBInspectable NSString *leftViewStoryboardID;
@property (nonatomic) IBInspectable NSString *rightViewStoryboardID;

@property (nonatomic) UIViewController *centerViewController;
@property (nonatomic) UIViewController *leftViewController;
@property (nonatomic) UIViewController *rightViewController;

@property (nonatomic) UIView *centerContainerView;
@property (nonatomic) UIView *menuContainerView;

@property (nonatomic) UIButton *hideMenuButton;

@property (nonatomic, assign) BOOL leftMenuVisible;
@property (nonatomic, assign) BOOL rightMenuVisible;
@end

@implementation BMSlideMenu

#pragma mark -=Initial=-
- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    _centerContainerView = [[UIView alloc] init];
}
- (void)awakeFromNib
{
    
    if (self.leftViewStoryboardID)
    {
        self.leftViewController = [self.storyboard instantiateViewControllerWithIdentifier:
                                   self.leftViewStoryboardID];
    }
    if (self.rightViewStoryboardID)
    {
        self.rightViewController = [self.storyboard instantiateViewControllerWithIdentifier:
                                    self.rightViewStoryboardID];
    }
    if (self.centerViewStoryboardID)
    {
        self.centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:
                                     self.centerViewStoryboardID];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hideMenuButton = [[UIButton alloc] initWithFrame:self.view.bounds];
    [self.hideMenuButton addTarget:self action:@selector(hideMenu)
                  forControlEvents:UIControlEventTouchUpInside];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                    initWithTarget:self action:@selector(panDidRecognized:)];
    panGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:panGestureRecognizer];
    self.view.multipleTouchEnabled = NO;
    
    self.menuContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.menuContainerView addSubview:self.leftViewController.view];
    [self.menuContainerView addSubview:self.rightViewController.view];
    [self.view addSubview:self.menuContainerView];
    
    self.centerContainerView.frame = self.view.bounds;
    [self.view addSubview:self.centerContainerView];
}

#pragma mark -=Setting up controllers=-
- (void)setLeftViewController:(UIViewController *)leftViewController
{
    _leftViewController = leftViewController;
    _leftViewController.slideMenu = self;
    _leftViewController.view.hidden = YES;
    
}
- (void)setRightViewController:(UIViewController *)rightViewController
{
    _rightViewController = rightViewController;
    _rightViewController.slideMenu = self;
    _rightViewController.view.hidden = YES;
}
- (void) setCenterViewController:(UIViewController *)centerViewController
{
    if (_centerViewController == centerViewController)
    {
        return;
    }
    centerViewController.view.alpha = 0;
    centerViewController.slideMenu = self;
    centerViewController.view.frame = self.view.bounds;
    [self.centerContainerView addSubview:centerViewController.view];

    [self hideMenu];
    [UIView animateWithDuration:kAnimationDuration animations:^{
        centerViewController.view.alpha = 1;
    } completion:^(BOOL finished) {
        [_centerViewController.view removeFromSuperview];
        _centerViewController = centerViewController;
    }];
}

#pragma mark -=Menu Animation=-
- (void)showLeftMenu
{
    [self showMenuWithType:BMSliderTypeLeft];
}
- (void)showRightMenu
{
    [self showMenuWithType:BMSliderTypeRight];
}

- (void)showMenuWithType:(BMSliderType)type
{
    float deltaX;
    if (type == BMSliderTypeLeft && !self.rightMenuVisible && self.leftViewController)
    {
        self.leftViewController.view.hidden = NO;
        self.leftMenuVisible = YES;
        deltaX = CGRectGetWidth(self.view.frame);
    }
    else if (type == BMSliderTypeRight && !self.leftMenuVisible && self.rightViewController)
    {
        self.rightViewController.view.hidden = NO;
        self.rightMenuVisible = YES;
        deltaX = 0;
    }
    else
    {
        [self hideMenu];
        return;
    }
    [self addHideMenuButtonIfNeeded];
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.centerContainerView.center = CGPointMake(deltaX,
                                                      self.centerContainerView.center.y);
    }];
}
- (void)hideMenu
{
    [self.hideMenuButton removeFromSuperview];
    self.rightMenuVisible = NO;
    self.leftMenuVisible = NO;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.centerContainerView.center = self.view.center;
    } completion:^(BOOL finished) {
        self.leftViewController.view.hidden = YES;
        self.rightViewController.view.hidden = YES;
    }];
}
- (void) addHideMenuButtonIfNeeded
{
    if (self.hideMenuButton.superview)
    {
        return;
    }
    [self.centerContainerView addSubview:self.hideMenuButton];
}

#pragma mark -=Gesture recognizer=-

- (void) panDidRecognized:(UIPanGestureRecognizer*)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:self.view];
    static CGPoint panOrigin;
    static CGPoint centerOrigin;
    static BMSliderType sliderType;
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            panOrigin = location;
            centerOrigin = self.centerContainerView.center;
            sliderType = [gestureRecognizer velocityInView:self.view].x > 0?
                                                BMSliderTypeLeft : BMSliderTypeRight;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            float deltaX = location.x - panOrigin.x;
            CGPoint center = centerOrigin;
            
            if ((sliderType == BMSliderTypeLeft && self.leftViewController)
                || (self.rightMenuVisible && deltaX > 0))
            {
                center.x = MIN(center.x + deltaX, CGRectGetWidth(self.view.bounds));
            }
            else if ((sliderType == BMSliderTypeRight && self.rightViewController)
                     || (self.leftMenuVisible && deltaX < 0))
            {
                center.x = MAX(center.x + deltaX, 0);
            }
            self.centerContainerView.center = center;
            
            self.leftViewController.view.hidden = self.centerContainerView.frame.origin.x < 0;
            self.rightViewController.view.hidden = self.centerContainerView.frame.origin.x > 0;
            
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            if ([gestureRecognizer velocityInView:self.view].x > 0)
            {
                sliderType == BMSliderTypeLeft?
                [self showMenuWithType:sliderType] : [self hideMenu];
            }
            else
            {
                sliderType == BMSliderTypeRight?
                [self showMenuWithType:sliderType] : [self hideMenu];
            }
        }
            break;
        default:
            break;
    }
}
@end
