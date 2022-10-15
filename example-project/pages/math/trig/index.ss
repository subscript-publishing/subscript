/// This file was auto-translated from the original HTML source, it is pretty messy. 
\h1{Trigonometry}

\grid[boxed]{
   \note{
      \h2{The Unit Circle & Special Angles In Trig}
      \img[min-width="500px", max-width="1000px", src="../images/math/7.svg"]\grid[col="1", boxed]{
         \note{
            \h4{Warning}
            \p[center]{Never use Pi (\{\pi})! It makes (thinking in terms of) radians confusing, 
                                Tao (\{\tau}) is what the enlightened trigonometer uses,
                                and won't screw you over.}
         }
      }\p{To easily memorize the special angles in trig, notice the repeating patterns on the above angles.}
      \ul{
         \li{For values on the x-axis, anything over \{\frac{1}{4}\tau}
                         and under \{\frac{3}{4}\tau} will be negative}
         \li{For values on the y-axis, anything over \{\frac{1}{2}\tau} will be negative}
         \li{\p{Diagonals will be \{\pm \frac{\sqrt{2}}{2}}}
         \p{For ratios of \{\frac{1}{12}\tau} on the sides, i.e.
                             \{\frac{1}{12}\tau},
                             \{\frac{2}{12}\tau},
                             \{\frac{4}{12}\tau},
                             \{\frac{5}{12}\tau},
                             \{\frac{7}{12}\tau},
                             \{\frac{8}{12}\tau},
                             \{\frac{10}{12}\tau}, and
                             \{\frac{11}{12}\tau}. Draw a circle and dot the point where it occurs
                             (which is pretty easy since the above are simple ratios of a circle
                             when expressed in terms of \{\tau}).
                             Then with regards to the \{x} and \{y} axis values:}
         \ul{
            \li{The longer size will be \{\pm \frac{\sqrt{3}}{2}}}
            \li{The shorter side will be \{\pm \frac{1}{2}}}
         }\p{See the above examples.}}
      }
   }
}

\h2{Trigonometric Identities}

\grid[col="2"]{
   \note[boxed]{
      \h3{Pythagorean Identities}
      \equation{
         \cos^2(\theta) + \sin^2(\theta) = 1
      }
      \grid[col="2"]{
         \equation{
            \sec^2(\theta) - \tan^2(\theta) &= 1 \\
                        \sec^2(\theta) &= 1 + \tan^2(\theta)
         }
         \equation{
            \csc^2(\theta) - \cot^2(\theta) &= 1 \\
                        \csc^2(\theta) &= 1 + \cot^2(\theta)
         }
      }
   }
   \note[boxed]{
      \h3{Sum and Difference Identities}
      \math{
         \begin{equation*}
\begin{split}
   \cos(\alpha - \beta) &= \cos(\alpha) \cdot \cos(\beta) + \sin(\alpha) \cdot \sin(\beta) \\
   \cos(\alpha + \beta) &= \cos(\alpha) \cdot \cos(\beta) - \sin(\alpha) \cdot \sin(\beta) \\
   &\\
   \sin(\alpha - \beta) &= \sin(\alpha) \cdot \cos(\beta) - \cos(\alpha) \cdot \sin(\beta) \\
   \sin(\alpha + \beta) &= \sin(\alpha) \cdot \cos(\beta) + \cos(\alpha) \cdot \sin(\beta) \\
            &\\
            \tan(\alpha + \beta) &= \frac{\tan(\alpha) + \tan(\beta)}{1 - \tan(\alpha) \cdot \tan(\beta)} \\
            \tan(\alpha - \beta) &= \frac{\tan(\alpha) - \tan(\beta)}{1 + \tan(\alpha) \cdot \tan(\beta)}
         \end{split}
         \end{equation*}
      }
   }
   \note[boxed]{
      \h3{Cofunction Identities}
      \grid[col="2"]{
         \equation{
            \sin(\theta) = \cos(\frac{1}{4}\tau - \theta)
         }
         \equation{
            \cos(\theta) = \sin(\frac{1}{4}\tau - \theta)
         }
         \equation{
            \tan(\theta) = \cot(\frac{1}{4}\tau - \theta)
         }
         \equation{
            \cot(\theta) = \tan(\frac{1}{4}\tau - \theta)
         }
         \equation{
            \csc(\theta) = \sec(\frac{1}{4}\tau - \theta)
         }
         \equation{
            \sec(\theta) = \csc(\frac{1}{4}\tau - \theta)
         }
      }
   }
   \note[boxed]{
      \h3{Ratio Identities}
      \math{
         \begin{equation*}
         \begin{split}
            \tan(90^\circ - x) & = \frac{\sin(90^\circ - x)}{\cos(90^\circ - x)} = \frac{\cos(x)}{\sin(x)} = \cot(x) \\
            \\
            \cot(90^\circ - x) & = \frac{\cos(90^\circ - x)}{\sin(90^\circ - x)} = \frac{\sin(x)}{\cos(x)} = \tan(x) \\
         \end{split}
         \end{equation*}
      }
   }
   \note[boxed]{
      \h3{Double-Angle Identities}
      \math{
         \begin{equation*}
         \begin{split}
            \sin(2\alpha) &= 2\sin(\alpha)\cos(\alpha) \\
            \cos(2\alpha) &= \cos^2(\alpha) - \sin^2(\alpha) \\
                        &= 1 - 2\sin^2(\alpha) \\
                        &= 2\cos^2(\alpha) - 1 \\
            &\\
            \tan(2\alpha) &= \frac{2\tan(\alpha)}{1 - \tan^2(\alpha)}
         \end{split}
         \end{equation*}
      }
   }
   \note[boxed]{
      \h3{Half-Angle Identities}
      \math{
         \begin{equation*}
         \begin{split}
            \sin \frac{\alpha}{2} &= \pm \sqrt{\frac{1 - \cos(\alpha)}{2}} \\
            \cos \frac{\alpha}{2} &= \pm \sqrt{\frac{1 + \cos(\alpha)}{2}} \\
            \tan \frac{\alpha}{2} &= \pm \sqrt{\frac{1 - \cos(\alpha)}{1 + \cos(\alpha)}} \\
                  &= \frac{sin(\alpha)}{1 + \cos(\alpha)} \\
                  &= \frac{1 - \cos(\alpha)}{sin(\alpha)}
         \end{split}
         \end{equation*}
      }
   }
   \note[boxed]{
      \h3{Power-Reducing Identities}
      \math{
         \begin{equation*}
         \begin{split}
            \sin^2(\alpha) &= \frac{1 - \cos(2\alpha)}{2} \\
            &\\
            \cos^2(\alpha) &= \frac{1 + \cos(2\alpha)}{2} \\
            &\\
            \tan^2(\alpha) &= \frac{1 - \cos(2\alpha)}{1 + \cos(2\alpha)}
         \end{split}
         \end{equation*}
      }
      \hr
      \equation{
         \sin\alpha\cdot\cos\alpha &= \frac{1}{2}\sin(2\alpha)
      }
   }
   \note[boxed]{
      \h3{Product-to-Sum Identities}
      \math{
         \begin{equation*}
         \begin{split}
            \sin(\alpha) \cdot \cos(\beta) &= \frac{1}{2} \Big[ \sin(\alpha + \beta) + \sin(\alpha - \beta) \Big] \\
            \cos(\alpha) \cdot \sin(\beta) &= \frac{1}{2} \Big[ \sin(\alpha + \beta) - \sin(\alpha - \beta) \Big] \\
            \cos(\alpha) \cdot \cos(\beta) &= \frac{1}{2} \Big[ \cos(\alpha + \beta) + \cos(\alpha - \beta) \Big] \\
            \sin(\alpha) \cdot \sin(\beta) &= \frac{1}{2} \Big[ \cos(\alpha - \beta) - \cos(\alpha + \beta) \Big]
         \end{split}
         \end{equation*}
      }
   }
   \note[boxed]{
      \h3{Sum-to-Product-Identities}
      \math{
         \begin{equation*}
         \begin{split}
            \sin(x) + \sin(y) &= 2 \cdot \sin\left( \frac{x + y}{2} \right) \cdot \cos\left( \frac{x - y}{2} \right) \\
            \cos(x) + \cos(y) &= 2 \cdot \cos\left( \frac{x + y}{2} \right) \cdot \cos\left( \frac{x - y}{2} \right) \\
            \sin(x) - \sin(y) &= 2 \cdot \cos\left( \frac{x + y}{2} \right) \cdot \sin\left( \frac{x - y}{2} \right) \\
            \cos(x) - \cos(y) &= -2 \sin \cos\left( \frac{x + y}{2} \right) \cdot \sin\left( \frac{x - y}{2} \right)
         \end{split}
         \end{equation*}
      }
   }
}
\h2{Trigonometric Equations}

\grid[col="2"]{
   \note[boxed]{
      \h3{Euler's Formula}
      \equation{
         e^{i x} &= \cos(x) + \mathrm{i}\sin(x)
      }
      \hr
      \equation{
         \mathrm{e}
                     &= \sum_{n = 0}^\infty \frac{1}{n!} \\
                     &= \lim_{n\to\infty} \left(1 + \frac{1}{n}\right)^n \\
                     &= \lim_{t \to 0} \left(1 + t\right)^{\frac{1}{t}}
      }
      \hr
      \equation{
         \mathrm{e}^x
                     &= 1 + \frac{x}{1!} + \frac{x^2}{2!} + \frac{x^3}{3!} + \cdots \\
                     &= \sum_{n = 0}^\infty \frac{x^n}{n!} \\
                     &= \lim_{n\to\infty} \left(1 + \frac{x}{n}\right)^n
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
      \hr
      \equation{
         z &= x + \mathrm{i}y \\
                       &= r \left(\cos\, \theta + \mathrm{i}\sin\, \theta\right)\\
                       & = r\;\mathrm{cis}\; \theta \\
      }
   }
   \note[boxed]{
      \equation{
         e^{i x} &= \cos\, x + \mathrm{i}\sin\, x \\
                     e ^{i x} &= r \left(\cos\, \theta + \mathrm{i}\sin\, \theta\right) \\
                     \left(\cos\, x + \mathrm{i}\sin\, x\right)^n &= \cos(n x) + \mathrm{i}\sin(n x) \\
      }
   }
   \note[boxed]{
      \equation{
         r &= |z| = |x + \mathrm{i}y| = \sqrt{x^2 + y^2} \\
                     r^2 &= x^2 + y^2 \\
                     \tan \theta &= \frac{y}{x} \\
                     \theta &= \arctan\left(\frac{y}{x}\right)
      }
   }
}
\grid[col="2"]{
   \note[boxed]{
      \h2{Polar Coordinate System}
      \p{Given}
      \equation{
         \tan \theta &= \frac{y}{x} \\
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
         z_1 &= r_1\;\mathrm{cis}\;\theta_1 \\
                     z_2 &= r_1\;\mathrm{cis}\;\theta_1
      }
      \p{Then}
      \equation{
         z_1 \cdot z_2 &= r_1 \cdot r_2 \;\mathrm{cis}\;\left(\theta_1 + \theta_2\right) \\
                     \frac{z_1}{z_2} &= \frac{r_1}{r_2} \;\mathrm{cis}\;\left(\theta_1 - \theta_2\right) \\
      }
      \hr
      \p{De Moivre’s Theorem}
      \equation{
         z^n &= r^n \;\mathrm{cis}\;\;n\theta
      }
      \p{De Moivre’s Theorem For Finding Roots}
      \equation{
         \underbrace{w_k = r^{\frac{1}{n}}\;\mathrm{cis}\;\frac{\theta + \tau\cdot{k}}{n}}
                     _{\begin{split}\forall\; k &= 0,1,2\cdots,n-1\\ n &\geq 1\end{split}}
      }
   }
   \note[boxed]{
      \h2{\small{Trigonometric form of a complex number}}
      \equation{
         z &= x + \mathrm{i}y \\
                       &= r \left(\cos\, \theta + \mathrm{i}\sin\, \theta\right)\\
                       & = r\;\mathrm{cis}\;\theta \\
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
         \img[width="300px", src="./old-images/matrix/trinagle-def-of-a-vector.png", center]
      }}
      \li{\p{\b{Do not divide vectors!}}}
      \li{\{\vec{v} \cdot \vec{v} = ||\vec{v}||^2 \implies \text{constant}}}
      \li{\{\vec{v} \cdot \left(\vec{v}\right)^\prime = 0}}
   }
}

\h2{Vector Operations}

\grid[col="2"]{
   \note[boxed]{
      \h3{Dot Product}
      \equation{
         \vec{a}\cdot\vec{b}
                     &=  \begin{bmatrix} a_1 \\ a_2 \\ a_3 \end{bmatrix}
                         \cdot
                         \begin{bmatrix} b_1 \\ b_2 \\ b_3 \end{bmatrix}
                     =  a_1b_1 + a_2b_2 + a_3b_3\\\\
                     \vec{a}\cdot\vec{b}
                     &=  \begin{bmatrix} a_1 \\ a_2 \end{bmatrix}
                         \cdot
                         \begin{bmatrix} b_1 \\ b_2 \end{bmatrix}
                     =  a_1b_1 + a_2b_2
      }
   }
   \note[boxed]{
      \h3{Cross Product}
      \equation{
         \vec{a}\times\vec{b}
                     &=
                     \begin{bmatrix} a_1 & a_2 & a_3 \end{bmatrix}\times\begin{bmatrix} b_1 & b_2 & b_3 \end{bmatrix}\\
                     &=
                     \mathrm{det}
                     \begin{pmatrix}
                     \mathrm{\hat{i}} & \mathrm{\hat{j}} & \mathrm{\hat{k}}\\
                     a_1 & a_2 & a_3\\
                     b_1 & b_2 & b_3
                     \end{pmatrix}\\
                     &=
                     \mathrm{\hat{i}}
                     \begin{vmatrix}
                     e & f\\
                     h & i
                     \end{vmatrix}
                     -
                     \mathrm{\hat{j}}
                     \begin{vmatrix}
                     d & f\\
                     g & i
                     \end{vmatrix}
                     +
                     \mathrm{\hat{k}}
                     \begin{vmatrix}
                     d & e\\
                     g & h
                     \end{vmatrix}\\
                     &= \mathrm{\hat{i}}\left(e i - f h\right)
                      - \mathrm{\hat{j}}\left(d i - f g\right)
                      + \mathrm{\hat{k}}\left(d h - e g\right)\\
                     &=
                     \begin{bmatrix}
                         e i - f h &
                         d i - f g &
                         d h - e g
                     \end{bmatrix}\\
                     &= \vec{c}
      }
   }
   \note[boxed]{
      \h3{Length of a Vector}
      \equation{
         |a| &= \sqrt{(a_1)^2 + (a_2)^2} \\
                     |a| &= \sqrt{(a_1)^2 + (a_2)^2 + (a_3)^2}
      }
   }
   \note[boxed]{
      \h3{Definition of Vector Addition}
      \p{If \{\vec{u}} and \{\vec{v}} are positioned so the initial point of \{\vec{v}} is at the terminal point of \{\vec{u}}, then the sum \{\vec{u} + \vec{v}} is the vector from the initial point of \{\vec{u}} to the terminal point of \{\vec{v}}.}
      \img[width="300px", src="./old-images/matrix/Definition-of-Vector-Addition.png", center]\hr
      \p{Given some vectors \{\vec{u}} and \{\vec{v}}, the vector \{\vec{u} - \vec{v}} is the vector that points from the head of \{\vec{v}} to the head of \{\vec{u}}}
      \img[center, width="200px", src="./old-images/matrix/vector-u-v.png"]
   }
}
\grid[col="3"]{
   \note[boxed]{
      \h3{Standard Basis Vectors}
      \equation{
         \mathrm{\hat{i}} &= \begin{bmatrix} 1 & 0 & 0 \end{bmatrix}\\
                     \mathrm{\hat{j}} &= \begin{bmatrix} 0 & 1 & 0 \end{bmatrix}\\
                     \mathrm{\hat{k}} &= \begin{bmatrix} 0 & 0 & 1 \end{bmatrix}
      }
      \hr
      \img[center, width="200px", src="./old-images/matrix/unit-vectors.png"]
   }
   \note[boxed]{
      \h3{Orthogonal}
      \p{Two vectors are orthogonal if and only if}
      \equation{
         \vec{a}\cdot\vec{b} = 0
      }
   }
   \note[boxed]{
      \h3{The Unit Vector}
      \equation{
         \hat{u} &= \frac{\vec{a}}{|\vec{a}|}
      }
   }
   \note[boxed]{
      \h3{\small{If \{\theta} is the angle between the vectors \{\vec{a}} and \{\vec{b}}, then}}
      \equation{
         \vec{a} \cdot \vec{a} = |\vec{a}| \cdot |\vec{a}| \cos\theta
      }
   }
   \note[boxed]{
      \h3{\small{If \{\theta} is the angle between the nonzero vectors \{\vec{a}} and \{\vec{b}}, then}}
      \equation{
         \cos\theta = \frac{\vec{a}\cdot\vec{b}}{|\vec{a}| |\vec{b}|}
      }
   }
   \note[boxed]{
      \h3{\small{Two nonzero vectors \{\vec{a}} and \{\vec{b}} are parallel if and only if}}
      \equation{
         \vec{a}\times\vec{b} = 0
      }
   }
}
\h3{Properties of the Dot Product}

\grid[col="3"]{
   \note[boxed]{
      \equation{
         \vec{a} \cdot \vec{a} = |\vec{a}|^2
      }
   }
   \note[boxed]{
      \equation{
         \vec{a} \cdot \left(\vec{b} + \vec{c}\right) = \vec{a}\vec{b} + \vec{a}\vec{c}
      }
   }
   \note[boxed]{
      \equation{
         \vec{a} \cdot \vec{b} = \vec{b} \cdot \vec{a}
      }
   }
   \note[boxed]{
      \equation{
         \left(c \cdot \vec{a}\right) \cdot \vec{b} = c\left(\vec{a} \cdot \vec{b}\right)
      }
   }
}
\h2{Direction Cosines & Direction Angles of a Vector}

\note{
   \img[center, src="./old-images/matrix/Direction-Cosines-Direction-Angles-of-a-Vector.png", width="300px"]
   \p[center]{Where}
   \equation{
      \vec{v} = \begin{bmatrix} v_x & v_y & v_z \end{bmatrix}
      ||\vec{v}|| = \sqrt{(v_x)^2 + (v_y)^2 + (v_z)^2}
   }
}

\grid[col="3"]{
   \note[boxed]{
      \h3{Direction Cosines}
      \equation{
         \cos\alpha &= \frac{v_x}{||\vec{v}||}\\
                     \cos\beta &= \frac{v_y}{||\vec{v}||}\\
                     \cos\gamma &= \frac{v_z}{||\vec{v}||}
      }
   }
   \note[boxed]{
      \h3{Direction Angles}
      \equation{
         \alpha &= \arccos \left(\frac{v_x}{||\vec{v}||}\right)\\
                     \beta &= \arccos \left(\frac{v_y}{||\vec{v}||}\right)\\
                     \gamma &= \arccos \left(\frac{v_z}{||\vec{v}||}\right)
      }
   }
   \note[boxed]{
      \h3{Theorem}
      \equation{
         \cos^2\alpha + \cos^2\beta + \cos^2\gamma = 1
      }
      \hr
      \h5{Proof}
      \equation{
         \vec{v} &= \hat{i}\cos\alpha + \hat{k}\cos\beta + \hat{k}\cos\gamma\\
                     ||\vec{v}|| &= || \hat{i}\cos\alpha + \hat{k}\cos\beta + \hat{k}\cos\gamma|| = 1
      }
      \p{Given}
      \equation{
         \sqrt{\cos^2\alpha + \cos^2\beta + \cos^2\gamma} &= 1\\
                     \sqrt{\cos^2\alpha + \cos^2\beta + \cos^2\gamma}^2 &= 1^2\\
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
         \vec{a} &= \begin{bmatrix} a_x & a_y & a_z \end{bmatrix}\\
                     \vec{b} &= \begin{bmatrix} b_x & b_y & b_z \end{bmatrix}
      }
      \p{The vectors \{\vec{a}} and \{\vec{b}} are parallel if and only if they are scalar multiples of one another.}
      \equation{
         \vec{a} &= k\;\vec{b} \;\;\;\;\forall k \neq 0
      }
      \h4{Alternatively}
      \equation{
         \frac{a_x}{b_x} = \frac{a_y}{b_y} = \frac{a_z}{b_z}
      }
   }
   \note[boxed]{
      \h3{Orthogonal Vectors}
      \ul{
         \li{When two vectors are orthogonal; they meet at right angles.}
      }\p{Given some vectors}
      \equation{
         \vec{a} &= \begin{bmatrix} a_x & a_y & a_z \end{bmatrix}\\
                     \vec{b} &= \begin{bmatrix} b_x & b_y & b_z \end{bmatrix}
      }
      \p{Two vectors are orthogonal if and only if}
      \equation{
         \vec{a}\times\vec{b} = 0
      }
   }
}
\h2{Reparameterization of the position vector \{\vec{v}(t)} in terms of length \{S(t)}}

\ul{
   \li{\p{We can parametrize a curve \b{with respect to arc length}; because arc length arises naturally from the shape of the curve and \b{does not depend on any coordinate system}.}}
}
\grid[col="2"]{
   \note[boxed]{
      \h3{The Arc Length Function}
      \p{Given}
      \equation{
         \vec{v}
                         &= \begin{bmatrix} x & y & z \end{bmatrix}
                         = \begin{bmatrix} f(t) & g(t) & h(t) \end{bmatrix}
      }
      \p{We can redefine \{\vec{v}} in terms of arc length between two endpoints}
      \math{
         \newcommand{\Long}{
                         \int_a^t \sqrt{
                             \left(f^\prime(u)\right)^2
                             \left(g^\prime(u)\right)^2
                             \left(h^\prime(u)\right)^2
                         }
                     }
                     \newcommand{\AltLong}{
                         \int_a^t \sqrt{
                             \left(\frac{\mathrm{d}x}{\mathrm{d}u}\right)^2
                             \left(\frac{\mathrm{d}y}{\mathrm{d}u}\right)^2
                             \left(\frac{\mathrm{d}z}{\mathrm{d}u}\right)^2
                         }
                     }
                     \newcommand{\short}{
                         \int_a^t ||\left(v^\prime(u)\right)||
                     }
                     \begin{equation}
                     \begin{split}
                         S(t)
                             &= \Long\\
                             &= \AltLong\\
                             &= \short
                     \end{split}
                     \end{equation}
      }\p{That is, \{S(t)} is the length of the curve (\{C}) between \{r(a)} and \{r(b)}.}
      \hr
      \p{Furthermore from the adjacent definition; we can simply the above to}
      \equation{
         S(t) = \int_a^t \frac{\mathrm{d}S}{\mathrm{d}t}
      }
   }
   \note[boxed]{
      \h3{The Arc Length Function}
      \equation{
         \frac{\mathrm{d}S}{\mathrm{d}t} \equiv || v^\prime(t) ||
      }
      \p{That is}
      \math{
         \newcommand{\Long}{
                         \sqrt{
                             \left(f^\prime(u)\right)^2
                             \left(g^\prime(u)\right)^2
                             \left(h^\prime(u)\right)^2
                         }
                     }
                     \newcommand{\AltLong}{
                         \sqrt{
                             \left(\frac{\mathrm{d}x}{\mathrm{d}u}\right)^2
                             \left(\frac{\mathrm{d}y}{\mathrm{d}u}\right)^2
                             \left(\frac{\mathrm{d}z}{\mathrm{d}u}\right)^2
                         }
                     }
                     \newcommand{\short}{
                         ||\left(v^\prime(u)\right)||
                     }
                     \begin{equation}
                     \begin{split}
                         \frac{\mathrm{d}S}{\mathrm{d}t}
                             &= \Long\\
                             &= \AltLong\\
                             &= \short
                     \end{split}
                     \end{equation}
      }
   }
}
\h2{Vectors Derived From Some Curve Defined by \{\vec{v}}}

\grid[col="2"]{
   \note[boxed]{
      \img[src="./old-images/matrix/curvature.png", center, width="300px"]
   }
   \note[boxed]{
      \h3{The Unit Vector}
      \equation{
         \hat{U} \equiv \frac{\vec{v}}{||\vec{v}||}
      }
   }
}
\grid[col="2"]{
   \note[boxed]{
      \h3{The Unit \b{Tangent} Vector}
      \equation{
         \vec{T}
         \equiv \frac{v^\prime(t)}{||v^\prime(t)||}
         \equiv \frac{\mathrm{d}v}{\mathrm{d}S}
      }
   }
   \note[boxed]{
      \h3{The Unit \b{Normal} Vector}
      \equation{
         \vec{N} \equiv \frac{T^\prime}{||T^\prime||}
      }
   }
   \note[boxed]{
      \h3{The Binormal Vector}
      \equation{
         \vec{B} \equiv \vec{T}\times\vec{N}
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
            \equiv \left|\frac{\mathrm{d}T}{\mathrm{d}S}\right|
            \equiv \frac{\left| T^\prime \right|}{\left| r^\prime \right|}
            \equiv \frac{\left| r^\prime \times r^{\prime\prime} \right|}{\left| r^\prime \right|^3}
      }
   }
   \note[boxed]{
      \h3{Tangential & Normal Components of the Acceleration Vector of the Curve}
      \p{When we study the motion of a particle, it is often useful to resolve the acceleration into two components, one in the direction of the tangent and the other in the direction of the normal.}
      \equation{
         a_{\vec{T}}
                         &= \frac{\mathrm{d}}{\mathrm{d}t} \left|\vec{v}\right|
                         = \frac{r^\prime \cdot r^{\prime\prime}}{|r^\prime|}\\
                     a_{\vec{N}}
                         &= \kappa \left|\vec{v}\right|^2
                         = \frac{\left|r^\prime \times r^{\prime\prime}\right|}{|r^\prime|}\\
         
                     \vec{a} &= a_{\vec{T}} \vec{T} + a_{\vec{N}} \vec{N}
      }
      \p{Specifically}
      \equation{
         \hbrace[right]{
            a_{\vec{T}}\\
            a_{\vec{N}}
         }
         \text{Tangential \& Normal Components of $\vec{a}$}
      }
   }
}
\h2{Vector Calculus}

\grid[col="3"]{
   \note[boxed]{
      \h3{\small{The Position Vector \{\vec{r}(t)}}}
      \p[center]{\small{(Original Function)}}
   }
   \note[boxed]{
      \h3{\small{The Velocity Vector \{\vec{v}(t)}}}
      \p[center]{\small{(First Derivative)}}
      \ul{
         \li{The velocity vector is also the tangent vector and points in the direction of the tangent line.}
         \li{The \b{speed} of the particle \u{at time t} is the \b{magnitude} of the velocity vector, that is,
                         \equation{
            \underbrace{|\vec{v}(t)| = |(\vec{r})^\prime(t)| = \frac{\mathrm{d}s}{\mathrm{d}t}}
                                _{\text{rate of change of distance with respect to time}}
         }}
      }
   }
   \note[boxed]{
      \h3{\small{The Acceleration Vector \{\vec{a}(t)}}}
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
                     \begin{vmatrix}
                     a & b\\
                     c & d
                     \end{vmatrix} =
                     ad - bc\\\\
                     |A| &=
                     \begin{vmatrix}
                     a & b & c\\
                     d & e & f\\
                     g & h & i
                     \end{vmatrix}\\ &=
                     a 
                     \begin{vmatrix}
                     e & f\\
                     h & i
                     \end{vmatrix}
                     -
                     b
                     \begin{vmatrix}
                     d & f\\
                     g & i
                     \end{vmatrix}
                     +
                     c
                     \begin{vmatrix}
                     d & e\\
                     g & h
                     \end{vmatrix}
      }
      \img[center, width="400px", src="./old-images/matrix/3x3-determinant.png"]\note[boxed]{
         \p{Only works for square matrices.}
      }
   }
   \note[boxed]{
      \h3{The Cross Product}
      \equation{
         \vec{a}\times\vec{b}
                     &=
                     \begin{bmatrix} a_1 & a_2 & a_3 \end{bmatrix}\times\begin{bmatrix} b_1 & b_2 & b_3 \end{bmatrix}\\
                     &=
                     \mathrm{det}
                     \begin{pmatrix}
                     \mathrm{\hat{i}} & \mathrm{\hat{j}} & \mathrm{\hat{k}}\\
                     a_1 & a_2 & a_3\\
                     b_1 & b_2 & b_3
                     \end{pmatrix}\\
                     &=
                     \mathrm{\hat{i}}
                     \begin{vmatrix}
                     e & f\\
                     h & i
                     \end{vmatrix}
                     -
                     \mathrm{\hat{j}}
                     \begin{vmatrix}
                     d & f\\
                     g & i
                     \end{vmatrix}
                     +
                     \mathrm{\hat{k}}
                     \begin{vmatrix}
                     d & e\\
                     g & h
                     \end{vmatrix}\\
                     &= \mathrm{\hat{i}}\left(e i - f h\right)
                      - \mathrm{\hat{j}}\left(d i - f g\right)
                      + \mathrm{\hat{k}}\left(d h - e g\right)\\
                     &=
                     \begin{bmatrix}
                         e i - f h &
                         d i - f g &
                         d h - e g
                     \end{bmatrix}\\
                     &= \vec{c}
      }
   }
}
\h1{Geometry}

\grid[boxed, col="3"]{
   \note{
      \h3{The Circle}
      \equation{
         \small\text{Area}\;\normalsize &= \pi r^2\\
                     \small\text{Circumference}\;\normalsize &= 2 \pi r
      }
   }
}

\h2{Definition of a Line}

\img[src="./old-images/matrix/vector-equation-of-a-line.png", center, width="500px"]
\grid[col="3"]{
   \note[boxed]{
      \h3{Vector Equation of a Line}
      \p{Given}
      \equation{
         \color[B]{P_1} &= \begin{bmatrix} \color[B]{x_1} & \color[B]{y_1} & \color[B]{z_1} \end{bmatrix}\\
                     \color[C]{P_2} &= \begin{bmatrix} \color[C]{x_2} & \color[C]{y_2} & \color[C]{z_2} \end{bmatrix}\\
      }
      \equation{
         \color[B]{P_1} &= \begin{bmatrix} \color[B]{x_1} & \color[B]{y_1} & \color[B]{z_1} \end{bmatrix}\\
                     \color[C]{P_2} &= \begin{bmatrix} \color[C]{x_2} & \color[C]{y_2} & \color[C]{z_2} \end{bmatrix}\\
      }
      \p{We can define a vector between \{\color[B]{P_1}} and \{\color[C]{P_2}}}
      \equation{
         \color[A]{\overrightarrow{\Delta\mathsf{v}}} &= 
                     \begin{bmatrix} \color[C]{x_2} \\ \color[C]{y_2} \\ \color[C]{z_2} \end{bmatrix} -
                     \begin{bmatrix} \color[B]{x_1} \\ \color[B]{y_1} \\ \color[B]{z_1} \end{bmatrix} =
                     \begin{bmatrix} \color[C]{x_2}-\color[B]{x_1} \\ \color[C]{y_2}-\color[B]{y_1} \\ \color[C]{z_2}-\color[B]{z_1} \end{bmatrix} =
                     \begin{bmatrix} \color[A]{\Delta_x} \\ \color[A]{\Delta_y} \\ \color[A]{\Delta_z} \end{bmatrix}
      }
      \h4{Therefore}
      \p{The equation of a line in 3D space or \{\mathbb{R}^3} can be defined VIA the following options}
      \equation{
         L &= \color[B]{P_1} + t\cdot\color[A]{\overrightarrow{\Delta\mathsf{v}}} \\
                     \begin{bmatrix} x \\ y \\ z \end{bmatrix} &= 
                     \begin{bmatrix} \color[B]{x_1} \\ \color[B]{y_1} \\ \color[B]{z_1} \end{bmatrix} +
                     t\begin{bmatrix} \color[A]{\Delta_x} \\ \color[A]{\Delta_y} \\ \color[A]{\Delta_z} \end{bmatrix} =
                     \begin{bmatrix} \color[B]{x_1} \\ \color[B]{y_1} \\ \color[B]{z_1} \end{bmatrix} +
                     \begin{bmatrix} t\;\color[A]{\Delta_x} \\ t\;\color[A]{\Delta_y} \\ t\;\color[A]{\Delta_z} \end{bmatrix} \\
                     &= 
                     \begin{bmatrix} \color[B]{x_1} + t\;\color[A]{\Delta_x} \\ \color[B]{y_1} + t\;\color[A]{\Delta_y} \\ \color[B]{z_1} + t\;\color[A]{\Delta_z} \end{bmatrix}\\
                     &= 
                     \begin{bmatrix} \color[B]{x_1} + t(\color[C]{x_2}-\color[B]{x_1}) \\ \color[C]{x_2} + t(\color[C]{x_2}-\color[B]{x_1}) \\ x_3 + t(\color[C]{x_2}-\color[B]{x_1}) \end{bmatrix}
      }
      \p{That is}
      \equation{
         L &= \color[B]{P_1} + t\cdot\color[A]{\overrightarrow{\Delta\mathsf{v}}}\\
                     \begin{bmatrix} x \\ y \\ z \end{bmatrix} &=
                     \begin{bmatrix} \color[B]{x_1} + t\;\color[A]{\Delta_x} \\ \color[B]{y_1} + t\;\color[A]{\Delta_y} \\ \color[B]{z_1} + t\;\color[A]{\Delta_z} \end{bmatrix}
                         = \begin{bmatrix} \color[B]{x_1} + t(\color[C]{x_2}-\color[B]{x_1}) \\ \color[B]{y_1} + t(\color[C]{y_2}-\color[B]{y_1}) \\ \color[B]{z_1} + t(\color[C]{z_2}-\color[B]{z_1}) \end{bmatrix}
      }
   }
   \grid{
      \note[boxed]{
         \h3{Parametric Equation of a Line}
         \equation{
            \underbrace{
               \begin{split}
                  x &= \color[B]{x_1} + t(\color[C]{x_2}-\color[B]{x_1}) = \color[B]{x_1} + t\;\color[A]{\Delta_x}\\
                  y &= \color[B]{x_1} + t(\color[C]{y_2}-\color[B]{y_1}) = \color[B]{y_1} + t\;\color[A]{\Delta_y}\\
                  z &= \color[B]{x_1} + t(\color[C]{z_2}-\color[B]{z_1}) = \color[B]{z_1} + t\;\color[A]{\Delta_z}
               \end{split}}_{
                  r \;=\; r_0 \;+\; a \;=\; r_0 \;+\; t\,v
               }
         }
      }
      \note[boxed]{
         \h3{Essentially}
         \equation{
            L &= \color[B]{P_1} + t\cdot\color[A]{\overrightarrow{\Delta\mathsf{v}}}\;\;\forall t\in\mathbb{R}
         }
         \p{That is, \{t} is the scaling factor. In a way, it's like it's a function of \{t}, but also similar to the slope (\{m}) in \{y = mx + b}, except \{m} (i.e. \{t}) is parameterized.}
         \hr
         \p{Sometimes this will be (confusingly) denoted as}
         \equation{
            \vec{r} &= \vec{r_0} + \vec{a} = \vec{r_0} + t\vec{v}\\
         }
      }
   }\note[boxed]{
      \h3{Symmetric Equation of a Line}
      \equation{
         t &= \frac{x - \color[B]{x_1}}{\color[C]{x_2}-\color[B]{x_1}} = \frac{x - \color[B]{x_1}}{\color[A]{\Delta_x}}\\
                     t &= \frac{y - \color[B]{y_1}}{\color[C]{y_2}-\color[B]{y_1}} = \frac{y - \color[B]{y_1}}{\color[A]{\Delta_y}}\\
                     t &= \frac{z - \color[B]{z_1}}{\color[C]{z_2}-\color[B]{z_1}} = \frac{z - \color[B]{z_1}}{\color[A]{\Delta_z}}
      }
      \p{Therefore}
      \equation{
         \frac{x - \color[B]{x_1}}{\color[A]{\Delta_x}}
                        &= \frac{y - \color[B]{y_1}}{\color[A]{\Delta_y}}
                         = \frac{z - \color[B]{z_1}}{\color[A]{\Delta_z}}
                     \\\\
                           \frac{x - \color[B]{x_1}}{\color[C]{x_2}-\color[B]{x_1}}
                        &= \frac{y - \color[B]{y_1}}{\color[C]{y_2}-\color[B]{y_1}}
                        =  \frac{z - \color[B]{z_1}}{\color[C]{z_2}-\color[B]{z_1}}
      }
      \hr
      \h4{Rationale}
      \p{We rewrite \{r = r_0 + a = r_0 + t v} in terms of \{t}.}
      \p{That is}
      \equation{
         x &= \color[B]{x_1} + t(\color[C]{x_2}-\color[B]{x_1}) = \color[B]{x_1} + t\;\color[A]{\Delta_x}\\
                     t\;\color[A]{\Delta_x}  &= x - \color[B]{x_1} = t(\color[C]{x_2}-\color[B]{x_1})\\
                     t &= \frac{x - \color[B]{x_1}}{\color[C]{x_2}-\color[B]{x_1}} = \frac{x - \color[B]{x_1}}{\color[A]{\Delta_x}} \\\\
                     y &= \color[B]{y_1} + t(\color[C]{y_2}-\color[B]{y_1}) = \color[B]{y_1} + t\;\color[A]{\Delta_y}\\
                     t\;\color[A]{\Delta_y}  &= y - \color[B]{y_1} = t(\color[C]{y_2}-\color[B]{y_1})\\
                     t &= \frac{y - \color[B]{y_1}}{\color[C]{y_2}-\color[B]{y_1}} = \frac{y - \color[B]{y_1}}{\color[A]{\Delta_y}} \\\\
                     z &= \color[B]{z_1} + t(\color[C]{z_2}-\color[B]{z_1}) = \color[B]{z_1} + t\;\color[A]{\Delta_z}\\
                     t\;\color[A]{\Delta_z} &= z - \color[B]{z_1} = t(\color[C]{z_2}-\color[B]{z_1}) \\
                     t &= \frac{z - \color[B]{z_1}}{\color[C]{z_2}-\color[B]{z_1}} = \frac{z - \color[B]{z_1}}{\color[A]{\Delta_z}}
      }
   }
}
\h2{Parameterizations of a curve}

\dl{\dt{Parametrized curve}\dd{A curve in the plane is said to be parameterized if the set of coordinates on the curve, (x,y), are represented as functions of a variable t.}\dd{A parametrized Curve is a path in the xy-plane traced out by the point \{\left(x(t), y(t)\right)} as the parameter \{t} ranges over an interval \{I}.}\dd{A parametrized Curve is a path in the xyz-plane traced out by the point \{\left(x(t), y(t), z(t)\right)} as the parameter \{t} ranges over an interval \{I}.}}
\h2{Curvature Properties}

\grid[col="3"]{
   \note[boxed]{
      \h3{Length of a Curve}
      \math{
         \newcommand{\Long}{
                         \int_a^b \sqrt{
                             \left(f^\prime(t)\right)^2
                             \left(g^\prime(t)\right)^2
                             \left(h^\prime(t)\right)^2
                         }
                     }
                     \newcommand{\AltLong}{
                         \int_a^b \sqrt{
                             \left(\frac{\mathrm{d}x}{\mathrm{d}t}\right)^2
                             \left(\frac{\mathrm{d}y}{\mathrm{d}t}\right)^2
                             \left(\frac{\mathrm{d}z}{\mathrm{d}t}\right)^2
                         }
                     }
                     \newcommand{\short}{
                         \int_a^b ||\left(r^\prime(t)\right)||
                     }
                     \begin{equation}
                     \begin{split}
                         L &= \Long\\
                           &= \AltLong\\
                           &= \short\\
                           &\implies \text{some constant}
                     \end{split}
                     \end{equation}
      }
   }
   \note[boxed]{
      \h3{The Arc Length Function}
      \p{Suppose}
      \ul{
         \li{\p{Given some curve \{C} defined by some vector \{\vec{r}} in \{\mathbb{R}^3}}}
         \li{\p{where \{r^\prime} is continuous and \{C} is traversed exactly once as \{t} increases from \{a} to \{b}}}
      }\p{We can define it's arc length function VIA}
      \math{
         \newcommand{\Long}{
               \int_a^t \sqrt{
                  \left(f^\prime(u)\right)^2
                  \left(g^\prime(u)\right)^2
                  \left(h^\prime(u)\right)^2
               }
         }
         \newcommand{\AltLong}{
               \int_a^t \sqrt{
                  \left(\frac{\mathrm{d}x}{\mathrm{d}u}\right)^2
                  \left(\frac{\mathrm{d}y}{\mathrm{d}u}\right)^2
                  \left(\frac{\mathrm{d}z}{\mathrm{d}u}\right)^2
               }
         }
         \newcommand{\short}{
               \int_a^t ||\left(r^\prime(u)\right)||
         }
\begin{equation**}
\begin{split}
S(t)
&= \Long\\
&= \AltLong\\
&= \short
\end{split}
\end{equation*}
}
}
}*