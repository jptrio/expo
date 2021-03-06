#import <UIKit/UIKit.h>

#import "ABI39_0_0RNSScreen.h"
#import "ABI39_0_0RNSScreenContainer.h"
#import "ABI39_0_0RNSScreenStackHeaderConfig.h"

#import <ABI39_0_0React/ABI39_0_0RCTUIManager.h>
#import <ABI39_0_0React/ABI39_0_0RCTShadowView.h>
#import <ABI39_0_0React/ABI39_0_0RCTTouchHandler.h>

@interface ABI39_0_0RNSScreenView () <UIAdaptivePresentationControllerDelegate, ABI39_0_0RCTInvalidating>
@end

@implementation ABI39_0_0RNSScreenView {
  __weak ABI39_0_0RCTBridge *_bridge;
  ABI39_0_0RNSScreen *_controller;
  ABI39_0_0RCTTouchHandler *_touchHandler;
}

@synthesize controller = _controller;

- (instancetype)initWithBridge:(ABI39_0_0RCTBridge *)bridge
{
  if (self = [super init]) {
    _bridge = bridge;
    _controller = [[ABI39_0_0RNSScreen alloc] initWithView:self];
    _stackPresentation = ABI39_0_0RNSScreenStackPresentationPush;
    _stackAnimation = ABI39_0_0RNSScreenStackAnimationDefault;
    _gestureEnabled = YES;
    _replaceAnimation = ABI39_0_0RNSScreenReplaceAnimationPop;
    _dismissed = NO;
  }

  return self;
}

- (void)ABI39_0_0ReactSetFrame:(CGRect)frame
{
  if (![self.ABI39_0_0ReactViewController.parentViewController
        isKindOfClass:[UINavigationController class]]) {
    [super ABI39_0_0ReactSetFrame:frame];
  }
  // when screen is mounted under UINavigationController it's size is controller
  // by the navigation controller itself. That is, it is set to fill space of
  // the controller. In that case we ignore ABI39_0_0React layout system from managing
  // the screen dimentions and we wait for the screen VC to update and then we
  // pass the dimentions to ui view manager to take into account when laying out
  // subviews
}

- (UIViewController *)ABI39_0_0ReactViewController
{
  return _controller;
}

- (void)updateBounds
{
  [_bridge.uiManager setSize:self.bounds.size forView:self];
}

- (void)setActive:(BOOL)active
{
  if (active != _active) {
    _active = active;
    [_ABI39_0_0ReactSuperview markChildUpdated];
  }
}

- (void)setPointerEvents:(ABI39_0_0RCTPointerEvents)pointerEvents
{
  // pointer events settings are managed by the parent screen container, we ignore
  // any attempt of setting that via ABI39_0_0React props
}

- (void)setStackPresentation:(ABI39_0_0RNSScreenStackPresentation)stackPresentation
{
  switch (stackPresentation) {
    case ABI39_0_0RNSScreenStackPresentationModal:
#ifdef __IPHONE_13_0
      if (@available(iOS 13.0, *)) {
        _controller.modalPresentationStyle = UIModalPresentationAutomatic;
      } else {
        _controller.modalPresentationStyle = UIModalPresentationFullScreen;
      }
#else
      _controller.modalPresentationStyle = UIModalPresentationFullScreen;
#endif
      break;
    case ABI39_0_0RNSScreenStackPresentationFullScreenModal:
      _controller.modalPresentationStyle = UIModalPresentationFullScreen;
      break;
    case ABI39_0_0RNSScreenStackPresentationFormSheet:
      _controller.modalPresentationStyle = UIModalPresentationFormSheet;
      break;
    case ABI39_0_0RNSScreenStackPresentationTransparentModal:
      _controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
      break;
    case ABI39_0_0RNSScreenStackPresentationContainedModal:
      _controller.modalPresentationStyle = UIModalPresentationCurrentContext;
      break;
    case ABI39_0_0RNSScreenStackPresentationContainedTransparentModal:
      _controller.modalPresentationStyle = UIModalPresentationOverCurrentContext;
      break;
    case ABI39_0_0RNSScreenStackPresentationPush:
      // ignored, we only need to keep in mind not to set presentation delegate
      break;
  }
  // There is a bug in UIKit which causes retain loop when presentationController is accessed for a
  // controller that is not going to be presented modally. We therefore need to avoid setting the
  // delegate for screens presented using push. This also means that when controller is updated from
  // modal to push type, this may cause memory leak, we warn about that as well.
  if (stackPresentation != ABI39_0_0RNSScreenStackPresentationPush) {
    // `modalPresentationStyle` must be set before accessing `presentationController`
    // otherwise a default controller will be created and cannot be changed after.
    // Documented here: https://developer.apple.com/documentation/uikit/uiviewcontroller/1621426-presentationcontroller?language=objc
    _controller.presentationController.delegate = self;
  } else if (_stackPresentation != ABI39_0_0RNSScreenStackPresentationPush) {
    ABI39_0_0RCTLogError(@"Screen presentation updated from modal to push, this may likely result in a screen object leakage. If you need to change presentation style create a new screen object instead");
  }
  _stackPresentation = stackPresentation;
}

