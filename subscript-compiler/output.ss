\h1{Miscellaneous}

\h2{Functional Utilities & Notation Conveniences}

\grid[col="2"]{
   \note[boxed]{
      \h3{Right to Left Evaluation}
      \equation{
         f \triangleleft x &= f \lparen[inline] x \rparen[inline]
      }
      \equation{
         f \circ g \triangleleft x
                             &= f \lparen[inline] g \lparen[inline] x \rparen[inline]  \rparen[inline]  \\
                             &= f \triangleleft g \triangleleft x
      }
   }
   \note[boxed]{
      \h3{Left to Right Evaluation}
      \equation{
         x \triangleright f &= f \lparen[inline] x \rparen[inline]
      }
   }
   \note[boxed]{
      \h3{Derivative Shorthand}
      \equation{
         \delta f \lparen[inline] x \rparen[inline]  &= \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] x \rbrace[inline]  f \lparen[inline] x \rparen[inline]  = f^\prime \lparen[inline] x \rparen[inline]
      }
      \p{For this notation, the derivative with respect to a given variable, is implicit.}
   }
}
\h2{Radians & Radian Conversion}

\grid[col="2"]{
   \note[boxed]{
      \h3{Constants}
      \equation{
         \tau &= 2\pi = 360^ \lbrace[inline] \circ \rbrace[inline]  \\
                     \pi &= \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline] \tau = 180^ \lbrace[inline] \circ \rbrace[inline]
      }
   }
   \note[boxed]{
      \h3{Conversion}
      \equation{
         \text \lbrace[inline] Given \rbrace[inline] \\
                     \textcolor \lbrace[inline] blue \rbrace[inline]  \lbrace[inline] 1 \rbrace[inline] ^ \lbrace[inline] \circ \rbrace[inline]  &= \frac \lbrace[inline] \textcolor \lbrace[inline] blue \rbrace[inline]  \lbrace[inline] 1 \rbrace[inline]  \rbrace[inline]  \lbrace[inline] 360 \rbrace[inline]  \tau \;  \lbrace[inline] \displaystyle  \lbrace[inline] \mathrm \lbrace[inline] rad \rbrace[inline]  \rbrace[inline]  \rbrace[inline]  \\
                     \textcolor \lbrace[inline] blue \rbrace[inline]  \lbrace[inline] 1 \rbrace[inline]  \; \mathrm \lbrace[inline] rad \rbrace[inline]  &= \frac \lbrace[inline] \textcolor \lbrace[inline] blue \rbrace[inline]  \lbrace[inline] 1 \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \tau \rbrace[inline]  \cdot 360^ \lbrace[inline] \circ \rbrace[inline]  = \textcolor \lbrace[inline] blue \rbrace[inline]  \lbrace[inline] 1 \rbrace[inline]  \cdot \frac \lbrace[inline] 360^ \lbrace[inline] \circ \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \tau \rbrace[inline]  \\
                     \\\text \lbrace[inline] Degrees to Radians \rbrace[inline] \\
                     \textcolor \lbrace[inline] blue \rbrace[inline]  \lbrace[inline] x^ \lbrace[inline] \circ \rbrace[inline]  \rbrace[inline]  &= \frac \lbrace[inline] \textcolor \lbrace[inline] blue \rbrace[inline]  \lbrace[inline] x \rbrace[inline]  \rbrace[inline]  \lbrace[inline] 360 \rbrace[inline]  \tau \;  \lbrace[inline] \displaystyle  \lbrace[inline] \mathrm \lbrace[inline] rad \rbrace[inline]  \rbrace[inline]  \rbrace[inline]  \\
                     \\\text \lbrace[inline] Radians to Degrees \rbrace[inline] \\
                     \textcolor \lbrace[inline] blue \rbrace[inline]  \lbrace[inline] x \rbrace[inline]  \; \mathrm \lbrace[inline] rad \rbrace[inline] 
                         &= \frac \lbrace[inline] \textcolor \lbrace[inline] blue \rbrace[inline]  \lbrace[inline] x \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \tau \rbrace[inline]  \cdot 360^ \lbrace[inline] \circ \rbrace[inline]  \\
                         &= \textcolor \lbrace[inline] blue \rbrace[inline]  \lbrace[inline] x \rbrace[inline]  \cdot \frac \lbrace[inline] 360^ \lbrace[inline] \circ \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \tau \rbrace[inline]  \\
                         &= \textcolor \lbrace[inline] blue \rbrace[inline]  \lbrace[inline] x \rbrace[inline]  \cdot \frac \lbrace[inline] 180^ \lbrace[inline] \circ \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \pi \rbrace[inline]  \\
      }
   }
}
\h1{Constants}

\grid[col="2"]{
   \note[boxed]{
      \h2{ℯ (Euler's number)}
      \equation{
         \mathrm \lbrace[inline] e \rbrace[inline] 
                         &= \sum_ \lbrace[inline] n = 0 \rbrace[inline] ^\infty \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] n! \rbrace[inline]  \\
                         &= \lim_ \lbrace[inline] n\to\infty \rbrace[inline]  \left \lparen[inline] 1 + \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] n \rbrace[inline] \right \rparen[inline] ^n \\
                         &= \lim_ \lbrace[inline] t \to 0 \rbrace[inline]  \left \lparen[inline] 1 + t\right \rparen[inline] ^ \lbrace[inline] \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] t \rbrace[inline]  \rbrace[inline]
      }
      \hr\equation{
         \mathrm \lbrace[inline] e \rbrace[inline] ^x
                         &= 1 + \frac \lbrace[inline] x \rbrace[inline]  \lbrace[inline] 1! \rbrace[inline]  + \frac \lbrace[inline] x^2 \rbrace[inline]  \lbrace[inline] 2! \rbrace[inline]  + \frac \lbrace[inline] x^3 \rbrace[inline]  \lbrace[inline] 3! \rbrace[inline]  + \cdots \\
                         &= \sum_ \lbrace[inline] n = 0 \rbrace[inline] ^\infty \frac \lbrace[inline] x^n \rbrace[inline]  \lbrace[inline] n! \rbrace[inline]  \\
                         &= \lim_ \lbrace[inline] n\to\infty \rbrace[inline]  \left \lparen[inline] 1 + \frac \lbrace[inline] x \rbrace[inline]  \lbrace[inline] n \rbrace[inline] \right \rparen[inline] ^n
      }
   }
}
\h1{Algebra}

\h2{Properties}

\grid[col="3"]{
   \equation{
      a^m \cdot b^n &= a^ \lbrace[inline] m+n \rbrace[inline] \\
              \left \lparen[inline] a^m\right \rparen[inline] ^n &= a^ \lbrace[inline] m\cdot\,n \rbrace[inline]  = \left \lparen[inline] a^n\right \rparen[inline] ^m\\
              \left \lparen[inline] a\cdot\,b\right \rparen[inline] ^n &= a^n \cdot b^n\\
              \left \lparen[inline] \frac \lbrace[inline] a \rbrace[inline]  \lbrace[inline] b \rbrace[inline] \right \rparen[inline] ^ \lbrace[inline] -n \rbrace[inline]  &= \left \lparen[inline] \frac \lbrace[inline] b \rbrace[inline]  \lbrace[inline] a \rbrace[inline] \right \rparen[inline] ^n\\
              \frac \lbrace[inline] x^n \rbrace[inline]  \lbrace[inline] y^n \rbrace[inline]  &= \left \lparen[inline] \frac \lbrace[inline] x \rbrace[inline]  \lbrace[inline] y \rbrace[inline] \right \rparen[inline] ^n\\
              x^ \lbrace[inline] y^z \rbrace[inline]  &= x^ \lbrace[inline] \left \lparen[inline] y ^ z\right \rparen[inline]  \rbrace[inline]  \neq \left \lparen[inline] x^y\right \rparen[inline] ^z
   }
   \equation{
      |x| &= \sqrt \lbrace[inline] x^2 \rbrace[inline]  \neq x
   }
   \equation{
      \log_ \lbrace[inline] \beta \rbrace[inline]  \lparen[inline] \alpha \rparen[inline]  &= \gamma\\
              \beta^ \lbrace[inline] \gamma \rbrace[inline]  &= \alpha\\
              \beta^ \lbrace[inline] \log_ \lbrace[inline] \beta \rbrace[inline]  \lparen[inline] N \rparen[inline]  \rbrace[inline]  &= N\;\text \lbrace[inline] for all $N > 0$ \rbrace[inline] \\
              \log_ \lbrace[inline] \beta \rbrace[inline]  \lparen[inline] \beta^x \rparen[inline]  &= x
   }
}
\h1{Trigonometry}

\h2{Trigonometric Identities}

\grid[col="2"]{
   \note[boxed]{
      \h3{Pythagorean Identities}
      \equation{
         \cos^2 \lparen[inline] \theta \rparen[inline]  + \sin^2 \lparen[inline] \theta \rparen[inline]  = 1
      }
      \grid[col="2"]{
         \equation{
            \sec^2 \lparen[inline] \theta \rparen[inline]  - \tan^2 \lparen[inline] \theta \rparen[inline]  &= 1 \\
                        \sec^2 \lparen[inline] \theta \rparen[inline]  &= 1 + \tan^2 \lparen[inline] \theta \rparen[inline]
         }
         \equation{
            \csc^2 \lparen[inline] \theta \rparen[inline]  - \cot^2 \lparen[inline] \theta \rparen[inline]  &= 1 \\
                        \csc^2 \lparen[inline] \theta \rparen[inline]  &= 1 + \cot^2 \lparen[inline] \theta \rparen[inline]
         }
      }
   }
   \note[boxed]{
      \h3{Sum and Difference Identities}
      \math{
         \begin \lbrace[inline] equation \rbrace[inline] 
                 \begin \lbrace[inline] split \rbrace[inline] 
                     \cos \lparen[inline] \alpha - \beta \rparen[inline]  &= \cos \lparen[inline] \alpha \rparen[inline]  \cdot \cos \lparen[inline] \beta \rparen[inline]  + \sin \lparen[inline] \alpha \rparen[inline]  \cdot \sin \lparen[inline] \beta \rparen[inline]  \\
                     \cos \lparen[inline] \alpha + \beta \rparen[inline]  &= \cos \lparen[inline] \alpha \rparen[inline]  \cdot \cos \lparen[inline] \beta \rparen[inline]  - \sin \lparen[inline] \alpha \rparen[inline]  \cdot \sin \lparen[inline] \beta \rparen[inline]  \\
                     &\\
                     \sin \lparen[inline] \alpha - \beta \rparen[inline]  &= \sin \lparen[inline] \alpha \rparen[inline]  \cdot \cos \lparen[inline] \beta \rparen[inline]  - \cos \lparen[inline] \alpha \rparen[inline]  \cdot \sin \lparen[inline] \beta \rparen[inline]  \\
                     \sin \lparen[inline] \alpha + \beta \rparen[inline]  &= \sin \lparen[inline] \alpha \rparen[inline]  \cdot \cos \lparen[inline] \beta \rparen[inline]  + \cos \lparen[inline] \alpha \rparen[inline]  \cdot \sin \lparen[inline] \beta \rparen[inline]  \\
                     &\\
                     \tan \lparen[inline] \alpha + \beta \rparen[inline]  &= \frac \lbrace[inline] \tan \lparen[inline] \alpha \rparen[inline]  + \tan \lparen[inline] \beta \rparen[inline]  \rbrace[inline]  \lbrace[inline] 1 - \tan \lparen[inline] \alpha \rparen[inline]  \cdot \tan \lparen[inline] \beta \rparen[inline]  \rbrace[inline]  \\
                     \tan \lparen[inline] \alpha - \beta \rparen[inline]  &= \frac \lbrace[inline] \tan \lparen[inline] \alpha \rparen[inline]  - \tan \lparen[inline] \beta \rparen[inline]  \rbrace[inline]  \lbrace[inline] 1 + \tan \lparen[inline] \alpha \rparen[inline]  \cdot \tan \lparen[inline] \beta \rparen[inline]  \rbrace[inline] 
                 \end \lbrace[inline] split \rbrace[inline] 
                 \end \lbrace[inline] equation \rbrace[inline]
      }
   }
   \note[boxed]{
      \h3{Cofunction Identities}
      \grid[col="2"]{
         \equation{
            \sin \lparen[inline] \theta \rparen[inline]  = \cos \lparen[inline] \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] 4 \rbrace[inline] \tau - \theta \rparen[inline]
         }
         \equation{
            \cos \lparen[inline] \theta \rparen[inline]  = \sin \lparen[inline] \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] 4 \rbrace[inline] \tau - \theta \rparen[inline]
         }
         \equation{
            \tan \lparen[inline] \theta \rparen[inline]  = \cot \lparen[inline] \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] 4 \rbrace[inline] \tau - \theta \rparen[inline]
         }
         \equation{
            \cot \lparen[inline] \theta \rparen[inline]  = \tan \lparen[inline] \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] 4 \rbrace[inline] \tau - \theta \rparen[inline]
         }
         \equation{
            \csc \lparen[inline] \theta \rparen[inline]  = \sec \lparen[inline] \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] 4 \rbrace[inline] \tau - \theta \rparen[inline]
         }
         \equation{
            \sec \lparen[inline] \theta \rparen[inline]  = \csc \lparen[inline] \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] 4 \rbrace[inline] \tau - \theta \rparen[inline]
         }
      }
   }
   \note[boxed]{
      \h3{Ratio Identities}
      \math{
         \begin \lbrace[inline] equation \rbrace[inline] 
                 \begin \lbrace[inline] split \rbrace[inline] 
                     \tan \lparen[inline] 90^\circ - x \rparen[inline]  & = \frac \lbrace[inline] \sin \lparen[inline] 90^\circ - x \rparen[inline]  \rbrace[inline]  \lbrace[inline] \cos \lparen[inline] 90^\circ - x \rparen[inline]  \rbrace[inline]  = \frac \lbrace[inline] \cos \lparen[inline] x \rparen[inline]  \rbrace[inline]  \lbrace[inline] \sin \lparen[inline] x \rparen[inline]  \rbrace[inline]  = \cot \lparen[inline] x \rparen[inline]  \\
                     \\
                     \cot \lparen[inline] 90^\circ - x \rparen[inline]  & = \frac \lbrace[inline] \cos \lparen[inline] 90^\circ - x \rparen[inline]  \rbrace[inline]  \lbrace[inline] \sin \lparen[inline] 90^\circ - x \rparen[inline]  \rbrace[inline]  = \frac \lbrace[inline] \sin \lparen[inline] x \rparen[inline]  \rbrace[inline]  \lbrace[inline] \cos \lparen[inline] x \rparen[inline]  \rbrace[inline]  = \tan \lparen[inline] x \rparen[inline]  \\
                 \end \lbrace[inline] split \rbrace[inline] 
                 \end \lbrace[inline] equation \rbrace[inline]
      }
   }
   \note[boxed]{
      \h3{Double-Angle Identities}
      \math{
         \begin \lbrace[inline] equation \rbrace[inline] 
                 \begin \lbrace[inline] split \rbrace[inline] 
                     \sin \lparen[inline] 2\alpha \rparen[inline]  &= 2\sin \lparen[inline] \alpha \rparen[inline] \cos \lparen[inline] \alpha \rparen[inline]  \\
                     \cos \lparen[inline] 2\alpha \rparen[inline]  &= \cos^2 \lparen[inline] \alpha \rparen[inline]  - \sin^2 \lparen[inline] \alpha \rparen[inline]  \\
                                 &= 1 - 2\sin^2 \lparen[inline] \alpha \rparen[inline]  \\
                                 &= 2\cos^2 \lparen[inline] \alpha \rparen[inline]  - 1 \\
                     &\\
                     \tan \lparen[inline] 2\alpha \rparen[inline]  &= \frac \lbrace[inline] 2\tan \lparen[inline] \alpha \rparen[inline]  \rbrace[inline]  \lbrace[inline] 1 - \tan^2 \lparen[inline] \alpha \rparen[inline]  \rbrace[inline] 
                 \end \lbrace[inline] split \rbrace[inline] 
                 \end \lbrace[inline] equation \rbrace[inline]
      }
   }
   \note[boxed]{
      \h3{Half-Angle Identities}
      \math{
         \begin \lbrace[inline] equation \rbrace[inline] 
                 \begin \lbrace[inline] split \rbrace[inline] 
                     \sin \frac \lbrace[inline] \alpha \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline]  &= \pm \sqrt \lbrace[inline] \frac \lbrace[inline] 1 - \cos \lparen[inline] \alpha \rparen[inline]  \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline]  \rbrace[inline]  \\
                     \cos \frac \lbrace[inline] \alpha \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline]  &= \pm \sqrt \lbrace[inline] \frac \lbrace[inline] 1 + \cos \lparen[inline] \alpha \rparen[inline]  \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline]  \rbrace[inline]  \\
                     \tan \frac \lbrace[inline] \alpha \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline]  &= \pm \sqrt \lbrace[inline] \frac \lbrace[inline] 1 - \cos \lparen[inline] \alpha \rparen[inline]  \rbrace[inline]  \lbrace[inline] 1 + \cos \lparen[inline] \alpha \rparen[inline]  \rbrace[inline]  \rbrace[inline]  \\
                         &= \frac \lbrace[inline] sin \lparen[inline] \alpha \rparen[inline]  \rbrace[inline]  \lbrace[inline] 1 + \cos \lparen[inline] \alpha \rparen[inline]  \rbrace[inline]  \\
                         &= \frac \lbrace[inline] 1 - \cos \lparen[inline] \alpha \rparen[inline]  \rbrace[inline]  \lbrace[inline] sin \lparen[inline] \alpha \rparen[inline]  \rbrace[inline] 
                 \end \lbrace[inline] split \rbrace[inline] 
                 \end \lbrace[inline] equation \rbrace[inline]
      }
   }
   \note[boxed]{
      \h3{Power-Reducing Identities}
      \math{
         \begin \lbrace[inline] equation \rbrace[inline] 
                 \begin \lbrace[inline] split \rbrace[inline] 
                     \sin^2 \lparen[inline] \alpha \rparen[inline]  &= \frac \lbrace[inline] 1 - \cos \lparen[inline] 2\alpha \rparen[inline]  \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline]  \\
                     &\\
                     \cos^2 \lparen[inline] \alpha \rparen[inline]  &= \frac \lbrace[inline] 1 + \cos \lparen[inline] 2\alpha \rparen[inline]  \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline]  \\
                     &\\
                     \tan^2 \lparen[inline] \alpha \rparen[inline]  &= \frac \lbrace[inline] 1 - \cos \lparen[inline] 2\alpha \rparen[inline]  \rbrace[inline]  \lbrace[inline] 1 + \cos \lparen[inline] 2\alpha \rparen[inline]  \rbrace[inline] 
                 \end \lbrace[inline] split \rbrace[inline] 
                 \end \lbrace[inline] equation \rbrace[inline]
      }\hr\equation{
         \sin\alpha\cdot\cos\alpha &= \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline] \sin \lparen[inline] 2\alpha \rparen[inline]
      }
   }
   \note[boxed]{
      \h3{Product-to-Sum Identities}
      \math{
         \begin \lbrace[inline] equation \rbrace[inline] 
                 \begin \lbrace[inline] split \rbrace[inline] 
                     \sin \lparen[inline] \alpha \rparen[inline]  \cdot \cos \lparen[inline] \beta \rparen[inline]  &= \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline]  \Big \lbrack[inline]  \sin \lparen[inline] \alpha + \beta \rparen[inline]  + \sin \lparen[inline] \alpha - \beta \rparen[inline]  \Big \rbrack[inline]  \\
                     \cos \lparen[inline] \alpha \rparen[inline]  \cdot \sin \lparen[inline] \beta \rparen[inline]  &= \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline]  \Big \lbrack[inline]  \sin \lparen[inline] \alpha + \beta \rparen[inline]  - \sin \lparen[inline] \alpha - \beta \rparen[inline]  \Big \rbrack[inline]  \\
                     \cos \lparen[inline] \alpha \rparen[inline]  \cdot \cos \lparen[inline] \beta \rparen[inline]  &= \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline]  \Big \lbrack[inline]  \cos \lparen[inline] \alpha + \beta \rparen[inline]  + \cos \lparen[inline] \alpha - \beta \rparen[inline]  \Big \rbrack[inline]  \\
                     \sin \lparen[inline] \alpha \rparen[inline]  \cdot \sin \lparen[inline] \beta \rparen[inline]  &= \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline]  \Big \lbrack[inline]  \cos \lparen[inline] \alpha - \beta \rparen[inline]  - \cos \lparen[inline] \alpha + \beta \rparen[inline]  \Big \rbrack[inline] 
                 \end \lbrace[inline] split \rbrace[inline] 
                 \end \lbrace[inline] equation \rbrace[inline]
      }
   }
   \note[boxed]{
      \h3{Sum-to-Product-Identities}
      \math{
         \begin \lbrace[inline] equation \rbrace[inline] 
                 \begin \lbrace[inline] split \rbrace[inline] 
                     \sin \lparen[inline] x \rparen[inline]  + \sin \lparen[inline] y \rparen[inline]  &= 2 \cdot \sin\left \lparen[inline]  \frac \lbrace[inline] x + y \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline]  \right \rparen[inline]  \cdot \cos\left \lparen[inline]  \frac \lbrace[inline] x - y \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline]  \right \rparen[inline]  \\
                     \cos \lparen[inline] x \rparen[inline]  + \cos \lparen[inline] y \rparen[inline]  &= 2 \cdot \cos\left \lparen[inline]  \frac \lbrace[inline] x + y \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline]  \right \rparen[inline]  \cdot \cos\left \lparen[inline]  \frac \lbrace[inline] x - y \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline]  \right \rparen[inline]  \\
                     \sin \lparen[inline] x \rparen[inline]  - \sin \lparen[inline] y \rparen[inline]  &= 2 \cdot \cos\left \lparen[inline]  \frac \lbrace[inline] x + y \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline]  \right \rparen[inline]  \cdot \sin\left \lparen[inline]  \frac \lbrace[inline] x - y \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline]  \right \rparen[inline]  \\
                     \cos \lparen[inline] x \rparen[inline]  - \cos \lparen[inline] y \rparen[inline]  &= -2 \sin \cos\left \lparen[inline]  \frac \lbrace[inline] x + y \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline]  \right \rparen[inline]  \cdot \sin\left \lparen[inline]  \frac \lbrace[inline] x - y \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline]  \right \rparen[inline] 
                 \end \lbrace[inline] split \rbrace[inline] 
                 \end \lbrace[inline] equation \rbrace[inline]
      }
   }
}
\h2{Trigonometric Equations}

