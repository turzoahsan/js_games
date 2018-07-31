globals 
[
  loop-counter
  roads
  lane-ycord
  west-lane-one
  west-lane-two
  east-lane-one
  east-lane-two
  max-speed-limit
  min-speed-limit
  lead-car
  lead-car-moves
  prev-xcor
  prev-ycor
  car-ahead
]

breed [ dividers divider ]
breed [ cars car ]


cars-own 
[
  speed        
  lane
  previous-x        
  agressive?   
]


to setup
  clear-all
  setup-display
  set max-speed-limit 1
  set min-speed-limit 0
  setup-cars
  watch lead-car
  reset-ticks
end

to go
  ask lead-car [ set prev-xcor xcor  set prev-ycor ycor ]
  cars-drive
  tick
  ask lead-car [ set lead-car-moves (lead-car-moves + distancexy prev-xcor prev-ycor) ]
end



to cars-drive
  ask cars 
  [
    ifelse (any? vehicles-directly-ahead) 
    [
      let new-lane try-change-lane
      if (new-lane = nobody) 
      [ 
        set speed [ speed ] of vehicle-directly-ahead
        slow-down 
      ] 
      
    ] 
    [
      speed-up 
    ]
    forward speed
  ]
end

to-report try-change-lane
  if (divider?) 
  [
    report nobody 
  ]
  let dist abs(previous-x - xcor)
  if (dist > 0 and dist < 5) 
  [
    report nobody 
  ]
  if (not agressive?) 
  [
    report nobody
  ]
  let open-patch change-to-fast-lane
  if (open-patch != nobody) 
  [
    report open-patch
  ]
  report change-to-slow-lane
end

to-report change-to-fast-lane
  let y 0
  let on-left patch-left-and-ahead 90 2
  ask on-left [
    set y abs(pycor)
  ]
  if (y = 2 and not any? cars-on on-left) [
    set previous-x xcor
    set label (label + 1)
    move-to on-left
    report on-left
  ]
  report nobody
end

to-report change-to-slow-lane
  let y 0
  let on-right patch-right-and-ahead 90 2
  ask on-right [
    set y abs(pycor)
  ]
  if (y = 4 and not any? cars-on on-right) [
    set previous-x xcor
    set label (label + 1)
    move-to on-right
    report on-right
  ]
  report nobody
end

to-report vehicles-directly-ahead
  ifelse (agressive?) 
  [
    report cars-on patch-ahead 1  
  ] 
  [
    report (turtle-set (cars-on patch-ahead 1) (cars-on patch-ahead buffer))  
  ]
end

to-report vehicle-directly-ahead
  report one-of vehicles-directly-ahead
end


to setup-cars 
  set-default-shape turtles "car-west"
  set west-lane-one 2
  set west-lane-two 4
  setup-traffic 270 west-lane-one west-lane-two
  
  set east-lane-one -2
  set east-lane-two -4
  set-default-shape turtles "car-east"
  setup-traffic 90 east-lane-one east-lane-two
  
  set lead-car one-of cars
  ask lead-car 
  [ 
    set color red
    if (not divider?) 
    [
      set agressive? true
      set label 0
    ]
  ]
end
  
to setup-traffic [ direction fast-lane slow-lane ]
  create-cars total-cars 
  [
    set color one-of [ 5 27 36 45 55 65 75 85 95 105 115 125 135 ] ; skip red
    set heading direction
    ifelse ((random 2) = 0) 
    [ 
      set lane-ycord fast-lane
    ] 
    [ 
      set lane-ycord slow-lane
    ]
    setxy random-xcor lane-ycord     
    set agressive? false
    if (not divider?) 
    [
      set previous-x max-pxcor
      if ((random 5) = 0) 
      [ 
        set agressive? true
        set label 0
      ]
    ]
    set speed 0.1 + random-float 0.9    
    avoid-collision    
  ]
end

to avoid-collision
  set loop-counter (loop-counter + 1)
  let max-iterations 100
