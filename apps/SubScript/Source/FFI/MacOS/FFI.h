//
//  MacOSFFI.h
//  SubScript (macOS)
//
//  Created by Colbyn Wadman on 10/23/22.
//

#ifndef MacOSFFI_h
#define MacOSFFI_h

#import <AppKit/AppKit.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#include "ss-notebook-format.h"

SS1_CAPI_MetalViewContextPtr metalDeviceToRustContext(MTKView* mtkView, id<MTLDevice> device, id<MTLCommandQueue> queue) {
    return init_metal_view_context((__bridge const void*)mtkView, (__bridge void*)device, (__bridge void*)queue);
}

void mtkViewToCanvasSurface(MTKView* mtkView, SS1_CAPI_MetalViewContextPtr context) {
    init_metal_view_surface((__bridge const void*)mtkView, context);
}

#endif /* MacOSFFI_h */