\grid[col="2"]{
   \note[boxed]{
      \h3{Euler's Formula}
      \equation{
         e^ \lbrace[inline] i x \rbrace[inline]  &= \cos \lparen[inline] x \rparen[inline]  + \mathrm \lbrace[inline] i \rbrace[inline] \sin \lparen[inline] x \rparen[inline]
      }
      \hr\equation{
         \mathrm \lbrace[inline] e \rbrace[inline] 
                     &= \sum_ \lbrace[inline] n = 0 \rbrace[inline] ^\infty \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] n! \rbrace[inline]  \\
                     &= \lim_ \lbrace[inline] n\to\infty \rbrace[inline]  \left \lparen[inline] 1 + \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] n \rbrace[inline] \right \rparen[inline] ^n \\
                     &= \lim_ \lbrace[inline] t \to 0 \rbrace[inline]  \left \lparen[inline] 1 + t\right \rparen[inline] ^ \lbrace[inline] \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] t \rbrace[inline]  \rbrace[inline]
      }
      \hr\equation{
         \mathrm \lbrace[inline] e \rbrace[inline] ^x
                     &= 1 + \frac \lbrace[inline] x \rbrace[inline]  \lbrace[inline] 1! \rbrace[inline]  + \frac \lbrace[inline] x^2 \rbrace[inline]  \lbrace[inline] 2! \rbrace[inline]  + \frac \lbrace[inline] x^3 \rbrace[inline]  \lbrace[inline] 3! \rbrace[inline]  + \cdots \\
                     &= \sum_ \lbrace[inline] n = 0 \rbrace[inline] ^\infty \frac \lbrace[inline] x^n \rbrace[inline]  \lbrace[inline] n! \rbrace[inline]  \\
                     &= \lim_ \lbrace[inline] n\to\infty \rbrace[inline]  \left \lparen[inline] 1 + \frac \lbrace[inline] x \rbrace[inline]  \lbrace[inline] n \rbrace[inline] \right \rparen[inline] ^n
      }
   }
}
\h1{Coordinate & Number Systems}

\grid[col="3"]{
   \note[boxed]{
      \equation{
         x &= r \cdot \cos\,\theta \\
                     y &= r \cdot \sin\,\theta \\
      }
      \hr\equation{
         z &= x + \mathrm \lbrace[inline] i \rbrace[inline] y \\
                       &= r \left \lparen[inline] \cos\, \theta + \mathrm \lbrace[inline] i \rbrace[inline] \sin\, \theta\right \rparen[inline] \\
                       & = r\;\mathrm \lbrace[inline] cis \rbrace[inline] \; \theta \\
      }
   }
   \note[boxed]{
      \equation{
         e^ \lbrace[inline] i x \rbrace[inline]  &= \cos\, x + \mathrm \lbrace[inline] i \rbrace[inline] \sin\, x \\
                     e ^ \lbrace[inline] i x \rbrace[inline]  &= r \left \lparen[inline] \cos\, \theta + \mathrm \lbrace[inline] i \rbrace[inline] \sin\, \theta\right \rparen[inline]  \\
                     \left \lparen[inline] \cos\, x + \mathrm \lbrace[inline] i \rbrace[inline] \sin\, x\right \rparen[inline] ^n &= \cos \lparen[inline] n x \rparen[inline]  + \mathrm \lbrace[inline] i \rbrace[inline] \sin \lparen[inline] n x \rparen[inline]  \\
      }
   }
   \note[boxed]{
      \equation{
         r &= |z| = |x + \mathrm \lbrace[inline] i \rbrace[inline] y| = \sqrt \lbrace[inline] x^2 + y^2 \rbrace[inline]  \\
                     r^2 &= x^2 + y^2 \\
                     \tan \theta &= \frac \lbrace[inline] y \rbrace[inline]  \lbrace[inline] x \rbrace[inline]  \\
                     \theta &= \arctan\left \lparen[inline] \frac \lbrace[inline] y \rbrace[inline]  \lbrace[inline] x \rbrace[inline] \right \rparen[inline]
      }
   }
}
\grid[col="2"]{
   \note[boxed]{
      \h2{Polar Coordinate System}
      \p{Given}
      \equation{
         \tan \theta &= \frac \lbrace[inline] y \rbrace[inline]  \lbrace[inline] x \rbrace[inline]  \\
                     r^2 &= x^2 + y^2 \\
      }
      \p{Then}
      \equation{
         x &= r \cdot \cos\,\theta \\
                     y &= r \cdot \sin\,\theta \\
      }
   }
   \note[boxed]{
      \h2{Properties}
      \p{Given}
      \equation{
         z_1 &= r_1\;\mathrm \lbrace[inline] cis \rbrace[inline] \;\theta_1 \\
                     z_2 &= r_1\;\mathrm \lbrace[inline] cis \rbrace[inline] \;\theta_1
      }
      \p{Then}
      \equation{
         z_1 \cdot z_2 &= r_1 \cdot r_2 \;\mathrm \lbrace[inline] cis \rbrace[inline] \;\left \lparen[inline] \theta_1 + \theta_2\right \rparen[inline]  \\
                     \frac \lbrace[inline] z_1 \rbrace[inline]  \lbrace[inline] z_2 \rbrace[inline]  &= \frac \lbrace[inline] r_1 \rbrace[inline]  \lbrace[inline] r_2 \rbrace[inline]  \;\mathrm \lbrace[inline] cis \rbrace[inline] \;\left \lparen[inline] \theta_1 - \theta_2\right \rparen[inline]  \\
      }
      \hr\p{De Moivre’s Theorem}
      \equation{
         z^n &= r^n \;\mathrm \lbrace[inline] cis \rbrace[inline] \;\;n\theta
      }
      \p{De Moivre’s Theorem For Finding Roots}
      \equation{
         \underbrace \lbrace[inline] w_k = r^ \lbrace[inline] \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] n \rbrace[inline]  \rbrace[inline] \;\mathrm \lbrace[inline] cis \rbrace[inline] \;\frac \lbrace[inline] \theta + \tau\cdot \lbrace[inline] k \rbrace[inline]  \rbrace[inline]  \lbrace[inline] n \rbrace[inline]  \rbrace[inline] 
                     _ \lbrace[inline] \begin \lbrace[inline] split \rbrace[inline] \forall\; k &= 0,1,2\cdots,n-1\\ n &\geq 1\end \lbrace[inline] split \rbrace[inline]  \rbrace[inline]
      }
   }
   \note[boxed]{
      \h2{\small{Trigonometric form of a complex number}}
      \equation{
         z &= x + \mathrm \lbrace[inline] i \rbrace[inline] y \\
                       &= r \left \lparen[inline] \cos\, \theta + \mathrm \lbrace[inline] i \rbrace[inline] \sin\, \theta\right \rparen[inline] \\
                       & = r\;\mathrm \lbrace[inline] cis \rbrace[inline] \;\theta \\
      }
   }
}
\h1{Vectors}

\note{
   \h2{Quick Facts}
   \ul{
      \li{\p{Two vectors are equal if they share the same magnitude and direction. \note[inline]{
         Initial points don't matter.
      }}}
      \li{\note{
         \p{You can define a vector with two points.}
         \img[src="../static/drawings/matrix/trinagle-def-of-a-vector.png", width="300px", center]
      }}
      \li{\p{\b{Do not divide vectors!}}}
      \li{\{\vec \lbrace[inline] v \rbrace[inline]  \cdot \vec \lbrace[inline] v \rbrace[inline]  = ||\vec \lbrace[inline] v \rbrace[inline] ||^2 \implies \text \lbrace[inline] constant \rbrace[inline]}}
      \li{\{\vec \lbrace[inline] v \rbrace[inline]  \cdot \left \lparen[inline] \vec \lbrace[inline] v \rbrace[inline] \right \rparen[inline] ^\prime = 0}}
   }
}

\h2{Vector Operations}

\grid[col="2"]{
   \note[boxed]{
      \h3{Dot Product}
      \equation{
         \vec \lbrace[inline] a \rbrace[inline] \cdot\vec \lbrace[inline] b \rbrace[inline] 
                     &=  \begin \lbrace[inline] bmatrix \rbrace[inline]  a_1 \\ a_2 \\ a_3 \end \lbrace[inline] bmatrix \rbrace[inline] 
                         \cdot
                         \begin \lbrace[inline] bmatrix \rbrace[inline]  b_1 \\ b_2 \\ b_3 \end \lbrace[inline] bmatrix \rbrace[inline] 
                     =  a_1b_1 + a_2b_2 + a_3b_3\\\\
                     \vec \lbrace[inline] a \rbrace[inline] \cdot\vec \lbrace[inline] b \rbrace[inline] 
                     &=  \begin \lbrace[inline] bmatrix \rbrace[inline]  a_1 \\ a_2 \end \lbrace[inline] bmatrix \rbrace[inline] 
                         \cdot
                         \begin \lbrace[inline] bmatrix \rbrace[inline]  b_1 \\ b_2 \end \lbrace[inline] bmatrix \rbrace[inline] 
                     =  a_1b_1 + a_2b_2
      }
   }
   \note[boxed]{
      \h3{Cross Product}
      \equation{
         \vec \lbrace[inline] a \rbrace[inline] \times\vec \lbrace[inline] b \rbrace[inline] 
                     &=
                     \begin \lbrace[inline] bmatrix \rbrace[inline]  a_1 & a_2 & a_3 \end \lbrace[inline] bmatrix \rbrace[inline] \times\begin \lbrace[inline] bmatrix \rbrace[inline]  b_1 & b_2 & b_3 \end \lbrace[inline] bmatrix \rbrace[inline] \\
                     &=
                     \mathrm \lbrace[inline] det \rbrace[inline] 
                     \begin \lbrace[inline] pmatrix \rbrace[inline] 
                     \mathrm \lbrace[inline] \hat \lbrace[inline] i \rbrace[inline]  \rbrace[inline]  & \mathrm \lbrace[inline] \hat \lbrace[inline] j \rbrace[inline]  \rbrace[inline]  & \mathrm \lbrace[inline] \hat \lbrace[inline] k \rbrace[inline]  \rbrace[inline] \\
                     a_1 & a_2 & a_3\\
                     b_1 & b_2 & b_3
                     \end \lbrace[inline] pmatrix \rbrace[inline] \\
                     &=
                     \mathrm \lbrace[inline] \hat \lbrace[inline] i \rbrace[inline]  \rbrace[inline] 
                     \begin \lbrace[inline] vmatrix \rbrace[inline] 
                     e & f\\
                     h & i
                     \end \lbrace[inline] vmatrix \rbrace[inline] 
                     -
                     \mathrm \lbrace[inline] \hat \lbrace[inline] j \rbrace[inline]  \rbrace[inline] 
                     \begin \lbrace[inline] vmatrix \rbrace[inline] 
                     d & f\\
                     g & i
                     \end \lbrace[inline] vmatrix \rbrace[inline] 
                     +
                     \mathrm \lbrace[inline] \hat \lbrace[inline] k \rbrace[inline]  \rbrace[inline] 
                     \begin \lbrace[inline] vmatrix \rbrace[inline] 
                     d & e\\
                     g & h
                     \end \lbrace[inline] vmatrix \rbrace[inline] \\
                     &= \mathrm \lbrace[inline] \hat \lbrace[inline] i \rbrace[inline]  \rbrace[inline] \left \lparen[inline] e i - f h\right \rparen[inline] 
                      - \mathrm \lbrace[inline] \hat \lbrace[inline] j \rbrace[inline]  \rbrace[inline] \left \lparen[inline] d i - f g\right \rparen[inline] 
                      + \mathrm \lbrace[inline] \hat \lbrace[inline] k \rbrace[inline]  \rbrace[inline] \left \lparen[inline] d h - e g\right \rparen[inline] \\
                     &=
                     \begin \lbrace[inline] bmatrix \rbrace[inline] 
                         e i - f h &
                         d i - f g &
                         d h - e g
                     \end \lbrace[inline] bmatrix \rbrace[inline] \\
                     &= \vec \lbrace[inline] c \rbrace[inline]
      }
   }
   \note[boxed]{
      \h3{Length of a Vector}
      \equation{
         |a| &= \sqrt \lbrace[inline]  \lparen[inline] a_1 \rparen[inline] ^2 +  \lparen[inline] a_2 \rparen[inline] ^2 \rbrace[inline]  \\
                     |a| &= \sqrt \lbrace[inline]  \lparen[inline] a_1 \rparen[inline] ^2 +  \lparen[inline] a_2 \rparen[inline] ^2 +  \lparen[inline] a_3 \rparen[inline] ^2 \rbrace[inline]
      }
   }
   \note[boxed]{
      \h3{Definition of Vector Addition}
      \p{If \{\vec \lbrace[inline] u \rbrace[inline]} and \{\vec \lbrace[inline] v \rbrace[inline]} are positioned so the initial point of \{\vec \lbrace[inline] v \rbrace[inline]} is at the terminal point of \{\vec \lbrace[inline] u \rbrace[inline]}, then the sum \{\vec \lbrace[inline] u \rbrace[inline]  + \vec \lbrace[inline] v \rbrace[inline]} is the vector from the initial point of \{\vec \lbrace[inline] u \rbrace[inline]} to the terminal point of \{\vec \lbrace[inline] v \rbrace[inline]}.}
      \img[width="300px", center, src="../static/drawings/matrix/Definition-of-Vector-Addition.png"]\hr\p{Given some vectors \{\vec \lbrace[inline] u \rbrace[inline]} and \{\vec \lbrace[inline] v \rbrace[inline]}, the vector \{\vec \lbrace[inline] u \rbrace[inline]  - \vec \lbrace[inline] v \rbrace[inline]} is the vector that points from the head of \{\vec \lbrace[inline] v \rbrace[inline]} to the head of \{\vec \lbrace[inline] u \rbrace[inline]}}
      \img[src="../static/drawings/matrix/vector-u-v.png", width="200px", center]
   }
}
\grid[col="3"]{
   \note[boxed]{
      \h3{Standard Basis Vectors}
      \equation{
         \mathrm \lbrace[inline] \hat \lbrace[inline] i \rbrace[inline]  \rbrace[inline]  &= \begin \lbrace[inline] bmatrix \rbrace[inline]  1 & 0 & 0 \end \lbrace[inline] bmatrix \rbrace[inline] \\
                     \mathrm \lbrace[inline] \hat \lbrace[inline] j \rbrace[inline]  \rbrace[inline]  &= \begin \lbrace[inline] bmatrix \rbrace[inline]  0 & 1 & 0 \end \lbrace[inline] bmatrix \rbrace[inline] \\
                     \mathrm \lbrace[inline] \hat \lbrace[inline] k \rbrace[inline]  \rbrace[inline]  &= \begin \lbrace[inline] bmatrix \rbrace[inline]  0 & 0 & 1 \end \lbrace[inline] bmatrix \rbrace[inline]
      }
      \hr\img[width="200px", center, src="../static/drawings/matrix/unit-vectors.png"]
   }
   \note[boxed]{
      \h3{Orthogonal}
      \p{Two vectors are orthogonal if and only if}
      \equation{
         \vec \lbrace[inline] a \rbrace[inline] \cdot\vec \lbrace[inline] b \rbrace[inline]  = 0
      }
   }
   \note[boxed]{
      \h3{The Unit Vector}
      \equation{
         \hat \lbrace[inline] u \rbrace[inline]  &= \frac \lbrace[inline] \vec \lbrace[inline] a \rbrace[inline]  \rbrace[inline]  \lbrace[inline] |\vec \lbrace[inline] a \rbrace[inline] | \rbrace[inline]
      }
   }
   \note[boxed]{
      \h3{\small{If \{\theta} is the angle between the vectors \{\vec \lbrace[inline] a \rbrace[inline]} and \{\vec \lbrace[inline] b \rbrace[inline]}, then}}
      \equation{
         \vec \lbrace[inline] a \rbrace[inline]  \cdot \vec \lbrace[inline] a \rbrace[inline]  = |\vec \lbrace[inline] a \rbrace[inline] | \cdot |\vec \lbrace[inline] a \rbrace[inline] | \cos\theta
      }
   }
   \note[boxed]{
      \h3{\small{If \{\theta} is the angle between the nonzero vectors \{\vec \lbrace[inline] a \rbrace[inline]} and \{\vec \lbrace[inline] b \rbrace[inline]}, then}}
      \equation{
         \cos\theta = \frac
                          \lbrace[inline] \vec \lbrace[inline] a \rbrace[inline] \cdot\vec \lbrace[inline] b \rbrace[inline]  \rbrace[inline] 
                          \lbrace[inline] |\vec \lbrace[inline] a \rbrace[inline] | |\vec \lbrace[inline] b \rbrace[inline] | \rbrace[inline]
      }
   }
   \note[boxed]{
      \h3{\small{Two nonzero vectors \{\vec \lbrace[inline] a \rbrace[inline]} and \{\vec \lbrace[inline] b \rbrace[inline]} are parallel if and only if}}
      \equation{
         \vec \lbrace[inline] a \rbrace[inline] \times\vec \lbrace[inline] b \rbrace[inline]  = 0
      }
   }
}
\h3{Properties of the Dot Product}

