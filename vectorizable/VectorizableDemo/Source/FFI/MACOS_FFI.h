//
//  MACOS_FFI.h
//  VectorizableDemo (macOS)
//
//  Created by Colbyn Wadman on 10/28/22.
//

#ifndef MACOS_FFI_h
#define MACOS_FFI_h
#import <AppKit/AppKit.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#include "vectorizable-demo.h"

RS_MetalBackendContextPtr vectorizableMetalBackendContextInit(id<MTLDevice> device, id<MTLCommandQueue> queue) {
    return vectorizable_metal_backend_context_init((__bridge void*)device, (__bridge void*)queue);
}

void vectorizableMetalBackendContextReloadViewSurface(RS_MetalBackendContextPtr metalBackendContextPtr, MTKView* view) {
    vectorizable_metal_backend_context_reload_view_surface(metalBackendContextPtr, (__bridge const void*)view);
}

void vectorizableDrawFlushAndSubmitBackground(RS_MetalBackendContextPtr metalBackendContextPtr, RS_AppModelPtr appModelPtr, MTKView* view) {
    vectorizable_draw_flush_and_submit_background(metalBackendContextPtr, appModelPtr, (__bridge const void*)view);
}
void vectorizableDrawFlushAndSubmitBackgroundActive(RS_MetalBackendContextPtr metalBackendContextPtr, RS_AppModelPtr appModelPtr, MTKView* view) {
    vectorizable_draw_flush_and_submit_background_active(metalBackendContextPtr, appModelPtr, (__bridge const void*)view);
}

void vectorizableDrawFlushAndSubmitForeground(RS_MetalBackendContextPtr metalBackendContextPtr, RS_AppModelPtr appModelPtr, MTKView* view) {
    vectorizable_draw_flush_and_submit_foreground(metalBackendContextPtr, appModelPtr, (__bridge const void*)view);
}
void vectorizableDrawFlushAndSubmitForegroundActive(RS_MetalBackendContextPtr metalBackendContextPtr, RS_AppModelPtr appModelPtr, MTKView* view) {
    vectorizable_draw_flush_and_submit_foreground_active(metalBackendContextPtr, appModelPtr, (__bridge const void*)view);
}

#endif /* MACOS_FFI_h */
