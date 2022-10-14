\h1[top-level]{Physics}

\h1{Constants}

\grid[col="3"]{
   \equation{
      g &= 9.8 \frac{m}{s^2}\;\text{downward} \;\text{where}\; a &= -g
   }
}
\h1{Tables}

\grid[col="2", style="grid-template-rows: max-content; grid-template-areas: 'a c' 'b d'"]{
   \h3[style="grid-area: a"]{Linear Kinematic Equations \small{(1D)}}
   \note[style="grid-area: b"]{
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
   \h3[style="grid-area: c"]{Rotational Kinematic Equations}
   \note[style="grid-area: d"]{
      \table{
         \thead{
            \tr{
               \th{Formula}
               \th{Missing}
               \th{Quantities Present}
            }
         }\tbody{
            \tr{
               \th{\{\omega_2 = \omega_1 + \alpha\Delta{t}}}
               \td{\{\Delta\theta}}\td{\span[style="display: flex; justify-content: space-between;"]{\{\omega_1}\{\omega_2}\{\alpha}\{\Delta{t}}}}
            }\tr{
               \th{\{\Delta\theta = \left(\frac{\omega_2 + \omega_1}{2}\right)\Delta{t}}}
               \td{\{a}}\td{\span[style="display: flex; justify-content: space-between;"]{\{\Delta\theta}\{\omega_1}\{\Delta{t}}\{\omega_2}}}
            }\tr{
               \th{\{\Delta\theta = \omega_1 \Delta{t} + \frac{1}{2}\alpha\Delta{t^2}}}
               \td{\{\omega_2}}\td{\span[style="display: flex; justify-content: space-between;"]{\{\Delta\theta}\{\omega_1}\{\Delta{t}}\{\alpha}}}
            }\tr{
               \th{\{\Delta\theta = \omega_2\Delta{t} - \frac{1}{2}\alpha\Delta{t^2}}}
               \td{\{\omega_1}}\td{\span[style="display: flex; justify-content: space-between;"]{\{\Delta\theta}\{\omega_2}\{\Delta{t}}\{\alpha}}}
            }\tr{
               \th{\{(\omega_2)^2 = (\omega_1)^2 + 2\alpha\Delta\theta}}
               \td{\{\Delta{t}}}\td{\span[style="display: flex; justify-content: space-between;"]{\{\Delta\theta}\{\omega_1}\{\omega_2}\{\alpha}}}
            }
         }
      }
   }
}
\grid[col="3"]{
   \note{
      \h3{Scalar or Vector}
      \table{
         \thead{
            \tr{
               \th{Name}
               \th{Type}
            }
         }\tbody{
            \tr{
               \th{Speed}
               \td{Scalar}
            }\tr{
               \th{Distance}
               \td{Scalar}
            }\tr{
               \th{Velocity}
               \td{Vector}
            }\tr{
               \th{Acceleration}
               \td{Vector}
            }\tr{
               \th{Average Velocity}
               \td{Vector}
            }\tr{
               \th{Displacement}
               \td{Vector}
            }\tr{
               \th{Position}
               \td{Vector}
            }
         }
      }
   }
}
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
\h1{Two-dimensional Projectile Motion}

\grid[boxed, col="1"]{
   \note{
      \h2{Conventions}
   }
}
\grid[col="1", boxed]{
   \note{
      \h2{Summary}
      \grid[col="2"]{
         \img[max-width="900px", src="../images/physics/17.svg"]\note{
            \img[max-width="900px", src="../images/physics/18.svg"]\p[justify]{It's easy to see in the above visualization that \{t}
                                and \{x} increase linearly, while \{y} is non-linear.}
         }
         \img[max-width="900px", src="../images/physics/20.svg"]\img[max-width="900px", src="../images/physics/21.svg"]
      }
   }
}
\h2{Formulas}

\grid[boxed, col="1"]{
   \note{
      \h3{Displacement & Projectile Position}
      \grid[col="2"]{
         \note{
            \h4{Generalized}
            \p{In general (without respect to any \{x} or \{y} axis values)}
            \equation{
               \text{Displacement}
                                       &= \Delta_{\text{general}}\\
                                       &= \bar{v}\cdot\Delta{t}
            }
            \p{Where the distance traveled or displaced is}
            \equation{
               \text{Displacement}
                                       &= \Delta_{\text{general}}\\
                                       &= V_1\cdot\Delta{t} + \frac{1}{2}a\Delta{t^2}
            }
         }
         \note{
            \h4{In terms of \{x} and \{y} axis values}
            \equation{
               \Delta{x} &= x_2 - x_1\\
                                   \Delta{y} &= y_2 - y_1
            }
         }
         \note{
            \h4{With respect to the \{y} axis}
            \p{The displacement of a given projectile in terms of the \{y} axis is}
            \equation{
               \Delta{y} = V_{y1}\cdot\Delta{t} + \frac{1}{2}a_y\Delta{t^2}
            }
            \p{Since \{\Delta{y} = y_2 - y_1}}
            \equation{
               \Delta{y} &= V_{y1}\cdot\Delta{t} + \frac{1}{2}a_y\Delta{t^2}\\
                                   y_2 - y_1 &= V_{y1}\cdot\Delta{t} + \frac{1}{2}a_y\Delta{t^2}\\
                                   y_2  &= y_1 + V_{y1}\cdot\Delta{t} + \frac{1}{2}a_y\Delta{t^2}
            }
            \p{Which can be read as (in terms of the \{y} axis)}
            \equation{
               \small{\text{the final position}}\;
                                       &= \small{\text{the initial position}}\;
                                       + V_{y1}\cdot\Delta{t} + \frac{1}{2}a_y\Delta{t^2}
            }
         }
         \note{
            \h4{With respect to the \{x} axis}
            \p{The displacement of a given projectile in terms of the \{x} axis is}
            \equation{
               \Delta{x} = V_{x}\cdot\Delta{t} + \frac{1}{2}a_x\Delta{t^2} (1)
            }
            \p{Note that \{a_x = 0} (because there is no force acting on the projectile in
                                the horizontal direction), and therefore the initial and final velocities are the same.
                                I.e. it's constant throughout. Therefore in summary}
            \ul{
               \li{\{a_x = 0}}
               \li{\{v_{x1} = v_{x2}} and therefore we will simple refer to the velocity
                                       vector as as \{v_x}.}
            }\p{Therefore we can simplify equation (1) considerably}
            \equation{
               \Delta{x}
                                       &= V_{x}\cdot\Delta{t} + 0\\
                                       &= V_{x}\cdot\Delta{t}
            }
         }
      }
   }
}
\h2{Solving Projectile Motion Problems}

\grid[boxed, col="1"]{
   \note{
      \h3{Projectile Motion}
      \img[max-width="600px", src="../images/physics/23.svg"]\grid[col="2"]{
         \note{
            \h4{In terms of the \{x} axis}
            \p{TODO}
            \equation{
               \Delta{x}
                                       &= x_2 - x_1 = V_{0,x} \dot t\\
                                   v_{x}
                                       &= v_{0,x} + a_x
            }
            \p{TODO}
         }
         \note{
            \h4{In terms of the \{y} axis}
            \p{TODO}
            \equation{
               \Delta{y}
                                       &= y_2 - y_1 = V_{0,x} \dot t\\
                                   v_{y}
                                       &= v_{0,y} + a_y
            }
            \p{TODO}
         }
      }\h4{In Summary}
      \p{Initial Quantities}
      \grid[col="2"]{
         \equation{
            v_x &= v_o\cdot\cos\theta\\
                            v_y &= v_o\cdot\sin\theta
         }
         \equation{
            a_y &= -g\\
                            a_x &= 0
         }
      }\p{Derived expressions}
      \grid[col="2"]{
         \equation{
            \Delta{x} &= v_{0,x} \cdot \Delta{t}\\
                            v_x &= v_{0,x}
         }
         \equation{
            \Delta{y} &= v_{0,y} \cdot \Delta{t} - \frac{1}{2} g \Delta{t^2}\\
                            v_y &= v_{0,y} - g \Delta{t}
         }
      }\p{Solutions}
      \equation{
         t_{\text{top}} &= \frac{v_0\cdot\sin\theta}{g}\\
                     \Delta{y_{\text{max}}} &= \frac{v_0^2 + sin^2\theta}{2g}\\
                     \text{Range} &= \frac
                         {2 \cdot v_0^2 \cdot \sin\theta \cdot \cos\theta}
                         {g}
      }
   }
   \note{
      \h3{Projectile Motion from an initial height, with given initial velocity and angle}
      \img[src="../images/physics/22.svg", max-width="800px"]\p{Given}
      \ul{
         \li{A projectile angle \{\theta}}
         \li{The initial height \{y_0}}
         \li{The initial velocity \{v_0}}
      }\p{We can therefore derive the the initial velocities for \{x} and \{y} in terms of
                  the given angle and initial velocity.}
      \equation{
         v_{0x} &= v_0 \cdot \cos\theta\\
                     v_{0y} &= v_0 \cdot \sin\theta
      }
      \p{Given the general formulas for displacement and velocity}
      \equation{
         \small
                     \text{displacement}
                         &= \text{initial displacement}
                         + \text{initial velocity} \cdot \Delta{t}
                         + \frac{1}{2}a\Delta{t^2}\\
                     \text{velocity} &= \text{initial velocity} + a\cdot\Delta{t}
      }
      \p{Which this information, we will derive specific equations in terms of the \{x}
                  and \{y} axes governing the projectile.}
      \grid[col="2"]{
         \note{
            \h4{In terms of the \{x} axis}
            \h5{Deriving displacement as a function of time}
            \p{Using the general formula from above in terms of \{x} as a function
                                of time.}
            \equation{
               x(t) &= x_0 + v_{0x} t + \frac{1}{2}a_x t^2
            }
            \p{Which we can simplify using the following facts}
            \ul{
               \li{From the given depiction of the problem, we know that \{x(0) = 0}.}
               \li{There is no acceleration along the \{x} axis, so \{a_x = 0}.}
               \li{\{v_{0x} = v_0\cdot\cos\theta} as shown above.}
            }\p{Therefore}
            \equation{
               x(t) &= 0 + v_{0x}\cdot t + \frac{1}{2}0 t^2\\
                                        &= v_{0x} t\\
                                        &= v_0\cos\theta\cdot t
            }
            \h6{Deriving velocity}
            \equation{
               v_x &= v_{0x} + a_x\cdot t\\
                                       &= v_0\cdot\cos\theta + 0\cdot t\\
                                       &= v_0\cdot\cos\theta
            }
         }
         \note{
            \h4{In terms of the \{y} axis}
            \h5{Deriving displacement as a function of time}
            \p{Using the general formula from above in terms of \{y} as a function
                                of time.}
            \equation{
               y(t) &= y_0 + v_{0y} t + \frac{1}{2}a_y t^2
            }
            \p{Which we can simplify using the following facts}
            \ul{
               \li{Initial height is given to us which we will represent as \{y_0},
                                       for the sake of generality.}
               \li{Acceleration along the \{y} axis is the constant for gravity,
                                       so \{a_y = -9.8\frac{\mathrm{m}}{\mathrm{s^2}}}.}
               \li{\{v_{0y} = v_0\cdot\sin\theta} as shown above.}
            }\p{Therefore}
            \equation{
               y(t) &= y_0 + v_{0y} t + \frac{1}{2}a_y t^2\\
                                        &= y_0
                                        + v_0\cdot\sin\theta\cdot t
                                        + \frac{1}{2}\left(-9.8\right) t^2\\
                                        &= y_0
                                        + v_0\cdot\sin\theta\cdot t
                                        - 4.9 t^2
            }
            \h5{Deriving velocity}
            \equation{
               v_y &= v_{0y} + a_y\cdot t
                                       &= v_{0y} + g \cdot t\\
                                       &= v_0\cdot\sin\theta - 9.8\frac{\mathrm{m}}{\mathrm{s^2}}
            }
         }
      }\hr\h4{In summary}
      \grid[col="2"]{
         \equation{
            x(t) &= v_0\cos\theta\cdot t\;(1)\\
                            v_x &= v_0\cdot\cos\theta\;(2)
         }
         \equation{
            y(t) &= y_0 + v_0\cdot\sin\theta\cdot t + \frac{1}{2}g t^2\;(3)\\
                                &= y_0 + v_0\cdot\sin\theta\cdot t - 4.9 t^2\\
                            v_y &= v_0\cdot\sin\theta + g \cdot t\;(4)\\
                                &= v_0\cdot\sin\theta - 9.8\frac{\mathrm{m}}{\mathrm{s^2}} \cdot t
         }
      }\hr\grid[col="2"]{
         \note{
            \h4{To find the range}
            \p{We know that at the moment of impact \{y = 0}, therefore we can use equation \{(3)}}
            \equation{
               y = y_0 + v_0\cdot\sin\theta\cdot t + \frac{1}{2}g t^2
            }
            \p{Rearranging a bit and setting \{y = 0}, we can see that solving for \{t}
                                will yield the time at which \{y = 0}.}
            \equation{
               0 = \underbrace{\frac{1}{2}g}_{\text{a}}\;t^2
                                   + \underbrace{v_0\cdot\sin\theta}_{\text{b}}\; t
                                   + \underbrace{y_0}_{\text{c}}
            }
            \p{Therefore}
            \equation{
               t &= \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}\\
                                   &= \frac
                                       {-v_0\cdot\sin\theta\pm\sqrt{\left(v_0\cdot\sin\theta\right)^2 - 4\left(\frac{1}{2}g\right)y_0}}
                                       {2\frac{1}{2}g}\\
                                   &= \frac
                                       {-v_0\cdot\sin\theta\pm\sqrt{\left(v_0\cdot\sin\theta\right)^2 - 2 g y_0}}
                                       {g}
            }
            \p{Plugging the solution for \{t} (and ignoring the negative or non-real solutions for \{t})
                                into \{x(t)} will yield the horizontal displacement (range) at the time \{y = 0}.
                                Therefore:}
            \equation{
               \text{range}\;=x(t)\;\small\text{where $t$ is the point at which $y=0$}
            }
         }
         \note{
            \h4{To find the maximum vertical displacement (i.e. peak height)}
            \p{We begin with equation \{\text{(4)}}}
            \equation{
               v_y &= v_0\cdot\sin\theta + g t
            }
            \p{We know that at the moment our projectile crests its trajectory,
                                the vertical component of our projectile will be zero. 
                                Therefore \{v_y = 0}. To find the time, we simply solve for \{t}.}
            \equation{
               0 &= v_0\cdot\sin\theta + g \cdot t\\
                                   -v_0\cdot\sin\theta &= g \cdot t\\
                                   \frac{-v_0\cdot\sin\theta}{g} &= t\\
                                   \therefore\;t &= \frac{-v_0\cdot\sin\theta}{g}
            }
            \p{Therefore, knowing the time at which our projectile crests its trajectory,
                                we simply plugin our solution for \{t} into the function given in
                                equation \{(4)}. I.e:}
            \equation{
               y_{\text{max}}
                                       &= y_0 + v_0\cdot\sin\theta\cdot t + \frac{1}{2}g t^2\\
                                       &= \small y_0 + v_0\cdot\sin\theta\cdot\left(\frac{-v_0\cdot\sin\theta}{g}\right)
                                       + \frac{1}{2}g \left(\frac{-v_0\cdot\sin\theta}{g}\right)^2
            }
         }
         \note{
            \h4{To find the velocity at a given moment of time}
            \p{Given some time which we will denote as \{t_n},
                                to find the velocity we simply plug in our given values
                                for \{\theta} and \{v_0} into equations \{(2)}
                                and \{(4)}. I.e.}
            \equation{
               v_x &= v_0\cdot\cos\theta\\
                                   v_y &= v_0\cdot\sin\theta + g \cdot t
            }
            \p{With the given value for \{t_n}, yielding the vector at time \{t = t_n},
                                which we will denote as \{\vec{v_n}}}
            \equation{
               A &= v_y(t_n)\\
                                   B &= v_x(t_n)\\
            }
            \p{To define the vector in terms of engineering notation,
                                (i.e. \{v_x\hat{i} + v_y\hat{j}})}
            \equation{
               \vec{v_n} &= B\hat{\textbf{i}} + A\hat{\textbf{j}}
            }
            \p{To define the vector in terms of magnitude (which we will denote as \{v_n})
                                and direction (which we will denote as \{\theta_n})}
            \equation{
               v_n &= \sqrt{A^2 + B^2}\\
                                   \theta_n &= \tan^{-1}\left(\frac{A}{B}\right)
            }
         }
      }
   }
}
\grid[boxed, col="2"]{
   \note{
      \h3{Range}
      \p{The distance a projectile travels is called its range.}
      \equation{
         \underbrace
                         {\text{range}\;=\frac{v^2 \cdot sin\left(2\theta\right)}{g}}
                         _{\small{\text{start/end elevation must be the same}}}
      }
      \p{Only applies in situations where the projectile lands at the same elevation from which it was fired.}
      \img[max-width="100%", src="../images/physics/13.svg"]
   }
}
\h1{Reasoning About Projectile Motion}

\grid[boxed, col="2"]{
   \note{
      \img[max-width="500px", src="../images/physics/12.svg", min-width="100px"]\img[min-width="100px", max-width="500px", src="../images/physics/15.svg"]
   }
   \note{
      \h2{Notes}
      \ul{
         \li{An object is in free fall when the only force acting on it is the force of gravity.}
      }
   }
   \note{
      \img[max-width="500px", src="../images/physics/24.svg", min-width="100px"]\h2{Question}
      \p{Based on the figure, for which trajectory was the object in the air for the greatest amount of time?}
      \h2{Answer}
      \p{\mark[font]{Trajectory A}}
      \h3{Explanation}
      \p{All that matters is the vertical height of the trajectory, which is based on the component of the
                  initial velocity in the vertical direction (\{v_0\sin\theta}).
                  The \mark[font]{higher the trajectory}, the more time the object will be in the air,
                  \u{regardless of the object's range or horizontal velocity}.}
   }
}
\h2{Problems}

\grid[boxed, col="2"]{
   \note{
      \img[max-width="600px", src="../images/physics/14.svg"]\p{The function in this graph represents an object that is speeding up,
                  or accelerating at a constant rate.}
   }
   \note{
      \p{When you throw a ball directly upward, what is true about
                  its acceleration after the ball has left your hand?}
      \p{Answer: The ball’s acceleration is always directed downward.}
      \p{Wrong: The ball’s acceleration is always directed downward,
                  except at the top of the motion, where the acceleration is zero.}
   }
   \note{
      \dl{\dt{Question}\dd{As an object moves in the x-y plane, which statement is true about the object’s
                      instantaneous velocity at a given moment?}\dt{Answer}\dd{The instantaneous velocity is tangent to the object’s path}\dt{Wrong}\dd{\ul{
         \li{The instantaneous velocity is perpendicular to the object’s path.}
         \li{The instantaneous velocity can point in any direction, independent of the object’s path.}
      }}\dt{Explanation}\dd{As an object moves in the x-y plane the instantaneous velocity is tangent to the
                      object‘s path at a given moment. This is because the displacement vector during
                      an infinitesimally small time interval is always directed along the object’s path
                      and the velocity vector always has the same direction as the displacement vector.}}
   }
}
\h1{Relative Motion}

\grid[boxed, col="2"]{
   \note{
      \h2{Galilean transformation of velocity}
      \p{The velocity \{\vec{v}} of some object P \mark[font]{as seen from a stationary frame}
                  must be the sum of \{\vec{w}} and \{\vec{v_F}}}
      \equation{
         \vec{v} &= \vec{w} + \vec{v_F}
      }
      \p{Where}
      \table{
         \thead{
            \tr{
               \th{Symbol}
               \th{Description}
            }
         }\tbody{
            \tr{
               \th{\{\vec{v}}}
               \td{Velocity as measured in a stationary frame}
            }\tr{
               \th{\{\vec{w}}}
               \td{Velocity of an object measured in the moving frame relative to the moving frame}
            }\tr{
               \th{\{\vec{v_F}}}
               \td{velocity of the moving frame - with respect to the stationary frame}
            }
         }
      }
   }
   \note{
      \h2{Galilean transformation of velocity (alternate notation)}
      \p{Given two reference frames \text{
         A
      } and \{B} and some object \{O}.
                  The velocity of the object can be defined in terms of \{A} or \{B} as shown}
      \table{
         \thead{
            \tr{
               \th{Symbol}
               \th{Description}
            }
         }\tbody{
            \tr{
               \th{\{\vec{v_{O,A}}}}
               \td{The velocity of \{O} relative to \{A}}
            }\tr{
               \th{\{\vec{v_{O,B}}}}
               \td{The velocity of \{O} relative to \{B}}
            }\tr{
               \th{\{\vec{v_{A,B}}}}
               \td{The velocity of \{A} relative to \{B}}
            }\tr{
               \th{\{\vec{v_{B,A}}}}
               \td{The velocity of \{B} relative to \{A}.
                                   It locates the origin of \{A} relative to the origin of \{B}.}
            }
         }
      }\p{Therefore}
      \equation{
         \vec{v_{O,B}} &= \vec{v_{O,A}} + \vec{v_{A,B}}\\
                     \vec{v_{O,A}} &= \vec{v_{O,B}} + \vec{v_{B,A}}
      }
   }
}
\h1{Rotational Motion & Kinematics}

\h2{Basics}

\grid[col="3"]{
   \equation{
      \smallText{Angular velocity} = \omega
                  &= \tau f\\
                  &= \frac{\tau}{T}\\
   }
   \equation{
      \smallText{Centripetal acceleration} = a_C
                  &= \frac{v^2}{r}\\
                  &= \frac{\omega^2 r^2}{r}\\
                  &= \omega^2 r
   }
   \equation{
      \text{Period} = T &= \frac{1}{f} = \frac{\tau}{\omega}
   }
}
\grid[col="2", style="max-width: 700px; margin: 0 auto;"]{
   \equation{
      \vec{v} &\perp \vec{r}\\
              \vec{a} &\perp \vec{v}\\
   }
   \equation{
      \left.
              \begin{array}{ll}
              \vec{a} &\parallel \vec{r}\\
              \vec{a} &\propto \vec{r}
              \end{array}
              \right\}\;\smallText{They are anti-parallel}
   }
}
\h2{Auxiliary Formula Reference}

\grid[col="2", boxed]{
   \note{
      \equation{
         \text{Period} = T &= \frac{1}{f} = \frac{\tau}{\omega}
      }
   }
}
\grid[boxed, col="2"]{
   \note{
      \equation{
         \theta
                         &= \omega \cdot t\\
                         &= \omega_1 \cdot t + \frac{1}{2} \alpha t^2\\
                     \omega_2 &= \omega_1 + \alpha \cdot t\\
                     \omega_2^2 &= \omega_1^2 + 2\cdot\alpha\cdot\theta\\
                     v &= \smaller{\frac{1 \text{circumference}}{1 \text{period}}}\\
                         &= \frac{2 \pi r}{T}
      }
   }
   \note{
      \table{
         \thead{
            \tr{
               \th{Formula}
               \th{Missing}
               \th{Quantities Present}
            }
         }\tbody{
            \tr{
               \th{\{\omega_2 = \omega_1 + \alpha\Delta{t}}}
               \td{\{\Delta\theta}}\td{\span[style="display: flex; justify-content: space-between;"]{\{\omega_1}\{\omega_2}\{\alpha}\{\Delta{t}}}}
            }\tr{
               \th{\{\Delta\theta = \left(\frac{\omega_2 + \omega_1}{2}\right)\Delta{t}}}
               \td{\{a}}\td{\span[style="display: flex; justify-content: space-between;"]{\{\Delta\theta}\{\omega_1}\{\Delta{t}}\{\omega_2}}}
            }\tr{
               \th{\{\Delta\theta = \omega_1 \Delta{t} + \frac{1}{2}\alpha\Delta{t^2}}}
               \td{\{\omega_2}}\td{\span[style="display: flex; justify-content: space-between;"]{\{\Delta\theta}\{\omega_1}\{\Delta{t}}\{\alpha}}}
            }\tr{
               \th{\{\Delta\theta = \omega_2\Delta{t} - \frac{1}{2}\alpha\Delta{t^2}}}
               \td{\{\omega_1}}\td{\span[style="display: flex; justify-content: space-between;"]{\{\Delta\theta}\{\omega_2}\{\Delta{t}}\{\alpha}}}
            }\tr{
               \th{\{(\omega_2)^2 = (\omega_1)^2 + 2\alpha\Delta\theta}}
               \td{\{\Delta{t}}}\td{\span[style="display: flex; justify-content: space-between;"]{\{\Delta\theta}\{\omega_1}\{\omega_2}\{\alpha}}}
            }
         }
      }
   }
   \note{
      \grid[col="1"]{
         \equation{
            \underbrace{\smallText{Arc Length}}_{S}
                                &=  \underbrace{\smallText{radius}}_{r}
                                    \cdot
                                    \underbrace{\smallText{Central angle}}_{\theta}\\
                            S &= r\cdot\theta\\
         }
         \img[max-width="200px", src="../images/physics/arc-length-formula.svg"]
      }\equation{
         \underbrace{\smallText{Linear displacement}}_{\Delta{x}}
                         &= \underbrace{\smallText{Angular displacement}}_{\theta}
                             \cdot
                            \underbrace{\smallText{radius}}_{r}\\
                     \Delta{x} &= \theta \cdot r\\
                     \underbrace{\smallText{Linear velocity}}_{v}
                         &=  \underbrace{\smallText{Angular Velocity}}_{\omega}
                             \cdot
                             \underbrace{\smallText{radius}}_{r}\\
                     v &= \omega \cdot r\\
                     \underbrace{\smallText{Linear acceleration}}_{a}
                         &=  \underbrace{\smallText{Angular acceleration}}_{\alpha}
                             \cdot
                             \underbrace{\smallText{radius}}_{r}\\
                     a &= \alpha \cdot r
      }
   }
   \note{
      \equation{
         \underbrace{\smallText{Angular displacement}}_{\theta}
                         &= \underbrace{\smallText{Angular speed}}_{\omega}
                             \cdot
                            \underbrace{\smallText{time}}_{t}\\
                     \theta &= \omega \cdot t
      }
      \p{A particle moves with uniform circular motion if and only
                  if its angular velocity V is constant and unchanging.}
   }
}
\h1{Uniform Circular Motion}

\p{Uniform means content speed}

\h1{Newton's Laws of Motion}

\grid[col="3", boxed]{
   \note{
      \p{The rate of change of momentum is what we call a force.}
   }
}
\h2{Laws}

\ol{
   \li{\p{An object at rest remains at rest, or if in motion, remains in motion at a constant velocity unless acted on by a net external force. We can express Newton's first law in vector form as}
   \equation{
      \underbrace{\vec{v} = \smallText{constant}}_{\mathclap{
                      \begin{gathered}
                      \smallText{when}\;\vec{F}_{\smallText{net}} = 0N
                      \end{gathered}
                  }}
   }
   \p{This equation says that a net force of zero implies that the velocity \{\vec{v}} of the object is constant. (The word “constant” can indicate zero velocity.)}}
   \li{\p{When a body is acted upon by a force, the time rate of change of its momentum equals the force.}
   \grid[col="2", style="grid-template-areas: 'a c' 'b c'; grid-template-columns: max-content;", boxed]{
      \note[style="grid-area: a; padding: 20px;"]{
         \equation{
            \overbrace{\smallText{Force}}^{\mathrm{F}}
                                    &=
                                        \overbrace{\smallText{Mass}}^{m}
                                        \cdot
                                        \overbrace{\smallText{Acceleration}}^{a}\\
                                \therefore\; F &= m \cdot a
         }
      }
      \note[style="grid-area: b;", compact]{
         \p[center]{Units}
         \table{
            \thead{
               \tr{
                  \th{Name}
                  \th{Symbol}
                  \th{Unit}
               }
            }\tbody{
               \tr{
                  \th{Newtons}
                  \td{\{\mathrm{N}}}\td{\{\mathrm{kg}\;\cdot\frac{\mathrm{m}}{\mathrm{s^2}}}}
               }
            }
         }
      }
      \note[compact, style="grid-area: c;"]{
         \equation{
            a = \frac{\overbrace{\sum \mathrm{F}}^{\mathclap{\smallText{Net force}}}}{m}
         }
         \p{This is the same formula as \{\mathrm{F} = m a}, except we've written the
                             force more precisely as the net force \{\sum \mathrm{F}}, and we've
                             divided both sides by the mass \{m} to get the acceleration \{a} by itself
                             on one side of the equation.}
         \p{One advantage of writing Newton's second law in this form is that it makes people less likely to
                             think that  \{m \cdot a}—mass times acceleration—is a specific force on an object. The
                             expression \{m \cdot a}, is not a force, \{m \cdot a}, is what the net force
                             equals.}
         \p{Looking at the form of Newton's second law shown above, we see that the acceleration is
                             proportional to the net force, \{\sum \mathrm{F}}, and is inversely proportional
                             to the mass, \{m}.}
      }
   }}
   \li{\p{If an object A exerts a force on object B, then object B must exert a force of equal magnitude and opposite direction back on object A. I.e. "action equals reaction".}
   \grid[col="1", boxed]{
      \note[style="height: fit-content;"]{
         \p{This law represents a certain symmetry in nature: forces always occur in pairs, and one
                             body cannot exert a force on another without experiencing a force itself. We sometimes
                             refer to this law loosely as action-reaction, where the force exerted is the action and
                             the force experienced as a consequence is the reaction.}
      }
   }}
}
\h2{Terms}

\dl{\dt{Inertia}\dd{The property of a body to remain at rest or to remain in motion with constant velocity is called inertia.}\dd{Newton's first law is often called the law of inertia}\dd{The inertia of an object is measured by its mass.}\dd{Mass can be determined by measuring how difficult an object is to accelerate.
        The more mass an object has, the harder it is to accelerate}\dt{Force}\dd{A force is a vector.}\dd{A force can be either a \mark[font]{contact force} or a \mark[font]{long-range force}.}\dt{Motion}\dd{By "motion", Newton meant the quantity now called momentum, which depends upon the amount of matter
        contained in a body, the speed at which that body is moving, and the direction in which it is moving.}\dd{In modern notation, the momentum of a body is the product of its mass and its velocity:
        \{\vec{p} = m \cdot \vec{v}}}}
\h2{Notes}

\grid[col="3", boxed]{
   \note{
      \h4{Question}
      \p{\mark[font]{True of false:} A ball is moving upwards and to the left. A net
                  force that points upwards and to the left must be acting on the ball?}
      \p{\mark[font]{Answer:} false!}
      \ul{
         \li{The net force points in the direction of the acceleration, not
                         necessarily in the direction of the velocity.}
         \li{If the net force points in the direction of velocity, the object will speed up.
                         If the net force points opposite to the velocity, the object will slow down.}
         \li{Since we don't know the acceleration of this ball which is moving up and left,
                         we can't say anything for sure about the net force.}
      }
   }
   \note{
      \h4{Question}
      \p{\mark[font]{True of false:} A less massive object has more inertia than a more massive object?}
      \p{\mark[font]{Answer:} false!}
      \ul{
         \li{Mass is a measure of an object's inertia (its tendency to resist change in velocity).
                         Less mass means less inertia.}
      }
   }
}