\grid[col="3"]{
   \note[boxed]{
      \equation{
         \vec \lbrace[inline] a \rbrace[inline]  \cdot \vec \lbrace[inline] a \rbrace[inline]  = |\vec \lbrace[inline] a \rbrace[inline] |^2
      }
   }
   \note[boxed]{
      \equation{
         \vec \lbrace[inline] a \rbrace[inline]  \cdot \left \lparen[inline] \vec \lbrace[inline] b \rbrace[inline]  + \vec \lbrace[inline] c \rbrace[inline] \right \rparen[inline]  = \vec \lbrace[inline] a \rbrace[inline] \vec \lbrace[inline] b \rbrace[inline]  + \vec \lbrace[inline] a \rbrace[inline] \vec \lbrace[inline] c \rbrace[inline]
      }
   }
   \note[boxed]{
      \equation{
         \vec \lbrace[inline] a \rbrace[inline]  \cdot \vec \lbrace[inline] b \rbrace[inline]  = \vec \lbrace[inline] b \rbrace[inline]  \cdot \vec \lbrace[inline] a \rbrace[inline]
      }
   }
   \note[boxed]{
      \equation{
         \left \lparen[inline] c \cdot \vec \lbrace[inline] a \rbrace[inline] \right \rparen[inline]  \cdot \vec \lbrace[inline] b \rbrace[inline]  = c\left \lparen[inline] \vec \lbrace[inline] a \rbrace[inline]  \cdot \vec \lbrace[inline] b \rbrace[inline] \right \rparen[inline]
      }
   }
}
\h2{Direction Cosines & Direction Angles of a Vector}

\note{
   \img[width="300px", center, src="../static/drawings/matrix/Direction-Cosines-Direction-Angles-of-a-Vector.png"]\p[center]{Where}
   \equation{
      \vec \lbrace[inline] v \rbrace[inline]  &= \begin \lbrace[inline] bmatrix \rbrace[inline]  v_x & v_y & v_z \end \lbrace[inline] bmatrix \rbrace[inline] 
              \;\;\;\;
              ||\vec \lbrace[inline] v \rbrace[inline] || &= \sqrt \lbrace[inline]  \lparen[inline] v_x \rparen[inline] ^2 +  \lparen[inline] v_y \rparen[inline] ^2 +  \lparen[inline] v_z \rparen[inline] ^2 \rbrace[inline]
   }
}

\grid[col="3"]{
   \note[boxed]{
      \h3{Direction Cosines}
      \equation{
         \cos\alpha &= \frac \lbrace[inline] v_x \rbrace[inline]  \lbrace[inline] ||\vec \lbrace[inline] v \rbrace[inline] || \rbrace[inline] \\
                     \cos\beta &= \frac \lbrace[inline] v_y \rbrace[inline]  \lbrace[inline] ||\vec \lbrace[inline] v \rbrace[inline] || \rbrace[inline] \\
                     \cos\gamma &= \frac \lbrace[inline] v_z \rbrace[inline]  \lbrace[inline] ||\vec \lbrace[inline] v \rbrace[inline] || \rbrace[inline]
      }
   }
   \note[boxed]{
      \h3{Direction Angles}
      \equation{
         \alpha &= \arccos \left \lparen[inline] \frac \lbrace[inline] v_x \rbrace[inline]  \lbrace[inline] ||\vec \lbrace[inline] v \rbrace[inline] || \rbrace[inline] \right \rparen[inline] \\
                     \beta &= \arccos \left \lparen[inline] \frac \lbrace[inline] v_y \rbrace[inline]  \lbrace[inline] ||\vec \lbrace[inline] v \rbrace[inline] || \rbrace[inline] \right \rparen[inline] \\
                     \gamma &= \arccos \left \lparen[inline] \frac \lbrace[inline] v_z \rbrace[inline]  \lbrace[inline] ||\vec \lbrace[inline] v \rbrace[inline] || \rbrace[inline] \right \rparen[inline]
      }
   }
   \note[boxed]{
      \h3{Theorem}
      \equation{
         \cos^2\alpha + \cos^2\beta + \cos^2\gamma = 1
      }
      \hr\h5{Proof}
      \equation{
         \vec \lbrace[inline] v \rbrace[inline]  &= \hat \lbrace[inline] i \rbrace[inline] \cos\alpha + \hat \lbrace[inline] k \rbrace[inline] \cos\beta + \hat \lbrace[inline] k \rbrace[inline] \cos\gamma\\
                     ||\vec \lbrace[inline] v \rbrace[inline] || &= || \hat \lbrace[inline] i \rbrace[inline] \cos\alpha + \hat \lbrace[inline] k \rbrace[inline] \cos\beta + \hat \lbrace[inline] k \rbrace[inline] \cos\gamma|| = 1
      }
      \p{Given}
      \equation{
         \sqrt \lbrace[inline] \cos^2\alpha + \cos^2\beta + \cos^2\gamma \rbrace[inline]  &= 1\\
                     \sqrt \lbrace[inline] \cos^2\alpha + \cos^2\beta + \cos^2\gamma \rbrace[inline] ^2 &= 1^2\\
                     \cos^2\alpha + \cos^2\beta + \cos^2\gamma &= 1
      }
      \p{Therefore}
      \equation{
         \cos^2\alpha + \cos^2\beta + \cos^2\gamma = 1\\
      }
   }
}
\h2{Vector Relations}

\grid[col="2"]{
   \note[boxed]{
      \h3{Parallel Vectors}
      \ul{
         \li{When two vectors are parallel; they never intersect (duh).}
      }\p{Given some vectors}
      \equation{
         \vec \lbrace[inline] a \rbrace[inline]  &= \begin \lbrace[inline] bmatrix \rbrace[inline]  a_x & a_y & a_z \end \lbrace[inline] bmatrix \rbrace[inline] \\
                     \vec \lbrace[inline] b \rbrace[inline]  &= \begin \lbrace[inline] bmatrix \rbrace[inline]  b_x & b_y & b_z \end \lbrace[inline] bmatrix \rbrace[inline]
      }
      \p{The vectors \{\vec \lbrace[inline] a \rbrace[inline]} and \{\vec \lbrace[inline] b \rbrace[inline]} are parallel if and only if they are scalar multiples of one another.}
      \equation{
         \vec \lbrace[inline] a \rbrace[inline]  &= k\;\vec \lbrace[inline] b \rbrace[inline]  \;\;\;\;\forall k \neq 0
      }
      \h4{Alternatively}
      \equation{
         \frac \lbrace[inline] a_x \rbrace[inline]  \lbrace[inline] b_x \rbrace[inline]  = \frac \lbrace[inline] a_y \rbrace[inline]  \lbrace[inline] b_y \rbrace[inline]  = \frac \lbrace[inline] a_z \rbrace[inline]  \lbrace[inline] b_z \rbrace[inline]
      }
   }
   \note[boxed]{
      \h3{Orthogonal Vectors}
      \ul{
         \li{When two vectors are orthogonal; they meet at right angles.}
      }\p{Given some vectors}
      \equation{
         \vec \lbrace[inline] a \rbrace[inline]  &= \begin \lbrace[inline] bmatrix \rbrace[inline]  a_x & a_y & a_z \end \lbrace[inline] bmatrix \rbrace[inline] \\
                     \vec \lbrace[inline] b \rbrace[inline]  &= \begin \lbrace[inline] bmatrix \rbrace[inline]  b_x & b_y & b_z \end \lbrace[inline] bmatrix \rbrace[inline]
      }
      \p{Two vectors are orthogonal if and only if}
      \equation{
         \vec \lbrace[inline] a \rbrace[inline] \times\vec \lbrace[inline] b \rbrace[inline]  = 0
      }
   }
}
\h2{Reparameterization of the position vector \{\vec \lbrace[inline] v \rbrace[inline]  \lparen[inline] t \rparen[inline]} in terms of length \{S \lparen[inline] t \rparen[inline]}}

\ul{
   \li{\p{We can parametrize a curve \b{with respect to arc length}; because arc length arises naturally from the shape of the curve and \b{does not depend on any coordinate system}.}}
}
\grid[col="2"]{
   \note[boxed]{
      \h3{The Arc Length Function}
      \p{Given}
      \equation{
         \vec \lbrace[inline] v \rbrace[inline] 
                         &= \begin \lbrace[inline] bmatrix \rbrace[inline]  x & y & z \end \lbrace[inline] bmatrix \rbrace[inline] 
                         = \begin \lbrace[inline] bmatrix \rbrace[inline]  f \lparen[inline] t \rparen[inline]  & g \lparen[inline] t \rparen[inline]  & h \lparen[inline] t \rparen[inline]  \end \lbrace[inline] bmatrix \rbrace[inline]
      }
      \p{We can redefine \{\vec \lbrace[inline] v \rbrace[inline]} in terms of arc length between two endpoints}
      \math{
         \newcommand \lbrace[inline] \Long \rbrace[inline]  \lbrace[inline] 
                         \int_a^t \sqrt \lbrace[inline] 
                             \left \lparen[inline] f^\prime \lparen[inline] u \rparen[inline] \right \rparen[inline] ^2
                             \left \lparen[inline] g^\prime \lparen[inline] u \rparen[inline] \right \rparen[inline] ^2
                             \left \lparen[inline] h^\prime \lparen[inline] u \rparen[inline] \right \rparen[inline] ^2
                          \rbrace[inline] 
                      \rbrace[inline] 
                     \newcommand \lbrace[inline] \AltLong \rbrace[inline]  \lbrace[inline] 
                         \int_a^t \sqrt \lbrace[inline] 
                             \left \lparen[inline] \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] x \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] u \rbrace[inline] \right \rparen[inline] ^2
                             \left \lparen[inline] \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] y \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] u \rbrace[inline] \right \rparen[inline] ^2
                             \left \lparen[inline] \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] z \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] u \rbrace[inline] \right \rparen[inline] ^2
                          \rbrace[inline] 
                      \rbrace[inline] 
                     \newcommand \lbrace[inline] \short \rbrace[inline]  \lbrace[inline] 
                         \int_a^t ||\left \lparen[inline] v^\prime \lparen[inline] u \rparen[inline] \right \rparen[inline] ||
                      \rbrace[inline] 
                     \begin \lbrace[inline] equation \rbrace[inline] 
                     \begin \lbrace[inline] split \rbrace[inline] 
                         S \lparen[inline] t \rparen[inline] 
                             &= \Long\\
                             &= \AltLong\\
                             &= \short
                     \end \lbrace[inline] split \rbrace[inline] 
                     \end \lbrace[inline] equation \rbrace[inline]
      }\p{That is, \{S \lparen[inline] t \rparen[inline]} is the length of the curve (\{C}) between \{r \lparen[inline] a \rparen[inline]} and \{r \lparen[inline] b \rparen[inline]}.}
      \hr\p{Furthermore from the adjacent definition; we can simply the above to}
      \equation{
         S \lparen[inline] t \rparen[inline]  = \int_a^t \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] S \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] t \rbrace[inline]
      }
   }
   \note[boxed]{
      \h3{The Arc Length Function}
      \equation{
         \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] S \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] t \rbrace[inline]  \equiv || v^\prime \lparen[inline] t \rparen[inline]  ||
      }
      \p{That is}
      \math{
         \newcommand \lbrace[inline] \Long \rbrace[inline]  \lbrace[inline] 
                         \sqrt \lbrace[inline] 
                             \left \lparen[inline] f^\prime \lparen[inline] u \rparen[inline] \right \rparen[inline] ^2
                             \left \lparen[inline] g^\prime \lparen[inline] u \rparen[inline] \right \rparen[inline] ^2
                             \left \lparen[inline] h^\prime \lparen[inline] u \rparen[inline] \right \rparen[inline] ^2
                          \rbrace[inline] 
                      \rbrace[inline] 
                     \newcommand \lbrace[inline] \AltLong \rbrace[inline]  \lbrace[inline] 
                         \sqrt \lbrace[inline] 
                             \left \lparen[inline] \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] x \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] u \rbrace[inline] \right \rparen[inline] ^2
                             \left \lparen[inline] \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] y \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] u \rbrace[inline] \right \rparen[inline] ^2
                             \left \lparen[inline] \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] z \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] u \rbrace[inline] \right \rparen[inline] ^2
                          \rbrace[inline] 
                      \rbrace[inline] 
                     \newcommand \lbrace[inline] \short \rbrace[inline]  \lbrace[inline] 
                         ||\left \lparen[inline] v^\prime \lparen[inline] u \rparen[inline] \right \rparen[inline] ||
                      \rbrace[inline] 
                     \begin \lbrace[inline] equation \rbrace[inline] 
                     \begin \lbrace[inline] split \rbrace[inline] 
                         \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] S \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] t \rbrace[inline] 
                             &= \Long\\
                             &= \AltLong\\
                             &= \short
                     \end \lbrace[inline] split \rbrace[inline] 
                     \end \lbrace[inline] equation \rbrace[inline]
      }
   }
}
\h2{Vectors Derived From Some Curve Defined by \{\vec \lbrace[inline] v \rbrace[inline]}}

\grid[col="2"]{
   \note[boxed]{
      \img[width="300px", center, src="../static/drawings/matrix/curvature.png"]
   }
   \note[boxed]{
      \h3{The Unit Vector}
      \equation{
         \hat \lbrace[inline] U \rbrace[inline]  \equiv \frac \lbrace[inline] \vec \lbrace[inline] v \rbrace[inline]  \rbrace[inline]  \lbrace[inline] ||\vec \lbrace[inline] v \rbrace[inline] || \rbrace[inline]
      }
   }
}
\grid[col="2"]{
   \note[boxed]{
      \h3{The Unit \b{Tangent} Vector}
      \equation{
         \vec \lbrace[inline] T \rbrace[inline] 
                         &\equiv \frac
                              \lbrace[inline] v^\prime \lparen[inline] t \rparen[inline]  \rbrace[inline] 
                              \lbrace[inline] ||v^\prime \lparen[inline] t \rparen[inline] || \rbrace[inline] 
                         &\equiv \frac
                              \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] v \rbrace[inline] 
                              \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] S \rbrace[inline]
      }
   }
   \note[boxed]{
      \h3{The Unit \b{Normal} Vector}
      \equation{
         \vec \lbrace[inline] N \rbrace[inline]  \equiv \frac
                          \lbrace[inline] T^\prime \rbrace[inline] 
                          \lbrace[inline] ||T^\prime|| \rbrace[inline]
      }
   }
   \note[boxed]{
      \h3{The Binormal Vector}
      \equation{
         \vec \lbrace[inline] B \rbrace[inline]  \equiv \vec \lbrace[inline] T \rbrace[inline] \times\vec \lbrace[inline] N \rbrace[inline]
      }
      \ul{
         \li{\p{Therefore, the binormal vector is orthogonal to both the tangent vector and the normal vector.}}
         \li{\p{The plane determined by the normal and binormal vectors N and B at a point P on a curve C is called the normal plane of C at P.}}
         \li{\p{The plane determined by the vectors T and N is called the osculating plane of C at P. The name comes from the Latin osculum, meaning “kiss.” It is the plane that comes closest to containing the part of the curve near P. (For a plane curve, the osculating plane is simply the plane that contains the curve.)}}
      }
   }
   \note[boxed]{
      \h3{Kappa - Curvature of a Vector}
      \equation{
         \kappa
                         &\equiv \left|\frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] T \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] S \rbrace[inline] \right|
                         &\equiv \frac
                              \lbrace[inline] \left| T^\prime \right| \rbrace[inline] 
                              \lbrace[inline] \left| r^\prime \right| \rbrace[inline] 
                         &\equiv \frac
                              \lbrace[inline] \left| r^\prime \times r^ \lbrace[inline] \prime\prime \rbrace[inline]  \right| \rbrace[inline] 
                              \lbrace[inline] \left| r^\prime \right|^3 \rbrace[inline]
      }
   }
   \note[boxed]{
      \h3{Tangential & Normal Components of the Acceleration Vector of the Curve}
      \p{When we study the motion of a particle, it is often useful to resolve the acceleration into two components, one in the direction of the tangent and the other in the direction of the normal.}
      \equation{
         a_ \lbrace[inline] \vec \lbrace[inline] T \rbrace[inline]  \rbrace[inline] 
                         &= \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] t \rbrace[inline]  \left|\vec \lbrace[inline] v \rbrace[inline] \right|
                         = \frac \lbrace[inline] r^\prime \cdot r^ \lbrace[inline] \prime\prime \rbrace[inline]  \rbrace[inline]  \lbrace[inline] |r^\prime| \rbrace[inline] \\
                     a_ \lbrace[inline] \vec \lbrace[inline] N \rbrace[inline]  \rbrace[inline] 
                         &= \kappa \left|\vec \lbrace[inline] v \rbrace[inline] \right|^2
                         = \frac \lbrace[inline] \left|r^\prime \times r^ \lbrace[inline] \prime\prime \rbrace[inline] \right| \rbrace[inline]  \lbrace[inline] |r^\prime| \rbrace[inline] \\
         
                     \vec \lbrace[inline] a \rbrace[inline]  &= a_ \lbrace[inline] \vec \lbrace[inline] T \rbrace[inline]  \rbrace[inline]  \vec \lbrace[inline] T \rbrace[inline]  + a_ \lbrace[inline] \vec \lbrace[inline] N \rbrace[inline]  \rbrace[inline]  \vec \lbrace[inline] N \rbrace[inline]
      }
      \p{Specifically}
      \equation{
         \left.\begin \lbrace[inline] aligned \rbrace[inline] 
                     a_ \lbrace[inline] \vec \lbrace[inline] T \rbrace[inline]  \rbrace[inline] \\
                     a_ \lbrace[inline] \vec \lbrace[inline] N \rbrace[inline]  \rbrace[inline] 
                     \end \lbrace[inline] aligned \rbrace[inline] \right\ \rbrace[inline]  \text \lbrace[inline] Tangential & Normal Components of $\vec \lbrace[inline] a \rbrace[inline] $ \rbrace[inline]
      }
   }
}
\h2{Vector Calculus}

