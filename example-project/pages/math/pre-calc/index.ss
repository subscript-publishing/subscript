/// This file was auto-translated from the original HTML source, it is pretty messy. 
\h1[top-level]{Pre-Calculus}

\h2{Limits}

\grid[col="2"]{
   \note[boxed]{
      \h3{L’Hospital’s Rule}
      \equation{
         \lim_{x\to{a}}\frac{f(x)}{g(x)} &= \lim_{x\to{a}}\frac{f^\prime(x)}{g^\prime(x)}\\
                     \text{if}\;\lim_{x\to{a}}\frac{f(x)}{g(x)} = \frac{0}{0}
                     \;&\text{or}\;\lim_{x\to{a}}\frac{f(x)}{g(x)} = \frac{\infty}{\infty}
      }
      \p{In other words, if L’Hospital’s Rule applies to indeterminate forms.}
   }
}
\h3{Limit Laws}

\grid[col="3"]{
   \equation{
      \lim_{x \to a} \Big[ f(x) + g(x) \Big] &= \lim_{x \to a} f(x) + \lim_{x \to a} g(x)
   }
   \equation{
      \lim_{x \to a} \Big[ f(x) - g(x) \Big] &= \lim_{x \to a} f(x) - \lim_{x \to a} g(x)
   }
   \equation{
      \lim_{x \to a} \Big[ c \cdot f(x) \Big] &= c \cdot \lim_{x \to a} f(x)
   }
   \equation{
      \lim_{x \to a} \Big[ f(x) \cdot g(x) \Big] &= \lim_{x \to a} f(x) \cdot \lim_{x \to a} g(x)
   }
   \equation{
      \lim_{x \to a} \frac{f(x)}{g(x)} &= \frac{\lim_{x \to a} f(x)}{\lim_{x \to a}g(x)} \; \text{if} \lim_{x \to a}g(x) \neq 0
   }
   \equation{
      \lim_{x \to a} \Big[ f(x) \Big]^n = \Big[ \lim_{x \to a} f(x) \Big]^n\;\text{if}\;n\in\mathbb{Z}^+
   }
   \equation{
      \underbrace{\lim_{x \to a} \sqrt[n]{f(x)} = \sqrt[n]{\lim_{x \to a} f(x)}\;\text{if}\;n\in\mathbb{Z}^+}_{\text{if $n$ is even we assume $\lim_{x \to a} f(x) > 0$}}
   }
   \equation{
      \lim_{x\to{c}}\, \left(f \circ g\right)(x) &= f\left(\lim_{x\to{c}}\, g(x)\right)
   }
}
\h3{Limit Formulas}

\grid[col="3"]{
   \equation{
      \lim_{x\to\infty} \frac{1}{x^r} &= 0\;,\;\forall r > 0
   }
   \equation{
      \lim_{x\to\infty} \frac{x^n}{!n} &= 0\;,\;\forall n \in \mathbb{R}
   }
}

\h3{Function Graphs}

\grid[col="2", boxed]{
   \note{
      \h4{Example}
      \img[max-width="600px", src="../../../assets/images/math/9.svg"]
   }
   \note{
      \h4{Example}
      \img[max-width="600px", src="../../../assets/images/math/10.svg"]
   }
   \note{
      \h4{Example}
      \img[max-width="600px", src="../../../assets/images/math/11.svg"]
   }
}

\h3{Growth Rates}

\ol{
   \li{\u{Factorial functions} grow faster than \u{exponential functions}.}
   \li{\u{Exponential functions} grow faster than \u{polynomials}.}
}