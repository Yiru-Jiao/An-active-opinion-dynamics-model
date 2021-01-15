;; code created by
;; Yiru Jiao
;; jiaoyiru@hit.edu.cn
;; Harbin Institute of Technology
;; for the article of
;; An active opinion dynamics model: the  gap between the voting result and group opinion
;;
globals [
  adequate-interaction
  fstopi ;; assistant parameter for action calculation
  fsthist ;; assistant parameter for faction calculation
  i
  j
  action-i
  action-j
  new-action-i
  new-action-j
  opinion-i
  action-for-game
  faction-for-game
  utility-for-game
  faction-j
  action-for-dycoda
  faction-for-dycoda
]

turtles-own [
  opinion
  action
  history
  faction
  utility
]

to setup
  clear-all
  initialize-agents
  ask turtles [
    set fstopi first opinion
    set action (list calculate-action) ;; initial individual actions
    set history (list calculate-history) ;; initial history
    set faction (list (random 3 - 1))
    set fsthist first history
    set faction fput calculate-faction faction ;; initial factions
    set utility (list 0.5) ;; initial utility > 0, otherwise interaction will not happen
  ]
  ask patches [
    set pcolor 1
  ]
  set i 0
  set j 0
  reset-ticks
end

to run-step
  clear-links
  ask turtle i [set shape "circle"]
  ask turtle j [set shape "circle"]
  set i random size-of-group
  set j random size-of-group
  while [i = j] [set j random size-of-group] ;; randomly choose two individuals xi and xj
  ;; similarity effect determines interaction willingness
  if (similarity_effect) [
    ask turtle i [set shape "face happy"]
    ask turtle j [set shape "face happy"]
    ; from xi's perspective
    set opinion-i first [opinion] of turtle i
    set action-for-game [action] of turtle i
    set faction-for-game [faction] of turtle i
    set faction-j first [faction] of turtle j
    set utility-for-game [utility] of turtle i
    let i_game game
    ; from xj's perspective
    set opinion-i first [opinion] of turtle j
    set action-for-game [action] of turtle j
    set faction-for-game [faction] of turtle j
    set faction-j first [faction] of turtle i
    let j_game game
    if (i_game and j_game) [
      ; interaction happens
      ask turtle i [create-link-with turtle j]
      ; update xi's distributes
      ; update opinion
      set opinion-i first [opinion] of turtle i
      set action-for-dycoda [action] of turtle i
      set faction-for-dycoda [faction] of turtle i
      set action-j first [action] of turtle j
      let opinion-updated-i dynamic-coda
      ; append updated distributes
      ask turtle i [
        set opinion fput opinion-updated-i opinion
        set fstopi first opinion
        set action fput calculate-action action
        set history fput calculate-history history
        set fsthist first history
        set faction fput calculate-faction faction
        ; change color based on opinion
        (ifelse
          (opinion-updated-i < 0.5) [set color (opinion-updated-i * 10 + 15)]
          (opinion-updated-i > 0.5) [set color (115 - opinion-updated-i * 10)]
          [set color white] )
      ]
      ; update xj's distributes
      ; update opinion
      set opinion-i first [opinion] of turtle j
      set action-for-dycoda [action] of turtle j
      set faction-for-dycoda [faction] of turtle j
      set action-j first [action] of turtle i
      let opinion-updated-j dynamic-coda
      ; append updated distributes
      ask turtle j [
        set opinion fput opinion-updated-j opinion
        set fstopi first opinion
        set action fput calculate-action action
        set history fput calculate-history history
        set fsthist first history
        set faction fput calculate-faction faction
        ; change color based on opinion
        (ifelse
          (opinion-updated-i < 0.5) [set color (opinion-updated-i * 10 + 15)]
          (opinion-updated-i > 0.5) [set color (115 - opinion-updated-i * 10)]
          [set color white] )
      ]
      ; update utility
      set action-i item 1 [action] of turtle i
      set new-action-i first [action] of turtle i
      set new-action-j first [action] of turtle j
      ask turtle i [
        set utility fput calculate-utility utility]
      set action-i item 1 [action] of turtle j
      set new-action-i first [action] of turtle j
      set new-action-j first [action] of turtle i
      ask turtle j [
        set utility fput calculate-utility utility]
    ]
  ]
  tick
end

to go
  run-step
  let check 0
  ask turtles [
    if (abs (first opinion - 0.5) > 0.495) [set check check + 1] ]
  if (check = size-of-group) [stop]
end