\grid[col="3"]{
   \note[boxed]{
      \h3{\small{The Position Vector \{\vec \lbrace[inline] r \rbrace[inline]  \lparen[inline] t \rparen[inline]}}}
      \p[center]{\small{(Original Function)}}
   }
   \note[boxed]{
      \h3{\small{The Velocity Vector \{\vec \lbrace[inline] v \rbrace[inline]  \lparen[inline] t \rparen[inline]}}}
      \p[center]{\small{(First Derivative)}}
      \ul{
         \li{The velocity vector is also the tangent vector and points in the direction of the tangent line.}
         \li{The \b{speed} of the particle \u{at time t} is the \b{magnitude} of the velocity vector, that is,
                         \equation{
            \underbrace \lbrace[inline] |\vec \lbrace[inline] v \rbrace[inline]  \lparen[inline] t \rparen[inline] | = | \lparen[inline] \vec \lbrace[inline] r \rbrace[inline]  \rparen[inline] ^\prime \lparen[inline] t \rparen[inline] | = \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] s \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] t \rbrace[inline]  \rbrace[inline] 
                                _ \lbrace[inline] \text \lbrace[inline] rate of change of distance with respect to time \rbrace[inline]  \rbrace[inline]
         }}
      }
   }
   \note[boxed]{
      \h3{\small{The Acceleration Vector \{\vec \lbrace[inline] a \rbrace[inline]  \lparen[inline] t \rparen[inline]}}}
      \p[center]{\small{(Second Derivative)}}
   }
}
\h1{Matrices}

\h2{Reference}

\grid[col="2"]{
   \note[boxed]{
      \h3{The Determinant of A Matrix}
      \equation{
         |A| &=
                     \begin \lbrace[inline] vmatrix \rbrace[inline] 
                     a & b\\
                     c & d
                     \end \lbrace[inline] vmatrix \rbrace[inline]  =
                     ad - bc\\\\
                     |A| &=
                     \begin \lbrace[inline] vmatrix \rbrace[inline] 
                     a & b & c\\
                     d & e & f\\
                     g & h & i
                     \end \lbrace[inline] vmatrix \rbrace[inline] \\ &=
                     a 
                     \begin \lbrace[inline] vmatrix \rbrace[inline] 
                     e & f\\
                     h & i
                     \end \lbrace[inline] vmatrix \rbrace[inline] 
                     -
                     b
                     \begin \lbrace[inline] vmatrix \rbrace[inline] 
                     d & f\\
                     g & i
                     \end \lbrace[inline] vmatrix \rbrace[inline] 
                     +
                     c
                     \begin \lbrace[inline] vmatrix \rbrace[inline] 
                     d & e\\
                     g & h
                     \end \lbrace[inline] vmatrix \rbrace[inline]
      }
      \img[src="../static/drawings/matrix/3x3-determinant.png", center, width="400px"]\note[boxed]{
         \p{Only works for square matrices.}
      }
   }
   \note[boxed]{
      \h3{The Cross Product}
      \equation{
         \vec \lbrace[inline] a \rbrace[inline] \times\vec \lbrace[inline] b \rbrace[inline] 
                     &=
                     \begin \lbrace[inline] bmatrix \rbrace[inline]  a_1 & a_2 & a_3 \end \lbrace[inline] bmatrix \rbrace[inline] \times\begin \lbrace[inline] bmatrix \rbrace[inline]  b_1 & b_2 & b_3 \end \lbrace[inline] bmatrix \rbrace[inline] \\
                     &=
                     \mathrm \lbrace[inline] det \rbrace[inline] 
                     \begin \lbrace[inline] pmatrix \rbrace[inline] 
                     \mathrm \lbrace[inline] \hat \lbrace[inline] i \rbrace[inline]  \rbrace[inline]  & \mathrm \lbrace[inline] \hat \lbrace[inline] j \rbrace[inline]  \rbrace[inline]  & \mathrm \lbrace[inline] \hat \lbrace[inline] k \rbrace[inline]  \rbrace[inline] \\
                     a_1 & a_2 & a_3\\
                     b_1 & b_2 & b_3
                     \end \lbrace[inline] pmatrix \rbrace[inline] \\
                     &=
                     \mathrm \lbrace[inline] \hat \lbrace[inline] i \rbrace[inline]  \rbrace[inline] 
                     \begin \lbrace[inline] vmatrix \rbrace[inline] 
                     e & f\\
                     h & i
                     \end \lbrace[inline] vmatrix \rbrace[inline] 
                     -
                     \mathrm \lbrace[inline] \hat \lbrace[inline] j \rbrace[inline]  \rbrace[inline] 
                     \begin \lbrace[inline] vmatrix \rbrace[inline] 
                     d & f\\
                     g & i
                     \end \lbrace[inline] vmatrix \rbrace[inline] 
                     +
                     \mathrm \lbrace[inline] \hat \lbrace[inline] k \rbrace[inline]  \rbrace[inline] 
                     \begin \lbrace[inline] vmatrix \rbrace[inline] 
                     d & e\\
                     g & h
                     \end \lbrace[inline] vmatrix \rbrace[inline] \\
                     &= \mathrm \lbrace[inline] \hat \lbrace[inline] i \rbrace[inline]  \rbrace[inline] \left \lparen[inline] e i - f h\right \rparen[inline] 
                      - \mathrm \lbrace[inline] \hat \lbrace[inline] j \rbrace[inline]  \rbrace[inline] \left \lparen[inline] d i - f g\right \rparen[inline] 
                      + \mathrm \lbrace[inline] \hat \lbrace[inline] k \rbrace[inline]  \rbrace[inline] \left \lparen[inline] d h - e g\right \rparen[inline] \\
                     &=
                     \begin \lbrace[inline] bmatrix \rbrace[inline] 
                         e i - f h &
                         d i - f g &
                         d h - e g
                     \end \lbrace[inline] bmatrix \rbrace[inline] \\
                     &= \vec \lbrace[inline] c \rbrace[inline]
      }
   }
}
\h1{Geometry}

\h2{Definition of a Line}

\img[width="500px", center, src="../static/drawings/matrix/vector-equation-of-a-line.png"]
\grid[col="3"]{
   \note[boxed]{
      \h3{Vector Equation of a Line}
      \p{Given}
      \equation{
         \colorB \lbrace[inline] P_1 \rbrace[inline]  &= \begin \lbrace[inline] bmatrix \rbrace[inline]  \colorB \lbrace[inline] x_1 \rbrace[inline]  & \colorB \lbrace[inline] y_1 \rbrace[inline]  & \colorB \lbrace[inline] z_1 \rbrace[inline]  \end \lbrace[inline] bmatrix \rbrace[inline] \\
                     \colorC \lbrace[inline] P_2 \rbrace[inline]  &= \begin \lbrace[inline] bmatrix \rbrace[inline]  \colorC \lbrace[inline] x_2 \rbrace[inline]  & \colorC \lbrace[inline] y_2 \rbrace[inline]  & \colorC \lbrace[inline] z_2 \rbrace[inline]  \end \lbrace[inline] bmatrix \rbrace[inline] \\
      }
      \equation{
         \colorB \lbrace[inline] P_1 \rbrace[inline]  &= \begin \lbrace[inline] bmatrix \rbrace[inline]  \colorB \lbrace[inline] x_1 \rbrace[inline]  & \colorB \lbrace[inline] y_1 \rbrace[inline]  & \colorB \lbrace[inline] z_1 \rbrace[inline]  \end \lbrace[inline] bmatrix \rbrace[inline] \\
                     \colorC \lbrace[inline] P_2 \rbrace[inline]  &= \begin \lbrace[inline] bmatrix \rbrace[inline]  \colorC \lbrace[inline] x_2 \rbrace[inline]  & \colorC \lbrace[inline] y_2 \rbrace[inline]  & \colorC \lbrace[inline] z_2 \rbrace[inline]  \end \lbrace[inline] bmatrix \rbrace[inline] \\
      }
      \p{We can define a vector between \{\colorB \lbrace[inline] P_1 \rbrace[inline]} and \{\colorC \lbrace[inline] P_2 \rbrace[inline]}}
      \equation{
         \colorA \lbrace[inline] \overrightarrow \lbrace[inline] \Delta\mathsf \lbrace[inline] v \rbrace[inline]  \rbrace[inline]  \rbrace[inline]  &= 
                     \begin \lbrace[inline] bmatrix \rbrace[inline]  \colorC \lbrace[inline] x_2 \rbrace[inline]  \\ \colorC \lbrace[inline] y_2 \rbrace[inline]  \\ \colorC \lbrace[inline] z_2 \rbrace[inline]  \end \lbrace[inline] bmatrix \rbrace[inline]  -
                     \begin \lbrace[inline] bmatrix \rbrace[inline]  \colorB \lbrace[inline] x_1 \rbrace[inline]  \\ \colorB \lbrace[inline] y_1 \rbrace[inline]  \\ \colorB \lbrace[inline] z_1 \rbrace[inline]  \end \lbrace[inline] bmatrix \rbrace[inline]  =
                     \begin \lbrace[inline] bmatrix \rbrace[inline]  \colorC \lbrace[inline] x_2 \rbrace[inline] -\colorB \lbrace[inline] x_1 \rbrace[inline]  \\ \colorC \lbrace[inline] y_2 \rbrace[inline] -\colorB \lbrace[inline] y_1 \rbrace[inline]  \\ \colorC \lbrace[inline] z_2 \rbrace[inline] -\colorB \lbrace[inline] z_1 \rbrace[inline]  \end \lbrace[inline] bmatrix \rbrace[inline]  =
                     \begin \lbrace[inline] bmatrix \rbrace[inline]  \colorA \lbrace[inline] \Delta_x \rbrace[inline]  \\ \colorA \lbrace[inline] \Delta_y \rbrace[inline]  \\ \colorA \lbrace[inline] \Delta_z \rbrace[inline]  \end \lbrace[inline] bmatrix \rbrace[inline]
      }
      \h4{Therefore}
      \p{The equation of a line in 3D space or \{\mathbb \lbrace[inline] R \rbrace[inline] ^3} can be defined VIA the following options}
      \equation{
         L &= \colorB \lbrace[inline] P_1 \rbrace[inline]  + t\cdot\colorA \lbrace[inline] \overrightarrow \lbrace[inline] \Delta\mathsf \lbrace[inline] v \rbrace[inline]  \rbrace[inline]  \rbrace[inline]  \\
                     \begin \lbrace[inline] bmatrix \rbrace[inline]  x \\ y \\ z \end \lbrace[inline] bmatrix \rbrace[inline]  &= 
                     \begin \lbrace[inline] bmatrix \rbrace[inline]  \colorB \lbrace[inline] x_1 \rbrace[inline]  \\ \colorB \lbrace[inline] y_1 \rbrace[inline]  \\ \colorB \lbrace[inline] z_1 \rbrace[inline]  \end \lbrace[inline] bmatrix \rbrace[inline]  +
                     t\begin \lbrace[inline] bmatrix \rbrace[inline]  \colorA \lbrace[inline] \Delta_x \rbrace[inline]  \\ \colorA \lbrace[inline] \Delta_y \rbrace[inline]  \\ \colorA \lbrace[inline] \Delta_z \rbrace[inline]  \end \lbrace[inline] bmatrix \rbrace[inline]  =
                     \begin \lbrace[inline] bmatrix \rbrace[inline]  \colorB \lbrace[inline] x_1 \rbrace[inline]  \\ \colorB \lbrace[inline] y_1 \rbrace[inline]  \\ \colorB \lbrace[inline] z_1 \rbrace[inline]  \end \lbrace[inline] bmatrix \rbrace[inline]  +
                     \begin \lbrace[inline] bmatrix \rbrace[inline]  t\;\colorA \lbrace[inline] \Delta_x \rbrace[inline]  \\ t\;\colorA \lbrace[inline] \Delta_y \rbrace[inline]  \\ t\;\colorA \lbrace[inline] \Delta_z \rbrace[inline]  \end \lbrace[inline] bmatrix \rbrace[inline]  \\
                     &= 
                     \begin \lbrace[inline] bmatrix \rbrace[inline]  \colorB \lbrace[inline] x_1 \rbrace[inline]  + t\;\colorA \lbrace[inline] \Delta_x \rbrace[inline]  \\ \colorB \lbrace[inline] y_1 \rbrace[inline]  + t\;\colorA \lbrace[inline] \Delta_y \rbrace[inline]  \\ \colorB \lbrace[inline] z_1 \rbrace[inline]  + t\;\colorA \lbrace[inline] \Delta_z \rbrace[inline]  \end \lbrace[inline] bmatrix \rbrace[inline] \\
                     &= 
                     \begin \lbrace[inline] bmatrix \rbrace[inline]  \colorB \lbrace[inline] x_1 \rbrace[inline]  + t \lparen[inline] \colorC \lbrace[inline] x_2 \rbrace[inline] -\colorB \lbrace[inline] x_1 \rbrace[inline]  \rparen[inline]  \\ \colorC \lbrace[inline] x_2 \rbrace[inline]  + t \lparen[inline] \colorC \lbrace[inline] x_2 \rbrace[inline] -\colorB \lbrace[inline] x_1 \rbrace[inline]  \rparen[inline]  \\ x_3 + t \lparen[inline] \colorC \lbrace[inline] x_2 \rbrace[inline] -\colorB \lbrace[inline] x_1 \rbrace[inline]  \rparen[inline]  \end \lbrace[inline] bmatrix \rbrace[inline]
      }
      \p{That is}
      \equation{
         L &= \colorB \lbrace[inline] P_1 \rbrace[inline]  + t\cdot\colorA \lbrace[inline] \overrightarrow \lbrace[inline] \Delta\mathsf \lbrace[inline] v \rbrace[inline]  \rbrace[inline]  \rbrace[inline] \\
                     \begin \lbrace[inline] bmatrix \rbrace[inline]  x \\ y \\ z \end \lbrace[inline] bmatrix \rbrace[inline]  &=
                     \begin \lbrace[inline] bmatrix \rbrace[inline]  \colorB \lbrace[inline] x_1 \rbrace[inline]  + t\;\colorA \lbrace[inline] \Delta_x \rbrace[inline]  \\ \colorB \lbrace[inline] y_1 \rbrace[inline]  + t\;\colorA \lbrace[inline] \Delta_y \rbrace[inline]  \\ \colorB \lbrace[inline] z_1 \rbrace[inline]  + t\;\colorA \lbrace[inline] \Delta_z \rbrace[inline]  \end \lbrace[inline] bmatrix \rbrace[inline] 
                         = \begin \lbrace[inline] bmatrix \rbrace[inline]  \colorB \lbrace[inline] x_1 \rbrace[inline]  + t \lparen[inline] \colorC \lbrace[inline] x_2 \rbrace[inline] -\colorB \lbrace[inline] x_1 \rbrace[inline]  \rparen[inline]  \\ \colorB \lbrace[inline] y_1 \rbrace[inline]  + t \lparen[inline] \colorC \lbrace[inline] y_2 \rbrace[inline] -\colorB \lbrace[inline] y_1 \rbrace[inline]  \rparen[inline]  \\ \colorB \lbrace[inline] z_1 \rbrace[inline]  + t \lparen[inline] \colorC \lbrace[inline] z_2 \rbrace[inline] -\colorB \lbrace[inline] z_1 \rbrace[inline]  \rparen[inline]  \end \lbrace[inline] bmatrix \rbrace[inline]
      }
   }
   \grid{
      \note[boxed]{
         \h3{Parametric Equation of a Line}
         \equation{
            \underbrace \lbrace[inline] \begin \lbrace[inline] split \rbrace[inline] 
                                x &= \colorB \lbrace[inline] x_1 \rbrace[inline]  + t \lparen[inline] \colorC \lbrace[inline] x_2 \rbrace[inline] -\colorB \lbrace[inline] x_1 \rbrace[inline]  \rparen[inline]  = \colorB \lbrace[inline] x_1 \rbrace[inline]  + t\;\colorA \lbrace[inline] \Delta_x \rbrace[inline] \\
                                y &= \colorB \lbrace[inline] x_1 \rbrace[inline]  + t \lparen[inline] \colorC \lbrace[inline] y_2 \rbrace[inline] -\colorB \lbrace[inline] y_1 \rbrace[inline]  \rparen[inline]  = \colorB \lbrace[inline] y_1 \rbrace[inline]  + t\;\colorA \lbrace[inline] \Delta_y \rbrace[inline] \\
                                z &= \colorB \lbrace[inline] x_1 \rbrace[inline]  + t \lparen[inline] \colorC \lbrace[inline] z_2 \rbrace[inline] -\colorB \lbrace[inline] z_1 \rbrace[inline]  \rparen[inline]  = \colorB \lbrace[inline] z_1 \rbrace[inline]  + t\;\colorA \lbrace[inline] \Delta_z \rbrace[inline] 
                            \end \lbrace[inline] split \rbrace[inline]  \rbrace[inline] _ \lbrace[inline] 
                                r \;=\; r_0 \;+\; a \;=\; r_0 \;+\; t\,v
                             \rbrace[inline]
         }
      }
      \note[boxed]{
         \h3{Essentially}
         \equation{
            L &= \colorB \lbrace[inline] P_1 \rbrace[inline]  + t\cdot\colorA \lbrace[inline] \overrightarrow \lbrace[inline] \Delta\mathsf \lbrace[inline] v \rbrace[inline]  \rbrace[inline]  \rbrace[inline] \;\;\forall t\in\mathbb \lbrace[inline] R \rbrace[inline]
         }
         \p{That is, \{t} is the scaling factor. In a way, it's like it's a function of \{t}, but also similar to the slope (\{m}) in \{y = mx + b}, except \{m} (i.e. \{t}) is parameterized.}
         \hr\p{Sometimes this will be (confusingly) denoted as}
         \equation{
            \vec \lbrace[inline] r \rbrace[inline]  &= \vec \lbrace[inline] r_0 \rbrace[inline]  + \vec \lbrace[inline] a \rbrace[inline]  = \vec \lbrace[inline] r_0 \rbrace[inline]  + t\vec \lbrace[inline] v \rbrace[inline] \\
         }
      }
   }\note[boxed]{
      \h3{Symmetric Equation of a Line}
      \equation{
         t &= \frac \lbrace[inline] x - \colorB \lbrace[inline] x_1 \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \colorC \lbrace[inline] x_2 \rbrace[inline] -\colorB \lbrace[inline] x_1 \rbrace[inline]  \rbrace[inline]  = \frac \lbrace[inline] x - \colorB \lbrace[inline] x_1 \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \colorA \lbrace[inline] \Delta_x \rbrace[inline]  \rbrace[inline] \\
                     t &= \frac \lbrace[inline] y - \colorB \lbrace[inline] y_1 \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \colorC \lbrace[inline] y_2 \rbrace[inline] -\colorB \lbrace[inline] y_1 \rbrace[inline]  \rbrace[inline]  = \frac \lbrace[inline] y - \colorB \lbrace[inline] y_1 \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \colorA \lbrace[inline] \Delta_y \rbrace[inline]  \rbrace[inline] \\
                     t &= \frac \lbrace[inline] z - \colorB \lbrace[inline] z_1 \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \colorC \lbrace[inline] z_2 \rbrace[inline] -\colorB \lbrace[inline] z_1 \rbrace[inline]  \rbrace[inline]  = \frac \lbrace[inline] z - \colorB \lbrace[inline] z_1 \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \colorA \lbrace[inline] \Delta_z \rbrace[inline]  \rbrace[inline]
      }
      \p{Therefore}
      \equation{
         \frac \lbrace[inline] x - \colorB \lbrace[inline] x_1 \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \colorA \lbrace[inline] \Delta_x \rbrace[inline]  \rbrace[inline] 
                        &= \frac \lbrace[inline] y - \colorB \lbrace[inline] y_1 \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \colorA \lbrace[inline] \Delta_y \rbrace[inline]  \rbrace[inline] 
                         = \frac \lbrace[inline] z - \colorB \lbrace[inline] z_1 \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \colorA \lbrace[inline] \Delta_z \rbrace[inline]  \rbrace[inline] 
                     \\\\
                           \frac \lbrace[inline] x - \colorB \lbrace[inline] x_1 \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \colorC \lbrace[inline] x_2 \rbrace[inline] -\colorB \lbrace[inline] x_1 \rbrace[inline]  \rbrace[inline] 
                        &= \frac \lbrace[inline] y - \colorB \lbrace[inline] y_1 \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \colorC \lbrace[inline] y_2 \rbrace[inline] -\colorB \lbrace[inline] y_1 \rbrace[inline]  \rbrace[inline] 
                        =  \frac \lbrace[inline] z - \colorB \lbrace[inline] z_1 \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \colorC \lbrace[inline] z_2 \rbrace[inline] -\colorB \lbrace[inline] z_1 \rbrace[inline]  \rbrace[inline]
      }
      \hr\h4{Rationale}
      \p{We rewrite \{r = r_0 + a = r_0 + t v} in terms of \{t}.}
      \p{That is}
      \equation{
         x &= \colorB \lbrace[inline] x_1 \rbrace[inline]  + t \lparen[inline] \colorC \lbrace[inline] x_2 \rbrace[inline] -\colorB \lbrace[inline] x_1 \rbrace[inline]  \rparen[inline]  = \colorB \lbrace[inline] x_1 \rbrace[inline]  + t\;\colorA \lbrace[inline] \Delta_x \rbrace[inline] \\
                     t\;\colorA \lbrace[inline] \Delta_x \rbrace[inline]   &= x - \colorB \lbrace[inline] x_1 \rbrace[inline]  = t \lparen[inline] \colorC \lbrace[inline] x_2 \rbrace[inline] -\colorB \lbrace[inline] x_1 \rbrace[inline]  \rparen[inline] \\
                     t &= \frac \lbrace[inline] x - \colorB \lbrace[inline] x_1 \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \colorC \lbrace[inline] x_2 \rbrace[inline] -\colorB \lbrace[inline] x_1 \rbrace[inline]  \rbrace[inline]  = \frac \lbrace[inline] x - \colorB \lbrace[inline] x_1 \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \colorA \lbrace[inline] \Delta_x \rbrace[inline]  \rbrace[inline]  \\\\
                     y &= \colorB \lbrace[inline] y_1 \rbrace[inline]  + t \lparen[inline] \colorC \lbrace[inline] y_2 \rbrace[inline] -\colorB \lbrace[inline] y_1 \rbrace[inline]  \rparen[inline]  = \colorB \lbrace[inline] y_1 \rbrace[inline]  + t\;\colorA \lbrace[inline] \Delta_y \rbrace[inline] \\
                     t\;\colorA \lbrace[inline] \Delta_y \rbrace[inline]   &= y - \colorB \lbrace[inline] y_1 \rbrace[inline]  = t \lparen[inline] \colorC \lbrace[inline] y_2 \rbrace[inline] -\colorB \lbrace[inline] y_1 \rbrace[inline]  \rparen[inline] \\
                     t &= \frac \lbrace[inline] y - \colorB \lbrace[inline] y_1 \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \colorC \lbrace[inline] y_2 \rbrace[inline] -\colorB \lbrace[inline] y_1 \rbrace[inline]  \rbrace[inline]  = \frac \lbrace[inline] y - \colorB \lbrace[inline] y_1 \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \colorA \lbrace[inline] \Delta_y \rbrace[inline]  \rbrace[inline]  \\\\
                     z &= \colorB \lbrace[inline] z_1 \rbrace[inline]  + t \lparen[inline] \colorC \lbrace[inline] z_2 \rbrace[inline] -\colorB \lbrace[inline] z_1 \rbrace[inline]  \rparen[inline]  = \colorB \lbrace[inline] z_1 \rbrace[inline]  + t\;\colorA \lbrace[inline] \Delta_z \rbrace[inline] \\
                     t\;\colorA \lbrace[inline] \Delta_z \rbrace[inline]  &= z - \colorB \lbrace[inline] z_1 \rbrace[inline]  = t \lparen[inline] \colorC \lbrace[inline] z_2 \rbrace[inline] -\colorB \lbrace[inline] z_1 \rbrace[inline]  \rparen[inline]  \\
                     t &= \frac \lbrace[inline] z - \colorB \lbrace[inline] z_1 \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \colorC \lbrace[inline] z_2 \rbrace[inline] -\colorB \lbrace[inline] z_1 \rbrace[inline]  \rbrace[inline]  = \frac \lbrace[inline] z - \colorB \lbrace[inline] z_1 \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \colorA \lbrace[inline] \Delta_z \rbrace[inline]  \rbrace[inline]
      }
   }
}
\h2{Parameterizations of a curve}

