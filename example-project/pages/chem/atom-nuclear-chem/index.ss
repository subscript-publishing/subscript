/// This file was auto-translated from the original HTML source, it is pretty messy. 
\h1{The Atom and Nuclear Chemistry}

\h2{Isotopes and Subatomic Particles}

\h2{Electrons and Quantum Mechanics}

\h2{Average Atomic Mass}

\grid[col="2", boxed]{
   \note{
      \p{If the average atomic mass of boron is \{10.81\;\mathrm{amu}}, what is the percent abundance of boron-11 (mass of \{11.009306\;\mathrm{amu}}) if the only other isotope is boron-10 (mass of \{10.012937\;\mathrm{amu}})? Given the formula for average atomic mass:}
      \equation{
         \smallText{adv. mass} &= \sum \left(\smallText{percent abundance} \times \smallText{mass}\right)\\
      }
      \p{Therefore in summary, we are given the following known quantities}
      \equation{
         \smallText{average atomic mass} &= 10.81\;\mathrm{amu}\\
                     \smallText{boron-11 mass} &= 11.009306\;\mathrm{amu}\\
                     \smallText{boron-10 mass} &= 10.012937\;\mathrm{amu}
      }
      \p{With the following unknown quantities}
      \equation{
         \smallText{boron-11 % abundance} &= X_{\smallText{B-11}}\\
                     \smallText{boron-10 % abundance} &= X_{\smallText{B-10}}
      }
      \p{And asked to find the percent abundance of boron-11 (\{X_{\smallText{B-11}}}). Therefore our equation is}
      \math{
         \small
                     \begin{gather*}
                     \underbrace{10.81\;\mathrm{amu}}_{\mathclap{\smallText{avg}_m}}
                          = X_{\smallText{B-11}} \times \underbrace{11.009306\;\mathrm{amu}}_{\mathclap{\smallText{M}_1}}
                          + X_{\smallText{B-10}} \times \underbrace{10.012937\;\mathrm{amu}}_{\mathclap{\smallText{M}_2}}\\
                     \underbrace{\smallText{avg}_m = X_{\smallText{B-11}} \times M_1 + X_{\smallText{B-10}} \times M_2}_{\smallText{shorthand}}
                     \end{gather*}
      }\p{We have two unknowns, but luckily we can use the following fact/relation and therefore express the percent abundance of boron-10 in terms of the percent abundance of boron-11}
      \equation{
         X_{\smallText{B-11}} + X_{\smallText{B-10}} = 100\% = 1\\
                     X_{\smallText{B-10}} = 1 - X_{\smallText{B-11}}
      }
      \p{Therefore}
      \equation{
         \small
         \smallText{avg}_m &= X_{\smallText{B-11}} M_1 + X_{\smallText{B-10}} M_2\\
         \smallText{avg}_m &= X_{\smallText{B-11}} M_1 + \left(1 - X_{\smallText{B-11}}\right) M_2\\
         \smallText{avg}_m &= X_{\smallText{B-11}} M_1 + M_2 - X_{\smallText{B-11}} M_2\\
         \smallText{avg}_m - M_2 &= X_{\smallText{B-11}} \left(M_1 - M_2\right)\\
         \frac{\smallText{avg}_m - M_2}{M_1 - M_2} &= X_{\smallText{B-11}}\\
         \therefore X_{\smallText{B-11}}
               &= \frac{\smallText{avg}_m - M_2}{M_1 - M_2}\\
               &= \frac{10.81\;\mathrm{amu} - 10.012937\;\mathrm{amu}}{11.009306\;\mathrm{amu} - 10.012937\;\mathrm{amu}}\\
               &\approx \underbrace{0.7995}_{\mathclap{
                  \begin{gathered}
                  \smallText{decimal form}\\
                  \smallText{multiply by $100$ to get percentage}
                  \end{gathered}
               }}\\
               &\approx 79.95\%
      }
      \p{But we aren't done, we have to compute significant figures.}
      \math{
         \begin{gather*}
                     \small
                     X_{\smallText{B-11}} =
                     \left.
                     \begin{array}{ll}
                     \frac{
                         \overbrace{10.81\;\mathrm{amu} - 10.012937\;\mathrm{amu}}^{\text{2 sig decimal places}}
                     }{
                         \underbrace{11.009306\;\mathrm{amu} - 10.012937\;\mathrm{amu}}_{\text{8 sig decimal places}}
                     }\\
                     \end{array}
                     \right\}
                     \therefore\;\smallText{2 sig figs}
                     \end{gather*}
      }\p{Therefore, we round our answer to 2 sig figs, yielding \{80.\%}}
   }
}