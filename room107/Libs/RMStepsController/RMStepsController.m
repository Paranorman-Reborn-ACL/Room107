//
//  RMViewController.m
//  RMStepsController
//
//  Created by Roland Moers on 14.11.13.
//  Copyright (c) 2013 Roland Moers
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "RMStepsController.h"

@interface RMStepsController ()

@property (nonatomic, strong, readwrite) NSMutableDictionary *results;
@property (nonatomic, strong) UIViewController *currentStepViewController;

@property (nonatomic, strong) UIView *stepViewControllerContainer;
@property (nonatomic) CGFloat containerY;

@end

@implementation RMStepsController

#pragma mark - Configuration
- (NSArray *)stepViewControllers {
    return @[];
}

- (NSArray *)stepTitles {
    return @[];
}

#pragma mark - Init and Dealloc
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.stepViewControllerContainer];
    
    CGFloat originX = 11.0f;
    _tradingProcessView = [[TradingProcessView alloc] initWithFrame:(CGRect){originX, [self spacingY], CGRectGetWidth(self.view.bounds) - 2 * originX, navigationBarHeight + [self spacingY]} processesArray:[self stepTitles]];
    [self.view addSubview:_tradingProcessView];
    
    _containerY = CGRectGetHeight(_tradingProcessView.bounds) + 2 * [self spacingY];
    UIView *container = self.stepViewControllerContainer;
    
    NSDictionary *bindingsDict = NSDictionaryOfVariableBindings(container);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[container]-(0)-|" options:0 metrics:nil views:bindingsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[container]-0-|" options:0 metrics:nil views:bindingsDict]];
    
    [self loadStepViewControllers];
    [self showStepViewController:[self.childViewControllers objectAtIndex:0] animated:NO];
}

#pragma mark - Properties
- (NSMutableDictionary *)results {
    if(!_results) {
        self.results = [@{} mutableCopy];
    }
    
    return _results;
}

- (UIView *)stepViewControllerContainer {
    if(!_stepViewControllerContainer) {
        self.stepViewControllerContainer = [[UIView alloc] initWithFrame:CGRectZero];
        _stepViewControllerContainer.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    return _stepViewControllerContainer;
}

#pragma mark - Helper
- (BOOL)extendViewControllerBelowBars:(UIViewController *)aViewController {
    return (aViewController.extendedLayoutIncludesOpaqueBars || (aViewController.edgesForExtendedLayout & UIRectEdgeTop));
}

- (void)updateContentInsetsForViewController:(UIViewController *)aViewController {
    if([self extendViewControllerBelowBars:aViewController]) {
        UIEdgeInsets insets = UIEdgeInsetsZero;
        insets.top += 0;
        
        [aViewController adaptToEdgeInsets:insets];
    }
}

- (void)loadStepViewControllers {
    NSArray *stepViewControllers = [self stepViewControllers];
    NSAssert([stepViewControllers count] > 0, @"Fatal: At least one step view controller must be returned by -[%@ stepViewControllers].", [self class]);
    
    for(UIViewController *aViewController in stepViewControllers) {
        NSAssert([aViewController isKindOfClass:[UIViewController class]], @"Fatal: %@ is not a subclass from UIViewController. Only UIViewControllers are supported by RMStepsController as steps.", [aViewController class]);
        
        aViewController.stepsController = self;
        
        [aViewController willMoveToParentViewController:self];
        [self addChildViewController:aViewController];
        [aViewController didMoveToParentViewController:self];
    }
}

- (void)showStepViewController:(UIViewController *)aViewController animated:(BOOL)animated {
    if(!animated) {
        [self showStepViewControllerWithoutAnimation:aViewController];
    } else {
        [self showStepViewControllerWithSlideInAnimation:aViewController];
    }
    
    [self updateContentInsetsForViewController:aViewController];
    
    [_tradingProcessView setCurrentStep:[NSNumber numberWithUnsignedInteger:[self.childViewControllers indexOfObject:aViewController]]];
}

- (void)showStepViewControllerWithoutAnimation:(UIViewController *)aViewController {
    [self.currentStepViewController.view removeFromSuperview];
    
    aViewController.view.frame = CGRectMake(0, _containerY, self.stepViewControllerContainer.frame.size.width, self.stepViewControllerContainer.frame.size.height - _containerY);
    aViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    aViewController.view.translatesAutoresizingMaskIntoConstraints = YES;
    
    [self.stepViewControllerContainer addSubview:aViewController.view];
    
    self.currentStepViewController = aViewController;
    
    [_tradingProcessView setCurrentStep:[NSNumber numberWithUnsignedInteger:[self.childViewControllers indexOfObject:aViewController]]];
}

- (void)showStepViewControllerWithSlideInAnimation:(UIViewController *)aViewController {
    NSInteger oldIndex = [self.childViewControllers indexOfObject:self.currentStepViewController];
    NSInteger newIndex = [self.childViewControllers indexOfObject:aViewController];
    
    BOOL fromLeft = NO;
    if(oldIndex < newIndex)
        fromLeft = NO;
    else
        fromLeft = YES;
    
    aViewController.view.frame = CGRectMake(fromLeft ? -self.stepViewControllerContainer.frame.size.width : self.stepViewControllerContainer.frame.size.width, _containerY, self.stepViewControllerContainer.frame.size.width, self.stepViewControllerContainer.frame.size.height - _containerY);
    aViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    aViewController.view.translatesAutoresizingMaskIntoConstraints = YES;
    
    [self.stepViewControllerContainer addSubview:aViewController.view];
    
    [_tradingProcessView setCurrentStep:[NSNumber numberWithUnsignedInteger:[self.childViewControllers indexOfObject:aViewController]]];
    
    __weak RMStepsController *blockself = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        aViewController.view.frame = CGRectMake(0, _containerY, blockself.stepViewControllerContainer.frame.size.width, blockself.stepViewControllerContainer.frame.size.height - _containerY);
        blockself.currentStepViewController.view.frame = CGRectMake(fromLeft ? blockself.stepViewControllerContainer.frame.size.width : -blockself.stepViewControllerContainer.frame.size.width, blockself.currentStepViewController.view.frame.origin.y, blockself.currentStepViewController.view.frame.size.width, blockself.currentStepViewController.view.frame.size.height);
    } completion:^(BOOL finished) {
        [blockself.currentStepViewController.view removeFromSuperview];
        blockself.currentStepViewController = aViewController;
    }];
}