\dl{\dt{Parametrized curve}\dd{A curve in the plane is said to be parameterized if the set of coordinates on the curve, (x,y), are represented as functions of a variable t.}\dd{A parametrized Curve is a path in the xy-plane traced out by the point \{\left \lparen[inline] x \lparen[inline] t \rparen[inline] , y \lparen[inline] t \rparen[inline] \right \rparen[inline]} as the parameter \{t} ranges over an interval \{I}.}\dd{A parametrized Curve is a path in the xyz-plane traced out by the point \{\left \lparen[inline] x \lparen[inline] t \rparen[inline] , y \lparen[inline] t \rparen[inline] , z \lparen[inline] t \rparen[inline] \right \rparen[inline]} as the parameter \{t} ranges over an interval \{I}.}}
\h2{Curvature Properties}

\grid[col="3"]{
   \note[boxed]{
      \h3{Length of a Curve}
      \math{
         \newcommand \lbrace[inline] \Long \rbrace[inline]  \lbrace[inline] 
                         \int_a^b \sqrt \lbrace[inline] 
                             \left \lparen[inline] f^\prime \lparen[inline] t \rparen[inline] \right \rparen[inline] ^2
                             \left \lparen[inline] g^\prime \lparen[inline] t \rparen[inline] \right \rparen[inline] ^2
                             \left \lparen[inline] h^\prime \lparen[inline] t \rparen[inline] \right \rparen[inline] ^2
                          \rbrace[inline] 
                      \rbrace[inline] 
                     \newcommand \lbrace[inline] \AltLong \rbrace[inline]  \lbrace[inline] 
                         \int_a^b \sqrt \lbrace[inline] 
                             \left \lparen[inline] \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] x \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] t \rbrace[inline] \right \rparen[inline] ^2
                             \left \lparen[inline] \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] y \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] t \rbrace[inline] \right \rparen[inline] ^2
                             \left \lparen[inline] \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] z \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] t \rbrace[inline] \right \rparen[inline] ^2
                          \rbrace[inline] 
                      \rbrace[inline] 
                     \newcommand \lbrace[inline] \short \rbrace[inline]  \lbrace[inline] 
                         \int_a^b ||\left \lparen[inline] r^\prime \lparen[inline] t \rparen[inline] \right \rparen[inline] ||
                      \rbrace[inline] 
                     \begin \lbrace[inline] equation \rbrace[inline] 
                     \begin \lbrace[inline] split \rbrace[inline] 
                         L &= \Long\\
                           &= \AltLong\\
                           &= \short\\
                           &\implies \text \lbrace[inline] some constant \rbrace[inline] 
                     \end \lbrace[inline] split \rbrace[inline] 
                     \end \lbrace[inline] equation \rbrace[inline]
      }
   }
   \note[boxed]{
      \h3{The Arc Length Function}
      \p{Suppose}
      \ul{
         \li{\p{Given some curve \{C} defined by some vector \{\vec \lbrace[inline] r \rbrace[inline]} in \{\mathbb \lbrace[inline] R \rbrace[inline] ^3}}}
         \li{\p{where \{r^\prime} is continuous and \{C} is traversed exactly once as \{t} increases from \{a} to \{b}}}
      }\p{We can define it's arc length function VIA}
      \math{
         \newcommand \lbrace[inline] \Long \rbrace[inline]  \lbrace[inline] 
                         \int_a^t \sqrt \lbrace[inline] 
                             \left \lparen[inline] f^\prime \lparen[inline] u \rparen[inline] \right \rparen[inline] ^2
                             \left \lparen[inline] g^\prime \lparen[inline] u \rparen[inline] \right \rparen[inline] ^2
                             \left \lparen[inline] h^\prime \lparen[inline] u \rparen[inline] \right \rparen[inline] ^2
                          \rbrace[inline] 
                      \rbrace[inline] 
                     \newcommand \lbrace[inline] \AltLong \rbrace[inline]  \lbrace[inline] 
                         \int_a^t \sqrt \lbrace[inline] 
                             \left \lparen[inline] \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] x \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] u \rbrace[inline] \right \rparen[inline] ^2
                             \left \lparen[inline] \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] y \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] u \rbrace[inline] \right \rparen[inline] ^2
                             \left \lparen[inline] \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] z \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] u \rbrace[inline] \right \rparen[inline] ^2
                          \rbrace[inline] 
                      \rbrace[inline] 
                     \newcommand \lbrace[inline] \short \rbrace[inline]  \lbrace[inline] 
                         \int_a^t ||\left \lparen[inline] r^\prime \lparen[inline] u \rparen[inline] \right \rparen[inline] ||
                      \rbrace[inline] 
                     \begin \lbrace[inline] equation \rbrace[inline] 
                     \begin \lbrace[inline] split \rbrace[inline] 
                         S \lparen[inline] t \rparen[inline] 
                             &= \Long\\
                             &= \AltLong\\
                             &= \short
                     \end \lbrace[inline] split \rbrace[inline] 
                     \end \lbrace[inline] equation \rbrace[inline]
      }
   }
}
\h1{Limits}

\grid[col="2"]{
   \note[boxed]{
      \h2{L’Hospital’s Rule}
      \equation{
         \lim_ \lbrace[inline] x\to \lbrace[inline] a \rbrace[inline]  \rbrace[inline] \frac \lbrace[inline] f \lparen[inline] x \rparen[inline]  \rbrace[inline]  \lbrace[inline] g \lparen[inline] x \rparen[inline]  \rbrace[inline]  &= \lim_ \lbrace[inline] x\to \lbrace[inline] a \rbrace[inline]  \rbrace[inline] \frac \lbrace[inline] f^\prime \lparen[inline] x \rparen[inline]  \rbrace[inline]  \lbrace[inline] g^\prime \lparen[inline] x \rparen[inline]  \rbrace[inline] \\
                     \text \lbrace[inline] if \rbrace[inline] \;\lim_ \lbrace[inline] x\to \lbrace[inline] a \rbrace[inline]  \rbrace[inline] \frac \lbrace[inline] f \lparen[inline] x \rparen[inline]  \rbrace[inline]  \lbrace[inline] g \lparen[inline] x \rparen[inline]  \rbrace[inline]  = \frac \lbrace[inline] 0 \rbrace[inline]  \lbrace[inline] 0 \rbrace[inline] 
                     \;&\text \lbrace[inline] or \rbrace[inline] \;\lim_ \lbrace[inline] x\to \lbrace[inline] a \rbrace[inline]  \rbrace[inline] \frac \lbrace[inline] f \lparen[inline] x \rparen[inline]  \rbrace[inline]  \lbrace[inline] g \lparen[inline] x \rparen[inline]  \rbrace[inline]  = \frac \lbrace[inline] \infty \rbrace[inline]  \lbrace[inline] \infty \rbrace[inline]
      }
      \p{In other words, if L’Hospital’s Rule applies to indeterminate forms.}
   }
}
\h2{Limit Laws}

\grid[col="3"]{
   \equation{
      \lim_ \lbrace[inline] x \to a \rbrace[inline]  \Big \lbrack[inline]  f \lparen[inline] x \rparen[inline]  + g \lparen[inline] x \rparen[inline]  \Big \rbrack[inline]  &= \lim_ \lbrace[inline] x \to a \rbrace[inline]  f \lparen[inline] x \rparen[inline]  + \lim_ \lbrace[inline] x \to a \rbrace[inline]  g \lparen[inline] x \rparen[inline]
   }
   \equation{
      \lim_ \lbrace[inline] x \to a \rbrace[inline]  \Big \lbrack[inline]  f \lparen[inline] x \rparen[inline]  - g \lparen[inline] x \rparen[inline]  \Big \rbrack[inline]  &= \lim_ \lbrace[inline] x \to a \rbrace[inline]  f \lparen[inline] x \rparen[inline]  - \lim_ \lbrace[inline] x \to a \rbrace[inline]  g \lparen[inline] x \rparen[inline]
   }
   \equation{
      \lim_ \lbrace[inline] x \to a \rbrace[inline]  \Big \lbrack[inline]  c \cdot f \lparen[inline] x \rparen[inline]  \Big \rbrack[inline]  &= c \cdot \lim_ \lbrace[inline] x \to a \rbrace[inline]  f \lparen[inline] x \rparen[inline]
   }
   \equation{
      \lim_ \lbrace[inline] x \to a \rbrace[inline]  \Big \lbrack[inline]  f \lparen[inline] x \rparen[inline]  \cdot g \lparen[inline] x \rparen[inline]  \Big \rbrack[inline]  &= \lim_ \lbrace[inline] x \to a \rbrace[inline]  f \lparen[inline] x \rparen[inline]  \cdot \lim_ \lbrace[inline] x \to a \rbrace[inline]  g \lparen[inline] x \rparen[inline]
   }
   \equation{
      \lim_ \lbrace[inline] x \to a \rbrace[inline]  \frac \lbrace[inline] f \lparen[inline] x \rparen[inline]  \rbrace[inline]  \lbrace[inline] g \lparen[inline] x \rparen[inline]  \rbrace[inline]  &= \frac \lbrace[inline] \lim_ \lbrace[inline] x \to a \rbrace[inline]  f \lparen[inline] x \rparen[inline]  \rbrace[inline]  \lbrace[inline] \lim_ \lbrace[inline] x \to a \rbrace[inline] g \lparen[inline] x \rparen[inline]  \rbrace[inline]  \; \text \lbrace[inline] if \rbrace[inline]  \lim_ \lbrace[inline] x \to a \rbrace[inline] g \lparen[inline] x \rparen[inline]  \neq 0
   }
   \equation{
      \lim_ \lbrace[inline] x \to a \rbrace[inline]  \Big \lbrack[inline]  f \lparen[inline] x \rparen[inline]  \Big \rbrack[inline] ^n = \Big \lbrack[inline]  \lim_ \lbrace[inline] x \to a \rbrace[inline]  f \lparen[inline] x \rparen[inline]  \Big \rbrack[inline] ^n\;\text \lbrace[inline] if \rbrace[inline] \;n\in\mathbb \lbrace[inline] Z \rbrace[inline] ^+
   }
   \equation{
      \underbrace \lbrace[inline] \lim_ \lbrace[inline] x \to a \rbrace[inline]  \sqrt \lbrack[inline] n \rbrack[inline]  \lbrace[inline] f \lparen[inline] x \rparen[inline]  \rbrace[inline]  = \sqrt \lbrack[inline] n \rbrack[inline]  \lbrace[inline] \lim_ \lbrace[inline] x \to a \rbrace[inline]  f \lparen[inline] x \rparen[inline]  \rbrace[inline] \;\text \lbrace[inline] if \rbrace[inline] \;n\in\mathbb \lbrace[inline] Z \rbrace[inline] ^+ \rbrace[inline] _ \lbrace[inline] \text \lbrace[inline] if $n$ is even we assume $\lim_ \lbrace[inline] x \to a \rbrace[inline]  f \lparen[inline] x \rparen[inline]  > 0$ \rbrace[inline]  \rbrace[inline]
   }
   \equation{
      \lim_ \lbrace[inline] x\to \lbrace[inline] c \rbrace[inline]  \rbrace[inline] \, \left \lparen[inline] f \circ g\right \rparen[inline]  \lparen[inline] x \rparen[inline]  &= f\left \lparen[inline] \lim_ \lbrace[inline] x\to \lbrace[inline] c \rbrace[inline]  \rbrace[inline] \, g \lparen[inline] x \rparen[inline] \right \rparen[inline]
   }
}
\h2{Limit Formulas}

\grid[col="3"]{
   \equation{
      \lim_ \lbrace[inline] x\to\infty \rbrace[inline]  \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] x^r \rbrace[inline]  &= 0\;,\;\forall r > 0
   }
   \equation{
      \lim_ \lbrace[inline] x\to\infty \rbrace[inline]  \frac \lbrace[inline] x^n \rbrace[inline]  \lbrace[inline] !n \rbrace[inline]  &= 0\;,\;\forall n \in \mathbb \lbrace[inline] R \rbrace[inline]
   }
}
\h2{Growth Rates}

