from cadquery import *

w = 10
d = 10
h = 10

part1 = Workplane().box(2*w,2*d,h)
part2 = Workplane().box(w,d,2*h)
part3 = Workplane().box(w,d,3*h)

assy = (
    Assembly(part1, Location(Vector(-w,0,h/2)))
    .add(part2, loc=Location(Vector(1.5*w,-.5*d,h/2)), color=Color(0,0,1,0.5))
    .add(part3, loc=Location(Vector(-.5*w,-.5*d,2*h)), color=Color("red"))
)
