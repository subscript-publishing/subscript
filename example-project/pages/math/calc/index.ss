/// This file was auto-translated from the original HTML source, it is pretty messy. 
\h1[top-level]{Calculus}

\note{
   \h2{Derivative Tables}
   \grid[boxed, col="3"]{
      \equation{
         \delta\sin(x) &= \cos(x) \\
                     \delta\csc(x) &= -\cot(x) \cdot \csc(x)
      }
      \equation{
         \delta\cos(x) &= -\sin(x) \\
                     \delta\sec(x) &= \tan(x) \cdot \sec(x)
      }
      \equation{
         \delta\tan(x) &= \sec^2(x) \\
                     \delta\cot(x) &= -\csc^2(x)
      }
   }\grid[boxed, col="3"]{
      \equation{
         \delta\sin^{-1}(x) &= \frac{1}{\sqrt{1 - x^2}}
      }
      \equation{
         \delta\cos^{-1}(x) &= -\frac{1}{\sqrt{1 - x^2}}
      }
      \equation{
         \delta\tan^{-1}(x) &= \frac{1}{1 + x^2}
      }
   }
}

\note{
   \h2{Integration Tables}
   \grid[col="3", boxed]{
      \equation{
         \int\sin(x)\;\mathrm{d}x &= -\cos x \\
                     \int\csc^2(x)\;\mathrm{d}x &= -\cot x \\
                     \int\csc(x)\cdot\cot(x)\;\mathrm{d}x &= -\csc x \\
                     \int\csc(x)\;\mathrm{d}x &= \ln\left|\csc x - \cot x\right| \\
                     \int\sinh(x)\;\mathrm{d}x &= \cosh(x) \\
      }
      \equation{
         \int\cos(x)\;\mathrm{d}x &= \sin x \\
                     \int\sec^2(x)\;\mathrm{d}x &= \tan x \\
                     \int\sec(x)\cdot\tan(x)\;\mathrm{d}x &= \sec x \\
                     \int\sec(x)\;\mathrm{d}x &= \ln\left|\sec x + \tan x\right| \\
                     \int\cosh(x)\;\mathrm{d}x &= \sinh(x) \\
      }
      \equation{
         \int\tan(x)\;\mathrm{d}x &= \ln| \sec x | \\
                     \int\cot(x)\;\mathrm{d}x &= \ln| \sin x | \\
      }
   }
   \grid[boxed, col="3"]{
      \equation{
         \int b^x\;\mathrm{d}x &= \frac{b^x}{\ln(b)}
      }
      \equation{
         \int\frac{1}{x^2 + a^2}\;\mathrm{d}x &= \frac{1}{a}\tan^{-1}\left(\frac{x}{a}\right)
      }
      \equation{
         \int\frac{1}{x^2 - a^2}\;\mathrm{d}x &= \frac{1}{2a}\ln\left|\frac{x-a}{x+a}\right|
      }
      \equation{
         \int\frac{1}{\sqrt{a^2 - x^2}}\;\mathrm{d}x &= \sin^{-1}\left(\frac{x}{a}\right),\;a>0
      }
      \equation{
         \int\frac{1}{\sqrt{x^2 \pm a^2}}\;\mathrm{d}x &= \ln\left|x+\sqrt{x^2\pm a^2}\right|
      }
   }
}