\ol{
   \li{\u{Factorial functions} grow faster than \u{exponential functions}.}
   \li{\u{Exponential functions} grow faster than \u{polynomials}.}
}
\h1{Calculus}

\note{
   \h2{Derivative Tables}
   \grid[col="3", boxed]{
      \equation{
         \delta\sin \lparen[inline] x \rparen[inline]  &= \cos \lparen[inline] x \rparen[inline]  \\
                     \delta\csc \lparen[inline] x \rparen[inline]  &= -\cot \lparen[inline] x \rparen[inline]  \cdot \csc \lparen[inline] x \rparen[inline]
      }
      \equation{
         \delta\cos \lparen[inline] x \rparen[inline]  &= -\sin \lparen[inline] x \rparen[inline]  \\
                     \delta\sec \lparen[inline] x \rparen[inline]  &= \tan \lparen[inline] x \rparen[inline]  \cdot \sec \lparen[inline] x \rparen[inline]
      }
      \equation{
         \delta\tan \lparen[inline] x \rparen[inline]  &= \sec^2 \lparen[inline] x \rparen[inline]  \\
                     \delta\cot \lparen[inline] x \rparen[inline]  &= -\csc^2 \lparen[inline] x \rparen[inline]
      }
   }\grid[boxed, col="3"]{
      \equation{
         \delta\sin^ \lbrace[inline] -1 \rbrace[inline]  \lparen[inline] x \rparen[inline]  &= \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] \sqrt \lbrace[inline] 1 - x^2 \rbrace[inline]  \rbrace[inline]
      }
      \equation{
         \delta\cos^ \lbrace[inline] -1 \rbrace[inline]  \lparen[inline] x \rparen[inline]  &= -\frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] \sqrt \lbrace[inline] 1 - x^2 \rbrace[inline]  \rbrace[inline]
      }
      \equation{
         \delta\tan^ \lbrace[inline] -1 \rbrace[inline]  \lparen[inline] x \rparen[inline]  &= \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] 1 + x^2 \rbrace[inline]
      }
   }
}

\note{
   \h2{Integration Tables}
   \grid[col="3", boxed]{
      \equation{
         \int\sin \lparen[inline] x \rparen[inline] \;\mathrm \lbrace[inline] d \rbrace[inline] x &= -\cos x \\
                     \int\csc^2 \lparen[inline] x \rparen[inline] \;\mathrm \lbrace[inline] d \rbrace[inline] x &= -\cot x \\
                     \int\csc \lparen[inline] x \rparen[inline] \cdot\cot \lparen[inline] x \rparen[inline] \;\mathrm \lbrace[inline] d \rbrace[inline] x &= -\csc x \\
                     \int\csc \lparen[inline] x \rparen[inline] \;\mathrm \lbrace[inline] d \rbrace[inline] x &= \ln\left|\csc x - \cot x\right| \\
                     \int\sinh \lparen[inline] x \rparen[inline] \;\mathrm \lbrace[inline] d \rbrace[inline] x &= \cosh \lparen[inline] x \rparen[inline]  \\
      }
      \equation{
         \int\cos \lparen[inline] x \rparen[inline] \;\mathrm \lbrace[inline] d \rbrace[inline] x &= \sin x \\
                     \int\sec^2 \lparen[inline] x \rparen[inline] \;\mathrm \lbrace[inline] d \rbrace[inline] x &= \tan x \\
                     \int\sec \lparen[inline] x \rparen[inline] \cdot\tan \lparen[inline] x \rparen[inline] \;\mathrm \lbrace[inline] d \rbrace[inline] x &= \sec x \\
                     \int\sec \lparen[inline] x \rparen[inline] \;\mathrm \lbrace[inline] d \rbrace[inline] x &= \ln\left|\sec x + \tan x\right| \\
                     \int\cosh \lparen[inline] x \rparen[inline] \;\mathrm \lbrace[inline] d \rbrace[inline] x &= \sinh \lparen[inline] x \rparen[inline]  \\
      }
      \equation{
         \int\tan \lparen[inline] x \rparen[inline] \;\mathrm \lbrace[inline] d \rbrace[inline] x &= \ln| \sec x | \\
                     \int\cot \lparen[inline] x \rparen[inline] \;\mathrm \lbrace[inline] d \rbrace[inline] x &= \ln| \sin x | \\
      }
   }\grid[col="3", boxed]{
      \equation{
         \int b^x\;\mathrm \lbrace[inline] d \rbrace[inline] x &= \frac \lbrace[inline] b^x \rbrace[inline]  \lbrace[inline] \ln \lparen[inline] b \rparen[inline]  \rbrace[inline]
      }
      \equation{
         \int\frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] x^2 + a^2 \rbrace[inline] \;\mathrm \lbrace[inline] d \rbrace[inline] x &= \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] a \rbrace[inline] \tan^ \lbrace[inline] -1 \rbrace[inline] \left \lparen[inline] \frac \lbrace[inline] x \rbrace[inline]  \lbrace[inline] a \rbrace[inline] \right \rparen[inline]
      }
      \equation{
         \int\frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] x^2 - a^2 \rbrace[inline] \;\mathrm \lbrace[inline] d \rbrace[inline] x &= \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] 2a \rbrace[inline] \ln\left|\frac \lbrace[inline] x-a \rbrace[inline]  \lbrace[inline] x+a \rbrace[inline] \right|
      }
      \equation{
         \int\frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] \sqrt \lbrace[inline] a^2 - x^2 \rbrace[inline]  \rbrace[inline] \;\mathrm \lbrace[inline] d \rbrace[inline] x &= \sin^ \lbrace[inline] -1 \rbrace[inline] \left \lparen[inline] \frac \lbrace[inline] x \rbrace[inline]  \lbrace[inline] a \rbrace[inline] \right \rparen[inline] ,\;a>0
      }
      \equation{
         \int\frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] \sqrt \lbrace[inline] x^2 \pm a^2 \rbrace[inline]  \rbrace[inline] \;\mathrm \lbrace[inline] d \rbrace[inline] x &= \ln\left|x+\sqrt \lbrace[inline] x^2\pm a^2 \rbrace[inline] \right|
      }
   }
}

\note[boxed]{
   \h2{Riemann Sums}
   \p[center]{Given}
   \equation{
      A &= \int_ \lbrace[inline] a \rbrace[inline] ^ \lbrace[inline] b \rbrace[inline]  f \lparen[inline] x \rparen[inline]  = \lim_ \lbrace[inline] n\to\infty \rbrace[inline] \sum_ \lbrace[inline] i=1 \rbrace[inline] ^ \lbrace[inline] n \rbrace[inline]  \Delta \lbrace[inline] x \rbrace[inline]  \cdot f \lparen[inline] x \rparen[inline]  \;\text \lbrace[inline] where \rbrace[inline] \;
                  \left\ \lbrace[inline] \begin \lbrace[inline] array \rbrace[inline]  \lbrace[inline] ll \rbrace[inline] 
                      \Delta \lbrace[inline] x \rbrace[inline]  = \frac \lbrace[inline] b - a \rbrace[inline]  \lbrace[inline] n \rbrace[inline] 
                  \end \lbrace[inline] array \rbrace[inline] \right.
   }
   \grid[col="2"]{
      \note[boxed]{
         \h3{Left Riemann Sum}
         \equation{
            A &= \int_ \lbrace[inline] a \rbrace[inline] ^ \lbrace[inline] b \rbrace[inline]  f \lparen[inline] x \rparen[inline]  \;\mathrm \lbrace[inline] d \rbrace[inline] x \approx L_n = \sum_ \lbrace[inline] i = 0 \rbrace[inline] ^ \lbrace[inline] n-1 \rbrace[inline] \, \Delta \lbrace[inline] x \rbrace[inline] \cdot f\left \lparen[inline] a + i\cdot\Delta \lbrace[inline] x \rbrace[inline] \right \rparen[inline]
         }
      }
      \note[boxed]{
         \h3{Right Riemann Sum}
         \equation{
            A &= \int_ \lbrace[inline] a \rbrace[inline] ^ \lbrace[inline] b \rbrace[inline]  f \lparen[inline] x \rparen[inline]  \;\mathrm \lbrace[inline] d \rbrace[inline] x \approx R_n = \sum_ \lbrace[inline] i = 1 \rbrace[inline] ^ \lbrace[inline] n \rbrace[inline] \, \Delta \lbrace[inline] x \rbrace[inline] \cdot f\left \lparen[inline] a + i\cdot\Delta \lbrace[inline] x \rbrace[inline] \right \rparen[inline]
         }
      }
   }\note[boxed]{
      \h3{Midpoint Riemann Sum}
      \math{
         \newcommand \lbrace[inline] \generalFormat \rbrace[inline]  \lbrace[inline] 
                         \sum_ \lbrace[inline] \small \lbrace[inline] \cdots \rbrace[inline]  \rbrace[inline] ^ \lbrace[inline] \small \lbrace[inline] \cdots \rbrace[inline]  \rbrace[inline] \, \Delta \lbrace[inline] x \rbrace[inline] \cdot f\left \lparen[inline] a + \text \lbrace[inline] “avg. of $x_i$ and $x_ \lbrace[inline] i-1 \rbrace[inline] $” \rbrace[inline]  \cdot \Delta \lbrace[inline] x \rbrace[inline] \right \rparen[inline] 
                      \rbrace[inline] 
                     \newcommand \lbrace[inline] \SigmaExampleOne \rbrace[inline]  \lbrace[inline] 
                         \sum_ \lbrace[inline] i = 1 \rbrace[inline] ^ \lbrace[inline] n \rbrace[inline] \, \Delta \lbrace[inline] x \rbrace[inline] \cdot f\left \lparen[inline] a + \frac \lbrace[inline] x_ \lbrace[inline] i - 1 \rbrace[inline]  + x_i \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline]  \cdot \Delta \lbrace[inline] x \rbrace[inline] \right \rparen[inline] 
                      \rbrace[inline] 
                     \newcommand \lbrace[inline] \SigmaExampleTwo \rbrace[inline]  \lbrace[inline] 
                         \sum_ \lbrace[inline] i = 0 \rbrace[inline] ^ \lbrace[inline] n-1 \rbrace[inline] \, \Delta \lbrace[inline] x \rbrace[inline] \cdot f\left \lparen[inline] a + \frac \lbrace[inline] x_ \lbrace[inline] i + 1 \rbrace[inline]  + x_i \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline]  \cdot \Delta \lbrace[inline] x \rbrace[inline] \right \rparen[inline] 
                      \rbrace[inline] 
                     \begin \lbrace[inline] equation \rbrace[inline] 
                     \begin \lbrace[inline] split \rbrace[inline] 
                         A = \int_ \lbrace[inline] a \rbrace[inline] ^ \lbrace[inline] b \rbrace[inline]  f \lparen[inline] x \rparen[inline]  \;\mathrm \lbrace[inline] d \rbrace[inline] x &\approx \generalFormat\\
                             &\approx \SigmaExampleOne\\
                             \text \lbrace[inline] or alternatively \rbrace[inline] &\\
                             A &\approx \SigmaExampleTwo
                     \end \lbrace[inline] split \rbrace[inline] 
                     \end \lbrace[inline] equation \rbrace[inline]
      }\hr\p[center]{We can also do away with the index notation and simplify things.}
      \math{
         \newcommand \lbrace[inline] \SigmaExampleOne \rbrace[inline]  \lbrace[inline] 
                         \sum_ \lbrace[inline] i = 1 \rbrace[inline] ^ \lbrace[inline] n \rbrace[inline] \, \Delta \lbrace[inline] x \rbrace[inline] \cdot f\left \lparen[inline] a + \frac \lbrace[inline]  \lparen[inline] i - 1 \rparen[inline]  + i \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline]  \cdot \Delta \lbrace[inline] x \rbrace[inline] \right \rparen[inline]  =
                         \sum_ \lbrace[inline] i = 1 \rbrace[inline] ^ \lbrace[inline] n \rbrace[inline] \, \Delta \lbrace[inline] x \rbrace[inline] \cdot f\left \lparen[inline] a + \frac \lbrace[inline] 2i - 1 \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline]  \cdot \Delta \lbrace[inline] x \rbrace[inline] \right \rparen[inline] 
                      \rbrace[inline] 
                     \newcommand \lbrace[inline] \SigmaExampleTwo \rbrace[inline]  \lbrace[inline] 
                         \sum_ \lbrace[inline] i = 0 \rbrace[inline] ^ \lbrace[inline] n-1 \rbrace[inline] \, \Delta \lbrace[inline] x \rbrace[inline] \cdot f\left \lparen[inline] a + \frac \lbrace[inline]  \lparen[inline] i + 1 \rparen[inline]  + i \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline]  \cdot \Delta \lbrace[inline] x \rbrace[inline] \right \rparen[inline]  =
                         \sum_ \lbrace[inline] i = 0 \rbrace[inline] ^ \lbrace[inline] n-1 \rbrace[inline] \, \Delta \lbrace[inline] x \rbrace[inline] \cdot f\left \lparen[inline] a + \frac \lbrace[inline] 2i + 1 \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline]  \cdot \Delta \lbrace[inline] x \rbrace[inline] \right \rparen[inline] 
                      \rbrace[inline] 
                     \begin \lbrace[inline] equation \rbrace[inline] 
                     \begin \lbrace[inline] split \rbrace[inline] 
                         A = \int_ \lbrace[inline] a \rbrace[inline] ^ \lbrace[inline] b \rbrace[inline]  f \lparen[inline] x \rparen[inline]  \;\mathrm \lbrace[inline] d \rbrace[inline] x
                             &\approx \SigmaExampleOne\\
                             &\approx \SigmaExampleTwo
                     \end \lbrace[inline] split \rbrace[inline] 
                     \end \lbrace[inline] equation \rbrace[inline]
      }
   }
   \note[boxed]{
      \h3{Trapezoidal Riemann Sum}
      \math{
         \dots
      }
   }
   \note[boxed]{
      \h3{Simpson's Rule}
      \equation{
         \dots
      }
   }
}

\grid[col="2"]{
   \note{
      \h2{Improper Integrals}
      \equation{
         \text \lbrace[inline] Given \rbrace[inline] &\;L = \int_ \lbrace[inline] a \rbrace[inline] ^ \lbrace[inline] \infty \rbrace[inline]  f \lparen[inline] x \rparen[inline]  \;\mathrm \lbrace[inline] d \rbrace[inline] x = \lim_ \lbrace[inline] t\to\infty \rbrace[inline]  \int_ \lbrace[inline] a \rbrace[inline] ^ \lbrace[inline] \infty \rbrace[inline]  f \lparen[inline] x \rparen[inline]  \;\mathrm \lbrace[inline] d \rbrace[inline] x = \lim_ \lbrace[inline] t\to\infty \rbrace[inline]  F \lparen[inline] x \rparen[inline] \\
                     \text \lbrace[inline] If \rbrace[inline] &\;L\;\text \lbrace[inline] “exists” \rbrace[inline] \;\text \lbrace[inline] then $L$ is \rbrace[inline] \;\mathbf \lbrace[inline] \text \lbrace[inline] convergent \rbrace[inline]  \rbrace[inline] \\
                     \text \lbrace[inline] If \rbrace[inline] &\;L\;\text \lbrace[inline] “does not exists” \rbrace[inline] \;\text \lbrace[inline] then $L$ is \rbrace[inline] \;\mathbf \lbrace[inline] \text \lbrace[inline] divergent \rbrace[inline]  \rbrace[inline]
      }
   }
}
\h2{Infinite Sequences}

\grid[col="2"]{
   \note[boxed]{
      \h3{Infinite Sequence}
      \equation{
         \text \lbrace[inline] Given \rbrace[inline] &\\
                     &S_n = \ \lbrace[inline] a_n\ \rbrace[inline] _ \lbrace[inline] n=1 \rbrace[inline] ^ \lbrace[inline] \infty \rbrace[inline] \\
                     \text \lbrace[inline] Tests \rbrace[inline] &\\
                     &\text \lbrace[inline] If \rbrace[inline] \;\lim_ \lbrace[inline] n\to\infty \rbrace[inline] \,S_n \text \lbrace[inline] “exists” \rbrace[inline] \;\text \lbrace[inline] then \rbrace[inline] \;\mathbf \lbrace[inline] \text \lbrace[inline] $S_n$ is convergent \rbrace[inline]  \rbrace[inline] \\
                     &\text \lbrace[inline] If \rbrace[inline] \;\lim_ \lbrace[inline] n\to\infty \rbrace[inline] \,S_n \text \lbrace[inline] “does not exists” \rbrace[inline] \;\text \lbrace[inline] then \rbrace[inline] \;\mathbf \lbrace[inline] \text \lbrace[inline] $S_n$ is Divergent \rbrace[inline]  \rbrace[inline] \\
      }
   }
   \note[boxed]{
      \h3{Helpful Theorem}
      \equation{
         \text \lbrace[inline] If \rbrace[inline] &\\
                     \lim_ \lbrace[inline] x\to\infty \rbrace[inline] \,|a_n| &= 0\\
                     \text \lbrace[inline] Then \rbrace[inline] &\\
                     \lim_ \lbrace[inline] x\to\infty \rbrace[inline] \,a_n &= 0\\
      }
   }
   \note[boxed]{
      \h3{Example}
      \equation{
         \text \lbrace[inline] Given \rbrace[inline] \\
                     S_n &= \ \lbrace[inline] \cos\left \lparen[inline] \frac \lbrace[inline] n\pi \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline] \right \rparen[inline] \ \rbrace[inline] \\
                     L &=\lim_ \lbrace[inline] n\to\infty \rbrace[inline] \,\cos\left \lparen[inline] \frac \lbrace[inline] n\pi \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline] \right \rparen[inline] \\
                     &= \cos\left \lparen[inline] \lim_ \lbrace[inline] n\to\infty \rbrace[inline] \,\frac \lbrace[inline] n\pi \rbrace[inline]  \lbrace[inline] 2 \rbrace[inline] \right \rparen[inline]  \\
                     &= \cos\left \lparen[inline] \infty\right \rparen[inline]  \\
                     &= \text \lbrace[inline] undefined \rbrace[inline]  \\
                 \text \lbrace[inline] Therefore \rbrace[inline] \\
                 \therefore\;&\text \lbrace[inline] $S_n$ is Divergent \rbrace[inline] &
      }
   }
   \note[boxed]{
      \h3{Example}
      \equation{
         \text \lbrace[inline] Given \rbrace[inline] \\
                     S_n &= \ \lbrace[inline] \sin\left \lparen[inline] \frac \lbrace[inline] \pi \rbrace[inline]  \lbrace[inline] n \rbrace[inline] \right \rparen[inline] \ \rbrace[inline] \\
                     L &= \lim_ \lbrace[inline] n\to\infty \rbrace[inline] \,\sin\left \lparen[inline] \frac \lbrace[inline] \pi \rbrace[inline]  \lbrace[inline] n \rbrace[inline] \right \rparen[inline] \\
                         &= \sin\left \lparen[inline] \lim_ \lbrace[inline] n\to\infty \rbrace[inline] \,\frac \lbrace[inline] \pi \rbrace[inline]  \lbrace[inline] n \rbrace[inline] \right \rparen[inline]  \\
                         &= \sin\left \lparen[inline] 0\right \rparen[inline]  \\
                         &= 0\\
                 \text \lbrace[inline] Therefore \rbrace[inline] \\
                 \therefore\;&\text \lbrace[inline] $S_n$ is Convergent \rbrace[inline]
      }
   }
}
\h2{Infinite Series}