;  let cars-near (turtle-set (turtles-on patch-ahead 1) (turtles-here) (turtles-on patch-ahead -1))
;  if any? other cars-near [ 
  if any? other cars-here [
    forward random 3
    if (loop-counter < 100) [
      avoid-collision
    ]
  ]
end
to locate-empty-road-spot
  move-to one-of roads with [ not any? turtles-on self ]
end

to speed-up  ; car procedure
  ifelse speed >= (max-speed-limit + random-float .2)
    [ set speed max-speed-limit ]
    [ set speed speed + car-acceleration ]
end

to slow-down  ; car procedure
  set speed (speed - car-deceleration)
  if speed < min-speed-limit [ 
    set speed min-speed-limit 
  ]
end

to setup-display
  setup-median
  setup-dividers
  setup-grass
end

to setup-median
  ask patches 
  [ 
    if (pycor = 0) 
    [
      set pcolor yellow
    ] 
  ]
end

to setup-dividers
  let c max-pycor / 2
  setup-divider c
  setup-divider (- c)
end

to setup-divider [ y ]
  create-dividers 1 
  [
    set shape "line"
    set color white   
    setxy min-pxcor y 
    set heading 90    
  ]
  let line-length 2   
  let line-spacing 1  
  if (divider?) 
  [     
    set line-length 1
    set line-spacing 0
  ]
  
  repeat (world-width / (line-length + line-spacing))
  [
    ask dividers 
    [
      paint-line line-length line-spacing
    ]
  ]
  ask dividers [ die ] 
end

to paint-line [ line-length line-spacing ] 
  pen-down
  forward line-length
  pen-up
  forward line-spacing
end

to setup-grass
  ask patches [
    if (pycor > (max-pycor - 1) or pycor < (min-pycor + 1))
    [ set pcolor green ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
7
10
782
236
25
6
15.0
1
10
1
1
1
0
1
0
1
-25
25
-6
6
0
0
1
ticks
30.0

BUTTON
18
254
82
287
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
92
253
155
286
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
171
250
343
283
total-cars
total-cars
2
75
25
1
1
NIL
HORIZONTAL

SLIDER
171
302
343
335
buffer
buffer
1
2
1
1
1
NIL
HORIZONTAL

SLIDER
172
353
344
386
car-deceleration
car-deceleration
0
.099
0.06
.001
1
NIL
HORIZONTAL

SLIDER
172
408
344
441
car-acceleration
car-acceleration
0
.0099
0.0060
.0001
1
NIL
HORIZONTAL

SWITCH
35
297
138
330
divider?
divider?
1
1
-1000

PLOT
361
248
774
442
Speeds
time
speed
0.0
3000.0
0.0
1.5
true
true
"" ""
PENS
"red car" 1.0 0 -2674135 true "" "plot [speed] of lead-car"
"minimum" 1.0 0 -1184463 true "" "plot min [speed] of cars"
"maximum" 1.0 0 -10899396 true "" "plot max [speed] of cars"

MONITOR
22
342
151
387
Red car's speed
[speed] of lead-car
3
1
11

MONITOR
22
396
153
441
Red car's average speed
lead-car-moves / ticks
3
1
11

@#$#@#$#@
## WHAT IS IT?

A multi-lane traffic simulator with the ability to toggle the divider between lanes to allow cars to change lanes.

## HOW IT WORKS

Each car is designated at creation as "agressive" or not, those that are can change lanes when another car is directly ahead instead of slowing down.

## HOW TO USE IT

Click "Setup", then "Go".

## THINGS TO NOTICE

The labels on each car show how many times they have changed lanes.

How the "wave" phenomena of jams is changed by the users selected options.

## THINGS TO TRY

Changing the buffer (the space between cars).

## EXTENDING THE MODEL

Have cars who were just cut off by a pass dramatically slow down.
Refactor the code to allow the number of lanes to be a user option.

## NETLOGO FEATURES

Note the "car-east" and "car-west" referenced in the code that were easily created with the built in Turtle Shapes Editor.

## RELATED MODELS

"Traffic Basic", "Traffic Grid", "Traffic 2 Lanes"

## CREDITS AND REFERENCES

Created for COMP575 at California State University Channel Islands (CSUCI)
by Carl.Edwards718@myci.csuci.edu
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car-east
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

car-west
false
0
Polygon -7500403 true true 0 180 21 164 39 144 60 135 74 132 87 106 97 84 115 63 141 50 165 50 225 60 300 150 300 165 300 225 0 225 0 180
Circle -16777216 true false 30 180 90
Circle -16777216 true false 180 180 90
Polygon -16777216 true false 138 80 168 78 166 135 91 135 106 105 111 96 120 89
Circle -7500403 true true 195 195 58
Circle -7500403 true true 47 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
