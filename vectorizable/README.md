# A WIP Embeddable, Immutable<sup>†</sup>, Low-Latency<sup>‡</sup>, Vector Graphics Rendering Engine On CPUs/GPUs

- Currently only IOS & MacOS is supported where the backend is Metal (GPU API).
- Also currently the internal backend is Google's Skia C++ Library (so make sure that the c++ 17 std lib is liked in).

<sup>†</sup> Immutable (i.e. append only with transformations and undo history WIP).

<sup>‡</sup> The API is very ad-hoc as opposed to giving the user a very general drawing API. 