\grid[col="2"]{
   \note[boxed]{
      \h3{Infinite Series}
      \equation{
         \text \lbrace[inline] Given \rbrace[inline] &\\
                     &S_n = \sum_ \lbrace[inline] n = 1 \rbrace[inline] ^ \lbrace[inline] \infty \rbrace[inline] \,a_n\\
                     \text \lbrace[inline] Tests \rbrace[inline] &\\
                     &\text \lbrace[inline] If \rbrace[inline] \;\lim_ \lbrace[inline] n\to\infty \rbrace[inline] \,a_n = 0\;\text \lbrace[inline] then \rbrace[inline] \;\text \lbrace[inline] $S_n$ may be $\mathbf \lbrace[inline] \text \lbrace[inline] convergent \rbrace[inline]  \rbrace[inline] $ \rbrace[inline] \\
                     &\text \lbrace[inline] If \rbrace[inline] \;\lim_ \lbrace[inline] n\to\infty \rbrace[inline] \,a_n \neq 0\;\text \lbrace[inline] then \rbrace[inline] \;\mathbf \lbrace[inline] \text \lbrace[inline] $S_n$ is divergent \rbrace[inline]  \rbrace[inline] \\
                     &\text \lbrace[inline] If \rbrace[inline] \;\lim_ \lbrace[inline] n\to\infty \rbrace[inline] \,a_n \text \lbrace[inline] “does not exists” \rbrace[inline] \;\text \lbrace[inline] then \rbrace[inline] \;\mathbf \lbrace[inline] \text \lbrace[inline] $S_n$ is divergent \rbrace[inline]  \rbrace[inline] \\
      }
      \p{Note that the limit of every \b{convergent} series is equal to zero. But the inverse isn't always true. If the limit is equal to zero, it \u{may not be convergent}.}
      \p{For example, \{\sum_ \lbrace[inline] n=1 \rbrace[inline] ^\infty \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] n \rbrace[inline]} does diverge; \u{but it's limit is equal to zero}.}
      \note[inline]{
         \p{If the limit is equal to zero; the \u{test is \b{inconclusive}}.}
      }
   }
   \note[boxed]{
      \h3{Geometric Series}
      \equation{
         \text \lbrace[inline] Given \rbrace[inline] &\\
                     &S_n = \sum_ \lbrace[inline] n = 1 \rbrace[inline] ^ \lbrace[inline] \infty \rbrace[inline] \,a_n = \sum_ \lbrace[inline] n = 1 \rbrace[inline] ^ \lbrace[inline] \infty \rbrace[inline] \,a\cdot r^ \lbrace[inline] n - 1 \rbrace[inline] \;\text \lbrace[inline] where \rbrace[inline] \;
                             \left\ \lbrace[inline] \begin \lbrace[inline] array \rbrace[inline]  \lbrace[inline] ll \rbrace[inline] 
                             \begin \lbrace[inline] split \rbrace[inline] 
                             a &= a_1\\
                             r &= \frac \lbrace[inline] S_2 \rbrace[inline]  \lbrace[inline] S_1 \rbrace[inline] 
                             \end \lbrace[inline] split \rbrace[inline] 
                             \end \lbrace[inline] array \rbrace[inline] \right.\\
                     \text \lbrace[inline] Alternatively \rbrace[inline] &\\
                     &S_n = \sum_ \lbrace[inline] n=0 \rbrace[inline] ^ \lbrace[inline] \infty \rbrace[inline] \,a_n = \sum_ \lbrace[inline] n=0 \rbrace[inline] ^ \lbrace[inline] \infty \rbrace[inline] \,a\cdot r^ \lbrace[inline] n \rbrace[inline] \\
                     \text \lbrace[inline] Tests \rbrace[inline] &\\
                     &\text \lbrace[inline] If \rbrace[inline] \;|r|\geq \lbrace[inline] 1 \rbrace[inline] \;\text \lbrace[inline] then \rbrace[inline] \;\mathbf \lbrace[inline] \text \lbrace[inline] $S_n$ is divergent \rbrace[inline]  \rbrace[inline] \\
                     &\text \lbrace[inline] If \rbrace[inline] \;|r|<1\;\text \lbrace[inline] then \rbrace[inline] \;\mathbf \lbrace[inline] \text \lbrace[inline] $S_n$ is convergent \rbrace[inline]  \rbrace[inline] \\
                     \text \lbrace[inline] Furthermore \rbrace[inline] &\\
                     &\sum_ \lbrace[inline] n = 1 \rbrace[inline] ^ \lbrace[inline] \infty \rbrace[inline] \,a_n = \sum_ \lbrace[inline] n = 1 \rbrace[inline] ^ \lbrace[inline] \infty \rbrace[inline] \,a\cdot r^ \lbrace[inline] n - 1 \rbrace[inline]  = \frac \lbrace[inline] a \rbrace[inline]  \lbrace[inline] 1 - r \rbrace[inline] \;\text \lbrace[inline] for all \rbrace[inline] \;|r|<1
      }
   }
   \note[boxed]{
      \h3{The Integral Test}
      \equation{
         &\text \lbrace[inline] Given \rbrace[inline] \\
                     &\;\;\;\;a_n = f \lparen[inline] n \rparen[inline] \;\text \lbrace[inline] $\forall$n on \rbrace[inline] \; \lbrack[inline] 1,n \rparen[inline] \\
                     &\;\;\;\;S_n = \sum_ \lbrace[inline] n = 1 \rbrace[inline] ^ \lbrace[inline] \infty \rbrace[inline] \,a_n\\
                     &\;\;\;\;F \lparen[inline] x \rparen[inline]  = \int_ \lbrace[inline] 1 \rbrace[inline] ^ \lbrace[inline] \infty \rbrace[inline] f \lparen[inline] x \rparen[inline] \;\mathrm \lbrace[inline] d \rbrace[inline] x\\
                     &\text \lbrace[inline] Where \rbrace[inline] \\
                     &\;\;\;\;f \lparen[inline] x \rparen[inline]  > 0, \forall\,x\in\, \lbrack[inline] 1, \infty \rparen[inline] \\
                     &\;\;\;\;f^\prime \lparen[inline] x \rparen[inline]  < 0, \forall\,x\in\, \lbrack[inline] 1, \infty \rparen[inline] \\
                     &\text \lbrace[inline] Tests \rbrace[inline] \\
                     &\;\;\;\;\text \lbrace[inline] If $S_n$ convergent; then $F \lparen[inline] x \rparen[inline] $ is $\mathbf \lbrace[inline] convergent \rbrace[inline] $ \rbrace[inline] \\
                     &\;\;\;\;\text \lbrace[inline] If $S_n$ divergent; then $F \lparen[inline] x \rparen[inline] $ is $\mathbf \lbrace[inline] divergent \rbrace[inline] $ \rbrace[inline]
      }
      \note{
         \h4{Constraints on \{\lbrack[inline] 1,n \rparen[inline]}}
         \ul{
            \li{Continuous}
            \li{Positive}
            \li{Decreasing (i.e. use derivative test)}
         }
      }
   }
   \note[boxed, style="display: grid;"]{
      \h3{P-Series -or- Harmonic Series}
      \equation{
         &\text \lbrace[inline] Given \rbrace[inline] \\
                     &\;\;\;\;S_n=\sum_ \lbrace[inline] n=1 \rbrace[inline] ^ \lbrace[inline] \infty \rbrace[inline] \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] n^p \rbrace[inline] \\
                     &\text \lbrace[inline] Tests \rbrace[inline] \\
                     &\;\;\;\;\text \lbrace[inline] If $p>1$ then $S_n$ is $\mathbf \lbrace[inline] convergent \rbrace[inline] $ \rbrace[inline] \\
                     &\;\;\;\;\text \lbrace[inline] If $0 < p \leq \lbrace[inline] 1 \rbrace[inline] $ then $S_n$ is $\mathbf \lbrace[inline] divergent \rbrace[inline] $ \rbrace[inline]
      }
      \note[boxed, style="align-self: flex-end;"]{
         \p{Note: the \u{Harmonic series} is the special case where \{p=1}}
      }
   }
   \note[boxed]{
      \h3{Comparison Test}
      \equation{
         &\text \lbrace[inline] Given \rbrace[inline] \\
                     &\;\;\;\;A_n = \sum_ \lbrace[inline] n=1 \rbrace[inline] ^\infty\,a_n\\
                     &\;\;\;\;B_n = \sum_ \lbrace[inline] n=1 \rbrace[inline] ^\infty\,b_n\\
                     &\text \lbrace[inline] Where \rbrace[inline] \\
                     &\;\;\;\;a_n, b_n \geq 0\\
                     &\;\;\;\;a_n \leq b_n\\
                     &\text \lbrace[inline] Tests \rbrace[inline] \\
                     &\;\;\;\;\text \lbrace[inline] If $B_n$ converges $\implies A_n$ converges \rbrace[inline] \\
                     &\;\;\;\;\text \lbrace[inline] If $A_n$ diverges $\implies B_n$ diverges \rbrace[inline] \\
      }
   }
   \note[boxed]{
      \h3{Limit Comparison Test}
      \equation{
         &\text \lbrace[inline] Given \rbrace[inline] \\
                     &\;\;\;\;A_n = \sum_ \lbrace[inline] n=1 \rbrace[inline] ^\infty\,a_n\\
                     &\;\;\;\;B_n = \sum_ \lbrace[inline] n=1 \rbrace[inline] ^\infty\,b_n\\
                     &\;\;\;\; L = \lim_ \lbrace[inline] n\to\infty \rbrace[inline] \frac \lbrace[inline] a_n \rbrace[inline]  \lbrace[inline] b_n \rbrace[inline] \\
                     &\text \lbrace[inline] Where \rbrace[inline] \\
                     &\;\;\;\;L > 0,\;L \neq \pm \infty\\
                     &\text \lbrace[inline] Therefore either both converge or diverge \rbrace[inline] \\
                     &\;\;\;\;\text \lbrace[inline] $A_n$ converges $\Longleftrightarrow B_n$ converges \rbrace[inline] \\
                     &\;\;\;\;\text \lbrace[inline] $A_n$ diverges $\Longleftrightarrow B_n$ diverges \rbrace[inline]
      }
      \note{
         \h4{Warning}
         \ul{
            \li{If \{L > 0}, this only means that the limit comparison test \u{can be used}. You \u{still need to determine if either}\{A_n} or \{B_b} converges or diverges.}
            \li{Therefore, this does not apply to any arbitrary rational function.}
         }
      }
      \note{
         \h4{Notes}
         \ul{
            \li{For many series, we find a suitable comparison, \{B_n}, by keeping only the \u{highest powers in the numerator and denominator} of \{A_n}.}
         }
      }
   }
   \note[boxed]{
      \h3{Estimating Infinite Series}
      \equation{
         \cdots
      }
   }
}
\h2{Differential Equations}

\grid[col="2"]{
   \note[boxed]{
      \h3{Separable Differential Equations}
      \equation{
         \text \lbrace[inline] Given \rbrace[inline] \\
                     \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] y \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] x \rbrace[inline] 
                         &= g \lparen[inline] x \rparen[inline]  \cdot f \lparen[inline] y \rparen[inline] \\
                         &= \frac \lbrace[inline] g \lparen[inline] x \rparen[inline]  \rbrace[inline]  \lbrace[inline] \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] f \lparen[inline] y \rparen[inline]  \rbrace[inline]  \rbrace[inline] \\
                         &= \frac \lbrace[inline] g \lparen[inline] x \rparen[inline]  \rbrace[inline]  \lbrace[inline] h \lparen[inline] y \rparen[inline]  \rbrace[inline] \;\text \lbrace[inline] where \rbrace[inline] \;h \lparen[inline] x \rparen[inline]  = \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] f \lparen[inline] y \rparen[inline]  \rbrace[inline] \\
                     \\\text \lbrace[inline] Therefore  \lparen[inline] restated \rparen[inline]  \rbrace[inline] \\
                     \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] y \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] x \rbrace[inline]  &= \frac \lbrace[inline] g \lparen[inline] x \rparen[inline]  \rbrace[inline]  \lbrace[inline] h \lparen[inline] y \rparen[inline]  \rbrace[inline] \\
                     \\\text \lbrace[inline] Multiply reciprocals \rbrace[inline] \\
                     h \lparen[inline] y \rparen[inline] \;\mathrm \lbrace[inline] d \rbrace[inline] y &= g \lparen[inline] x \rparen[inline] \;\mathrm \lbrace[inline] d \rbrace[inline] x\\
                     \\\text \lbrace[inline] Integrate \rbrace[inline] \\
                     \int h \lparen[inline] y \rparen[inline] \;\mathrm \lbrace[inline] d \rbrace[inline] y &= \int g \lparen[inline] x \rparen[inline] \;\mathrm \lbrace[inline] d \rbrace[inline] x\\
                     \\\text \lbrace[inline] Differentiate \rbrace[inline] \\
                     \frac \lbrace[inline] d \rbrace[inline]  \lbrace[inline] dx \rbrace[inline]  \left \lparen[inline] \int h \lparen[inline] y \rparen[inline] \;\mathrm \lbrace[inline] d \rbrace[inline] y\right \rparen[inline]  &= \frac \lbrace[inline] d \rbrace[inline]  \lbrace[inline] dx \rbrace[inline]  \left \lparen[inline] \int g \lparen[inline] x \rparen[inline] \;\mathrm \lbrace[inline] d \rbrace[inline] x\right \rparen[inline] \\
                     \\\text \lbrace[inline] Given \rbrace[inline] \\
                     \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline]  \rbrace[inline]  \lbrace[inline] dx \rbrace[inline] 
                         &= \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline]  \rbrace[inline]  \lbrace[inline] dx \rbrace[inline]  \cdot \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] y \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] y \rbrace[inline] 
                         = \textcolor \lbrace[inline] blue \rbrace[inline]  \lbrace[inline] \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline]  \rbrace[inline]  \lbrace[inline] dy \rbrace[inline]  \rbrace[inline]  \cdot \textcolor \lbrace[inline] JungleGreen \rbrace[inline]  \lbrace[inline] \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] y \rbrace[inline]  \lbrace[inline] dx \rbrace[inline]  \rbrace[inline] \\
                     \\\text \lbrace[inline] Therefore the LHS is equal to \rbrace[inline] \\
                     \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline]  \rbrace[inline]  \lbrace[inline] dx \rbrace[inline]  \left \lparen[inline] \int h \lparen[inline] y \rparen[inline]  \mathrm \lbrace[inline] d \rbrace[inline] y\right \rparen[inline] 
                         &= \textcolor \lbrace[inline] blue \rbrace[inline]  \lbrace[inline] \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline]  \rbrace[inline]  \lbrace[inline] dy \rbrace[inline]  \rbrace[inline]  \left \lparen[inline] \int h \lparen[inline] y \rparen[inline]  \mathrm \lbrace[inline] d \rbrace[inline] y\right \rparen[inline]  \textcolor \lbrace[inline] JungleGreen \rbrace[inline]  \lbrace[inline] \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] y \rbrace[inline]  \lbrace[inline] dx \rbrace[inline]  \rbrace[inline] \\
                         &= h \lparen[inline] y \rparen[inline]  \textcolor \lbrace[inline] JungleGreen \rbrace[inline]  \lbrace[inline] \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] y \rbrace[inline]  \lbrace[inline] dx \rbrace[inline]  \rbrace[inline] 
                     \\\text \lbrace[inline] Therefore  \lparen[inline] in conclusion \rparen[inline]  \rbrace[inline] \\
                     \therefore \; h \lparen[inline] y \rparen[inline] \;\frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] y \rbrace[inline]  \lbrace[inline] dx \rbrace[inline]  &= g \lparen[inline] x \rparen[inline]
      }
   }
   \note[boxed]{
      \h3{Growth and Decay Models}
      \equation{
         \text \lbrace[inline] Given \rbrace[inline] \\
                     \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] y \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] t \rbrace[inline]  &= \textcolor \lbrace[inline] Periwinkle \rbrace[inline]  \lbrace[inline] k \rbrace[inline]  y\\
                     \text \lbrace[inline] Proof \rbrace[inline] \\
                     \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] y \rbrace[inline] \;\mathrm \lbrace[inline] d \rbrace[inline] y &= \textcolor \lbrace[inline] Periwinkle \rbrace[inline]  \lbrace[inline] k \rbrace[inline] \;\mathrm \lbrace[inline] d \rbrace[inline] t \\
                     \int \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] y \rbrace[inline] \;\mathrm \lbrace[inline] d \rbrace[inline] y &= \int \textcolor \lbrace[inline] Periwinkle \rbrace[inline]  \lbrace[inline] k \rbrace[inline] \;\mathrm \lbrace[inline] d \rbrace[inline] t \\
                     \ln \lparen[inline] y \rparen[inline]  &=  \textcolor \lbrace[inline] Periwinkle \rbrace[inline]  \lbrace[inline] k \rbrace[inline]  t + \textcolor \lbrace[inline] SeaGreen \rbrace[inline]  \lbrace[inline] C \rbrace[inline]  \\
                     e^ \lbrace[inline] \ln \lparen[inline] y \rparen[inline]  \rbrace[inline]  &= e^  \lbrace[inline] \textcolor \lbrace[inline] Periwinkle \rbrace[inline]  \lbrace[inline] k \rbrace[inline]  t + \textcolor \lbrace[inline] SeaGreen \rbrace[inline]  \lbrace[inline] C \rbrace[inline]  \rbrace[inline]  \\
                     y &= e^ \lbrace[inline] \textcolor \lbrace[inline] Periwinkle \rbrace[inline]  \lbrace[inline] k \rbrace[inline]  t \rbrace[inline]  \cdot e^ \lbrace[inline] \textcolor \lbrace[inline] SeaGreen \rbrace[inline]  \lbrace[inline] C \rbrace[inline]  \rbrace[inline]  \\
                     y &= e^ \lbrace[inline] \textcolor \lbrace[inline] Periwinkle \rbrace[inline]  \lbrace[inline] k \rbrace[inline]  t \rbrace[inline]  \cdot \textcolor \lbrace[inline] SeaGreen \rbrace[inline]  \lbrace[inline] C \rbrace[inline]  \\
                     \text \lbrace[inline] Therefore \rbrace[inline] \\
                     y &= \textcolor \lbrace[inline] SeaGreen \rbrace[inline]  \lbrace[inline] C \rbrace[inline]  e^ \lbrace[inline] \textcolor \lbrace[inline] Periwinkle \rbrace[inline]  \lbrace[inline] k \rbrace[inline]  t \rbrace[inline]
      }
      \p{The above states that all solutions for \{y^\prime = k y} are of the form \{y = C e^ \lbrace[inline] k t \rbrace[inline]}.}
      \p{Where}
      \equation{
         \textcolor \lbrace[inline] SeaGreen \rbrace[inline]  \lbrace[inline] C \rbrace[inline]  &= \textcolor \lbrace[inline] SeaGreen \rbrace[inline]  \lbrace[inline] \text \lbrace[inline] Initial value of $y$ \rbrace[inline]  \rbrace[inline] \\
                     \textcolor \lbrace[inline] Periwinkle \rbrace[inline]  \lbrace[inline] k \rbrace[inline]  &= \textcolor \lbrace[inline] Periwinkle \rbrace[inline]  \lbrace[inline] \text \lbrace[inline] Proportionality constant \rbrace[inline]  \rbrace[inline] \\
      }
      \p{Exponential growth occurs when \{\textcolor \lbrace[inline] Periwinkle \rbrace[inline]  \lbrace[inline] k > 0 \rbrace[inline]}, and exponential decay occurs when \{\textcolor \lbrace[inline] Periwinkle \rbrace[inline]  \lbrace[inline] k < 0 \rbrace[inline]}.}
      \hr\p{The Law of Natural Growth:}
      \equation{
         \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] \textcolor \lbrace[inline] DarkOrchid \rbrace[inline]  \lbrace[inline] P \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] t \rbrace[inline] 
                         = \textcolor \lbrace[inline] Periwinkle \rbrace[inline]  \lbrace[inline] k \rbrace[inline]  \textcolor \lbrace[inline] DarkOrchid \rbrace[inline] P
      }
      \p{The Logistic Model of Population Growth:}
      \equation{
         \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] \textcolor \lbrace[inline] DarkOrchid \rbrace[inline] P \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] t \rbrace[inline] 
                         = \textcolor \lbrace[inline] Periwinkle \rbrace[inline]  \lbrace[inline] k \rbrace[inline]  \textcolor \lbrace[inline] DarkOrchid \rbrace[inline] P
                             \left \lparen[inline] 1 - \frac \lbrace[inline] \textcolor \lbrace[inline] DarkOrchid \rbrace[inline]  \lbrace[inline] P \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \textcolor \lbrace[inline] Aquamarine \rbrace[inline]  \lbrace[inline] L \rbrace[inline]  \rbrace[inline] \right \rparen[inline]
      }
      \p{Where}
      \equation{
         \textcolor \lbrace[inline] Periwinkle \rbrace[inline]  \lbrace[inline] k \rbrace[inline]  &= \textcolor \lbrace[inline] Periwinkle \rbrace[inline]  \lbrace[inline] \text \lbrace[inline] Constant of proportionality \rbrace[inline]  \rbrace[inline] \\
                     \textcolor \lbrace[inline] DarkOrchid \rbrace[inline]  \lbrace[inline] P \rbrace[inline]  &= \textcolor \lbrace[inline] DarkOrchid \rbrace[inline]  \lbrace[inline] \text \lbrace[inline] Population at time $t$ \rbrace[inline]  \rbrace[inline] \\
                     \textcolor \lbrace[inline] Aquamarine \rbrace[inline]  \lbrace[inline] L \rbrace[inline]  &= \textcolor \lbrace[inline] Aquamarine \rbrace[inline]  \lbrace[inline] \text \lbrace[inline] Max size of population \rbrace[inline]  \rbrace[inline] \\
      }
   }
   \note[boxed]{
      \h3{Solving the Logistic Equation}
      \equation{
         \D \lbrace[inline] P \rbrace[inline]  \lbrace[inline] t \rbrace[inline]  &= kP \parens \lbrace[inline] 1 - \frac \lbrace[inline] P \rbrace[inline]  \lbrace[inline] L \rbrace[inline]  \rbrace[inline]  \\
                     \s \lbrace[inline] d \rbrace[inline] P &= kP \parens \lbrace[inline] 1 - \frac \lbrace[inline] P \rbrace[inline]  \lbrace[inline] L \rbrace[inline]  \rbrace[inline]  \s \lbrace[inline] d \rbrace[inline] t \\
                     \reciprocal \lbrace[inline] P \parens \lbrace[inline] 1 - \frac \lbrace[inline] P \rbrace[inline]  \lbrace[inline] L \rbrace[inline]  \rbrace[inline]  \rbrace[inline]  \s \lbrace[inline] d \rbrace[inline] P &= k \s \lbrace[inline] d \rbrace[inline] t
      }
      \p{Via partial fraction decomposition}
      \equation{
         \reciprocal \lbrace[inline] P \parens \lbrace[inline] 1 - \frac \lbrace[inline] P \rbrace[inline]  \lbrace[inline] L \rbrace[inline]  \rbrace[inline]  \rbrace[inline]  &= \frac \lbrace[inline] A \rbrace[inline]  \lbrace[inline] P \rbrace[inline]  + \frac \lbrace[inline] B \rbrace[inline]  \lbrace[inline] \parens \lbrace[inline] 1 - \frac \lbrace[inline] P \rbrace[inline]  \lbrace[inline] L \rbrace[inline]  \rbrace[inline]  \rbrace[inline] \\
                     0P + 1 &= A\parens \lbrace[inline] 1 - \frac \lbrace[inline] P \rbrace[inline]  \lbrace[inline] L \rbrace[inline]  \rbrace[inline]  + BP\\
                     0P + 1 &= A - \frac \lbrace[inline] P A \rbrace[inline]  \lbrace[inline] L \rbrace[inline]  + BP\\
                     0P + 1 &= P\parens \lbrace[inline] B - \frac \lbrace[inline] A \rbrace[inline]  \lbrace[inline] L \rbrace[inline]  \rbrace[inline]  + A \\
                     \text \lbrace[inline] Where \rbrace[inline] \\
                     \left.\begin \lbrace[inline] array \rbrace[inline]  \lbrace[inline] ll \rbrace[inline] 
                         B - \frac \lbrace[inline] A \rbrace[inline]  \lbrace[inline] L \rbrace[inline]  &= 0\\
                         A &= 1
                     \end \lbrace[inline] array \rbrace[inline] \right\ \rbrace[inline] 
                     \;\begin \lbrace[inline] array \rbrace[inline]  \lbrace[inline] ll \rbrace[inline] 
                     A &= 1\\
                     B &= \reciprocal \lbrace[inline] L \rbrace[inline] 
                     \end \lbrace[inline] array \rbrace[inline] \\
                     \text \lbrace[inline] Therefore \rbrace[inline] \\
                     \reciprocal \lbrace[inline] P \parens \lbrace[inline] 1 - \frac \lbrace[inline] P \rbrace[inline]  \lbrace[inline] L \rbrace[inline]  \rbrace[inline]  \rbrace[inline]  &= \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] P \rbrace[inline]  + \frac \lbrace[inline] \reciprocal \lbrace[inline] L \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \parens \lbrace[inline] 1 - \frac \lbrace[inline] P \rbrace[inline]  \lbrace[inline] L \rbrace[inline]  \rbrace[inline]  \rbrace[inline]
      }
      \p{Rewriting the differential equation}
      \equation{
         \reciprocal \lbrace[inline] P \parens \lbrace[inline] 1 - \frac \lbrace[inline] P \rbrace[inline]  \lbrace[inline] L \rbrace[inline]  \rbrace[inline]  \rbrace[inline]  \s \lbrace[inline] d \rbrace[inline] P
                         &= \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] P \rbrace[inline]  + \frac \lbrace[inline] \reciprocal \lbrace[inline] L \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \parens \lbrace[inline] 1 - \frac \lbrace[inline] P \rbrace[inline]  \lbrace[inline] L \rbrace[inline]  \rbrace[inline]  \rbrace[inline]  \s \lbrace[inline] d \rbrace[inline] P\\
                         &= k \s \lbrace[inline] d \rbrace[inline] t \\
                     \int \frac \lbrace[inline] 1 \rbrace[inline]  \lbrace[inline] P \rbrace[inline]  + \frac \lbrace[inline] \reciprocal \lbrace[inline] L \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \parens \lbrace[inline] 1 - \frac \lbrace[inline] P \rbrace[inline]  \lbrace[inline] L \rbrace[inline]  \rbrace[inline]  \rbrace[inline] 
                         &= \int k \s \lbrace[inline] d \rbrace[inline] t \\
                     \ln\; P - \reciprocal \lbrace[inline] L \rbrace[inline]  \ln\parens \lbrace[inline] 1 - \frac \lbrace[inline] P \rbrace[inline]  \lbrace[inline] L \rbrace[inline]  \rbrace[inline]  &= k t + C\\
                     \ln\parens \lbrace[inline] \frac
                          \lbrace[inline] P \rbrace[inline] 
                          \lbrace[inline] L \cdot \parens \lbrace[inline] 1 - \frac \lbrace[inline] P \rbrace[inline]  \lbrace[inline] L \rbrace[inline]  \rbrace[inline]  \rbrace[inline] 
                      \rbrace[inline]
      }
   }
}
\h2{Second Order Homogeneous Linear Differential Equations with Constant Coefficients}

