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

SS1_CAPI_MetalBackendContextPtr metalDeviceToRustContext(id<MTLDevice> device, id<MTLCommandQueue> queue) {
    return ss1_metal_backend_context_init((__bridge void*)device, (__bridge void*)queue);
}

void mtkMetalViewLayerToCanvasSurfaceX(SS1_CAPI_MetalBackendContextPtr metal_backend_context_ptr,
                                 SS1_CAPI_MetalViewLayersPtr metal_view_layers_ptr,
                                 MTKView* layer_view,
                                 SS1_CAPI_MetalViewLayerType layer_type) {
    return ss1_metal_view_layers_provision_for_layer(metal_backend_context_ptr,
                                           metal_view_layers_ptr,
                                           (__bridge const void*)layer_view,
                                           layer_type);
}



void mtkViewsToCanvasSurfaces(SS1_CAPI_MetalBackendContextPtr metal_backend_context_ptr,
                              SS1_CAPI_MetalViewLayersPtr metal_view_layers_ptr,
                                                       MTKView* background_view,
                                                       MTKView* background_active_view,
                                                       MTKView* foreground_view,
                                                       MTKView* foreground_active_view) {
    return ss1_metal_view_layers_provision(metal_backend_context_ptr,
                                           metal_view_layers_ptr,
                                           (__bridge const void*)background_view,
                                           (__bridge const void*)background_active_view,
                                           (__bridge const void*)foreground_view,
                                           (__bridge const void*)foreground_active_view);
}


#endif /* MacOSFFI_h */
