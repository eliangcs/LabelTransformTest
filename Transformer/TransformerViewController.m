//
//  TransformerViewController.m
//  Transformer
//
//  Created by Lion User on 10/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TransformerViewController.h"

@interface TransformerViewController ()
@property (weak, nonatomic) IBOutlet UILabel *mylabel;
@end

@implementation TransformerViewController
@synthesize mylabel = _mylabel;

- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        UIView *piece = gesture.view;
        CGPoint locationInView = [gesture locationInView:piece];
        CGPoint locationInSuperview = [gesture locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}

- (void)setMylabel:(UILabel *)mylabel
{
    _mylabel = mylabel;
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaleMyLabel:)];
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateMyLabel:)];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panMyLabel:)];
    
    [pinchGesture setDelegate:self];
    [rotationGesture setDelegate:self];
    [panGesture setDelegate:self];	
    
    [self.mylabel addGestureRecognizer:pinchGesture];
    [self.mylabel addGestureRecognizer:rotationGesture];
    [self.mylabel addGestureRecognizer:panGesture];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{	
    return YES;
}

- (void)scaleMyLabel:(UIPinchGestureRecognizer *)gesture
{
    [self adjustAnchorPointForGestureRecognizer:gesture];
    
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged)
    {
        UILabel *label = (UILabel *) gesture.view;
        CGFloat newFontSize = MAX(10.0f, MIN(1500.0f, label.font.pointSize * gesture.scale));
        
        // set font size
        label.font = [self.mylabel.font fontWithSize:newFontSize];
        CGSize newSize = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(9999.0f, 9999.0f) lineBreakMode:label.lineBreakMode];
        
        // set view width and height
        CGRect newBounds = label.bounds;
        newBounds.size = newSize;
        label.bounds = newBounds;
        
        gesture.scale = 1.0f;
    }
}

- (void)panMyLabel:(UIPanGestureRecognizer *)gesture
{    
    [self adjustAnchorPointForGestureRecognizer:gesture];
    
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [gesture translationInView:gesture.view.superview];
        
        gesture.view.center = CGPointMake(gesture.view.center.x + translation.x, gesture.view.center.y + translation.y);
        [gesture setTranslation:CGPointZero inView:gesture.view.superview];
    }
}

- (void)rotateMyLabel:(UIRotationGestureRecognizer *)gesture
{
    [self adjustAnchorPointForGestureRecognizer:gesture];
    
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged)
    {
        gesture.view.transform = CGAffineTransformRotate(gesture.view.transform, gesture.rotation);
        gesture.rotation = 0.0f;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // if the gesture recognizers's view isn't one of our pieces, don't allow simultaneous recognition
    if (gestureRecognizer.view != self.mylabel)
        return NO;
    
    // if the gesture recognizers are on different views, don't allow simultaneous recognition
    if (gestureRecognizer.view != otherGestureRecognizer.view)
        return NO;
    
    // if either of the gesture recognizers is the long press, don't allow simultaneous recognition
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] || [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
        return NO;
    
    return YES;
}

@end