\grid[col="2"]{
   \note{
      \h3{Properties}
      \ul{
         \li{\p{If \{f \lparen[inline] x \rparen[inline]} and \{g \lparen[inline] x \rparen[inline]} are solutions; then \{f + g} is also a solution. Therefore, the most general solution to some second order homogeneous linear differential equations with constant coefficients would be \{y = C_1 f \lparen[inline] x \rparen[inline]  + C_2 g \lparen[inline] x \rparen[inline]}.}
         \p{This is why, when you find two solutions to the characteristic equation \{r_1} and \{r_2} respectively, we write it like so.}}
      }
   }
   \note{
      \h3{\{r_1 = r_2}}
      \p{Given some:}
      \equation{
         a y^ \lbrace[inline] \prime\prime \rbrace[inline]  + b y^\prime + c y = 0\;\text \lbrace[inline] where $a \neq 0$ \rbrace[inline] \\
      }
      \p{We can presume that \{y} is of the form \{e^ \lbrace[inline] r t \rbrace[inline]}, and therefore:}
      \equation{
         \text \lbrace[inline] if \rbrace[inline] \\
                     y &= e^ \lbrace[inline] r t \rbrace[inline] \\
                     \text \lbrace[inline] then \rbrace[inline] \\
                     y^ \lbrace[inline] \prime \rbrace[inline]  &= r e^ \lbrace[inline] r t \rbrace[inline] \\
                     y^ \lbrace[inline] \prime\prime \rbrace[inline]  &= r^2 e^ \lbrace[inline] r t \rbrace[inline]
      }
      \p{Substituting this back into the original equation, we have:}
      \equation{
         0 &= a r^2 e^ \lbrace[inline] r t \rbrace[inline]  + b r e^ \lbrace[inline] r t \rbrace[inline]  + c e^ \lbrace[inline] r t \rbrace[inline] \\
                       &= e^ \lbrace[inline] r t \rbrace[inline]  \left \lparen[inline] a r^2 + b r + c\right \rparen[inline]
      }
      \p{Where:}
      \equation{
         &= \underbrace \lbrace[inline] e^ \lbrace[inline] r t \rbrace[inline]  \rbrace[inline] _\text \lbrace[inline] never $0$ \rbrace[inline] 
                        \underbrace \lbrace[inline] \left \lparen[inline] a r^2 + b r + c\right \rparen[inline]  \rbrace[inline] _\text \lbrace[inline] ? \rbrace[inline]
      }
      \p{So therefore:}
      \equation{
         &\underbrace \lbrace[inline] a r^2 + b r + c = 0 \rbrace[inline] 
                     _\text \lbrace[inline] characteristic equation \rbrace[inline] \\
                     &r = \frac
                          \lbrace[inline] -b \pm \sqrt \lbrace[inline] b^2 - 4ac \rbrace[inline]  \rbrace[inline] 
                          \lbrace[inline] 2a \rbrace[inline] 
                       \implies r_1, r_2
      }
      \p{Where the general solution is of the form:}
      \equation{
         \left.
         \begin \lbrace[inline] array \rbrace[inline]  \lbrace[inline] ll \rbrace[inline] 
             y &=\; &C_1\; e^ \lbrace[inline] r_1 t \rbrace[inline]  &+\; C_2\; e^ \lbrace[inline] r_2 t \rbrace[inline] \\
             y^\prime &=\; &C_1\; r_1\; e^ \lbrace[inline] r_1 t \rbrace[inline]  &+\; C_2\; r_2\; e^ \lbrace[inline] r_2 t \rbrace[inline] \\
             y^ \lbrace[inline] \prime\prime \rbrace[inline]  &=\; &C_1\; \left \lparen[inline] r_1\right \rparen[inline] ^2\; e^ \lbrace[inline] r_1 t \rbrace[inline]  &+\; C_2\; \left \lparen[inline] r_2\right \rparen[inline] ^2\; e^ \lbrace[inline] r_2 t \rbrace[inline] 
         \end \lbrace[inline] array \rbrace[inline] 
         \right\ \rbrace[inline] \text \lbrace[inline] $\forall r_1 \; r_2$ where $r_1 \neq r_2$ \rbrace[inline]
      }
   }
}
\h2{Parametric Equations}

\grid[col="2"]{
   \note{
      \h3{First Derivative Formula}
      \p{To find the derivative of a given function defined parametrically by the equations \{x = u \lparen[inline] t \rparen[inline]} and \{y = v \lparen[inline] t \rparen[inline]}.}
      \equation{
         \text \lbrace[inline] Given \rbrace[inline] \\
                     x &= u \lparen[inline] t \rparen[inline] \\
                     y &= v \lparen[inline] t \rparen[inline] \\
                     \text \lbrace[inline] Therefore \rbrace[inline] \\
                     \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] y \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] x \rbrace[inline] 
                         &= \frac
                          \lbrace[inline] \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] y \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] t \rbrace[inline]  \rbrace[inline] 
                          \lbrace[inline] \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] x \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] t \rbrace[inline]  \rbrace[inline] 
                         = \frac \lbrace[inline] v^\prime \lparen[inline] t \rparen[inline]  \rbrace[inline]  \lbrace[inline] u^\prime \lparen[inline] t \rparen[inline]  \rbrace[inline]
      }
   }
   \note{
      \h3{Second Derivative Formula}
      \p{To find the second derivative of a given function defined parametrically by the equations \{x = u \lparen[inline] t \rparen[inline]} and \{y = v \lparen[inline] t \rparen[inline]}.}
      \equation{
         \text \lbrace[inline] Given \rbrace[inline] \\
                     x &= u \lparen[inline] t \rparen[inline] \\
                     y &= v \lparen[inline] t \rparen[inline] \\
                     \text \lbrace[inline] Therefore \rbrace[inline] \\
                     \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline]  \lbrace[inline] ^2 \rbrace[inline]  y \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] x^2 \rbrace[inline] 
                         &= \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] x \rbrace[inline] \left \lparen[inline] \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] y \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] x \rbrace[inline] \right \rparen[inline] \\
                         &= \frac
                          \lbrace[inline] 
                             \frac \lbrace[inline] d \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] t \rbrace[inline] \left \lparen[inline]  \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] y \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] x \rbrace[inline]  \right \rparen[inline] 
                          \rbrace[inline] 
                          \lbrace[inline] \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] x \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] t \rbrace[inline]  \rbrace[inline] \\
                         &= \frac
                              \lbrace[inline] 
                                 \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] t \rbrace[inline] 
                                 \left \lparen[inline] \frac \lbrace[inline] v^\prime \lparen[inline] t \rparen[inline]  \rbrace[inline]  \lbrace[inline] u^\prime \lparen[inline] t \rparen[inline]  \rbrace[inline] \right \rparen[inline] 
                              \rbrace[inline] 
                              \lbrace[inline] u^\prime \lparen[inline] t \rparen[inline]  \rbrace[inline] \\
                         &=  \underbrace
                                  \lbrace[inline] 
                                     \frac
                                      \lbrace[inline] 
                                         \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] t \rbrace[inline] 
                                         \left \lparen[inline] \frac \lbrace[inline] v^\prime \lparen[inline] t \rparen[inline]  \rbrace[inline]  \lbrace[inline] u^\prime \lparen[inline] t \rparen[inline]  \rbrace[inline] \right \rparen[inline] 
                                      \rbrace[inline] 
                                      \lbrace[inline] 
                                         \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] t \rbrace[inline] 
                                         u \lparen[inline] t \rparen[inline] 
                                      \rbrace[inline] 
                                     = \frac
                                          \lbrace[inline] 
                                             \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] t \rbrace[inline] 
                                          \rbrace[inline] 
                                          \lbrace[inline] 
                                             \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] t \rbrace[inline] 
                                          \rbrace[inline] 
                                         \frac
                                          \lbrace[inline] 
                                             \left \lparen[inline] \frac \lbrace[inline] v^\prime \lparen[inline] t \rparen[inline]  \rbrace[inline]  \lbrace[inline] u^\prime \lparen[inline] t \rparen[inline]  \rbrace[inline] \right \rparen[inline] 
                                          \rbrace[inline] 
                                          \lbrace[inline] 
                                             u \lparen[inline] t \rparen[inline] 
                                          \rbrace[inline] 
                                  \rbrace[inline] _ \lbrace[inline] \text \lbrace[inline] notice the common $\frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline]  \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] t \rbrace[inline] $ \rbrace[inline]  \rbrace[inline]
      }
      \note[inline]{
         \p{The above shows different ways of representing \{\frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] ^ \lbrace[inline] 2 \rbrace[inline] y \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] x^2 \rbrace[inline]}. (I.e. it doesn't correspond to some final solution.)}
      }
   }
   \note{
      \h3{Arc Length}
      \p{Formula for the arc length of a parametric curve over the interval \{\lbrack[inline] a, b \rbrack[inline]}.}
      \equation{
         \int_a^b \sqrt \lbrace[inline] 
                         \left \lparen[inline] \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] x \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] t \rbrace[inline] \right \rparen[inline] ^2 +
                         \left \lparen[inline] \frac \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] y \rbrace[inline]  \lbrace[inline] \mathrm \lbrace[inline] d \rbrace[inline] t \rbrace[inline] \right \rparen[inline] ^2
                      \rbrace[inline] 
                     \mathrm \lbrace[inline] d \rbrace[inline] t
      }
   }
}