\note[boxed]{
   \h2{Riemann Sums}
   \p[center]{Given}
   \equation{
      A &= \int_{a}^{b} f(x) = \lim_{n\to\infty}\sum_{i=1}^{n} \Delta{x} \cdot f(x) \;\text{where}\;
         \hbrace[left]{
            \Delta{x} = \frac{b - a}{n}
         }
   }
   \grid[col="2"]{
      \note[boxed]{
         \h3{Left Riemann Sum}
         \equation{
            A &= \int_{a}^{b} f(x) \;\mathrm{d}x \approx L_n = \sum_{i = 0}^{n-1}\, \Delta{x}\cdot f\left(a + i\cdot\Delta{x}\right)
         }
      }
      \note[boxed]{
         \h3{Right Riemann Sum}
         \equation{
            A &= \int_{a}^{b} f(x) \;\mathrm{d}x \approx R_n = \sum_{i = 1}^{n}\, \Delta{x}\cdot f\left(a + i\cdot\Delta{x}\right)
         }
      }
   }\note[boxed]{
      \h3{Midpoint Riemann Sum}
      \math{
         \newcommand{\generalFormat}{
                         \sum_{\small{\cdots}}^{\small{\cdots}}\, \Delta{x}\cdot f\left(a + \text{“avg. of $x_i$ and $x_{i-1}$”} \cdot \Delta{x}\right)
                     }
                     \newcommand{\SigmaExampleOne}{
                         \sum_{i = 1}^{n}\, \Delta{x}\cdot f\left(a + \frac{x_{i - 1} + x_i}{2} \cdot \Delta{x}\right)
                     }
                     \newcommand{\SigmaExampleTwo}{
                         \sum_{i = 0}^{n-1}\, \Delta{x}\cdot f\left(a + \frac{x_{i + 1} + x_i}{2} \cdot \Delta{x}\right)
                     }
                     \begin{equation}
                     \begin{split}
                         A = \int_{a}^{b} f(x) \;\mathrm{d}x &\approx \generalFormat\\
                             &\approx \SigmaExampleOne\\
                             \text{or alternatively}&\\
                             A &\approx \SigmaExampleTwo
                     \end{split}
                     \end{equation}
      }\hr\p[center]{We can also do away with the index notation and simplify things.}
      \math{
         \newcommand{\SigmaExampleOne}{
                         \sum_{i = 1}^{n}\, \Delta{x}\cdot f\left(a + \frac{(i - 1) + i}{2} \cdot \Delta{x}\right) =
                         \sum_{i = 1}^{n}\, \Delta{x}\cdot f\left(a + \frac{2i - 1}{2} \cdot \Delta{x}\right)
                     }
                     \newcommand{\SigmaExampleTwo}{
                         \sum_{i = 0}^{n-1}\, \Delta{x}\cdot f\left(a + \frac{(i + 1) + i}{2} \cdot \Delta{x}\right) =
                         \sum_{i = 0}^{n-1}\, \Delta{x}\cdot f\left(a + \frac{2i + 1}{2} \cdot \Delta{x}\right)
                     }
                     \begin{equation}
                     \begin{split}
                         A = \int_{a}^{b} f(x) \;\mathrm{d}x
                             &\approx \SigmaExampleOne\\
                             &\approx \SigmaExampleTwo
                     \end{split}
                     \end{equation}
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
         \text{Given}&\;L = \int_{a}^{\infty} f(x) \;\mathrm{d}x = \lim_{t\to\infty} \int_{a}^{\infty} f(x) \;\mathrm{d}x = \lim_{t\to\infty} F(x)\\
                     \text{If}&\;L\;\text{“exists”}\;\text{then $L$ is}\;\mathbf{\text{convergent}}\\
                     \text{If}&\;L\;\text{“does not exists”}\;\text{then $L$ is}\;\mathbf{\text{divergent}}
      }
   }
}
\h2{Infinite Sequences}

