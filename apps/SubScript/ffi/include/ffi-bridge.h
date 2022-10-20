#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef enum SSColorScheme {
  SSColorSchemeLight,
  SSColorSchemeDark,
} SSColorScheme;

typedef struct SSV1CanvasRuntime SSV1CanvasRuntime;

typedef struct SSV1RGBAColor {
  double red;
  double green;
  double blue;
  double alpha;
} SSV1RGBAColor;

typedef struct SSV1ColorModes {
  struct SSV1RGBAColor light;
  struct SSV1RGBAColor dark;
} SSV1ColorModes;

typedef struct SSV1Pen {
  struct SSV1ColorModes color;
} SSV1Pen;

typedef struct SSPointer_SSV1CanvasRuntime {
  struct SSV1CanvasRuntime *ptr;
} SSPointer_SSV1CanvasRuntime;

typedef struct SSPointer_SSV1CanvasRuntime SSV1CanvasRuntimePtr;

void ssv1_global_runtime_set_active_pen(struct SSV1Pen new_pen);

SSV1CanvasRuntimePtr ssv1_init_canvas_runtime(void);

void ssv1_free_canvas_runtime(SSV1CanvasRuntimePtr ptr);

void ssv1_canvas_runtime_begin_stroke(SSV1CanvasRuntimePtr ptr);

void ssv1_canvas_runtime_end_stroke(SSV1CanvasRuntimePtr ptr);

void ssv1_canvas_runtime_record_stroke_point(SSV1CanvasRuntimePtr ptr,
                                             double width,
                                             double height,
                                             double x,
                                             double y);

void ssv1_canvas_runtime_set_color_scheme(SSV1CanvasRuntimePtr ptr,
                                          enum SSColorScheme ss_color_scheme);

void ssv1_canvas_runtime_draw(SSV1CanvasRuntimePtr ptr,
                              double width,
                              double height,
                              CGContextRef context);
