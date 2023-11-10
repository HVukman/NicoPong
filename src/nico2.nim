# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

import nico

import random


const
  window_width=520 
  window_height=260
  scale=1
  paddle_width=5
  paddle_height=30
  fullscreen=false
  paddle_speed=40.0
  enemy_speed=35.0
  paddle_init=window_height/2
  ball_width=5
  ball_height=5
  init_bounce=[1.0,-1.0]
  init_x_dir=[1.0,-1.0]
  

var 
  
  ditherLevel = 0.8f
  xorMode = true
  pos_paddle_y=0.0
  enem_paddle_y=0.0
  player_score=0
  enemy_score=0
  ball_speed=60.0
  ball_init_x=0.0
  ball_init_y=0.0
  bounce=sample(init_bounce)
  x_dir=sample(init_x_dir)
  state="Game"
  is_pause=false

type
  Paddle = ref object
    x:float32
    y:float

proc newPaddle(x: float32, y:float32): Paddle =
  Paddle(
    x: x,
    y: y
  )

proc drawPaddle(paddle:Paddle)=

  setColor(7)
  rectfill(paddle.x,paddle.y,paddle.x+paddle_width,paddle.y+paddle_height)

type
  Ball=ref object
    x:float
    y:float

proc newBall(x:float, y:float):Ball=
    
    Ball(x:x,
         y:y
    )

proc player_win(player_win:bool)=
  x_dir=sample(init_x_dir)
  synth(0, synSaw , 20.0, 10, -2, 200)
  ball_init_x=0
  if player_win==true:
    player_score+=1 
  elif player_win==false:
    enemy_score+=1


proc ball_update_x( dt:float32)=
  if ball_init_x>window_width/2:
    player_win(true)
  if ball_init_x<(-window_width)/2:
    player_win(false)
  ball_init_x+=ball_speed*dt*x_dir
  
proc ball_update_y( dt:float32)=
  
  ball_init_y+=bounce*ball_speed*dt 
  if ball_init_y>window_height/2:
    bounce= -1.0
    ball_speed += rand(1.0)
  elif ball_init_y<(-window_height)/2:
    bounce=1.0
    ball_speed += rand(1.0)
 

proc drawBall(ball:Ball)=
  setColor(5)
  
  rectfill(ball.x,ball.y,ball.x+ball_width,ball.y+ball_height)

func collision(ball: Ball, paddle: Paddle): bool =
  return not (
    ball.x > paddle.x + paddle_width or
    ball.x + 2 * ball_width < paddle.x or
    ball.y > paddle.y + paddle_height or
    ball.y + 2 * ball_height < paddle.y
  )

type
  GameStates = enum
    pause, game


proc gameInit()=
  var game_state=GameStates.game
  loadFont(1, "font.png")
  loadSfx(0,"bing.ogg")
  if xorMode:
    ditherADitherXor(ditherLevel)
  setPalette(loadPalettePico8())
  createWindow("Pong", window_width, window_height, scale, fullscreen)

  echo "Init"

proc reset()=
  player_score=0
  enemy_score=0
  pos_paddle_y=0
  enem_paddle_y=0
  ball_init_x=0
  ball_init_y=0


template buttonpress(ks:Keycode,pos_paddle:float,speed:float,dir:float)=
    if key(ks)==true:
      pos_paddle += speed*dt*dir


proc gameUpdate(dt:float32)=
  
  if state=="Pause" :
    if keyp(Keycode.K_ESCAPE) and is_pause==true:
      state="Game"
      is_pause=false


  elif state=="Game":
    ball_update_x(dt)
    ball_update_y(dt)
    
    buttonpress(Keycode.K_W,pos_paddle_y,paddle_speed,-1.0)
    buttonpress(Keycode.K_S,pos_paddle_y,paddle_speed,1.0)
    buttonpress(Keycode.K_UP,enem_paddle_y,enemy_speed,-1.0)
    buttonpress(Keycode.K_DOWN,enem_paddle_y,enemy_speed,+1.0)

    if keyp(Keycode.K_ESCAPE):
      state="Pause"
      is_pause=true
    if keyp(Keycode.K_r):
      reset()
 

proc gameDraw()=
  cls()
  
  var paddle=newPaddle(0,paddle_init+pos_paddle_y)
  var enemy_paddle=newPaddle(window_width-paddle_width,paddle_init+enem_paddle_y)

  var ball=newBall(window_width/2+ball_init_x,window_height/2+ball_init_y)

  if (collision(ball,paddle))==true:
    x_dir= 1
    sfx(0,0)
    echo("collision")
    
  if (collision(ball,enemy_paddle))==true:
    x_dir= -1
    sfx(0,0)
    echo("collision")

  drawPaddle(paddle)
  drawPaddle(enemy_paddle)

  drawBall(ball)
  setColor(6)
  setFont(1)
  var score="Player Score: " & $(player_score)
  var enemy_score_string="Enemy Score: " & $(enemy_score)

  print(score,1,10,3)
  print(enemy_score_string,window_width/2+10,10,3)
  if is_pause==true:
    print("PAUSE",window_width/2,window_height/2,3)

nico.init("impbox","cgajam")
randomize()
fixedSize(true)
integerScale(true)
nico.run(gameInit, gameUpdate, gameDraw)