\grid[col="2"]{
   \note[boxed]{
      \h3{Infinite Sequence}
      \equation{
         \text{Given}&\\
         &S_n = \{a_n\}_{n=1}^{\infty}\\
         \text{Tests}&\\
         &\text{If}\;\lim_{n\to\infty}\,S_n \text{“exists”}\;\text{then}\;\mathbf{\text{$S_n$ is convergent}}\\
         &\text{If}\;\lim_{n\to\infty}\,S_n \text{“does not exists”}\;\text{then}\;\mathbf{\text{$S_n$ is Divergent}}
      }
   }
   \note[boxed]{
      \h3{Helpful Theorem}
      \equation{
         \text{If}&\\
         \lim_{x\to\infty}\,|a_n| &= 0\\
         \text{Then}&\\
         \lim_{x\to\infty}\,a_n &= 0\\
      }
   }
   \note[boxed]{
      \h3{Example}
      \p{Given}
      \equation{
            S_n &= \{\cos\left(\frac{n\pi}{2}\right)\}\\
            L &=\lim_{n\to\infty}\,\cos\left(\frac{n\pi}{2}\right)\\
            &= \cos\left(\lim_{n\to\infty}\,\frac{n\pi}{2}\right) \\
            &= \cos\left(\infty\right) \\
            &= \text{undefined}
      }
      \p{Therefore}
      \equation{
         \therefore\;\text{$S_n$ is Divergent}
      }
   }
   \note[boxed]{
      \h3{Example}
      \p{Given}
      \equation{
            S_n &= \{\sin\left(\frac{\pi}{n}\right)\}\\
            L &= \lim_{n\to\infty}\,\sin\left(\frac{\pi}{n}\right)\\
                  &= \sin\left(\lim_{n\to\infty}\,\frac{\pi}{n}\right) \\
                  &= \sin\left(0\right) \\
                  &= 0
      }
      \p{Therefore}
      \equation{
         \therefore\;\text{$S_n$ is Convergent}
      }
   }
}
\h2{Infinite Series}

