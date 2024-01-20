turtles-own
[
  ;; (синий) начальное состояние
  infected1?   ;; if true, the turtle is infectious (желтый) если узел заражен
  infected2?           ;; if true, the turtle is infectious (красный) если узел заражен
  resistant?          ;; if true, the turtle can't be infected (серый) если узел не чувствителен
  exposed?     ;; if true, the turtle is (зеленый) латентный эффект
]

to setup
  clear-all
  setup-nodes
  setup-spatially-clustered-network
  ask n-of initial-outbreak-size turtles
    [ become-infected1 ]
  ask links [ set color white ]
  reset-ticks
end

to setup-nodes
  set-default-shape turtles "circle"
  create-turtles number-of-nodes
   [
    ; for visual reasons, we don't put any nodes *too* close to the edges
     setxy (random-xcor * 0.95) (random-ycor * 0.95)
     become-susceptible
  ]
end

to setup-spatially-clustered-network
  let num-links (average-node-degree * number-of-nodes) / 2
  while [count links < num-links ]
  [
    ask one-of turtles
    [
      let choice (min-one-of (other turtles with [not link-neighbor? myself])
                   [distance myself])
      if choice != nobody [ create-link-with choice ]
    ]
  ]
  ; make the network look a little prettier
  repeat 10
  [
    layout-spring turtles links 0.3 (world-width / (sqrt number-of-nodes)) 1
  ]
end

to go
  if all? turtles [not infected1? and not infected2?]
    [ stop ]
  spread-virus
  do-virus-checks
  tick
end

to become-infected1  ;; turtle procedure
  set infected1? true
  set infected2? false
  set resistant? false
  set color yellow
end

to become-infected2  ;; turtle procedure
  set infected1? false
  set infected2? true
  set resistant? false
  set exposed? false
  set color red
end

to become-exposed  ;; turtle procedure
  set infected1? false
  set infected2? false
  set resistant? false
  set exposed? true
  set color green
end

to become-susceptible  ;; 1turtle procedure
  set infected1? false
  set infected2? false
  set resistant? false
  set exposed? false
  set color blue
end

to become-resistant  ;; turtle procedure
  set infected1? false
  set infected2? false
  set resistant? true
  set exposed? false
  set color gray
  ask my-links [ set color gray - 2 ]
end



to spread-virus
  ask turtles with [infected1? or infected2? or exposed?]
    [ ask link-neighbors with [not (resistant? or  exposed?)]
        [
        let choice random 4
        (ifelse
          choice = 0 [
          if random-float 100 < virus-spread-chance1
              [ become-infected1 ]]
         choice = 1 [
          if random-float 100 < virus-spread-chance2
              [ become-infected2 ]]
          choice = 2 [
          if random-float 100 < virus-spread-exposed
              [ become-exposed ]]
        )
      ]
    ]
end

