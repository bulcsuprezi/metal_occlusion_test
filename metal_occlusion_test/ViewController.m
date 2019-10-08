//
//  ViewController.m
//  metal_occlusion_test
//
//  Created by Bulcsu Andrasi on 2019. 10. 07..
//  Copyright © 2019. Bulcsu Andrasi. All rights reserved.
//

#import "ViewController.h"

#include <stdio.h>
#include <mach/mach_time.h>

@implementation ViewController {
	id<MTLDevice> _device;
	id<MTLCommandQueue> _commandQueue;
	MTKView *_mtkView;
	mach_timebase_info_data_t _timeBaseInfo;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	_device = MTLCreateSystemDefaultDevice();
	_commandQueue = [_device newCommandQueue];
	_mtkView = (MTKView *)self.view;
	_mtkView.device = _device;
	_mtkView.delegate = self;
	_mtkView.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
	
	mach_timebase_info(&_timeBaseInfo);
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {

}


- (void)drawInMTKView:(nonnull MTKView *)view {
	@autoreleasepool {
		id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
		
		uint64_t passDescStart = mach_absolute_time();
		MTLRenderPassDescriptor *passDesc = _mtkView.currentRenderPassDescriptor;
		uint64_t passDescEnd = mach_absolute_time();
		
		passDesc.colorAttachments[0].loadAction = MTLLoadActionClear;
		static float clearColor;
		passDesc.colorAttachments[0].clearColor = MTLClearColorMake(clearColor, clearColor, clearColor, clearColor);
		id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:passDesc];
		[encoder endEncoding];
		
#if 01
		[commandBuffer presentDrawable:_mtkView.currentDrawable];
#else
		__block id<CAMetalDrawable> drawable = _mtkView.currentDrawable;
		[commandBuffer addScheduledHandler:^(id<MTLCommandBuffer> commandBuffer) {
			[drawable present];
		}];
#endif
		
		[commandBuffer commit];
		
		clearColor += 1.0/60.0;
		if(clearColor > 1){
			clearColor -= 1;
		}

		uint64_t completedStart = mach_absolute_time();
		[commandBuffer waitUntilCompleted];
		uint64_t completedEnd = mach_absolute_time();
		
		uint64_t passDescElapsed = passDescEnd - passDescStart;
		printf("passDesc : %llu\n", passDescElapsed * _timeBaseInfo.numer / _timeBaseInfo.denom);
		uint64_t completedElapsed = completedEnd - completedStart;
		printf("completed : %llu\n", completedElapsed * _timeBaseInfo.numer / _timeBaseInfo.denom);
	}
}


@end