- (void)viewDidLayoutSubviews {
    self.currentStepViewController.view.frame = CGRectMake(0, _containerY, self.stepViewControllerContainer.frame.size.width, self.stepViewControllerContainer.frame.size.height - _containerY);
    [self updateContentInsetsForViewController:self.currentStepViewController];
}

#pragma mark - Actions
- (void)showNextStep {
    NSInteger index = [self.childViewControllers indexOfObject:self.currentStepViewController];
    if(index < [self.childViewControllers count]-1) {
        UIViewController *nextStepViewController = [self.childViewControllers objectAtIndex:index+1];
        [self showStepViewController:nextStepViewController animated:YES];
    } else {
        [self finishedAllSteps];
    }
}

- (void)showPreviousStep {
    NSInteger index = [self.childViewControllers indexOfObject:self.currentStepViewController];
    if(index > 0) {
        UIViewController *nextStepViewController = [self.childViewControllers objectAtIndex:index-1];
        [self showStepViewController:nextStepViewController animated:YES];
    } else {
        [self canceled];
    }
}

- (void)showStepForIndex:(NSInteger)index animated:(BOOL)animated {
    UIViewController *stepViewController = [self.childViewControllers objectAtIndex:index];
    [self showStepViewController:stepViewController animated:animated];
}

- (NSUInteger)currentStep {
    return [self.childViewControllers indexOfObject:self.currentStepViewController];
}

- (void)finishedAllSteps {
    LogDebug(@"Finished");
}

- (void)canceled {
    LogDebug(@"Canceled");
}

@end

#pragma mark - Helper Categories

#import <objc/runtime.h>

static char const * const stepsControllerKey = "stepsControllerKey";

@implementation UIViewController (RMStepsController)

//@dynamic stepsController, step;

#pragma marl - Properties
- (RMStepsController *)stepsController {
    return objc_getAssociatedObject(self, stepsControllerKey);
}

- (void)setStepsController:(RMStepsController *)stepsController {
    objc_setAssociatedObject(self, stepsControllerKey, stepsController, OBJC_ASSOCIATION_ASSIGN);
}

#pragma mark - Helper
- (void)adaptToEdgeInsets:(UIEdgeInsets)newInsets {
    
}

@end

@interface UITableViewController (RMMultipleViewsController)
@end

@implementation UITableViewController (RMMultipleViewsController)

#pragma mark - Helper
- (void)adaptToEdgeInsets:(UIEdgeInsets)newInsets {
    self.tableView.contentInset = newInsets;
    self.tableView.scrollIndicatorInsets = newInsets;
}

@end

@interface UICollectionViewController (RMMultipleViewsController)
@end

@implementation UICollectionViewController (RMMultipleViewsController)

#pragma mark - Helper
- (void)adaptToEdgeInsets:(UIEdgeInsets)newInsets {
    self.collectionView.contentInset = newInsets;
    self.collectionView.scrollIndicatorInsets = newInsets;
}

@end
