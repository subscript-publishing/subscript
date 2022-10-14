/// This file was auto-translated from the original HTML source, it is pretty messy. 
\h1[page-title]{Newton's laws of motion}

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