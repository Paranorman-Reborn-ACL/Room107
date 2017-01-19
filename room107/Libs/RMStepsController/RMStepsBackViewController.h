//
//  RMStepsBackViewController.h
//  room107
//
//  Created by ningxia on 15/9/8.
//  Copyright (c) 2015年 107room. All rights reserved.
//

#import "Room107ViewController.h"

@interface RMStepsBackViewController : Room107ViewController

/// @name Properties

/**
 Returns an instance `NSMutableDictionary` which can be used for storing results of one step. These results can then be accessed by another step using the dictionary returned here.
 */
@property (nonatomic, strong, readonly) NSMutableDictionary *results;

/// @name Instance Methods

/**
 A subclass of `RMStepsController` is supposed to return an array of view controllers here. Every view controller will be one step in the process. The first element in the array will be the first step and the last element will be the last step.
 
 The default implementation returns an empty array.
 
 @return An array with one view controller for every step.
 */
- (NSArray *)stepViewControllers;

- (NSArray *)stepTitles;

/**
 Call this method to proceed to the next step. When you call this method when already in the last step `-[RMStepsController finishedAllSteps]`will be called.
 */
- (void)showNextStep;

/**
 Call this method to proceed to the needed step.
 */
- (void)showStepForIndex:(NSInteger)index;

/**
 Call this method to go one step back. When you call this method when already in the first step `-[RMStepsController canceled]`will be called.
 */
- (void)showPreviousStep;

/**
 This method is called after `-[RMStepsController showNextStep]` has been called in the last step. A subclass of `RMStepsController` is supposed to do whatever needs to be done here after all steps have been finished.
 */
- (void)finishedAllSteps;

/**
 This method is called after `-[RMStepsController showPreviousStep]` has been called in the first step. A subclass of `RMStepsController` is supposed to do whatever needs to be done here after the process has been canceled by the user.
 */
- (void)canceled;

@end

/**
 `UIViewController(RMStepsController)` is a category of `UIViewController` for providing mandatory properties so that a UIViewController can be used as a step in `RMStepsController`.
 */

@interface UIViewController (RMStepsController)

/**
 Provides access to the instance of `RMStepsController` this `UIViewController` is shown in as a child view controller.
 
 If this `UIViewController` is not part of any `RMStepsController` this property will be `nil`.
 */
@property (nonatomic, strong) RMStepsBackViewController *stepsController;

/**
 This method is called when a `RMStepsController` is about to show the called instance of `UIViewController` and this instance indicates that it wants to be extended below bars. The called `UIViewController` can use the parameters to update it's content such that no content will disappear below a toolbar.
 
 @param newInsets The new edge insets.
 */
- (void)adaptToEdgeInsets:(UIEdgeInsets)newInsets;

@end