\grid[col="2"]{
   \note[boxed]{
      \h3{Infinite Series}
      \equation{
         \text{Given}&\\
         &S_n = \sum_{n = 1}^{\infty}\,a_n\\
         \text{Tests}&\\
         &\text{If}\;\lim_{n\to\infty}\,a_n = 0\;\text{then}\;\text{$S_n$ may be $\mathbf{\text{convergent}}$}\\
         &\text{If}\;\lim_{n\to\infty}\,a_n \neq 0\;\text{then}\;\mathbf{\text{$S_n$ is divergent}}\\
         &\text{If}\;\lim_{n\to\infty}\,a_n \text{“does not exists”}\;\text{then}\;\mathbf{\text{$S_n$ is divergent}}\\
      }
      \p{Note that the limit of every \b{convergent} series is equal to zero. But the inverse isn't always true. If the limit is equal to zero, it \u{may not be convergent}.}
      \p{For example, \{\sum_{n=1}^\infty \frac{1}{n}} does diverge; \u{but it's limit is equal to zero}.}
      \note[inline]{
         \p{If the limit is equal to zero; the \u{test is \b{inconclusive}}.}
      }
   }
   \note[boxed]{
      \h3{Geometric Series}
      \p{Given}
      \equation{
         S_n = \sum_{n = 1}^{\infty}\,a_n = \sum_{n = 1}^{\infty}\,a\cdot r^{n - 1}\;\text{where}\;\hbrace[left]{a &= a_1\\ r &= \frac{S_2}{S_1}}
      }
      \p{Alternatively}
      \equation{
         S_n = \sum_{n=0}^{\infty}\,a_n = \sum_{n=0}^{\infty}\,a\cdot r^{n}
      }
      \p{Tests}
      \equation{
         \text{If}\;|r|\geq{1}\;\text{then}\;\mathbf{\text{$S_n$ is divergent}}\\
         \text{If}\;|r|<1\;\text{then}\;\mathbf{\text{$S_n$ is convergent}}\\
      }
      \p{Furthermore}
      \equation{
         \sum_{n = 1}^{\infty}\,a_n = \sum_{n = 1}^{\infty}\,a\cdot r^{n - 1} = \frac{a}{1 - r}\;\text{for all}\;|r|<1
      }
   }
   \note[boxed]{
      \h3{The Integral Test}
      \equation{
         &\text\lbrace[inline]Given\rbrace[inline]\\
                     &\;\;\;\;a_n = f\lparen[inline]n\rparen[inline]\;\text\lbrace[inline]$\forall$n on\rbrace[inline]\;\lbrack[inline]1,n\rparen[inline]\\
                     &\;\;\;\;S_n = \sum_\lbrace[inline]n = 1\rbrace[inline]^\lbrace[inline]\infty\rbrace[inline]\,a_n\\
                     &\;\;\;\;F\lparen[inline]x\rparen[inline] = \int_\lbrace[inline]1\rbrace[inline]^\lbrace[inline]\infty\rbrace[inline]f\lparen[inline]x\rparen[inline]\;\mathrm\lbrace[inline]d\rbrace[inline]x\\
                     &\text\lbrace[inline]Where\rbrace[inline]\\
                     &\;\;\;\;f\lparen[inline]x\rparen[inline] > 0, \forall\,x\in\,\lbrack[inline]1, \infty\rparen[inline]\\
                     &\;\;\;\;f^\prime\lparen[inline]x\rparen[inline] < 0, \forall\,x\in\,\lbrack[inline]1, \infty\rparen[inline]\\
                     &\text\lbrace[inline]Tests\rbrace[inline]\\
                     &\;\;\;\;\text\lbrace[inline]If $S_n$ convergent; then $F\lparen[inline]x\rparen[inline]$ is $\mathbf\lbrace[inline]convergent\rbrace[inline]$\rbrace[inline]\\
                     &\;\;\;\;\text\lbrace[inline]If $S_n$ divergent; then $F\lparen[inline]x\rparen[inline]$ is $\mathbf\lbrace[inline]divergent\rbrace[inline]$\rbrace[inline]
      }
      \note{
         \h4{Constraints on \{\lbrack[inline]1,n\rparen[inline]}}
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
         &\text{Given}\\
                     &\;\;\;\;S_n=\sum_{n=1}^{\infty}\frac{1}{n^p}\\
                     &\text{Tests}\\
                     &\;\;\;\;\text{If $p>1$ then $S_n$ is $\mathbf{convergent}$}\\
                     &\;\;\;\;\text{If $0 < p \leq{1}$ then $S_n$ is $\mathbf{divergent}$}
      }
      \note[boxed, style="align-self: flex-end;"]{
         \p{Note: the \u{Harmonic series} is the special case where \{p=1}}
      }
   }
   \note[boxed]{
      \h3{Comparison Test}
      \equation{
         &\text{Given}\\
                     &\;\;\;\;A_n = \sum_{n=1}^\infty\,a_n\\
                     &\;\;\;\;B_n = \sum_{n=1}^\infty\,b_n\\
                     &\text{Where}\\
                     &\;\;\;\;a_n, b_n \geq 0\\
                     &\;\;\;\;a_n \leq b_n\\
                     &\text{Tests}\\
                     &\;\;\;\;\text{If $B_n$ converges $\implies A_n$ converges}\\
                     &\;\;\;\;\text{If $A_n$ diverges $\implies B_n$ diverges}\\
      }
   }
   \note[boxed]{
      \h3{Limit Comparison Test}
      \equation{
         &\text{Given}\\
                     &\;\;\;\;A_n = \sum_{n=1}^\infty\,a_n\\
                     &\;\;\;\;B_n = \sum_{n=1}^\infty\,b_n\\
                     &\;\;\;\; L = \lim_{n\to\infty}\frac{a_n}{b_n}\\
                     &\text{Where}\\
                     &\;\;\;\;L > 0,\;L \neq \pm \infty\\
                     &\text{Therefore either both converge or diverge}\\
                     &\;\;\;\;\text{$A_n$ converges $\Longleftrightarrow B_n$ converges}\\
                     &\;\;\;\;\text{$A_n$ diverges $\Longleftrightarrow B_n$ diverges}
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
         \text{Given}\\
         \frac{\mathrm{d}y}{\mathrm{d}x}
               &= g(x) \cdot f(y)\\
               &= \frac{g(x)}{\frac{1}{f(y)}}\\
               &= \frac{g(x)}{h(y)}\;\text{where}\;h(x) = \frac{1}{f(y)}\\
         \\\text{Therefore (restated)}\\
         \frac{\mathrm{d}y}{\mathrm{d}x} &= \frac{g(x)}{h(y)}\\
         \\\text{Multiply reciprocals}\\
         h(y)\;\mathrm{d}y &= g(x)\;\mathrm{d}x\\
         \\\text{Integrate}\\
         \int h(y)\;\mathrm{d}y &= \int g(x)\;\mathrm{d}x\\
         \\\text{Differentiate}\\
         \frac{d}{dx} \left(\int h(y)\;\mathrm{d}y\right) &= \frac{d}{dx} \left(\int g(x)\;\mathrm{d}x\right)\\
         \\\text{Given}\\
         \frac{\mathrm{d}}{dx}
               &= \frac{\mathrm{d}}{dx} \cdot \frac{\mathrm{d}y}{\mathrm{d}y}
               = \textcolor{blue}{\frac{\mathrm{d}}{dy}} \cdot \textcolor{JungleGreen}{\frac{\mathrm{d}y}{dx}}\\
         \\\text{Therefore the LHS is equal to}\\
         \frac{\mathrm{d}}{dx} \left(\int h(y) \mathrm{d}y\right)
               &= \textcolor{blue}{\frac{\mathrm{d}}{dy}} \left(\int h(y) \mathrm{d}y\right) \textcolor{JungleGreen}{\frac{\mathrm{d}y}{dx}}\\
               &= h(y) \textcolor{JungleGreen}{\frac{\mathrm{d}y}{dx}}
         \\\text{Therefore (in conclusion)}\\
         \therefore \; h(y)\;\frac{\mathrm{d}y}{dx} &= g(x)
      }
   }
   \note[boxed]{
      \h3{Growth and Decay Models}
      \equation{
         \text{Given}\\
                     \frac{\mathrm{d}y}{\mathrm{d}t} &= \textcolor{Periwinkle}{k} y\\
                     \text{Proof}\\
                     \frac{1}{y}\;\mathrm{d}y &= \textcolor{Periwinkle}{k}\;\mathrm{d}t \\
                     \int \frac{1}{y}\;\mathrm{d}y &= \int \textcolor{Periwinkle}{k}\;\mathrm{d}t \\
                     \ln(y) &=  \textcolor{Periwinkle}{k} t + \textcolor{SeaGreen}{C} \\
                     e^{\ln(y)} &= e^ {\textcolor{Periwinkle}{k} t + \textcolor{SeaGreen}{C}} \\
                     y &= e^{\textcolor{Periwinkle}{k} t} \cdot e^{\textcolor{SeaGreen}{C}} \\
                     y &= e^{\textcolor{Periwinkle}{k} t} \cdot \textcolor{SeaGreen}{C} \\
                     \text{Therefore}\\
                     y &= \textcolor{SeaGreen}{C} e^{\textcolor{Periwinkle}{k} t}
      }
      \p{The above states that all solutions for \{y^\prime = k y} are of the form \{y = C e^{k t}}.}
      \p{Where}
      \equation{
         \textcolor{SeaGreen}{C} &= \textcolor{SeaGreen}{\text{Initial value of $y$}}\\
                     \textcolor{Periwinkle}{k} &= \textcolor{Periwinkle}{\text{Proportionality constant}}\\
      }
      \p{Exponential growth occurs when \{\textcolor{Periwinkle}{k > 0}}, and exponential decay occurs when \{\textcolor{Periwinkle}{k < 0}}.}
      \hr\p{The Law of Natural Growth:}
      \equation{
         \frac{\mathrm{d}\textcolor{DarkOrchid}{P}}{\mathrm{d}t}
                         = \textcolor{Periwinkle}{k} \textcolor{DarkOrchid}P
      }
      \p{The Logistic Model of Population Growth:}
      \equation{
         \frac{\mathrm{d}\textcolor{DarkOrchid}P}{\mathrm{d}t}
                         = \textcolor{Periwinkle}{k} \textcolor{DarkOrchid}P
                             \left(1 - \frac{\textcolor{DarkOrchid}{P}}{\textcolor{Aquamarine}{L}}\right)
      }
      \p{Where}
      \equation{
         \textcolor{Periwinkle}{k} &= \textcolor{Periwinkle}{\text{Constant of proportionality}}\\
                     \textcolor{DarkOrchid}{P} &= \textcolor{DarkOrchid}{\text{Population at time $t$}}\\
                     \textcolor{Aquamarine}{L} &= \textcolor{Aquamarine}{\text{Max size of population}}\\
      }
   }
   \note[boxed]{
      \h3{Solving the Logistic Equation}
      \equation{
         \frac{\mathrm{d}P}{\mathrm{d}t} &= kP \parens{1 - \frac{P}{L}} \\
         \mathrm{d}P &= kP \parens{1 - \frac{P}{L}} \mathrm{d}t \\
         \frac{1}{P \parens{1 - \frac{P}{L}}} \mathrm{d}P &= k \mathrm{d}t
      }
      \p{Via partial fraction decomposition}
      \equation{
         \frac{1}{P \parens{1 - \frac{P}{L}}} &= \frac{A}{P} + \frac{B}{\parens{1 - \frac{P}{L}}}\\
                     0P + 1 &= A\parens{1 - \frac{P}{L}} + BP\\
                     0P + 1 &= A - \frac{P A}{L} + BP\\
                     0P + 1 &= P\parens{B - \frac{A}{L}} + A \\
                     \text{Where}\\
                     \hbrace[right]{
                        B - \frac{A}{L} &= 0\\
                        A &= 1
                     }
                     \;\begin{array}{ll}
                     A &= 1\\
                     B &= \frac{1}{L}
                     \end{array}\\
                     \text{Therefore}\\
                     \frac{1}{P \parens{1 - \frac{P}{L}}} &= \frac{1}{P} + \frac{\frac{1}{L}}{\parens{1 - \frac{P}{L}}}
      }
      \p{Rewriting the differential equation}
      \equation{
         \frac{1}{P \parens{1 - \frac{P}{L}}} \mathrm{d}P
                         &= \frac{1}{P} + \frac{\frac{1}{L}}{\parens{1 - \frac{P}{L}}} \mathrm{d}P\\
                         &= k \mathrm{d}t \\
                     \int \frac{1}{P} + \frac{\frac{1}{L}}{\parens{1 - \frac{P}{L}}}
                         &= \int k \mathrm{d}t \\
                     \ln\; P - \frac{1}{L} \ln\parens{1 - \frac{P}{L}} &= k t + C\\
                     \ln\parens{\frac{P}{L \cdot \parens{1 - \frac{P}{L}}}}
      }
   }
}
\h2{Second Order Homogeneous Linear Differential Equations with Constant Coefficients}

\grid[col="2"]{
   \note{
      \h3{Properties}
      \ul{
         \li{\p{If \{f(x)} and \{g(x)} are solutions; then \{f + g} is also a solution. Therefore, the most general solution to some second order homogeneous linear differential equations with constant coefficients would be \{y = C_1 f(x) + C_2 g(x)}.}
         \p{This is why, when you find two solutions to the characteristic equation \{r_1} and \{r_2} respectively, we write it like so.}}
      }
   }
   \note{
      \h3{\{r_1 = r_2}}
      \p{Given some:}
      \equation{
         a y^{\prime\prime} + b y^\prime + c y = 0\;\text{where $a \neq 0$}\\
      }
      \p{We can presume that \{y} is of the form \{e^{r t}}, and therefore:}
      \equation{
         \text{if}\\
                     y &= e^{r t}\\
                     \text{then}\\
                     y^{\prime} &= r e^{r t}\\
                     y^{\prime\prime} &= r^2 e^{r t}
      }
      \p{Substituting this back into the original equation, we have:}
      \equation{
         0 &= a r^2 e^{r t} + b r e^{r t} + c e^{r t}\\
                       &= e^{r t} \left(a r^2 + b r + c\right)
      }
      \p{Where:}
      \equation{
         &= \underbrace{e^{r t}}_\text{never $0$}
                        \underbrace{\left(a r^2 + b r + c\right)}_\text{?}
      }
      \p{So therefore:}
      \equation{
         &\underbrace{a r^2 + b r + c = 0}
                     _\text{characteristic equation}\\
                     &r = \frac
                         {-b \pm \sqrt{b^2 - 4ac}}
                         {2a}
                       \implies r_1, r_2
      }
      \p{Where the general solution is of the form:}
      \equation{
         \hbrace[right]{
            y &=\; &C_1\; e^{r_1 t} &+\; C_2\; e^{r_2 t}\\
            y^\prime &=\; &C_1\; r_1\; e^{r_1 t} &+\; C_2\; r_2\; e^{r_2 t}\\
            y^{\prime\prime} &=\; &C_1\; \left(r_1\right)^2\; e^{r_1 t} &+\; C_2\; \left(r_2\right)^2\; e^{r_2 t}
         }
         \text{$\forall r_1 \; r_2$ where $r_1 \neq r_2$}
      }
   }
}
\h2{Parametric Equations}

\grid[col="2"]{
   \note{
      \h3{First Derivative Formula}
      \p{To find the derivative of a given function defined parametrically by the equations \{x = u(t)} and \{y = v(t)}.}
      \equation{
         \text{Given}\\
                     x &= u(t)\\
                     y &= v(t)\\
                     \text{Therefore}\\
                     \frac{\mathrm{d}y}{\mathrm{d}x}
                         &= \frac
                         {\frac{\mathrm{d}y}{\mathrm{d}t}}
                         {\frac{\mathrm{d}x}{\mathrm{d}t}}
                         = \frac{v^\prime(t)}{u^\prime(t)}
      }
   }
   \note{
      \h3{Second Derivative Formula}
      \p{To find the second derivative of a given function defined parametrically by the equations \{x = u(t)} and \{y = v(t)}.}
      \p{Given}
      \equation{
            x &= u(t)\\
            y &= v(t)\\
      }
      \p{Therefore}
      \equation{
      \frac{\mathrm{d}{^2} y}{\mathrm{d}x^2}
            &= \frac{\mathrm{d}}{\mathrm{d}x}\left(\frac{\mathrm{d}y}{\mathrm{d}x}\right)\\
            &= \frac{\frac{d}{\mathrm{d}t}\left( \frac{\mathrm{d}y}{\mathrm{d}x} \right)}{\frac{\mathrm{d}x}{\mathrm{d}t}}\\
            &= \frac{\frac{\mathrm{d}}{\mathrm{d}t}\left(\frac{v^\prime(t)}{u^\prime(t)}\right)}{u^\prime(t)}\\
            &= \underbrace{
               \frac{\frac{\mathrm{d}}{\mathrm{d}t}\left(\frac{v^\prime(t)}{u^\prime(t)}\right)}{\frac{\mathrm{d}}{\mathrm{d}t}u(t)} = \frac{\frac{\mathrm{d}}{\mathrm{d}t}}{\frac{\mathrm{d}}{\mathrm{d}t}}\frac{\left(\frac{v^\prime(t)}{u^\prime(t)}\right)}{u(t)}
         }_{
            \text{notice the common $\frac{\mathrm{d}}{\mathrm{d}t}$}
         }
      }
      \note[inline]{
         \p{The above shows different ways of representing \{\frac{\mathrm{d}^{2}y}{\mathrm{d}x^2}}. (I.e. it doesn't correspond to some final solution.)}
      }
   }
   \note{
      \h3{Arc Length}
      \p{Formula for the arc length of a parametric curve over the interval \{[a, b]}.}
      \equation{
         \int_a^b \sqrt{
                         \left(\frac{\mathrm{d}x}{\mathrm{d}t}\right)^2 +
                         \left(\frac{\mathrm{d}y}{\mathrm{d}t}\right)^2
                     }
                     \mathrm{d}t
      }
   }
}