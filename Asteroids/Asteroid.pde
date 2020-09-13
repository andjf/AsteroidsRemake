import java.awt.Polygon;

class Asteroid {
  PShape shape;
  PVector position, velocity, acceleration;
  float direction;

  Polygon poly;
  Area asteroidArea;

  int size;

  final int MINIMUM_VERTICIES = 7, MAXIMUM_VERTICIES = 15, MINIMUM_RADIUS = 50, MAXIMUM_RADIUS = 120;

  public Asteroid() {
    this(3);
  }

  public Asteroid(float x, float y) {
    this(3);
    this.position = new PVector(x, y);
  }

  public Asteroid(Asteroid parent, boolean up) {
    this.position = new PVector(parent.position.x, parent.position.y + (up ? 20 : -20));
    float parentVel = parent.velocity.mag();
    float parentTheta = parent.velocity.heading();
    float newTheta = parentTheta + ((up ? -1 : 1) * random(PI / 10, PI / 5));
    this.velocity = new PVector(cos(newTheta), sin(newTheta)).mult(parentVel);
    this.acceleration = new PVector();

    this.size = parent.size - 1;
    float scale = 1.0 / pow(2, 3 - this.size);
    this.shape = establishShape(MINIMUM_VERTICIES, MAXIMUM_VERTICIES, MINIMUM_RADIUS, MAXIMUM_RADIUS);
    this.shape.scale(scale);

    this.poly = updatePolygon(scale);

    this.asteroidArea = new Area(this.poly);
  }

  public Asteroid(int sz) {
    this.position = choseRandomWall();
    this.velocity = new PVector();
    this.acceleration = new PVector();

    this.size = sz;
    float scale = 1.0 / pow(2, 3 - this.size);
    this.shape = establishShape(MINIMUM_VERTICIES, MAXIMUM_VERTICIES, MINIMUM_RADIUS, MAXIMUM_RADIUS);
    this.shape.scale(scale);

    this.poly = updatePolygon(scale);
    this.asteroidArea = new Area(this.poly);
  }

  public boolean containsPellet(Pellet p) {
    return this.containsPoint(p.position.x, p.position.y);
  }

  public boolean containsPoint(float x, float y) {
    return this.poly.contains((int)(x), (int)(y));
  }

  private PVector choseRandomWall() {
    int randomWall = (int)(random(0, 4));
    if (randomWall == 0) {
      return new PVector(random(0, width), 0);
    } else if (randomWall == 1) {
      return new PVector(width, random(0, height));
    } else if (randomWall == 2) {
      return new PVector(random(0, width), height);
    } else {
      return new PVector(0, random(0, height));
    }
  }

  public void update() {
    this.velocity.add(this.acceleration);
    this.position.add(this.velocity);
    this.wrapAround(MAXIMUM_RADIUS);
    this.poly.reset();

    this.poly = updatePolygon(1.0 / pow(2, 3 - this.size));
    this.asteroidArea = new Area(this.poly);
  }

  public void wrapAround(float radius) {
    if (this.position.y <= -radius) {
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

  private Polygon updatePolygon(float scale) {
    int[] newPointsX = new int[this.shape.getVertexCount()];
    int[] newPointsY = new int[this.shape.getVertexCount()];
    for (int i = 0; i < this.shape.getVertexCount(); i++) {
      newPointsX[i] = (int)((this.shape.getVertex(i).x * scale + this.position.x));
      newPointsY[i] = (int)((this.shape.getVertex(i).y * scale + this.position.y));
    }
    return new Polygon(newPointsX, newPointsY, newPointsX.length);
  }

  private PShape establishShape(int minVerticies, int maxverticies, float minRadius, float maxRadius) {
    int numberOfVertices = (int)random(minVerticies, maxverticies);
    PShape s = createShape();
    s.beginShape();
    for (int i = 0; i < numberOfVertices; i++) {
      float r = random(minRadius, maxRadius);
      float theta = map(i, 0, numberOfVertices, 0, TWO_PI) + random(-TWO_PI / (2 * numberOfVertices), TWO_PI / (2 * numberOfVertices));
      s.vertex(r * cos(theta), r * sin(theta));
    }
    s.endShape(CLOSE);
    return s;
  }

  public void explode(ArrayList<Asteroid> asteroids) {
    if (this.size > 1) {
      asteroids.add(new Asteroid(this, true));
      asteroids.add(new Asteroid(this, false));
    }
    asteroids.remove(this);
  }

  public void show() {
    pushMatrix();
    translate(this.position.x, this.position.y);
    rotate(this.direction);
    this.shape.setStroke(color(255));
    this.shape.setFill(false);
    this.shape.setStrokeWeight(pow(2, 3 - this.size) + 1);
    shape(this.shape, 0, 0);
    popMatrix();
  }
}
