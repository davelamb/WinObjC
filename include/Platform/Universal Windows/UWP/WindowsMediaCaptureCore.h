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

// WindowsMediaCaptureCore.h
// Generated from winmd2objc

#pragma once

#ifndef OBJCUWP_WINDOWS_MEDIA_CORE_CAPTURE_DEVICES_PROTECTION_PLAYBACK_EXPORT
#define OBJCUWP_WINDOWS_MEDIA_CORE_CAPTURE_DEVICES_PROTECTION_PLAYBACK_EXPORT __declspec(dllimport)
#ifndef IN_OBJCUWP_BUILD
#pragma comment(lib, "ObjCUWP_Windows_Media_Core_Capture_Devices_Protection_Playback.lib")
#endif
#endif
#include <UWP/interopBase.h>

@class WMCCVariablePhotoSequenceCapture, WMCCVariablePhotoCapturedEventArgs;
@protocol WMCCIVariablePhotoCapturedEventArgs
, WMCCIVariablePhotoSequenceCapture, WMCCIVariablePhotoSequenceCapture2;

#include "WindowsFoundation.h"
#include "WindowsMediaCapture.h"

#import <Foundation/Foundation.h>

// Windows.Media.Capture.Core.VariablePhotoSequenceCapture
#ifndef __WMCCVariablePhotoSequenceCapture_DEFINED__
#define __WMCCVariablePhotoSequenceCapture_DEFINED__

OBJCUWP_WINDOWS_MEDIA_CORE_CAPTURE_DEVICES_PROTECTION_PLAYBACK_EXPORT
@interface WMCCVariablePhotoSequenceCapture : RTObject
#if defined(__cplusplus)
+ (instancetype)createWith:(IInspectable*)obj;
#endif
- (EventRegistrationToken)addPhotoCapturedEvent:(void (^)(WMCCVariablePhotoSequenceCapture*, WMCCVariablePhotoCapturedEventArgs*))del;
- (void)removePhotoCapturedEvent:(EventRegistrationToken)tok;
- (EventRegistrationToken)addStoppedEvent:(void (^)(WMCCVariablePhotoSequenceCapture*, RTObject*))del;
- (void)removeStoppedEvent:(EventRegistrationToken)tok;
- (RTObject<WFIAsyncAction>*)startAsync;
- (RTObject<WFIAsyncAction>*)stopAsync;
- (RTObject<WFIAsyncAction>*)finishAsync;
- (RTObject<WFIAsyncAction>*)updateSettingsAsync;
@end

#endif // __WMCCVariablePhotoSequenceCapture_DEFINED__

// Windows.Media.Capture.Core.VariablePhotoCapturedEventArgs
#ifndef __WMCCVariablePhotoCapturedEventArgs_DEFINED__
#define __WMCCVariablePhotoCapturedEventArgs_DEFINED__

OBJCUWP_WINDOWS_MEDIA_CORE_CAPTURE_DEVICES_PROTECTION_PLAYBACK_EXPORT
@interface WMCCVariablePhotoCapturedEventArgs : RTObject
#if defined(__cplusplus)
+ (instancetype)createWith:(IInspectable*)obj;
#endif
@property (readonly) WFTimeSpan* captureTimeOffset;
@property (readonly) WMCCapturedFrameControlValues* capturedFrameControlValues;
@property (readonly) WMCCapturedFrame* frame;
@property (readonly) id /* unsigned int */ usedFrameControllerIndex;
@end

#endif // __WMCCVariablePhotoCapturedEventArgs_DEFINED__