to do-virus-checks
  ask turtles with [infected1? or infected2?]
  [
    if random 100 < recovery-chance
    [
      ifelse random 100 < gain-resistance-chance
        [ become-resistant ]
        [ become-susceptible ]
    ]

  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
261
11
827
578
-1
-1
13.61
1
10
1
1
1
0
0
0
1
-20
20
-20
20
1
1
1
ticks
30.0

SLIDER
24
322
229
355
gain-resistance-chance
gain-resistance-chance
0.0
100
4.0
1
1
%
HORIZONTAL

SLIDER
24
284
229
317
recovery-chance
recovery-chance
0.0
10.0
5.0
0.1
1
%
HORIZONTAL

SLIDER
25
175
230
208
virus-spread-chance1
virus-spread-chance1
0.0
10.0
10.0
0.1
1
%
HORIZONTAL

BUTTON
25
125
120
165
NIL
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
135
125
230
165
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
833
12
1489
575
System Status
time
% of nodes
0.0
52.0
0.0
100.0
true
true
"" ""
PENS
"susceptible" 1.0 0 -13345367 true "" "plot (count turtles with [not infected1? and not infected2? and not resistant?]) / (count turtles) * 100"
"infected1" 1.0 0 -1184463 true "" "plot (count turtles with [infected1?]) / (count turtles) * 100"
"resistant" 1.0 0 -7500403 true "" "plot (count turtles with [resistant?]) / (count turtles) * 100"
"infected2" 1.0 0 -2674135 true "" "plot (count turtles with [infected2?]) / (count turtles) * 100"
"exposed" 1.0 0 -15040220 true "" "plot (count turtles with [exposed?]) / (count turtles) * 100"

SLIDER
25
15
230
48
number-of-nodes
number-of-nodes
10
300
55.0
5
1
NIL
HORIZONTAL

SLIDER
25
85
230
118
initial-outbreak-size
initial-outbreak-size
1
number-of-nodes
10.0
1
1
NIL
HORIZONTAL

SLIDER
25
50
230
83
average-node-degree
average-node-degree
1
number-of-nodes - 1
7.0
1
1
NIL
HORIZONTAL

SLIDER
25
210
229
243
virus-spread-chance2
virus-spread-chance2
0
10.0
10.0
0.1
1
%
HORIZONTAL

SLIDER
24
247
229
280
virus-spread-exposed
virus-spread-exposed
0
10
0.6
0.1
1
%
HORIZONTAL

@#$#@#$#@
## Описание модели 

Эта модель демонстрирует распространение вируса через сеть. Хотя модель несколько абстрактна, одна из интерпретаций состоит в том, что каждый узел представляет собой компьютер, и мы моделируем продвижение компьютерного вируса (или червя) через эту сеть. Каждый узел может находиться в одном из трех состояний: восприимчивый, зараженный или устойчивый. В научной литературе такую модель иногда называют моделью SEIR для эпидемий.

## Принцип работы

 На каждом временном шаге (галочка) каждый зараженный узел (красный цвет) пытается заразить всех своих соседей. Восприимчивые соседи (отмечены синим цветом) будут заражены с вероятностью, определяемой ползунком ВИРУС-РАСПРЕДЕЛЕНИЕ-ШАНС. Это может соответствовать вероятности того, что кто-то в уязвимой системе действительно выполнит зараженное вложение электронного письма.
Устойчивые узлы (окрашены серым цветом) не могут быть заражены. Это может соответствовать актуальному антивирусному программному обеспечению и исправлениям безопасности, которые делают компьютер невосприимчивым к этому конкретному вирусу.

Зараженные узлы не сразу узнают о том, что они заражены. Лишь время от времени (определяется ползунком VIRUS-CHECK-FREQUENCY) узлы проверяют, заражены ли они вирусом. Это может быть регулярная процедура сканирования на вирусы или просто человек, заметивший что-то подозрительное в поведении компьютера. При обнаружении вируса существует вероятность его удаления (определяется ползунком ВОССТАНОВЛЕНИЕ-ШАНС).

Если узел выздоровеет, существует некоторая вероятность того, что он станет устойчивым к этому вирусу в будущем (задается ползунком GAIN-RESISTANCE-CHANCE).

Когда узел становится устойчивым, связи между ним и его соседями затемняются, поскольку они больше не являются возможными векторами распространения вируса.

## Как использлвать 

С помощью ползунков выберите КОЛИЧЕСТВО УЗЛОВ и СРЕДНЮЮ СТЕПЕНЬ УЗЛА (среднее количество ссылок, исходящих из каждого узла).

Создаваемая сеть основана на близости (евклидовом расстоянии) между узлами. Узел выбирается случайным образом и подключается к ближайшему узлу, с которым он еще не подключен. Этот процесс повторяется до тех пор, пока в сети не будет правильного количества связей, обеспечивающего указанную среднюю степень узла.

Ползунок INITIAL-OUTBREAK-SIZE определяет, сколько узлов запустит симуляцию, зараженную вирусом.

Затем нажмите SETUP, чтобы создать сеть. Нажмите GO, чтобы запустить модель. Модель перестанет работать, как только вирус полностью исчезнет.

Ползунки VIRUS-SPREAD-CHANCE, VIRUS-CHECK-FREQUENCY, RECOVERY-CHANCE и GAIN-RESISTANCE-CHANCE (обсуждаемые выше в разделе «Как это работает») можно настроить перед нажатием кнопки GO или во время работы модели.

График СТАТУС СЕТИ показывает количество узлов в каждом состоянии (S, I, R) с течением времени.

## Дальнейшее развитие

В конце цикла, после того как вирус вымер, некоторые узлы все еще восприимчивы, а другие стали невосприимчивы. Каково соотношение количества иммунных узлов к числу восприимчивых узлов? Как на это влияет изменение СРЕДНЕЙ УЗЛОВОЙ СТЕПЕНИ сети?

## Что можно попробовать

Установите GAIN-RESISTANCE-CHANCE на 0%. При каких условиях вирус все равно вымрет? Сколько времени это занимает? Какие условия необходимы для жизни вируса? Если ШАНС ВОССТАНОВЛЕНИЯ больше 0, даже если ШАНС РАСПРОСТРАНЕНИЯ ВИРУСА высок, думаете ли вы, что если бы вы могли запускать модель вечно, вирус мог бы остаться в живых?

## РАСШИРЕНИЕ МОДЕЛИ

Реальные компьютерные сети, в которых распространяются вирусы, обычно не основаны на пространственной близости, как сети, обнаруженные в этой модели. В реальных компьютерных сетях чаще обнаруживается «безмасштабное» распределение степеней связей, что несколько похоже на сети, созданные с использованием модели предпочтительного прикрепления. Попробуйте поэкспериментировать с различными альтернативными сетевыми структурами и посмотрите, чем отличается поведение вируса.

Предположим, вирус распространяется, рассылая себя по электронной почте всем, кто есть в адресной книге компьютера. Поскольку нахождение в чьей-то адресной книге не является симметричным отношением, измените эту модель, чтобы использовать направленные ссылки вместо ненаправленных.

Можете ли вы моделировать несколько вирусов одновременно? Как они будут взаимодействовать? Иногда, если на компьютере установлено вредоносное ПО, он более уязвим для заражения другим вредоносным ПО.

Попробуйте создать модель, подобную этой, но в которой вирус способен мутировать. Такие самомодифицирующиеся вирусы представляют собой значительную угрозу компьютерной безопасности, поскольку традиционные методы идентификации сигнатур вирусов могут против них не работать. В вашей модели узлы, которые стали невосприимчивыми, могут быть повторно заражены, если вирус мутировал и стал значительно отличаться от варианта, который первоначально заразил узел.

## СВЯЗАННЫЕ МОДЕЛИ

Virus, Disease, Preferential Attachment, Diffusion on a Directed Network
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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
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