to initialize-agents
  create-turtles size-of-group [
    set opinion (list generalize-random)
    (ifelse
      (first opinion < 0.5) [set color (first opinion * 16 + 12)]
      (first opinion > 0.5) [set color (118 - first opinion * 16)]
      [set color white] )
    set shape "circle"
    set size 80 / size-of-group
  ]
  while [abs(mean [first opinion] of turtles - initial-group-opinion) > 0.001] [
    clear-all
    create-turtles size-of-group [
      set opinion (list generalize-random)
    (ifelse
      (first opinion < 0.5) [set color (first opinion * 10 + 15)]
      (first opinion > 0.5) [set color (115 - first opinion * 10)]
      [set color white] )
      set shape "circle"
      set size 80 / size-of-group
    ]
  ]
  set-default-shape turtles "circle"
  layout-circle turtles 15
end

to-report generalize-random  ;; initialize individual opinions
  let mean-for-initialization 1.4 * initial-group-opinion - 0.2
  let variance-for-initialization (ifelse-value
    (mean-for-initialization > 0.5) [mean-for-initialization / 3]
    [(1 - mean-for-initialization) / 3]
    )
  let generalized-random random-normal mean-for-initialization variance-for-initialization
  while [generalized-random < 0 or generalized-random > 1] [
    set generalized-random random-normal mean-for-initialization variance-for-initialization]
  report generalized-random
end

to-report calculate-action
  let calculated-action (ifelse-value
    (fstopi < 0.5) [-1]
    (fstopi > 0.5) [1]
    [(ifelse-value (random-float 1 < 0.5) [-1] [1])]
    )
  report calculated-action
end

to-report calculate-history
  let lenopi length opinion
  let calculated-history (ifelse-value
    (lenopi = 1 ) [last opinion]
    (lenopi < conservative-degree ) [sum opinion / lenopi]
    [sum sublist opinion 0 conservative-degree / conservative-degree]
    )
  report calculated-history
end

to-report calculate-faction
  let calculated-faction (ifelse-value
    (fsthist > (0.5 + rejection-of-different-opinions)) [1]
    (fsthist <= (0.5 - rejection-of-different-opinions)) [-1]
    [0]
  )
  report calculated-faction
end

to-report calculate-utility ;; estimate utility; i reprents oneself, j reprents i's target
  let calculated-utility (ifelse-value
    (new-action-j = action-i) [1]
    [(ifelse-value
      (new-action-i = action-i) [-0.1]
      [-1]
      )]
  )
  report calculated-utility
end

to-report similarity_effect ;; generate interactive willingness based on Similarity Effect
  let decision (ifelse-value
    (first [faction] of turtle i = 0 or first [faction] of turtle j = 0) [
      (ifelse-value
        ;(random-float 1 <= (0.5 + 7 * (atan (10 * rejection-of-different-opinions) 1) / 90 * pi / 20) ) [true]
        (random-float 1 <= (0.5 + 0.4 * rejection-of-different-opinions) ) [true]
        [false]
        )
    ]
    (first [faction] of turtle i = first [faction] of turtle j) [
      (ifelse-value
        ;(random-float 1 <= (0.8 + (atan (10 * rejection-of-different-opinions) 1) / 90 * pi / 5) ) [true]
        (random-float 1 <= (0.8 + 0.4 * rejection-of-different-opinions) ) [true]
        [false]
        )
    ] [
      (ifelse-value
        ;(random-float 1 <= (0.2 + (atan (10 * rejection-of-different-opinions) 1) / 90 * pi / 2) ) [true]
        (random-float 1 <= (0.2 + 0.4 * rejection-of-different-opinions) ) [true]
        [false]
        )
    ]
    )
  report decision
end

to-report game ;; Interaction choice based on imperfect information game
  ifelse (faction-j != 0) [set action-j faction-j] [
    ifelse (random-float 1 <= 0.5) [set action-j -1] [set action-j 1] ]
  set action-for-dycoda action-for-game
  set faction-for-dycoda faction-for-game
  set fstopi dynamic-coda
  set new-action-i calculate-action
  set action-i first action-for-game
  set new-action-j action-j
  let utility-i calculate-utility
  ifelse (first faction-for-game != 0) [set action-i first faction-for-game] [
    ifelse (random-float 1 <= 0.5) [set action-i -1] [set action-i 1] ]
  set new-action-i action-j
  set new-action-j action-i
  set action-i action-j
  let utility-j calculate-utility
  let interaction (ifelse-value
    (utility-i < 0 or utility-j < 0) [false]
    [(ifelse-value
      (random-float 1 < (sum utility-for-game / length utility-for-game)) [true]
      [false]
      )
    ]
    )
  report interaction
end

