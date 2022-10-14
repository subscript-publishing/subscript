/// This file was auto-translated from the original HTML source, it is pretty messy. 
\h1{Kinematic Equations in 1D}

\grid[boxed, col="1"]{
   \note{
      \grid[col="2"]{
         \note{
            \h2{Conventions}
            \equation{
               \bar{v} &= \text{Average velocity}\\
                                   \bar{a} &= \text{Average acceleration}\\
                                   \text{Time} = \Delta{t} &= t_2 - t_1\\
                                   \text{Displacement} = \Delta{x} &= x_2 - x_1\\
                                   \Delta{v} &= v_2 - v_1\\
            }
         }
         \note{
            \h5{Graphical Representation}
            \img[src="../images/physics/4.svg", max-width="900px", min-width="600px"]
         }
      }
   }
}
\grid[col="1", boxed]{
   \note{
      \h2{Standard Equations}
      \grid[col="3"]{
         \equation{
            v_2 &= v_1 + a\Delta{t}
         }
         \equation{
            (v_2)^2 &= (v_1)^2 + 2a\Delta{x}
         }
         \equation{
            \Delta{x} &= v_1 \Delta{t} + \frac{1}{2}a\Delta{t^2}\\
                                      &= v_2\Delta{t} - \frac{1}{2}a\Delta{t^2}\\
                                      &= \left(\frac{v_2 + v_1}{2}\right)\Delta{t}
         }
      }\h2{Summary}
      \div[table-wrapper]{
         \table{
            \thead{
               \tr{
                  \th{Formula}
                  \th{Missing}
                  \th{Quantities Present}
               }
            }\tbody{
               \tr{
                  \th{\{v_2 = v_1 + a\Delta{t}}}
                  \td{\{\Delta{x}}}\td{\span[style="display: flex; justify-content: space-between;"]{\{v_1}\{v_2}\{a}\{\Delta{t}}}}
               }\tr{
                  \th{\{\Delta{x} = \left(\frac{v_2 + v_1}{2}\right)\Delta{t}}}
                  \td{\{a}}\td{\span[style="display: flex; justify-content: space-between;"]{\{\Delta{x}}\{v_1}\{\Delta{t}}\{v_2}}}
               }\tr{
                  \th{\{\Delta{x} = v_1 \Delta{t} + \frac{1}{2}a\Delta{t^2}}}
                  \td{\{v_2}}\td{\span[style="display: flex; justify-content: space-between;"]{\{\Delta{x}}\{v_1}\{\Delta{t}}\{a}}}
               }\tr{
                  \th{\{\Delta{x} = v_2\Delta{t} - \frac{1}{2}a\Delta{t^2}}}
                  \td{\{v_1}}\td{\span[style="display: flex; justify-content: space-between;"]{\{\Delta{x}}\{v_2}\{\Delta{t}}\{a}}}
               }\tr{
                  \th{\{(v_2)^2 = (v_1)^2 + 2a\Delta{x}}}
                  \td{\{\Delta{t}}}\td{\span[style="display: flex; justify-content: space-between;"]{\{\Delta{x}}\{v_1}\{v_2}\{a}}}
               }
            }
         }
      }
   }
}
\grid[boxed, col="1"]{
   \note{
      \h2{Basics}
      \grid[col="3"]{
         \note{
            \h4{Constant Velocity}
            \equation{
               \bar{v} &= \frac{\Delta{x}}{\Delta{t}}\\
                                   \Delta{x} &= \bar{v}\Delta{t}
            }
         }
         \note{
            \h4{Uniform acceleration}
            \equation{
               \bar{a} &= \frac{\Delta{v}}{\Delta{t}}\\
                                   v_2 &= v_1 + a\Delta{t}\\
                                   \Delta{x} &= v_0\Delta{t}+\frac{1}{2}a\Delta{t^2}\\
                                   (v_2)^2 &= (v_1)^2 - 2\bar{a}\Delta{x}
            }
         }
         \note{
            \h2{Miscellaneous}
            \equation{
               \bar{v} &= \frac{\Delta{x}}{\Delta{t}} = \frac{v_2 + v_1}{2}\\
                                   \bar{a} &= \frac{\Delta{v}}{\Delta{t}}
            }
         }
      }
   }
}
\h2{Deriving Displacement Formulas}

