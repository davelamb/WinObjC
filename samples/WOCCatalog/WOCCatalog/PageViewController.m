//******************************************************************************
//
// Copyright (c) 2015 Microsoft Corporation. All rights reserved.
//
// This code is licensed under the MIT License (MIT).
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//******************************************************************************

#import <Foundation/Foundation.h>
#import "PageViewController.h"

#import <UWP/WindowsUICore.h>
#import <UWP/WindowsUITextCore.h>
#import <UWP/WindowsUIViewManagement.h>

static const int c_numControllers = 3;

@interface PageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
- (void)_forward;
- (void)_reverse;
@end

@interface PageViewPage : UIViewController

- (instancetype)initwithIndex:(NSUInteger)idx controller:(UIPageViewController*)controller;

- (NSUInteger)index;

@end

@implementation PageViewPage {
    NSUInteger _index;
    UIPageViewController* _controller;
}

- (instancetype)initwithIndex:(NSUInteger)idx controller:(UIPageViewController*)controller {
    _index = idx;
    _controller = controller;
    return [self init];
}

- (void)viewDidLoad {
    UILabel* label = [UILabel new];

    self.view = [UIView new];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.autoresizesSubviews = YES;

    [label setText:[NSString stringWithFormat:@"Page %lu", (unsigned long)[self index]]];
    label.frame = CGRectMake(0, 200, self.view.frame.size.width, 25);
    label.textAlignment = NSTextAlignmentCenter;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;

// TODO: Bar button items.
#ifdef WINOBJC
    UIButton* forwardButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIButton* reverseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];

    forwardButton.frame = CGRectMake(self.view.frame.size.width - 100, 100, 50, 50);
    reverseButton.frame = CGRectMake(50, 100, 50, 50);
    forwardButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

    [forwardButton setTitle:@">>" forState:UIControlStateNormal];
    [reverseButton setTitle:@"<<" forState:UIControlStateNormal];

    [forwardButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [reverseButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    [forwardButton addTarget:_controller action:@selector(_forward) forControlEvents:UIControlEventTouchUpInside];
    [reverseButton addTarget:_controller action:@selector(_reverse) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:forwardButton];
    [self.view addSubview:reverseButton];
#endif

    // Create a label to naively show some text.
    UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 200, 30)];
    textLabel.backgroundColor = [UIColor lightGrayColor];
    textLabel.text = @"";

    [self.view addSubview:textLabel];

    // The CoreTextEditContext processes text input, but other keys are
    // the apps's responsibility.
    //_coreWindow = CoreWindow.GetForCurrentThread();
    WUCCoreWindow* coreWindow = coreWindow = [WUCCoreWindow getForCurrentThread];
    
    //_coreWindow.KeyDown += CoreWindow_KeyDown;
    EventRegistrationToken keyDownToken = [coreWindow addKeyDownEvent:^(WUCCoreWindow *window, WUCKeyEventArgs *args) {
        switch (args.virtualKey) {
            // Backspace
            case WSVirtualKeyBack:
                textLabel.text = [textLabel.text substringToIndex:textLabel.text.length-1];
                break;
            default:
                // Do nothing?
                break;
        }
    }];
    
    // Create a CoreTextEditContext for our custom edit control.
    //CoreTextServicesManager manager = CoreTextServicesManager.GetForCurrentView();
    WUTCCoreTextServicesManager* manager = [WUTCCoreTextServicesManager getForCurrentView];
    //_editContext = manager.CreateEditContext();
    WUTCCoreTextEditContext* editContext = [manager createEditContext];

    //_coreWindow.PointerPressed += CoreWindow_PointerPressed;
    EventRegistrationToken pointerPressedToken = [coreWindow addPointerPressedEvent:^(WUCCoreWindow* window, WUCPointerEventArgs* args) {
        // Set focus on the input context
        [editContext notifyFocusEnter];
    }];

    // Get the Input Pane so we can programmatically hide and show it.
    //_inputPane = InputPane.GetForCurrentView();
    WUVInputPane* inputPane = [WUVInputPane getForCurrentView];

    // For demonstration purposes, this sample sets the Input Pane display policy to Manual
    // so that it can manually show the software keyboard when the control gains focus and
    // dismiss it when the control loses focus. If you leave the policy as Automatic, then
    // the system will hide and show the Input Pane for you. Note that on Desktop, you will
    // need to implement the UIA text pattern to get expected automatic behavior.
    //_editContext.InputPaneDisplayPolicy = CoreTextInputPaneDisplayPolicy.Manual;
    editContext.inputPaneDisplayPolicy = WUTCCoreTextInputPaneDisplayPolicyManual;

    // Set the input scope to Text because this text box is for any text.
    // This also informs software keyboards to show their regular
    // text entry layout.  There are many other input scopes and each will
    // inform a keyboard layout and text behavior.
    //_editContext.InputScope = CoreTextInputScope.Text;
    editContext.inputScope = WUTCCoreTextInputScopeText;

    // The system raises this event to request a specific range of text.
    //_editContext.TextRequested += EditContext_TextRequested;
    EventRegistrationToken textRequestedToken = [editContext addTextRequestedEvent:^(WUTCCoreTextEditContext* context, WUTCCoreTextTextRequestedEventArgs* args) {
        // Return the text
        WUTCCoreTextTextRequest* request = args.request;
        NSUInteger startRange = MIN(request.range.startCaretPosition, textLabel.text.length);
        NSUInteger endRange = MIN(request.range.endCaretPosition, textLabel.text.length);
        request.text = [textLabel.text substringWithRange:NSMakeRange(startRange, endRange - startRange)];
    }];

    // The system raises this event to request the current selection.
    //_editContext.SelectionRequested += EditContext_SelectionRequested;
    EventRegistrationToken selectionRequestedToken = [editContext addSelectionRequestedEvent:^(WUTCCoreTextEditContext* context, WUTCCoreTextSelectionRequestedEventArgs* args) {
        // Return the selection
    }];

    // The system raises this event when it wants the edit control to remove focus.
    //_editContext.FocusRemoved += EditContext_FocusRemoved;
    EventRegistrationToken focusRemovedToken = [editContext addSelectionRequestedEvent:^(WUTCCoreTextEditContext* context, WUTCCoreTextSelectionRequestedEventArgs* args) {
        // Return the selection
    }];

    // The system raises this event to update text in the edit control.
    //_editContext.TextUpdating += EditContext_TextUpdating;
    EventRegistrationToken textUpdatingToken = [editContext addTextUpdatingEvent:^(WUTCCoreTextEditContext* context, WUTCCoreTextTextUpdatingEventArgs* args) {
        // Update label text
        textLabel.text = [textLabel.text stringByAppendingString:args.text];
    }];

    // The system raises this event to change the selection in the edit control.
    //_editContext.SelectionUpdating += EditContext_SelectionUpdating;
    EventRegistrationToken selectionUpdatingToken = [editContext addSelectionUpdatingEvent:^(WUTCCoreTextEditContext* context, WUTCCoreTextSelectionUpdatingEventArgs* args) {
        // Highlight text
    }];

    // The system raises this event when it wants the edit control
    // to apply formatting on a range of text.
    //_editContext.FormatUpdating += EditContext_FormatUpdating;
    EventRegistrationToken formatUpdatingToken = [editContext addFormatUpdatingEvent:^(WUTCCoreTextEditContext* context, WUTCCoreTextFormatUpdatingEventArgs* args) {
        // Update formatting
    }];

    // The system raises this event to request layout information.
    // This is used to help choose a position for the IME candidate window.
    //_editContext.LayoutRequested += EditContext_LayoutRequested;
    EventRegistrationToken layoutRequestedToken = [editContext addLayoutRequestedEvent:^(WUTCCoreTextEditContext* context, WUTCCoreTextLayoutRequestedEventArgs* args) {
        // Return the frame?
    }];

    // The system raises this event to notify the edit control
    // that the string composition has started.
    //_editContext.CompositionStarted += EditContext_CompositionStarted;
    EventRegistrationToken compositionStartedToken = [editContext addCompositionStartedEvent:^(WUTCCoreTextEditContext* context, WUTCCoreTextCompositionStartedEventArgs* args) {
        // Not sure.
    }];

    // The system raises this event to notify the edit control
    // that the string composition is finished.
    //_editContext.CompositionCompleted += EditContext_CompositionCompleted;
    EventRegistrationToken compositionCompletedToken = [editContext addCompositionCompletedEvent:^(WUTCCoreTextEditContext* context, WUTCCoreTextCompositionCompletedEventArgs* args) {
        // Not sure.
    }];

    // The system raises this event when the NotifyFocusLeave operation has
    // completed. Our sample does not use this event.
    // _editContext.NotifyFocusLeaveCompleted += EditContext_NotifyFocusLeaveCompleted;
    
    [self.view addSubview:label];
}

