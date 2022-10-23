//
//  IOSFFI.h
//  SubScript (iOS)
//
//  Created by Colbyn Wadman on 10/23/22.
//

#ifndef IOSFFI_h
#define IOSFFI_h

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#include "ss-notebook-format.h"

static SS1_CAPI_CanvasContext* metalDeviceToRustContext(MTKView* mtkView, id<MTLDevice> device, id<MTLCommandQueue> queue) {
    return metal_device_to_rust_context((__bridge const void*)mtkView, (__bridge void*)device, (__bridge void*)queue);
}

static SS1_CAPI_CanvasSurface* mtkViewToCanvasSurface(MTKView* mtkView, SS1_CAPI_CanvasContext* context)
{
    return app_logic_init_canvas_surface((__bridge const void*)mtkView, context);
}


#endif /* IOSFFI_h */