\grid[boxed, col="2"]{
   \note{
      \h3{Displacement when object moves with constant velocity}
      \h4{Deriving \{\Delta{x} = \bar{v}\Delta{t}}}
      \img[max-width="500px", src="../images/physics/1.svg"]\equation{
         \Delta{x} &= \bar{v}\Delta{t}
      }
   }
   \note{
      \h3{Displacement when object accelerates from rest}
      \h4{Deriving \{\Delta{x} = \frac{1}{2}\bar{a}\Delta{t^2}}}
      \img[src="../images/physics/2.svg", min-width="500px", max-width="900px"]\equation{
         \Delta{x} &= \frac{1}{2}\Delta{v}\Delta{t}\\
                               &= \frac{1}{2}\bar{a}\Delta{t^2}
      }
   }
}
\grid[boxed, col="1"]{
   \note{
      \h3{Displacement when object accelerates with initial velocity}
      \h4{Deriving \{\Delta{x} = v_1\Delta{t} + \frac{1}{2}\bar{a}\Delta{t^2}}}
      \img[src="../images/physics/4.svg", max-width="900px", min-width="500px"]\equation{
         \Delta{x} &= v_1\Delta{t} + \frac{1}{2}\Delta{v}\Delta{t} \\
                               &= v_1\Delta{t} + \frac{1}{2}\bar{a}\Delta{t^2}
      }
   }
}
\h1{Deriving The Other Kinematic Formulas}

\grid[boxed, col="2"]{
   \note{
      \h2{Deriving \{v_2 = v_1 + \bar{a}\Delta{t}}}
      \p{Given}
      \equation{
         \bar{a} &= \frac{\Delta{v}}{\Delta{t}} = \frac{v_2 - v_1}{\Delta{t}}\;(1)
      }
      \p{We can rearrange \{v_2} from equation (1) like so}
      \equation{
         \bar{a} &= \frac{v_2 - v_1}{\Delta{t}}\\
                     \bar{a}\Delta{t} &= v_2 - v_1\\
                     v_1 + \bar{a}\Delta{t} &= v_2\\
                     \therefore v_2 &= v_1 + \bar{a}\Delta{t}
      }
      \p{Therefore}
      \equation{
         v_2 &= v_1 + \bar{a}\Delta{t}
      }
   }
   \note{
      \h3{Deriving \{v_2^2 = v_1^2 + 2\bar{a}\Delta{x}}}
      \p{Given}
      \equation{
         \bar{a} &= \frac{\Delta{v}}{\Delta{t}}\;(1)\\
                     \bar{v} &= \frac{\Delta{x}}{\Delta{t}}\;(2)\\
                             &= \frac{v_2 + v_1}{2}\;(3)
      }
      \p{\{\Delta{t}} from equation (1) can be rearranged as}
      \equation{
         \Delta{t} &= \frac{\Delta{v}}{\bar{a}} = \frac{v_2 - v_1}{\bar{a}}\;(4)
      }
      \p{\{\Delta{x}} from equation (2) can be rearranged like so}
      \equation{
         \bar{v} &= \frac{\Delta{x}}{\Delta{t}}\\
                     \bar{v}\Delta{t} &= \Delta{x}\\
                     \therefore \Delta{x} &= \bar{v}\cdot\Delta{t}
      }
      \p{Using the following equations from above}
      \ul{
         \li{\{\bar{v} = \frac{v_2 + v_1}{2}} from equation (3)}
         \li{\{\Delta{t} = \frac{v_2 - v_1}{\bar{a}}} from equation (4)}
      }\equation{
         \Delta{x} &= \bar{v}\cdot\Delta{t}\\
                               &= \frac{v_2 + v_1}{2}\cdot\frac{v_2 - v_1}{\bar{a}}\\
                               &= \frac{(v_2)^2 - (v_1)^2}{2\bar{a}}\;(5)
      }
      \p{Rearranging equation (5)}
      \equation{
         2\bar{a}\Delta{x} &= (v_2)^2 - (v_1)^2
      }
      \p{Rearrange again to obtain the more common form}
      \equation{
         (v_2)^2 &= (v_1)^2 + 2\bar{a}\Delta{x}
      }
   }
   \note{
      \p{TODO}
   }
}