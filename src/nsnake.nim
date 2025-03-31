import illwill
import random, os, strutils, times, parsecfg

# Definition of basic types for the game
type
  Position = tuple[x, y: int]
  Direction = enum
    UP, DOWN, LEFT, RIGHT
  Snake = object
    body: seq[Position]      # Sequence of positions representing the snake's body
    direction: Direction     # Current direction of movement
    lastTail: Position       # Store the last tail position for clean up
  Game = object
    snake: Snake
    food: Position          # Position of the food
    lastFood: Position      # Store the last food position
    score: int              # Current score
    lastScore: int          # Store the last score
    gameOver: bool          # Game state
    lastGameState: bool     # Store the last game state

let FOOD_CHAR  = "*"
let SNAKE_CHAR = "@"
let DEAD_CHAR  = "X"

# --------------------------------------------------
# Game Initialization

proc exitProc() =
  illwillDeinit()
  showCursor() 
  stdout.write("\x1b[2J")  # Clear screen
  stdout.write("\x1b[H")   # Move cursor to top-left corner
  stdout.flushFile()       # Ensure all changes are written

proc initGame(width, height: int): Game =
  # Initialize game state with snake in the middle and random food position
  result.snake.body = @[(width div 2, height div 2)]
  result.snake.direction = RIGHT
  result.snake.lastTail = (0, 0)
  result.food = (rand(width-2)+1, rand(height-2)+1)
  result.lastFood = (-1, -1)
  result.score = 0
  result.lastScore = 0
  result.gameOver = false
  result.lastGameState = false

proc moveSnake(game: var Game, width, height: int) =
  # Store the last tail position before moving
  game.snake.lastTail = game.snake.body[^1]

  # Get current head position
  let head = game.snake.body[0]
  var newHead = head
  
  # Calculate new head position based on direction
  case game.snake.direction
  of UP:    newHead.y -= 1
  of DOWN:  newHead.y += 1
  of LEFT:  newHead.x -= 1
  of RIGHT: newHead.x += 1
  
  # Add new head to the beginning of the snake
  game.snake.body.insert(newHead, 0)
  
  # Store the current food position before potentially changing it
  game.lastFood = game.food
   
  # Check if food was eaten
  if newHead == game.food:
    game.lastScore = game.score
    game.score += 1
    # Generate new food position
    game.food = (rand(width-2)+1, rand(height-2)+1)
  else:
    # Remove tail if no food was eaten
    game.snake.body.delete(game.snake.body.len-1)
  
  # Check for collisions with walls or self
  if newHead.x in [0, width] or newHead.y in [0, height] or
     newHead in game.snake.body[1..^1]:
    game.lastGameState = game.gameOver
    game.gameOver = true

# --------------------------------------------------
# High Score Management using std/parsecfg

proc getHighScoreFilePath(): string =
  # Return platform-specific config file path
  when defined(windows):
    if os.getEnv("APPDATA") != "":
      return joinPath(os.getEnv("APPDATA"), "nsnake.ini")
    else:
      return "nsnake.ini"
  elif defined(macosx):
    return joinPath(os.getHomeDir(), "Library", "Application Support", "nsnake.ini")
  else:
    #return joinPath(os.getHomeDir(), ".local", "share", "nsnake.ini")
    return joinPath(os.getHomeDir(), ".local", "share", "nsnake.ini")

proc loadHighScore(): int =
  # Load high score from INI file
  let path = getHighScoreFilePath()
  if fileExists(path):
    let cfg = loadConfig(path)
    try:
      return parseInt(cfg.getSectionValue("Game", "HighScore"))
    except:
      return 0
  return 0

proc saveHighScore(score: int) =
  # Save high score to INI file
  let path = getHighScoreFilePath()
  var cfg = newConfig()
  
  try:
    # Create directory if it doesn't exist
    let dir = parentDir(path)
    if not dirExists(dir):
      createDir(dir)
      
    # Add the section and key
    cfg.setSectionKey("Game", "HighScore", $score)
  
    writeConfig(cfg, path)
  except IOError, OSError:
    exitProc()
    echo "Couldn't write to config file: ", path
    quit(0)

