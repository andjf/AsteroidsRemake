//this class is gross.
//should make a ExplosionParticle class
class Explosion {

  PVector position;

  int numberOfParticles;
  int lifespan;

  boolean isComplete;

  boolean fromShip;

  float[][] particlesInfo;

  public Explosion(Asteroid a, int numParticles, int totalLife) {
    this.fromShip = false;
    this.position = a.position;
    this.lifespan = totalLife;
    this.numberOfParticles = numParticles;
    
    this.particlesInfo = new float[this.numberOfParticles][5];
    for (int i = 0; i < particlesInfo.length; i++) {
      //x positoin
      particlesInfo[i][0] = this.position.x;
      //y position
      particlesInfo[i][1] = this.position.y;
      //heading
      if (random(100) <= 90 && a.velocity.mag() > 0.01) {
        float heading = a.velocity.heading();
        particlesInfo[i][2] = random(heading - PI / 5, heading + PI / 5);
      } else {
        particlesInfo[i][2] = random(0, TWO_PI);
      }
      //speed
      particlesInfo[i][3] = random(0.5, 5);
      //life
      particlesInfo[i][4] = this.lifespan;
    }
    isComplete = false;
  }

  public Explosion(Ship s, int numParticles, int totalLife) {
    this.fromShip = true;
    this.position = s.position;
    this.lifespan = totalLife;
    this.numberOfParticles = numParticles;
    this.particlesInfo = new float[this.numberOfParticles][5];
    for (int i = 0; i < this.numberOfParticles; i++) {
      //x positoin
      particlesInfo[i][0] = this.position.x;
      //y position
      particlesInfo[i][1] = this.position.y;
      //heading
      if (random(100) <= map(s.velocity.mag(), 0, 25, 0, 100) + 10) {
        float heading = s.velocity.heading();
        particlesInfo[i][2] = random(heading - PI / 5, heading + PI / 5);
      } else {
        particlesInfo[i][2] = random(0, TWO_PI);
      }
      //speed
      particlesInfo[i][3] = random(0.5, 3);
      //life
      particlesInfo[i][4] = this.lifespan;
    }
    isComplete = false;
  }

  public void update() {
    boolean hasPositive = false;
    for (int i = 0; i < this.numberOfParticles; i++) {
      particlesInfo[i][0] += particlesInfo[i][3] * cos(particlesInfo[i][2]);
      particlesInfo[i][1] += particlesInfo[i][3] * sin(particlesInfo[i][2]);
      particlesInfo[i][4] -= map(particlesInfo[i][3], 0.5, 5, 5, 10);
      if (particlesInfo[i][4] > 0) {
        hasPositive = true;
      }
    }
    this.isComplete = !hasPositive;
  }

  public void show() {
    for (int i = 0; i < this.numberOfParticles; i++) {
      strokeWeight(map(particlesInfo[i][3], 0.5, 5, this.fromShip ? 10 : 2, 1));
      //stroke(color(255, this.fromShip ? 0 : 255, this.fromShip ? 0 : 255), map(particlesInfo[i][4], 0, this.lifespan, 0, 255));
      stroke(255, map(particlesInfo[i][4], 0, this.lifespan, 0, 255));

      point(particlesInfo[i][0], particlesInfo[i][1]);
    }
  }
}