- (NSUInteger)index {
    return _index;
}

@end

@implementation PageViewController {
    NSMutableArray* _controllers;
}

- (instancetype)init {
    return [self initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                   navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                 options:nil];
}

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
     viewControllerBeforeViewController:(UIViewController*)viewController {
    NSUInteger idx = [(PageViewPage*)viewController index];

    idx = ((idx + c_numControllers - 1) % c_numControllers);

    return [_controllers objectAtIndex:idx];
}

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
      viewControllerAfterViewController:(UIViewController*)viewController {
    NSUInteger idx = [(PageViewPage*)viewController index];

    idx = ((idx + 1) % c_numControllers);

    return [_controllers objectAtIndex:idx];
}

- (void)viewDidLoad {
    _controllers = [NSMutableArray new];

    for (int i = 0; i < c_numControllers; i++) {
        UIViewController* pageController = [[PageViewPage alloc] initwithIndex:i controller:self];
        [_controllers addObject:pageController];
    }

    [self setViewControllers:[NSArray arrayWithObjects:[_controllers objectAtIndex:0], nil]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];

    [self setDelegate:self];
    [self setDataSource:self];

// TODO: Bar button items.
#ifndef WINOBJC
    UIBarButtonItem* forward =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(_forward)];
    UIBarButtonItem* reverse =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(_reverse)];

    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:forward, reverse, nil];
