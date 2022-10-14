\h1[page-title]{Mathematics}

/// /// \include[path="algebra/index.ss", baseline="h2"]
/// /// \include[path="trig/index.ss", baseline="h2"]

\h1{Algebra}

\h2{Function Composition And Notation Conveniences}
\layout[col=2] {
    \note{
        \h3{Right to Left Evaluation}
        \equation{
            f \triangleleft x &= f(x)\\
            f \triangleleft g \triangleleft x &= f(g(x))\\
            f \circ g \triangleleft x &= f(g(x))
        }
        \p{(Reading and evaluating expressions from right to left should be the standard in mathematics, as it is in Haskell.)}
    }
    \note{
        \h3{Left to Right Evaluation}
        \equation{
            x \triangleright f &= f(x)\\
            x \triangleright f \triangleright g &= g(f(x))
        }
        \p{(Somewhat confusing since it's not right to left, but can be convenient and look nice...)}
    }
}
\p{Parentheses are evil, inelegant, and requires more work to write/type and read.
The fewer parentheses the better. When things get complicated, smart use of function composition
on the other hand looks beautiful when used well.}


\h2{Algebra Basics}

\layout[col="3"]{
    \equation{
        a^{-x} &= \frac{1}{a^x}
    }
    \equation{
        a^x a^y &= a^{\left(x + y\right)}
    }
    \equation{
        \frac{a^x}{a^y} &= a^{\left(x - y\right)}
    }
    \equation{
        \left(a^x\right)^y &= a^{\left(x y\right)}
    }
    \equation{
        a^0 &= 1 \\
        a^1 &= a \\
        a^{\frac{1}{n}} &= \sqrt[n]{a}
    }
    \equation{
        \frac{1}{\frac{a}{b}} &= \left(\frac{a}{b}\right)^{-1} &= \frac{b}{a}
    }
}
\layout[col="2"]{
    \equation{
        a &= e^x \\
        \ln a &= x
    }
    \equation{
        \ln \triangleleft\; e^x &= x \\
        e^{\ln{\left(x\right)}} &= x 
    }
}
\layout[col="3"]{
    \equation{
        \ln \triangleleft\; a \cdot b &= \ln{a} + \ln{b}
    }
    \equation{
        \ln \triangleleft\; \frac{a}{b} &= \ln{a} - \ln{b}
    }
    \equation{
        \ln \triangleleft\; a^n &= n \cdot \ln{a}
    }
}
\h1{Trigonometry}
\layout[col=1]{
    \note{
        \h2{The Unit Circle & Special Angles In Trig}
        \img[min-width="500px", max-width="1000px", src="../images/math/7.svg"]
        \p{To easily memorize the special angles in trig, notice the repeating patterns on the above angles.}
        \ul{
            \li{For values on the x-axis, anything over \{\frac{1}{4}\tau} and under \{\frac{3}{4}\tau} will be negative}
            \li{For values on the y-axis, anything over \{\frac{1}{2}\tau} will be negative}
            \li{Diagonals will be \{\pm \frac{\sqrt{2}}{2}}}
            \li{
                For ratios of \{\frac{1}{12}\tau} on the sides, i.e.
                \{\frac{1}{12}\tau},
                \{\frac{2}{12}\tau},
                \{\frac{4}{12}\tau},
                \{\frac{5}{12}\tau},
                \{\frac{7}{12}\tau},
                \{\frac{8}{12}\tau},
                \{\frac{10}{12}\tau}, and
                \{\frac{11}{12}\tau}.
                Draw a circle and dot the point where it occurs
                (which is pretty easy since the above are simple ratios of a circle
                when expressed in terms of \{\tau}).
                Then with regards to the \{x} and \{y} axis values
                \ul{
                    \li{The longer size will be \{\pm \frac{\sqrt{3}}{2}}}
                    \li{The shorter side will be \{\pm \frac{1}{2}}}
                }
                See the above examples.
            }
        }
    }
}
/// <layout boxed col="1">
///     <note>
///         <h2>Conventions</h2>
///         <layout col="2">
///             <img max-width="300px" src="../images/math/6.svg">
///             <layout col="2">
///                 <equation>
///                     \sin\theta &= \frac{b}{c}\\
///                     \cos\theta &= \frac{a}{c}\\
///                     \tan\theta &= \frac{b}{a}
///                 </equation>
///                 <equation>
///                     \csc\theta &= \frac{1}{\sin\theta} = \frac{c}{b}\\
///                     \sec\theta &= \frac{1}{\cos\theta} = \frac{c}{b}\\
///                     \cot\theta &= \frac{1}{\tan\theta} = \frac{a}{b}
///                 </equation>
///             </layout>
///         </layout>
///     </note>
///     <note>
///         <h2>Radians & Radian Conversion</h2>
///         <layout col="2">
///             <note>
///                 <h3>Constants</h3>
///                 <equation>
///                     \tau &= 2\pi = 360^{\circ} \\
///                     \pi &= \frac{1}{2}\tau = 180^{\circ}
///                 </equation>
///             </note>
///             <note>
///                 <h3>Conversion</h3>
///                 <p>Given</p>
///                 <equation>
///                     {1}^{\circ}
///                         &= \frac{{1}}{360} \tau \; {\displaystyle {\mathrm{rad}}} \\
///                     {1} \; \mathrm{rad}
///                         &= \frac{{1}}{\tau} \cdot 360^{\circ}
///                         = {1} \cdot \frac{360^{\circ}}{\tau}
///                 </equation>
///                 <p>Degrees to Radians (in terms of <tex>\tau</tex>)</p>
///                 <equation>
///                     {x^{\circ}} &= \frac{{x}}{360} \tau \; {\displaystyle {\mathrm{rad}}}
///                 </equation>
///                 <p>Radians to (terrible and arbitrary) Degrees (the formula doesn't even look as nice)</p>
///                 <equation>
///                     {x} \; \mathrm{rad}
///                         &= \frac{{x}}{\tau} \cdot 360^{\circ} \\
///                         &= {x} \cdot \frac{360^{\circ}}{\tau} \\
///                         &= {x} \cdot \frac{180^{\circ}}{\pi}
///                 </equation>
///             </note>
///         </layout>
///     </note>
/// </layout>
/// <h1>Geometry</h1>
/// <layout col="3" boxed>
///     <note>
///         <h3>The Circle</h3>
///         <equation>
///             \small\text{Area}\;\normalsize &= \pi r^2\\
///             \small\text{Circumference}\;\normalsize &= 2 \pi r
///         </equation>
///     </note>
/// </layout>

/// <h1>Pre-Calculus</h1>
/// <h1>Calculus</h1>
/// <h2>Function Graphs</h2>
/// <layout col="2" boxed>
///     <note>
///         <h4>Example</h4>
///         <img max-width="600px" src="../images/math/9.svg">
///     </note>
///     <note>
///         <h4>Example</h4>
///         <img max-width="600px" src="../images/math/10.svg">
///     </note>
///     <note>
///         <h4>Example</h4>
///         <img max-width="600px" src="../images/math/11.svg">
///     </note>
/// </layout>
/// <h2>Derivative Formulas</h2>
/// <layout col="4">
///     <equation>
///         \frac{\mathrm{d}}{\mathrm{d}x} x^n &= n \cdot x^{n -1}
///     </equation>
/// </layout>
/// <h2>Integral Formulas</h2>
/// <layout col="3">
///     <equation>
///         \int 1 \;\mathrm{d}x &= x + \mathrm{c}
///     </equation>
///     <equation>
///         \int a \;\mathrm{d}x &= ax + \mathrm{c}
///     </equation>
///     <equation>
///         \int x^n \;\mathrm{d}x &= \frac{x^{x + 1}}{n + 1} + \mathrm{c}
///     </equation>
/// </layout>
