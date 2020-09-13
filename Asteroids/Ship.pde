import java.awt.geom.Area;

class Ship {
  PVector position, velocity, acceleration;
  float direction;

  boolean exploding;

  Area ship;

  Explosion shipExplosion;

  final float THRUST_POWER = 0.13;
  final float TURN_SPEED = 0.08;
  final int NUMBER_OF_LIVES = 5;

  int lives;

  public Ship() {
    this.lives = NUMBER_OF_LIVES;

    this.position = new PVector(width / 2, height / 2);
    this.velocity = new PVector();
    this.acceleration = new PVector();

    this.direction = 0;

    this.exploding = false;
    this.shipExplosion = new Explosion(this, 150, 500);

    this.ship = this.updateArea();
  }

  public Ship(float x, float y) {
    this.lives = NUMBER_OF_LIVES;

    this.position = new PVector(x, y);
    this.velocity = new PVector();
    this.acceleration = new PVector();

    this.direction = 0;

    this.exploding = false;
    this.shipExplosion = new Explosion(this, 150, 500);

    this.ship = this.updateArea();
  }

  public void update(boolean leftPressed, boolean rightPressed, boolean boost) {
    this.velocity.add(this.acceleration);
    this.direction += (rightPressed ? TURN_SPEED : 0) - (leftPressed ? TURN_SPEED : 0);
    if (boost) {
      this.velocity.add(new PVector(cos(this.direction), sin(this.direction)).mult(THRUST_POWER));
    }
    this.velocity.mult(0.995);
    this.position.add(this.velocity);
    this.wrapAround(30);
    this.ship = this.updateArea();
  }

  public void wrapAround(float radius) {
    if (this.position.y <= -radius) {
      this.position.y = height + radius - 5;
    } else if (this.position.y >= height + radius) {
      this.position.y = -radius + 5;
    }
    if (this.position.x <= -radius) {
      this.position.x = width + radius;
    } else if (this.position.x >= width + radius) {
      this.position.x = -radius;
    }
  }

  private Area updateArea() {
    int[] xPoints = new int[] {-25, 25, -25};
    int[] yPoints = new int[] {15, 0, -15};
    for (int i = 0; i < 3; i++) {
      float mag = sqrt(pow(xPoints[i], 2) + pow(yPoints[i], 2));
      float heading = atan2(yPoints[i], xPoints[i]);
      xPoints[i] = (int)(mag * cos(heading + this.direction) + this.position.x);
      yPoints[i] = (int)(mag * sin(heading + this.direction) + this.position.y);
    }

    return new Area(new Polygon(xPoints, yPoints, 3));
  }

  public void explode() {
    this.lives--;
    this.exploding = true;
    this.shipExplosion = new Explosion(this, 150, 500);
    this.position = new PVector(width / 2, height / 2);
  }

  public void show(boolean boost) {
    //this draws the "lives" of the ship
    //does not draw it in the game menu
    if (!Asteroids.gameMenu) {
      pushMatrix();
      strokeWeight(2);
      stroke(255);
      translate(width + 20, 45);
      for (int i = 0; i < this.lives; i++) {
        translate(-50, 0);
        line(0, -25, -15, 25);
        line(0, -25, 15, 25);
        float y1 = -17;
        line(-map(y1, -25, 25, 15, 0), -y1, map(y1, -25, 25, 15, 0), -y1);
      }
      popMatrix();
    }

    if (!this.exploding) {
      pushMatrix();
      translate(this.position.x, this.position.y);
      rotate(this.direction);
      fill(255, 50);
      noStroke();
      rectMode(LEFT);
      if (Asteroids.framesSinceLastShot <= Asteroids.SHOT_DELAY) {
        rect(-25, -15, Math.min(map(Asteroids.framesSinceLastShot, 0, Asteroids.SHOT_DELAY, 0, 25), 25), 15);
      }
      noFill();
      boolean on;
      if(Asteroids.shipIsInvincible) {
        if(Asteroids.gameTimer % 50 > 15) {
          on = true;
        } else {
         on = false; 
        }
      } else {
        on = true;
      }
      stroke(color(255, on ? 255 : 0));
      strokeWeight(2);
      line(25, 0, -25, -15);
      line(25, 0, -25, 15);

      float x = -17;
      line(x, -map(x, -25, 25, 15, 0), x, map(x, -25, 25, 15, 0));

      noFill();
      strokeWeight(1);

      if (boost) {
        stroke(255, 75);
        strokeWeight(2);
        for (int i = 0; i < 5; i++) {
          float y = random(-map(x, -25, 25, 15, 0), map(x, -25, 25, 15, 0));
          line(x, y, x - random(5, 50), y + random(-7, 7));
        }
      }
      popMatrix();
    } else {
      this.position = new PVector(width / 2, height / 2);
      this.velocity = new PVector();
      this.shipExplosion.update();
      this.shipExplosion.show();
      if (this.shipExplosion.isComplete) {
        this.exploding = false;
      }
      if (lives < 0 && this.shipExplosion.isComplete) {
        Asteroids.gameOver = true;
      }
    }
  }
}
