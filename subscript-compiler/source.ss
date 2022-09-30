\h1{Hello world}
\include[path="test/hello.ss", baseline="h2"]
\table{
    \row{1}{2}{3}{4}
}

\math{
    \frac{m}{s^2}
}

\note{
    \h2{Hello world}
    \p{\test}
}\!where{
    {\test} => {1}
}


// Drawings are supported!!!!!!!!!
\layout[2col]{
    \include[src="test/Untitled.ssd1"]\!where{
        {\drawing} => {
            \note{
                \h1{Hello Drawing}
                \hr
                \drawing
            }
        }
    }
}