- (void)setStackAnimation:(ABI39_0_0RNSScreenStackAnimation)stackAnimation
{
  _stackAnimation = stackAnimation;

  switch (stackAnimation) {
    case ABI39_0_0RNSScreenStackAnimationFade:
      _controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
      break;
    case ABI39_0_0RNSScreenStackAnimationFlip:
      _controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
      break;
    case ABI39_0_0RNSScreenStackAnimationNone:
    case ABI39_0_0RNSScreenStackAnimationDefault:
      // Default
      break;
  }
}

- (void)setGestureEnabled:(BOOL)gestureEnabled
{
  #ifdef __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
      _controller.modalInPresentation = !gestureEnabled;
    }
  #endif

  _gestureEnabled = gestureEnabled;
}

- (void)setReplaceAnimation:(ABI39_0_0RNSScreenReplaceAnimation)replaceAnimation
{
  _replaceAnimation = replaceAnimation;
}

- (UIView *)ABI39_0_0ReactSuperview
{
  return _ABI39_0_0ReactSuperview;
}

- (void)addSubview:(UIView *)view
{
  if (![view isKindOfClass:[ABI39_0_0RNSScreenStackHeaderConfig class]]) {
    [super addSubview:view];
  } else {
    ((ABI39_0_0RNSScreenStackHeaderConfig*) view).screenView = self;
  }
}

- (void)notifyFinishTransitioning
{
  [_controller notifyFinishTransitioning];
}

- (void)notifyDismissed
{
  _dismissed = YES;
  if (self.onDismissed) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (self.onDismissed) {
        self.onDismissed(nil);
      }
    });
  }
}

- (void)notifyWillAppear
{
  if (self.onWillAppear) {
    self.onWillAppear(nil);
  }
}

- (void)notifyWillDisappear
{
  if (self.onWillDisappear) {
    self.onWillDisappear(nil);
  }
}

- (void)notifyAppear
{
  if (self.onAppear) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (self.onAppear) {
        self.onAppear(nil);
      }
    });
  }
}

- (void)notifyDisappear
{
  if (self.onDisappear) {
    self.onDisappear(nil);
  }
}

- (BOOL)isMountedUnderScreenOrABI39_0_0ReactRoot
{
  for (UIView *parent = self.superview; parent != nil; parent = parent.superview) {
    if ([parent isKindOfClass:[ABI39_0_0RCTRootView class]] || [parent isKindOfClass:[ABI39_0_0RNSScreenView class]]) {
      return YES;
    }
  }
  return NO;
}

- (void)didMoveToWindow
{
  // For ABI39_0_0RN touches to work we need to instantiate and connect ABI39_0_0RCTTouchHandler. This only applies
  // for screens that aren't mounted under ABI39_0_0RCTRootView e.g., modals that are mounted directly to
  // root application window.
  if (self.window != nil && ![self isMountedUnderScreenOrABI39_0_0ReactRoot]) {
    if (_touchHandler == nil) {
      _touchHandler = [[ABI39_0_0RCTTouchHandler alloc] initWithBridge:_bridge];
    }
    [_touchHandler attachToView:self];
  } else {
    [_touchHandler detachFromView:self];
  }
}

- (void)presentationControllerWillDismiss:(UIPresentationController *)presentationController
{
  // We need to call both "cancel" and "reset" here because ABI39_0_0RN's gesture recognizer
  // does not handle the scenario when it gets cancelled by other top
  // level gesture recognizer. In this case by the modal dismiss gesture.
  // Because of that, at the moment when this method gets called the ABI39_0_0React's
  // gesture recognizer is already in FAILED state but cancel events never gets
  // send to JS. Calling "reset" forces ABI39_0_0RCTTouchHanler to dispatch cancel event.
  // To test this behavior one need to open a dismissable modal and start
  // pulling down starting at some touchable item. Without "reset" the touchable
  // will never go back from highlighted state even when the modal start sliding
  // down.
  [_touchHandler cancel];
  [_touchHandler reset];
}

- (BOOL)presentationControllerShouldDismiss:(UIPresentationController *)presentationController
{
  return _gestureEnabled;
}

- (void)presentationControllerDidDismiss:(UIPresentationController *)presentationController
{
  if ([_ABI39_0_0ReactSuperview respondsToSelector:@selector(presentationControllerDidDismiss:)]) {
    [_ABI39_0_0ReactSuperview performSelector:@selector(presentationControllerDidDismiss:)
                          withObject:presentationController];
  }
}

- (void)invalidate
{
  _controller = nil;
}

@end

@implementation ABI39_0_0RNSScreen {
  __weak id _previousFirstResponder;
  CGRect _lastViewFrame;
}

