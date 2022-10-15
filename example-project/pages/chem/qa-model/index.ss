/// This file was auto-translated from the original HTML source, it is pretty messy. 
\h2{Quantum Mechanical Models of the Atom}

\h3{The Electromagnetic Spectrum}

\img[src="../../images/chem/5.svg", max-width="100%"]
\h3{Terms}

\dl{\dt{Pauli Exclusion Principle}\dd{No two electrons in an atom can have the same four quantum numbers.}\dd{Pauli’s Principle prevents two electrons with the same spin from existing in the same subshell,
        each subshell will be filled with one spin direction before they are filled with the opposite spin.
        This is the second of Hund’s Rules.}\dt{Aufbau Principle}\dd{This pattern of orbital filling is known as the aufbau principle (the German word aufbau means “build up”).}\dt{Hund’s rule}\dd{When filling degenerate orbitals, electrons fill them singly first, then with parallel spins.}\dd{I.e. start by filling boxes with single 'upward' arrows, and then once all of such boxes are maxed out,
        then you add double arrows pointing in opposite directions.}\dd{Pauli’s Principle prevents two electrons with the same spin from existing in the same subshell,
        each subshell will be filled with one spin direction before they are filled with the opposite spin.
        This is the second of Hund’s Rules.}\dt{Coulomb’s Law}\dd{\equation{
   \mathrm{E} &= \frac{1}{4\pi\varepsilon_0}\cdot\frac{q_1\;q_2}{r}
}}}
\grid[col="2", boxed]{
   \note{
      \h4{Aufbau Principle}
      \img[src="../../images/chem/18.svg", max-width="900px"]
   }
   \note{
      \h4{Hund’s rule}
      \img[max-width="900px", src="../../images/chem/19.svg"]
   }
   \note{
      \h4{Pauli's Exclusion Principle}
      \p{Each election has a unique set of four quantum numbers (i.e. see quantum numbers).
                  They are}
      \ul{
         \li{\{\mathrm{n}}}
         \li{\{\mathrm{l}}}
         \li{\{\mathrm{m}_l}}
         \li{\{\mathrm{m}_s}}
      }
   }
}
\h3{Overview}

\img[max-width="500px", src="../../images/chem/4.svg"]
\grid[col="1"]{
   \note{
      \h4{Formulas}
      \grid[col="3"]{
         \equation{
            \mathrm{f} = \nu &= \frac{c}{\lambda}
         }
         \equation{
            \mathrm{\lambda} = \frac{\smallText{speed}}{\smallText{frequency}}
         }
         \equation{
            \mathrm{E}
                            &= \mathrm{h}\times\mathrm{f}\\
                            &= \mathrm{h}\frac{\mathrm{c}}{\lambda}
         }
         \equation{
            \mathrm{T} &= \frac{1}{f}
         }
         \equation{
            \lambda &= \frac{c}{f}
         }
      }
   }
   \note{
      \h4{Values}
      \table{
         \thead{
            \tr{
               \th{Name}
               \th{Symbol}
               \th{Unit}
               \th{Description}
               \th{Range}
            }
         }\tbody{
            \tr{
               \th{Wavelength}
               \td{\{\mathrm{\lambda}}}\td{Any unit for distance}\td{Distance between two analogous points}\td{Always Positive}
            }\tr{
               \th{Frequency}
               \td{\{f} or \{\nu} (nu)}\td{\span[style="display: flex; justify-content: space-between;"]{\{㎐ = \frac{\text{1 cycle}}{\text{second}}}\{\mathrm{s}^{-1}}}}\td{Number of cycles}\td{Always Positive}
            }\tr{
               \th{Energy}
               \td{\{\mathrm{E}}}\td{\span[style="display: flex; justify-content: space-between;"]{\span{\{\mathrm{J}} (joule)}}}\td{Amount of energy (\{\mathrm{E}}) in a light packet}\td
            }
         }
      }
   }
   \note{
      \h4{Constants}
      \table{
         \thead{
            \tr{
               \th{Name}
               \th{Symbol}
               \th{Unit}
               \th{Value}
            }
         }
         \tbody{
            \tr{
               \th{Speed of Light}
               \td{\{\mathrm{c}}}
               \td{\{\\frac{\\mathrm{m}}{\\mathrm{s}}}}
               \td{\{\mathrm{c} = \sci{3.00}{8}\\frac{\\mathrm{m}}{\\mathrm{s}}}}
            }
            \tr{
               \th{Planck's constant}
               \td{\{\mathrm{h}}}
               \td{
                  \ul{
                     \li{Energy multiplied by time}
                     \li{joule-seconds}
                     \li{\{\mathrm{J}\cdot\mathrm{s}}}
                  }
               }
               \td{\{\mathrm{h} = \sci{6.626}{-34}\;\mathrm{J}\cdot\mathrm{s}}}
            }
         }
      }
   }
   \note{
      \h4{Other Formulas}
      \grid[boxed, col="2"]{
         \note{
            \h5{de Broglie Relation}
            \equation{
               \lambda &= \frac{\mathrm{h}}{\mathrm{m}\mathrm{v}}\\
               \text{where}&\\
                  m &= \text{mass}\\
                  v &= \text{velocity} \neq \nu\;\text{(nu)}
            }
         }
         \note{
            \h5{Heisenberg's Uncertainty Principle}
            \equation{
               \Delta{x} \times \mathrm{m} \Delta{v} \geq \frac{\mathrm{h}}{4\pi}
            }
            \p{Where}
            \ul{
               \li{\{\Delta{x}} is the uncertainty in position.}
               \li{\{\Delta{v}} is the uncertainty in velocity.}
               \li{\{\mathrm{m}} is the mass of the particle.}
               \li{\{\mathrm{h}} is the plank's constant.}
            }\p{In general it states that the more you know about an electrons position,
                                the less you know about it's velocity.}
         }
         \note{
            \h5{Energy of an Electron in an Orbital with Quantum Number \{\mathrm{n}} in a Hydrogen Atom}
            \equation{
               E_n &= \sci{-2.18}{-18} \mathrm{J} \left(\frac{1}{n^2}\right)
            }
         }
         \note{
            \h5{Energy of an Electron in an Orbital with Quantum Number \{\mathrm{n}} for any atom}
            \equation{
               E_n &= \sci{-2.18}{-18} \mathrm{J} \left(\frac{1}{n^2}\right) \cdot \mathrm{Z}^2
            }
            \p{Where \{\mathrm{Z}} is the atomic number of the given element.}
         }
         \note{
            \h5{Change in Energy That Occurs in an Atom When It Undergoes a Transition between Levels \a[href="#atomic-spectroscopy-detailed"]{(Further Details)}}
            \p[center]{\{n_{\small\text{initial}}} and \{n_{\small\text{final}}}}
            \equation{
               \Delta{E} &= \sci{-2.18}{-18} \mathrm{J} \left(\frac{1}{n^2_f} - \frac{1}{n^2_i}\right)
            }
            \ul{
               \li{If \{\Delta{E}} is negative, energy is being released.}
               \li{If \{\Delta{E}} is positive, energy is being absorbed.}
            }
         }
         \note{
            \h5{Ionization Energy}
            \equation{
               \mathrm{IE}_{n,\smallText{Big Jump}} -1
                  &= \smallText{\# of valance electrons}\\
                  &= \smallText{Element row \#}
            }
            \p{Where}
            \ul{
               \li{\{n} is the electron number}
               \li{\{\smallText{Big jump}} the point on the table where you see the highest difference/delta.}
            }
         }
      }
   }
}
\h4{Atomic Spectroscopy}

\grid[col="2", boxed]{
   \note[id="atomic-spectroscopy-detailed"]{
      \h5{The Principal Quantum Number (n) (Hydrogen Atom)}
      \p{For the hydrogen atom, the energy of an electron in an orbital with quantum number \{n} is given by}
      \equation{
         E_n = \sci{-2.18}{-18}\mathrm{J}\;\frac{1}{n^2}
      }
      \p{Therefore the difference in energy is given by the following}
      \equation{
         \Delta E &= \Delta E_{\smallText{Final}} - \Delta E_{\smallText{Initial}}\\
                              &= \left(\sci{-2.18}{-18}\mathrm{J}\;\frac{1}{{n_f}^2}\right)
                              -  \left(\sci{-2.18}{-18}\mathrm{J}\;\frac{1}{{n_i}^2}\right)\\
                              &= \sci{-2.18}{-18}\mathrm{J}\;\frac{1}{{n_f}^2}
                              +  \sci{2.18}{-18}\mathrm{J}\;\frac{1}{{n_i}^2}\\
                              &= \sci{-2.18}{-18}\mathrm{J}\; \left(\frac{1}{{n_f}^2} - \frac{1}{{n_i}^2}\right)
      }
   }
   \note[id="atomic-spectroscopy-detailed"]{
      \h5{The Principal Quantum Number (n) (Any Atom)}
      \p{For the hydrogen atom, the energy of an electron in an orbital with quantum number \{n} is given by}
      \p{TODO}
      \equation{
         E_n &= \sci{-2.18}{-18} \mathrm{J} \left(\frac{1}{n^2}\right) \cdot \mathrm{Z}^2
      }
      \p{Where \{\mathrm{Z}} is the atomic number of the given element.}
   }
}
\h4{Electron Configuration}

\grid[col="2", boxed]{
   \note{
      \h5{Traditional Chart}
      \img[src="../../images/chem/8.svg", max-width="600px"]\img[src="../../images/chem/20.svg", max-width="600px"]
   }
   \note{
      \h5{Better Method}
      \img[max-width="600px", src="../../images/chem/9.svg"]
   }
}
\h5{Examples}

\grid[col="2"]{
   \note{
      \h6{Electron configuration for \{_{26}\mathrm{Fe}}}
      \equation{
         \ce{\underbrace{1s^2 2s^2 2p^6 3s^2 3p^6}_{\smallText{Equal to Argon}} 4s^2 3d^6}
                      &= \ce{[Ar] 4s^2 3d^6}
      }
      \p{Since the electron configuration for Argon is}
      \equation{
         \ce{[Ar] = 1s^2 2s^2 2p^6 3s^2 3p^6}
      }
   }
   \note{
      \h6{Electron configuration for \{_{26}\mathrm{Fe}^{+2}}}
      \p{Beginning with the electron configuration for \{_{26}\mathrm{Fe}}}
      \equation{
         \underbrace{1s^2\; 2s^2\; 2p^6\; 3s^2\; 3p^6}_{\smallText{Equal to Argon}}\;
                         \overbrace{4s^2\; 3d^6}^{\mathclap{
                             \begin{gathered}
                             \smallText{Which should we remove 2 $\mathrm{e}^{-}$ from?}\\
                             \smallText{($4s^2$ or $3d^6$)?}\\
                             \end{gathered}
                         }}
                         &= \ce{[Ar]
                                 \underbrace{4s^2\; 3d^6}_{\mathclap{
                                     \begin{gathered}
                                     \smallText{Which should we remove 2 $\mathrm{e}^{-}$ from?}\\
                                     \smallText{($4s^2$ or $3d^6$)?}\\
                                     \end{gathered}
                                 }}
                             }
      }
      \p{Remove the electrons from the term with the higher electron state. 
                  \mark[font]{Warning!} Do not \u{just} remove the electrons
                  from the rightmost term since the rightmost term may be a lower electron
                  state. For instance given \{4s^2\; 3d^6}}
      \ul{
         \li{\{4s^2} is in a \mark[font]{higher} electron state}
         \li{\{3d^6} is in a \mark[font]{lower} electron state}
      }\grid[boxed, col="1"]{
         \note{
            \p{Alternatively, to compute the lowest energy orbital, add the principle quantum number (\{n})
                                to the The angular momentum quantum number (\{l}) to get the orbital with the lowest energy.
                                Therefore}
            \equation{
               \smallText{orbital with the lowest energy} &= O_{\smallText{min}} = n + l\\
            }
            \p{Given \{\ce{4s^2}} and \{\ce{3d^6}}}
            \grid[col="2"]{
               \equation{
                  \ce{4s^2}\;\hbrace[left]{
                     n &= 4\\
                     i &= 0\\
                     \therefore\; O_{\smallText{min}} &= 4
                  }
               }
               \equation{
                  \ce{3d^6}\; \hbrace[left]{
                     n &= 3\\
                     i &= 2\\
                     \therefore\; O_{\smallText{min}} &= 5
                  }
               }
            }\p{NVM this is an exception to the rule...}
            \p{TODO move this somewhere else...}
         }
      }\p{As shown}
      \equation{
         \underbrace{1s^2\; 2s^2\; 2p^6\; 3s^2\; 3p^6}\;
                         \overbrace{4s^{\left(2 - 2\right)}}^{ \mathclap{
                             \begin{gathered}
                             \smallText{higher state}\\
                             \smallText{remove $2\mathrm{e^{-}}$}
                             \end{gathered}
                         }}\;
                         \underbrace{3d^6}_{ \mathclap{\smallText{lower state}}}\;
                         &= [\mathrm{Ar}]\;
                         \overbrace{4s^{\left(2 - 2\right)}}^{ \mathclap{
                             \begin{gathered}
                             \smallText{higher state}\\
                             \smallText{remove $2\mathrm{e^{-}}$}
                             \end{gathered}
                         }}\;
                         \underbrace{3d^6}_{ \mathclap{\smallText{lower state}}}\\\\
                     \underbrace{1s^2\; 2s^2\; 2p^6\; 3s^2\; 3p^6}\;
                         \underbrace{3d^6}_{ \mathclap{\smallText{unchanged}}}\;
                         &= [\mathrm{Ar}]\;
                         \underbrace{3d^6}_{ \mathclap{\smallText{unchanged}}}
      }
      \p{Therefore the electron configuration for \{_{26}\mathrm{Fe}^{+2}} is:}
      \equation{
         \ce{1s^2 2s^2 2p^6 3s^2 3p^6 3d^6}
                         &= \ce{[Ar] 3d^6}
      }
   }
   \note{
      \h6{Electron configuration for \{_{24}\mathrm{Cr}}}
      \p{It would appear that the electron configuration for \{_{24}\mathrm{Cr}} would be}
      \equation{
         \overbrace{1s^2\; 2s^2\; 2p^6\; 3s^2\; 3p^6}^{\smallText{Equal to Argon}}\;
                         \underbrace{4s^2\; 3d^4}_{ \mathclap{\smallText{this is wrong!}}}\;
                     &= [\mathrm{Ar}]\;
                         \underbrace{4s^2\; 3d^4}_{ \mathclap{\smallText{this is wrong!}}}\;
      }
      \p{But this is wrong! It's actually}
      \equation{
         \overbrace{1s^2\; 2s^2\; 2p^6\; 3s^2\; 3p^6}^{\smallText{Equal to Argon}}\;
                         \underbrace{4s^1\; 3d^5}_{ \mathclap{\smallText{notice the superscripts}}}\;
                     &= [\mathrm{Ar}]\;
                         \underbrace{4s^1\; 3d^5}_{ \mathclap{\smallText{notice the superscripts}}}\;
      }
   }
}
\h5{How-tos}

\h6{What are the valence electrons?}

\grid[col="2", boxed]{
   \note{
      \p{Given}
      \equation{
         \ce{1s^2 2s^2 2p^6 3s^2 3p^4}
      }
      \p{The valance electrons will be the ones in the highest energy state. Therefore}
      \equation{
         \overbrace{1s^2\; 2s^2\; 2p^6}^{\mathclap{
                         \smallText{Core electrons}
                     }}\;
                     \underbrace{3s^2\;3p^4}_{\mathclap{
                         \begin{gathered}
                         \smallText{Highest state}\\
                         \smallText{Therefore these are the valence electrons}
                         \end{gathered}
                     }}
      }
      \p{Therefore there are \{6} valence electrons.}
   }
   \note{
      \p{Given}
      \equation{
         \ce{[Ne] 3s^2 3p^2}
      }
      \p{The valance electrons will be the ones in the highest energy state. Therefore}
      \equation{
         [\mathrm{Ne}]
                     \underbrace{3s^2 3p^2}_{\mathclap{
                         \begin{gathered}
                         \smallText{Highest state}\\
                         \smallText{Therefore these are the valence electrons}
                         \end{gathered}
                     }}
      }
      \p{Therefore there are \{4} valence electrons.}
   }
}
\h4{Quantum Numbers}

\h5{Overview}

\grid[col="2", style="max-width: 900px; margin: 0 auto; grid-template-columns: max-content;"]{
   \table{
      \thead{
         \tr{
            \th{Symbol}
            \th{Description}
         }
      }\tbody{
         \tr{
            \th{\{\mathrm{n}}}
            \td{The principle quantum number}
         }\tr{
            \th{\{l}}
            \td{The angular momentum quantum number}
         }\tr{
            \th{\{\mathrm{m}_1}}
            \td{The magnetic quantum number}
         }\tr{
            \th{\{\mathrm{m}_s}}
            \td{The spin quantum number}
         }
      }
   }
}
\h5{The Principle Quantum Number (\{\mathrm{n}})}

\grid[col="2"]{
   \table{
      \thead{
         \tr{
            \th{Value of \{\mathrm{n}}}
            \th{Value of \{l}}
            \th{Orbital Sublevel}
         }
      }\tbody{
         \tr{
            \th{\{\mathrm{n} = 1}}
            \td{\{l = 0}}\th{\span[style="display: flex; justify-content: space-between; column-gap: 8px;"]{\{1\mathrm{s}}}}
         }\tr{
            \th{\{\mathrm{n} = 2}}
            \th{\span[style="display: flex; justify-content: space-between; column-gap: 8px;"]{\{l = 0}\{l = 1}}}
            \th{\span[style="display: flex; justify-content: space-between; column-gap: 8px;"]{\{2\mathrm{s}}\{2\mathrm{p}}}}
         }\tr{
            \th{\{\mathrm{n} = 3}}
            \th{\span[style="display: flex; justify-content: space-between; column-gap: 8px;"]{\{l = 0}\{l = 1}\{l = 2}}}
            \th{\span[style="display: flex; justify-content: space-between; column-gap: 8px;"]{\{3\mathrm{s}}\{3\mathrm{p}}\{3\mathrm{d}}}}
         }\tr{
            \th{\{\mathrm{n} = 4}}
            \th{\span[style="display: flex; justify-content: space-between; column-gap: 8px;"]{\{l = 0}\{l = 1}\{l = 2}\{l = 3}}}
            \th{\span[style="display: flex; justify-content: space-between; column-gap: 8px;"]{\{4\mathrm{s}}\{4\mathrm{p}}\{4\mathrm{d}}\{4\mathrm{f}}}}
         }
      }
   }
}
\h5{Angular Momentum Quantum Number}

\grid[col="2", style="max-width: 900px; margin: 0 auto; grid-template-columns: max-content;"]{
   \table{
      \thead{
         \tr{
            \th{Value}
            \th{Result}
         }
      }\tbody{
         \tr{
            \th{\{l = 0}}
            \td{\{\mathrm{s}}}
         }\tr{
            \th{\{l = 1}}
            \td{\{\mathrm{p}}}
         }\tr{
            \th{\{l = 2}}
            \td{\{\mathrm{d}}}
         }\tr{
            \th{\{l = 3}}
            \td{\{\mathrm{f}}}
         }
      }
   }\table{
      \thead{
         \tr{
            \th{Value of \{l}}
            \th{Value of \{\mathrm{m_l}}}
         }
      }\tbody{
         \tr{
            \th{\{l = 0}}
            \th{\span[style="display: flex; justify-content: space-between; column-gap: 8px;"]{\{\mathrm{m_l} = 0}}}
         }\tr{
            \th{\{l = 1}}
            \th{\span[style="display: flex; justify-content: space-between; column-gap: 8px;"]{\{\mathrm{m_l} = -1}\{\mathrm{m_l} = 0}\{\mathrm{m_l} = 1}}}
         }\tr{
            \th{\{l = 2}}
            \th{\span[style="display: flex; justify-content: space-between; column-gap: 8px;"]{\{\mathrm{m_l} = -2}\{\mathrm{m_l} = -1}\{\mathrm{m_l} = 0}\{\mathrm{m_l} = 1}\{\mathrm{m_l} = 2}}}
         }\tr{
            \th{\{l = 2}}
            \th{\span[style="display: flex; justify-content: space-between; column-gap: 8px;"]{\{\mathrm{m_l} = -3}\{\mathrm{m_l} = -2}\{\mathrm{m_l} = -1}\{\mathrm{m_l} = 0}\{\mathrm{m_l} = 1}\{\mathrm{m_l} = 2}\{\mathrm{m_l} = 3}}}
         }
      }
   }
}
\h5{Summary}

\grid[col="3", boxed]{
   \equation{
      l \leq \mathrm{n} - 1
   }
   \equation{
      -l \leq \mathrm{m_l} \leq l
   }
}
\h5{Useful Formulas}

\grid[col="2", boxed]{
   \note{
      \p{The equation for a maximum number of electrons a given energy level can
                  hold given some value for \{n}}
      \equation{
         \text{max}_{\mathrm{e}^{-}} &= 2n^2
      }
   }
   \note{
      \p{How many orbitals are possible given some value for \{n}}
      \equation{
         \text{max}_{\smallText{orbitals}} &= n^2
      }
   }
}
\h5{Examples}

\grid[boxed, col="2"]{
   \note{
      \img[max-width="600px", src="../../images/chem/10.svg"]
   }
   \note{
      \img[src="../../images/chem/12.svg", max-width="600px"]
   }
   \note{
      \img[src="../../images/chem/11.svg", max-width="600px"]
   }
}
\h4{Light}

\h5{Interference and Diffraction}

\grid[boxed, col="2"]{
   \note{
      \h6{Constructive Interference}
      \p{If two waves of equal amplitude are in phase when they interact—that is, they
                  align with overlapping crests—a wave with \mark[font]{twice the amplitude} results. This is
                  called \mark[font]{constructive interference}.}
      \img[max-width="800px", src="../../images/chem/6.svg"]
   }
   \note{
      \h6{Destructive Interference}
      \p{If two waves are \mark[font]{completely out of phase} when they interact—that is, they
                  align so that the crest from one overlaps with the trough from the other—the waves
                  cancel by \mark[font]{destructive interference}.}
      \img[max-width="800px", src="../../images/chem/7.svg"]
   }
}