to-report dynamic-coda ;; dynamic coda updating rule
  let d 0.75 - atan (10 * rejection-of-different-opinions / 180 / 2) 1
  let len length action-for-dycoda
  let P-p-I-p d
  let P-p-I-m (1 - d)
  let P-m-I-p (1 - d)
  let P-m-I-m d
  if (len != 1) [
    set faction-for-dycoda sublist faction-for-dycoda 1 (length faction-for-dycoda)
    let check 0
    let f-p 0
    let f-m 0
    let a-p-f-p 0
    let a-m-f-p 0
    let a-p-f-m 0
    let a-m-f-m 0
    let a-p-f-mi 0
    let a-m-f-mi 0
    while [check < length faction-for-dycoda] [
      (ifelse
        (item check faction-for-dycoda = 1) [set f-p f-p + 1]
        (item check faction-for-dycoda = -1) [set f-m f-m + 1] [
          set f-p f-p + 0.5
          set f-m f-m + 0.5 ] )
      let ca-dycoda item check action-for-dycoda * 2 + item check faction-for-dycoda
      (ifelse
        (ca-dycoda = 3) [set a-p-f-p a-p-f-p + 1]
        (ca-dycoda = -1) [set a-m-f-p a-m-f-p + 1]
        (ca-dycoda = 1) [set a-p-f-m a-p-f-m + 1]
        (ca-dycoda = -3) [set a-m-f-m a-m-f-m + 1]
        (ca-dycoda = 2) [set a-p-f-mi a-p-f-mi + 1]
        (ca-dycoda = -2) [set a-m-f-mi a-m-f-mi + 1] )
      set check check + 1 ]
    ifelse (f-p = 0 or f-m = 0 or a-p-f-p = 0 or a-m-f-p = 0 or a-p-f-m = 0 or a-m-f-m = 0) [
      set P-p-I-p d
      set P-p-I-m (1 - d)
      set P-m-I-p (1 - d)
      set P-m-I-m d] [
      set P-p-I-p (a-p-f-p + 0.5 * a-p-f-mi) / f-p
      set P-p-I-m (a-p-f-m + 0.5 * a-p-f-mi) / f-m
      set P-m-I-p (a-m-f-p + 0.5 * a-m-f-mi) / f-p
      set P-m-I-m (a-m-f-m + 0.5 * a-m-f-mi) / f-m] ]
  let new-opinion-i opinion-i
  ifelse (action-j = 1) [
    ifelse (opinion-i = 1) [set new-opinion-i 1] [
      let Odds P-p-I-p / P-p-I-m * opinion-i / (1 - opinion-i)
      set new-opinion-i Odds / (1 + Odds) ] ] [
    ifelse (opinion-i = 1) [set new-opinion-i 1] [
      let Odds P-m-I-p / P-m-I-m * opinion-i / (1 - opinion-i)
      set new-opinion-i Odds / (1 + Odds) ] ]
  report new-opinion-i
end

to-report group-opinion
  report mean [first opinion] of turtles
end

to-report voting-result
  report (occurrences 1 [first action] of turtles) / size-of-group
end

to-report occurrences [x the-list]
  report reduce
    [ [occurrence-count next-item] -> ifelse-value (next-item = x) [occurrence-count + 1] [occurrence-count] ] (fput 0 the-list)
end
@#$#@#$#@
GRAPHICS-WINDOW
9
10
448
450
-1
-1
13.061
1
10
1
1
1
0
0
0
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
462
10
541
43
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

INPUTBOX
462
66
541
126
size-of-group
50.0
1
0
Number

SLIDER
552
103
732
136
initial-group-opinion
initial-group-opinion
0.25
0.75
0.25
0.05
1
NIL
HORIZONTAL

PLOT
462
245
838
451
group behavior changes with time
number of interaction
group opinion/voting
0.0
10.0
0.0
0.05
true
true
"" ""
PENS
"group opinion" 1.0 0 -12895429 true "plot group-opinion" "plot group-opinion"
"voting result" 1.0 0 -15040220 true "plot voting-result" "plot voting-result"

MONITOR
461
189
568
234
group opinion
group-opinion
10
1
11

BUTTON
649
10
732
43
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

BUTTON
554
10
635
43
One step
run-step
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
554
58
732
91
conservative-degree
conservative-degree
0
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
462
146
732
179
rejection-of-different-opinions
rejection-of-different-opinions
0
0.5
0.25
0.05
1
NIL
HORIZONTAL

MONITOR
585
189
716
234
voting result
voting-result
17
1
11

MONITOR
733
190
838
235
gap
abs (group-opinion - voting-result)
17
1
11

TEXTBOX
738
11
901
219
Red is for one side of a person's opinion and blue for the other.\n\nVarying color purity indicates the firmness of people's opinions: the higher the purity, the stronger the opinion.\n\nWhite line means the two people are interacting with each other.
12
0.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

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
NetLogo 6.1.1
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