- (instancetype)initWithView:(UIView *)view
{
  if (self = [super init]) {
    self.view = view;
  }
  return self;
}

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];

  if (!CGRectEqualToRect(_lastViewFrame, self.view.frame)) {
    _lastViewFrame = self.view.frame;
    [((ABI39_0_0RNSScreenView *)self.viewIfLoaded) updateBounds];
  }
}

- (id)findFirstResponder:(UIView*)parent
{
  if (parent.isFirstResponder) {
    return parent;
  }
  for (UIView *subView in parent.subviews) {
    id responder = [self findFirstResponder:subView];
    if (responder != nil) {
      return responder;
    }
  }
  return nil;
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
  [super willMoveToParentViewController:parent];
  if (parent == nil) {
    id responder = [self findFirstResponder:self.view];
    if (responder != nil) {
      _previousFirstResponder = responder;
    }
  }
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  [((ABI39_0_0RNSScreenView *)self.view) notifyWillAppear];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];

  [((ABI39_0_0RNSScreenView *)self.view) notifyWillDisappear];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [((ABI39_0_0RNSScreenView *)self.view) notifyAppear];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];

  [((ABI39_0_0RNSScreenView *)self.view) notifyDisappear];
  if (self.parentViewController == nil && self.presentingViewController == nil) {
    // screen dismissed, send event
    [((ABI39_0_0RNSScreenView *)self.view) notifyDismissed];
  }
}

- (void)notifyFinishTransitioning
{
  [_previousFirstResponder becomeFirstResponder];
  _previousFirstResponder = nil;
}

@end

@implementation ABI39_0_0RNSScreenManager

ABI39_0_0RCT_EXPORT_MODULE()

ABI39_0_0RCT_EXPORT_VIEW_PROPERTY(active, BOOL)
ABI39_0_0RCT_EXPORT_VIEW_PROPERTY(gestureEnabled, BOOL)
ABI39_0_0RCT_EXPORT_VIEW_PROPERTY(replaceAnimation, ABI39_0_0RNSScreenReplaceAnimation)
ABI39_0_0RCT_EXPORT_VIEW_PROPERTY(stackPresentation, ABI39_0_0RNSScreenStackPresentation)
ABI39_0_0RCT_EXPORT_VIEW_PROPERTY(stackAnimation, ABI39_0_0RNSScreenStackAnimation)
ABI39_0_0RCT_EXPORT_VIEW_PROPERTY(onWillAppear, ABI39_0_0RCTDirectEventBlock);
ABI39_0_0RCT_EXPORT_VIEW_PROPERTY(onWillDisappear, ABI39_0_0RCTDirectEventBlock);
ABI39_0_0RCT_EXPORT_VIEW_PROPERTY(onAppear, ABI39_0_0RCTDirectEventBlock);
ABI39_0_0RCT_EXPORT_VIEW_PROPERTY(onDisappear, ABI39_0_0RCTDirectEventBlock);
ABI39_0_0RCT_EXPORT_VIEW_PROPERTY(onDismissed, ABI39_0_0RCTDirectEventBlock);

- (UIView *)view
{
  return [[ABI39_0_0RNSScreenView alloc] initWithBridge:self.bridge];
}

@end

@implementation ABI39_0_0RCTConvert (ABI39_0_0RNSScreen)

ABI39_0_0RCT_ENUM_CONVERTER(ABI39_0_0RNSScreenStackPresentation, (@{
                                                  @"push": @(ABI39_0_0RNSScreenStackPresentationPush),
                                                  @"modal": @(ABI39_0_0RNSScreenStackPresentationModal),
                                                  @"fullScreenModal": @(ABI39_0_0RNSScreenStackPresentationFullScreenModal),
                                                  @"formSheet": @(ABI39_0_0RNSScreenStackPresentationFormSheet),
                                                  @"containedModal": @(ABI39_0_0RNSScreenStackPresentationContainedModal),
                                                  @"transparentModal": @(ABI39_0_0RNSScreenStackPresentationTransparentModal),
                                                  @"containedTransparentModal": @(ABI39_0_0RNSScreenStackPresentationContainedTransparentModal)
                                                  }), ABI39_0_0RNSScreenStackPresentationPush, integerValue)

ABI39_0_0RCT_ENUM_CONVERTER(ABI39_0_0RNSScreenStackAnimation, (@{
                                                  @"default": @(ABI39_0_0RNSScreenStackAnimationDefault),
                                                  @"none": @(ABI39_0_0RNSScreenStackAnimationNone),
                                                  @"fade": @(ABI39_0_0RNSScreenStackAnimationFade),
                                                  @"flip": @(ABI39_0_0RNSScreenStackAnimationFlip),
                                                  }), ABI39_0_0RNSScreenStackAnimationDefault, integerValue)

ABI39_0_0RCT_ENUM_CONVERTER(ABI39_0_0RNSScreenReplaceAnimation, (@{
                                                  @"push": @(ABI39_0_0RNSScreenReplaceAnimationPush),
                                                  @"pop": @(ABI39_0_0RNSScreenReplaceAnimationPop),
                                                  }), ABI39_0_0RNSScreenReplaceAnimationPop, integerValue)


@end

