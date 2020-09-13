class Pellet {
  PVector position, velocity, acceleration;
  float radius;
  float direction;
  int life;

  final int LIFESPAN = 70;
  final float PELLET_SPEED = 25;

  public Pellet(Ship parent) {
    this.position = new PVector(cos(parent.direction), sin(parent.direction)).mult(25).add(parent.position);
    this.direction = parent.direction;
    this.velocity = new PVector(cos(this.direction), sin(this.direction)).mult(PELLET_SPEED);
    this.acceleration = new PVector();

    this.life = LIFESPAN;

    this.radius = 2;
  }

  public void update() {
    this.life--;
    this.position.add(this.velocity);
    this.wrapAround(3);
  }

  public void wrapAround(float radius) {
    if (this.position.y <= radius) {
      this.position.y = height + radius;
    } else if (this.position.y >= height + radius) {
      this.position.y = -radius;
    }
    if (this.position.x <= -radius) {
      this.position.x = width + radius;
    } else if (this.position.x >= width + radius) {
      this.position.x = -radius;
    }
  }

  public void show() {
    fill(255);
    stroke(255);
    strokeWeight(1);
    ellipse(this.position.x, this.position.y, this.radius * 2, this.radius * 2);
  }
}
