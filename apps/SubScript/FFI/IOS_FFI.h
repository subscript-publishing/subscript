//
//  IOS_FFI.h
//  SubScript (iOS)
//
//  Created by Colbyn Wadman on 10/29/22.
//

#ifndef IOS_FFI_h
#define IOS_FFI_h

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import "ss-app-engine.h"

SSMetalBackendContextPointer metalBackendContextInit(id<MTLDevice> device, id<MTLCommandQueue> queue) {
    return metal_backend_context_init((__bridge void*)device, (__bridge void*)queue);
}

void metalBackendContextReloadViewSurface(SSMetalBackendContextPointer metalBackendContextPtr, MTKView* view) {
    metal_backend_context_reload_view_surface(metalBackendContextPtr, (__bridge const void*)view);
}


void ss1MetalViewDrawFlushAndSubmit(SSMetalBackendContextPointer metalBackendContextPtr, SSRootScenePointer rootScenePointer, MTKView* view, SSViewInfo viewInfo) {
    draw_flush_and_submit_view(metalBackendContextPtr, rootScenePointer, (__bridge const void*)view, viewInfo);
}


#endif /* IOS_FFI_h */
