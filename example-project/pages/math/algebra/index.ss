/// This file was auto-translated from the original HTML source, it is pretty messy. 
\h1{Miscellaneous}

\h2{Functional Utilities & Notation Conveniences}

\grid[col="2"]{
   \note[boxed]{
      \h3{Right to Left Evaluation}
      \equation{
         f \triangleleft x &= f(x)
      }
      \equation{
         f \circ g \triangleleft x
                             &= f(g(x)) \\
                             &= f \triangleleft g \triangleleft x
      }
   }
   \note[boxed]{
      \h3{Left to Right Evaluation}
      \equation{
         x \triangleright f &= f(x)
      }
   }
   \note[boxed]{
      \h3{Derivative Shorthand}
      \equation{
         \delta f(x) &= \frac{\mathrm{d}}{\mathrm{d}x} f(x) = f^\prime(x)
      }
      \p{For this notation, the derivative with respect to a given variable, is implicit.}
   }
}
\h2{Radians & Radian Conversion}

\grid[col="2"]{
   \note[boxed]{
      \h3{Constants}
      \equation{
         \tau &= 2\pi = 360^{\circ} \\
                     \pi &= \frac{1}{2}\tau = 180^{\circ}
      }
   }
   \note[boxed]{
      \h3{Conversion}
      \equation{
         \text{Given}\\
                     \textcolor{blue}{1}^{\circ} &= \frac{\textcolor{blue}{1}}{360} \tau \; {\displaystyle {\mathrm{rad}}} \\
                     \textcolor{blue}{1} \; \mathrm{rad} &= \frac{\textcolor{blue}{1}}{\tau} \cdot 360^{\circ} = \textcolor{blue}{1} \cdot \frac{360^{\circ}}{\tau} \\
                     \\\text{Degrees to Radians}\\
                     \textcolor{blue}{x^{\circ}} &= \frac{\textcolor{blue}{x}}{360} \tau \; {\displaystyle {\mathrm{rad}}} \\
                     \\\text{Radians to Degrees}\\
                     \textcolor{blue}{x} \; \mathrm{rad}
                         &= \frac{\textcolor{blue}{x}}{\tau} \cdot 360^{\circ} \\
                         &= \textcolor{blue}{x} \cdot \frac{360^{\circ}}{\tau} \\
                         &= \textcolor{blue}{x} \cdot \frac{180^{\circ}}{\pi} \\
      }
   }
}
\h1{Constants}

\grid[col="2"]{
   \note[boxed]{
      \h2{ℯ (Euler's number)}
      \equation{
         \mathrm{e}
                         &= \sum_{n = 0}^\infty \frac{1}{n!} \\
                         &= \lim_{n\to\infty} \left(1 + \frac{1}{n}\right)^n \\
                         &= \lim_{t \to 0} \left(1 + t\right)^{\frac{1}{t}}
      }
      \hr\equation{
         \mathrm{e}^x
                         &= 1 + \frac{x}{1!} + \frac{x^2}{2!} + \frac{x^3}{3!} + \cdots \\
                         &= \sum_{n = 0}^\infty \frac{x^n}{n!} \\
                         &= \lim_{n\to\infty} \left(1 + \frac{x}{n}\right)^n
      }
   }
}

\h1{Algebra}

\h2{Properties}

\grid[col="3"]{
   \equation{
      a^m \cdot b^n &= a^{m+n}\\
              \left(a^m\right)^n &= a^{m\cdot\,n} = \left(a^n\right)^m\\
              \left(a\cdot\,b\right)^n &= a^n \cdot b^n\\
              \left(\frac{a}{b}\right)^{-n} &= \left(\frac{b}{a}\right)^n\\
              \frac{x^n}{y^n} &= \left(\frac{x}{y}\right)^n\\
              x^{y^z} &= x^{\left(y ^ z\right)} \neq \left(x^y\right)^z
   }
   \equation{
      |x| &= \sqrt{x^2} \neq x
   }
   \equation{
      \log_{\beta}(\alpha) &= \gamma\\
              \beta^{\gamma} &= \alpha\\
              \beta^{\log_{\beta}(N)} &= N\;\text{for all $N > 0$}\\
              \log_{\beta}(\beta^x) &= x
   }
}