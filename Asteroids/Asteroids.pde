/*
* @author Andrew Ferrin
* @version June 25 2020
*/

//the ship
Ship s;
//booleans for the ship to navigate
boolean spinLeft, spinRight, boost;

//booleans for the game's stage
public static boolean gameOver = false;
public static boolean gameMenu = true;
public static boolean shipIsInvincible = false;

//ArrayLists for the asteroids, pellets, and explosions
ArrayList<Asteroid> asteroids;
ArrayList<Pellet> pellets = new ArrayList<Pellet>();
ArrayList<Explosion> explosions = new ArrayList<Explosion>();

//displaying score stuff
PFont scoreFont;
int score;
PFont gameOverFont;

//timer that keeps track of the frames during the active game
static int gameTimer = 0;

//handles the delay between shots
final static int SHOT_DELAY = 20;
static int framesSinceLastShot = SHOT_DELAY;

//frames since game has ended
int gameOverCounter = 0;

void setup() {
  this.score = 0;
  fullScreen();
  frameRate(60);
  background(0);
  s = new Ship();
  s.direction = -PI / 2;
  asteroids = new ArrayList<Asteroid>();
  for (int i = 0; i < 5; i++) {
    asteroids.add(new Asteroid());
    asteroids.get(i).velocity = new PVector(random(2, 4) * (random(100) > 50 ? 1 : -1), random(2, 4) * (random(100) > 50 ? 1 : -1));
  }
  scoreFont = createFont("SourceCodePro-ExtraLight.otf", 50);
  gameOverFont = createFont("SourceCodePro-Bold.otf", 200);
}

void draw() {
  background(0);
  handleText();
  if (!gameOver) {
    handleShip();
    checkForPelletCollision(100);
    checkForShipCollisionAndShowAsteroids();
    possiblyCreateNewAsteroid(1000);
    checkIfShouldRemoveExplosions();
    handlePellets();
    updateTimers();
  }
}

public void updateTimers() {
  if (!gameMenu) {
    gameTimer++;
  }
  framesSinceLastShot++;
}

public void handleShip() {
  s.update(spinLeft, spinRight, boost);
  s.show(boost);
}

public void checkForShipCollisionAndShowAsteroids() {
  for (Asteroid a : asteroids) {
    a.asteroidArea.intersect(s.ship);
    if (!a.asteroidArea.isEmpty() && !s.exploding) {
      //Ship crashes into astroid
      if (!gameMenu && !shipIsInvincible) {
        s.explode();
        shipIsInvincible = true;
      }
    }    
    a.show();
  }
}

public void checkForPelletCollision(int scoreIncrease) {
  for (int i = 0; i < asteroids.size(); i++) {
    asteroids.get(i).update();
    if (!gameMenu) {
      for (Pellet p : pellets) {
        if (asteroids.get(i).containsPellet(p)) {
          explosions.add(new Explosion(asteroids.get(i), 100, 300));
          pellets.remove(p);
          asteroids.get(i).explode(asteroids);
          score += scoreIncrease;
          break;
        }
      }
    }
  }
}

public void possiblyCreateNewAsteroid(int delay) {
  if (gameTimer % delay == 0 && !gameMenu) {
    asteroids.add(new Asteroid());
    asteroids.get(asteroids.size() - 1).velocity = new PVector(random(2, 4 + (gameTimer / (float)(delay / 5))) * (random(100) > 50 ? 1 : -1), random(random(2, 4 + (gameTimer / (float)(delay / 5))) * (random(100) > 50 ? 1 : -1)));
  }
}

public void handlePellets() {
  for (int i = 0; i < pellets.size(); i++) {
    if (pellets.get(i).life <= 0) {
      pellets.remove(i);
      i--;
      continue;
    }
    pellets.get(i).update();
    pellets.get(i).show();
  }
}

public void checkIfShouldRemoveExplosions() {
  for (int i = 0; i < explosions.size(); i++) {
    explosions.get(i).update();
    explosions.get(i).show();
    if (explosions.get(i).isComplete) {
      explosions.remove(i);
      i--;
    }
  }
}

public void handleText() {
  if (gameMenu) {
    textSize(150);
    textAlign(CENTER, CENTER);
    textFont(gameOverFont);
    fill(255);
    text("Asteroids", width / 2, height / 2 - 120);
    textFont(scoreFont);
    textSize(50);
    text("By: AndJ", width / 2, height / 2 + 55);

    textSize(20);
    text("Press Down arrow key to start game", width / 2, height / 2 + 100);
    text("Use Space key to shoot", width / 2, height / 2 + 130);
    text("Use Up, Right, and Left arrow keys to navigate", width / 2, height / 2 + 160);
    text("Try it out... nothing should happen", width / 2, height / 2 + 190);

    //make sure you dont display the score
    return;
  }

  fill(255);
  textFont(scoreFont);
  if (!gameOver) {
    textSize(50);
    textAlign(LEFT, TOP);
    text("Score: " + this.score, 10, 10);
  } else {
    textSize(100);
    textAlign(CENTER, CENTER);
    text("Score: " + this.score, width / 2, height / 2 + 70);
    textAlign(CENTER);
    textFont(gameOverFont);
    fill(255, map(sin(gameOverCounter / 15.0), -1, 1, 0, 255));
    text("GAME OVER", width / 2, height / 2);
    gameOverCounter++;
  }
}

void keyPressed() {
  if (key == 'b') {
    noLoop();
    exit();
  }
  if (key == ' ' && !s.exploding) {
    if (shipIsInvincible) {
      shipIsInvincible = false;
    }
    if (framesSinceLastShot >= SHOT_DELAY) {
      framesSinceLastShot = 0;
      pellets.add(new Pellet(s));
    }
  }
  if (keyCode == UP) {
    if (shipIsInvincible) {
      shipIsInvincible = false;
    }
    boost = true;
  }
  if (keyCode == LEFT) {
    spinLeft = true;
  }
  if (keyCode == RIGHT) {
    spinRight = true;
  }
  if (keyCode == DOWN) {
    if (gameMenu) {
      gameMenu = false;
    }
  }
}

void keyReleased() {
  if (keyCode == UP) {
    boost = false;
  }
  if (keyCode == LEFT) {
    spinLeft = false;
  }
  if (keyCode == RIGHT) {
    spinRight = false;
  }
}
