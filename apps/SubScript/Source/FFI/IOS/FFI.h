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

SS1_CAPI_MetalBackendContextPtr metalDeviceToRustContext(id<MTLDevice> device, id<MTLCommandQueue> queue) {
    return ss1_metal_backend_context_init((__bridge void*)device, (__bridge void*)queue);
}

SS1_CAPI_DrawResult ss1MetalViewDrawFlushAndSubmit(SS1_CAPI_MetalBackendContextPtr metalBackendContextPtr,
                                                   SS1_CAPI_CanvasRuntimeContextPtr canvasRuntimeContextPtr,
                                                   MTKView* view,
                                                   SS1_CAPI_ViewInfo viewInfo) {
    
    return ss1_metal_view_draw_flush_and_submit(metalBackendContextPtr,
                                                canvasRuntimeContextPtr,
                                                (__bridge const void*)view,
                                                viewInfo);
}


void ss1MetalBackendContextProvisionView(SS1_CAPI_MetalBackendContextPtr metalBackendContextPtr, MTKView* view) {
    
    ss1_metal_backend_context_provision_view(metalBackendContextPtr, (__bridge const void*)view);
}

#endif /* IOSFFI_h */