#endif

    self.view.backgroundColor = [UIColor grayColor];
}

- (void)_forward {
    NSUInteger idx = [(PageViewPage*)[self.viewControllers objectAtIndex:0] index];

    idx = ((idx + 1) % c_numControllers);

    [self setViewControllers:[NSArray arrayWithObjects:[_controllers objectAtIndex:idx], nil]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES
                  completion:nil];
}

- (void)_reverse {
    NSUInteger idx = [(PageViewPage*)[self.viewControllers objectAtIndex:0] index];

    idx = ((idx + c_numControllers - 1) % c_numControllers);

    [self setViewControllers:[NSArray arrayWithObjects:[_controllers objectAtIndex:idx], nil]
                   direction:UIPageViewControllerNavigationDirectionReverse
                    animated:YES
                  completion:nil];
}

- (void)pageViewController:(UIPageViewController*)pageViewController willTransitionToViewControllers:(NSArray*)pendingViewControllers {
    PageViewPage* pageFrom = (PageViewPage*)[pageViewController.viewControllers objectAtIndex:0];
    PageViewPage* pageTo = (PageViewPage*)[pendingViewControllers objectAtIndex:0];
    NSLog(@"Will transition from page %lu to page %lu.", (unsigned long)pageFrom.index, (unsigned long)pageTo.index);
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController*)pageViewController {
    return _controllers.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController*)pageViewController {
    return [(PageViewPage*)[self.viewControllers objectAtIndex:0] index];
}

- (void)pageViewController:(UIPageViewController*)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray*)previousViewControllers
       transitionCompleted:(BOOL)completed {
    PageViewPage* pageFrom = (PageViewPage*)[previousViewControllers objectAtIndex:0];
    PageViewPage* pageTo = (PageViewPage*)[pageViewController.viewControllers objectAtIndex:0];
    NSString* finishedString;
    NSString* completedString;

    if (finished) {
        finishedString = @"finished";
    } else {
        finishedString = @"didn't finish";
    }

    if (completed) {
        completedString = @"completed";
    } else {
        completedString = @"didn't complete";
    }

    NSLog(@"Transition from page %lu to page %lu %@, and the animation %@.",
          (unsigned long)pageFrom.index,
          (unsigned long)pageTo.index,
          completedString,
          finishedString);
}

@end