# --------------------------------------------------
# Game Display

proc drawGame(game: Game, highScore: int, tb: var TerminalBuffer, width, height: int) =
  # Only draw the frame and scores initially
  if game.score == 0 and game.lastScore == 0:
    tb.clear()
    tb.setForegroundColor(fgWhite, true)
    tb.drawRect(0, 0, width*2, height)
    tb.setForegroundColor(fgGreen, true)
    tb.write(0, 0, "Score: 0")
    tb.write(15, 0, "High Score: " & $highScore)
    # Draw initial food
    tb.setForegroundColor(fgRed, true)
    tb.write(game.food.x*2, game.food.y, FOOD_CHAR)
 
  # Update score if changed
  if game.score != game.lastScore:
    tb.setForegroundColor(fgGreen, true)
    tb.write(0, 0, "Score: " & $game.score)

  # Clear last tail position if snake moved without eating
  # Now we also clear it when game over state changes
  if (not game.gameOver and game.snake.lastTail != game.snake.body[0]) or
     (game.gameOver != game.lastGameState):
    tb.write(game.snake.lastTail.x*2, game.snake.lastTail.y, " ")

  # Update food position if changed
  if game.food != game.lastFood:
    tb.write(game.lastFood.x*2, game.lastFood.y, " ")
    tb.setForegroundColor(fgRed, true)
    tb.write(game.food.x*2, game.food.y, FOOD_CHAR)

  # Update snake appearance
  if game.gameOver != game.lastGameState:
    # If game state changed, redraw entire snake
    for i, pos in game.snake.body:
      if i < game.score + 1:
        if game.gameOver:
          tb.setForegroundColor(fgRed, true)
          tb.write(pos.x*2, pos.y, DEAD_CHAR)
        else:
          tb.setForegroundColor(fgGreen, true)
          tb.write(pos.x*2, pos.y, SNAKE_CHAR)
  else:
    # Otherwise, just update the head position
    if not game.gameOver:
      tb.setForegroundColor(fgGreen, true)
      tb.write(game.snake.body[0].x*2, game.snake.body[0].y, SNAKE_CHAR)
  
  # Update game over message
  if game.gameOver != game.lastGameState and game.gameOver:
    tb.setForegroundColor(fgRed, true)
    tb.write((width*2) div 2 - 4, height div 2, "Game Over")
    tb.write((width*2) div 2 - 8, height div 2 + 1, "Press R to restart")
  
  tb.display()

# --------------------------------------------------
# Main Program

proc main() =
  const
    width = 20
    height = 20
    updateInterval = 100  # Update interval in milliseconds
  var
    tb = newTerminalBuffer(terminalWidth(), terminalHeight())
    game = initGame(width, height)
    lastUpdate = epochTime()
    highScore = loadHighScore()
  
  # Initialize terminal
  illwillInit(fullscreen=true)
  hideCursor()

  tb.setForegroundColor(fgWhite, true)
  tb.clear()
  
  # Main game loop
  while true:
    var key = getKey()
    case key
    # Arrow keys and vim controls (hjkl)
    of Key.Up, Key.K:    game.snake.direction = UP
    of Key.Down, Key.J:  game.snake.direction = DOWN
    of Key.Left, Key.H:  game.snake.direction = LEFT
    of Key.Right, Key.L: game.snake.direction = RIGHT
    of Key.R:
      # Update high score if current score is higher
      if game.score > highScore:
        highScore = game.score
        saveHighScore(highScore)
      game = initGame(width, height)  # Restart game
    of Key.Escape, Key.Q:
      exitProc()
      break
    else: discard

    # Update game state at fixed interval
    if epochTime() - lastUpdate > updateInterval / 1000:
      lastUpdate = epochTime()
      if not game.gameOver:
        game.moveSnake(width, height)
      else:
        if game.score > highScore:
          highScore = game.score
          saveHighScore(highScore)
      game.drawGame(highScore, tb, width, height)
      sleep(updateInterval)
      
when isMainModule:
  main()
