# Performance

This is just measuring some quick and dirty hacks. 

|No Parallelization|include caching|`l.cmp(&r).reverse()`|Average Elapsed Time `13.45s`|
|No Parallelization|include caching|`l.cmp(&r)`|Average Elapsed Time `13.83s`|
|No Parallelization|no caching|N/A|Average Elapsed Time `21.87s`|
|Partial Parallelization<sup>†</sup>|no caching|N/A|Average Elapsed Time `5.70s`|
|AST + Page Parallelization|no caching|N/A|Average Elapsed Time `4.98s`|

- <sup>†</sup>
    + Only parallelized compilation of each page
