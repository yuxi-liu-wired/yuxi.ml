// Shared variables
let vx = 0;
let vy = 0;
let fourVelocity = minkowskiNormalize([vx, vy, 1]);

let circleDiameter = 2;
let dotDiameter = 0.1;
let circleColor = hexToRgb("#ffffff");

let lightConeHeight = 1;
let lightConeColor = hexToRgb("#7887ab");
console.log(lightConeColor);
let spaceCircleColor = hexToRgb("#7887ab");
let spaceCircleDotColor = [255, 0, 0];
const leftSketchBackgroundColor = [0, 0, 0];

const spaceCircleDotTrail = [];
const spaceCircleDotTrailLength = 100;
const spaceCircleDotTrailFading = 0.99;
const scaleFactor = 100;
const canvasSize = 500;

// The vector defining the orientation of the space circle.
let ex = [1, 0, 0];

// Left Sketch: Unit circle with draggable dot
let leftSketch = function (p) {
  let checkboxTrail;
  let dot = { x: 0, y: 0 };
  let dragging = false;

  p.setup = function () {
    p.createCanvas(canvasSize, canvasSize);
    p.noStroke();

    // checkboxTrail = p.createCheckbox("Show trail");
    // checkboxTrail.position(0, 100);
  
  };

  p.draw = function () {
    p.background(0);
    p.translate(p.width / 2, p.height / 2);
    p.scale(scaleFactor);

    p.push()
    let gamma = velocityToLorentzFactor([vx, vy]);
    let theta = Math.atan2(vy, vx);
    p.rotate(theta);
    p.fill(lightConeColor);
    p.ellipse(0, 0, circleDiameter * gamma, circleDiameter);
    p.pop();

    // The projection of space circle to 2D
    p.push();
    // Update the trail array with the new position
    spaceCircleDotTrail.unshift({x: ex[0], y: ex[1]});
    if (spaceCircleDotTrail.length > spaceCircleDotTrailLength) { spaceCircleDotTrail.pop(); }
    // Draw the trail
    let alpha = 1;
    let size = dotDiameter;
    for (let i = 0; i < spaceCircleDotTrail.length; i++) {
      alpha *= spaceCircleDotTrailFading;
      size *= spaceCircleDotTrailFading;
      p.strokeWeight(size);
      p.stroke(spaceCircleDotColor[0] * alpha + leftSketchBackgroundColor[0] * (1 - alpha),
               spaceCircleDotColor[1] * alpha + leftSketchBackgroundColor[1] * (1 - alpha),
               spaceCircleDotColor[2] * alpha + leftSketchBackgroundColor[2] * (1 - alpha));
      if (i < spaceCircleDotTrail.length - 1) {
        p.line(spaceCircleDotTrail[i].x, spaceCircleDotTrail[i].y, 
               spaceCircleDotTrail[i + 1].x, spaceCircleDotTrail[i + 1].y);
      }
    }
    // Draw the current position
    p.fill(spaceCircleDotColor);
    p.ellipse(ex[0], ex[1], dotDiameter, dotDiameter);
    p.pop();

    p.fill(circleColor);
    p.ellipse(0, 0, circleDiameter, circleDiameter);
    p.fill(0, 0, 0);
    p.ellipse(dot.x, dot.y, dotDiameter, dotDiameter);

    if (dragging) {
      let [mouseXTransformed, mouseYTransformed] = getMouseXY(p);
      dot.x = mouseXTransformed;
      dot.y = mouseYTransformed;

      let d = p.dist(0, 0, dot.x, dot.y);
      let epsilon = 0.2; // avoid extremely high velocities
      let bound = (circleDiameter/2) * (1 - epsilon);
      if (d > bound) {
        let angle = p.atan2(dot.y, dot.x);
        dot.x = bound * p.cos(angle);
        dot.y = bound * p.sin(angle);
      }
      vx = dot.x;
      vy = dot.y;
      fourVelocity = minkowskiNormalize([vx, vy, 1]);
      ex = minkowskiProjection(ex, fourVelocity);
    }
  };

  p.mousePressed = function () {
    let [mouseXTransformed, mouseYTransformed] = getMouseXY(p);
    if (p.dist(mouseXTransformed, mouseYTransformed, dot.x, dot.y) < dotDiameter/2) {
      dragging = true;
    }
  };

  p.mouseReleased = function () {
    dragging = false;
  };

  function getMouseXY(p) {
    let mouseXTransformed = (p.mouseX - p.width / 2) / scaleFactor;
    let mouseYTransformed = (p.mouseY - p.height / 2) / scaleFactor;
    return [mouseXTransformed, mouseYTransformed];
  }
};

new p5(leftSketch, 'velocity-canvas');

// Right Sketch: spacetime diagram
let rightSketch = function (p) {
  p.setup = function () {
    p.createCanvas(canvasSize, canvasSize, p.WEBGL);
    p.camera(0, -canvasSize*1.2, 0, 0, 0, 0, 0, 0, 1);
  };
  let detailX = 50;
  let detailY = 50;
  let timelikeHyperboloid = new p5.Geometry(detailX, detailY, function() {
    for (let i = 0; i <= detailX; i++) {
      let theta = p.map(i, 0, detailX, 0, p.TWO_PI);
      for (let j = 0; j <= detailY; j++) {
        let r = p.map(j, 0, detailY, 0, 5);
        let x = Math.sinh(r) * Math.cos(theta);
        let y = Math.sinh(r) * Math.sin(theta);
        let z = Math.cosh(r);
        this.vertices.push(new p5.Vector(x, y, z));
      }
    }
    this.computeFaces();
    this.computeNormals();
  });

  p.draw = function () {
    fourVelocity = minkowskiNormalize([vx, vy, 1]);

    let mouseInCanvas = 
      this.mouseX < this.width &&
      this.mouseX > 0 &&
      this.mouseY < this.height &&
      this.mouseY > 0;
    
    if (mouseInCanvas) {p.orbitControl(1, 1, 1, { freeRotation: true });}
    p.scale(scaleFactor)
    p.rotateX(p.PI);
    p.background(0);

    // System-wide plotting.
    // xyz axes with different colors
    p.push();
    p.stroke(255, 0, 0);
    p.line(-1, 0, 0, 1, 0, 0);
    p.stroke(0, 255, 0);
    p.line(0, -1, 0, 0, 1, 0);
    p.stroke(0, 0, 255);
    p.line(0, 0, -1, 0, 0, 1);
    p.pop();
    
    // Plot that should not be affected by the Lorentz transform.
    // The 3-velocity vector.
    p.push();
    p.stroke('red');
    p.strokeWeight(10);
    p.point(vx, vy, 1);
    p.pop();

    // the two hyperboloids
    // p.model(timelikeHyperboloid);

    // The reference point on the space circle.
    p.push();
    p.stroke(spaceCircleDotColor);
    p.strokeWeight(20);
    p.point(ex[0], ex[1], ex[2]);
    p.pop();

    // Plot that should be affected by the Lorentz transform.
    let transform = velocityToLorentzTransform([vx, vy]);
    let transformMatrix = [transform.get([0, 0]), transform.get([0, 1]), transform.get([0, 2]), 0,
                           transform.get([1, 0]), transform.get([1, 1]), transform.get([1, 2]), 0,
                           transform.get([2, 0]), transform.get([2, 1]), transform.get([2, 2]), 0,
                           0, 0, 0, 1];
    p.applyMatrix(...transformMatrix);

    // Draw the vector fourVelocity
    p.push();
    p.stroke(255);
    p.strokeWeight(2);
    p.line(0, 0, 0, 0, 0, 1);
    p.pop();

    // The space circle
    p.push();
    p.beginShape();
    p.noFill();
    p.stroke(circleColor);
    p.strokeWeight(4);
    for (let theta = 0; theta < p.TWO_PI; theta += 0.01) {
      p.vertex(Math.cos(theta), Math.sin(theta), 0);
    }
    p.endShape(p.CLOSE);  
    p.pop();

    // Draw a cone with apex at fourVelocity, pointing towards -z
    p.push();
    p.translate(0, 0, 1);
    p.translate(0, 0, - lightConeHeight/2)
    p.rotateX(p.PI * 0.5);
    p.fill(lightConeColor);
    p.cone(lightConeHeight, lightConeHeight, 24, 1, false);
    p.pop();

    // Draw a cone with apex at -fourVelocity, pointing towards +z
    p.push();
    p.translate(0, 0, -1);
    p.translate(0, 0, + lightConeHeight/2)
    p.rotateX(p.PI * 1.5);
    p.fill(lightConeColor);
    p.cone(lightConeHeight, lightConeHeight, 24, 1, false);
    p.pop();
  };
};
new p5(rightSketch, 'spacetime-canvas');

function hexToRgb(hex) {
  let result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result ? [parseInt(result[1], 16), parseInt(result[2], 16), parseInt(result[3], 16)] : null;
}

function minkowskiProduct(u, v) {
  return u[0] * v[0] + u[1] * v[1] - u[2] * v[2];
}

function minkowskiNormSquared(u) { return minkowskiProduct(u, u); }

function minkowskiNormalize(u) {
  let norm = Math.sqrt(Math.abs(minkowskiNormSquared(u)));
  return [u[0] / norm, u[1] / norm, u[2] / norm];
}

// Requires minkowskiNormSquared(u) = -1, and minkowskiProduct(e, u) = 0
// that is, u is a time-like unit vector that is Minkowski-orthogonal to e.
// In this special case, minkowskiProjection is greatly simplified.
function minkowskiProjection(e, u_prime) {
  // e' = e + <e, u'> u'
  let eu = minkowskiProduct(e, u_prime);
  eu = [e[0] + eu * u_prime[0], e[1] + eu * u_prime[1], e[2] + eu * u_prime[2]];
  return minkowskiNormalize(eu);
}

function normalizeVector(vec) {
  let angle = Math.atan2(vec[1], vec[0]);
  return [Math.cos(angle), Math.sin(angle)];
}

function velocityToRapidity(v) {
  let speed = Math.sqrt(v[0] * v[0] + v[1] * v[1]);
  return Math.atanh(speed);
}
function velocityToRapidityVector(v) {
  let direction = normalizeVector(v);
  let rapidity = Math.atanh(v);
  return [direction[0] * rapidity, direction[1] * rapidity];s
}

function velocityToLorentzFactor(v) {
  let rapidity = velocityToRapidity(v);
  return Math.cosh(rapidity);
}

function velocityToLorentzTransform(v) {
  let rapidity = velocityToRapidity(v);
  let n = normalizeVector(v);
  let cosh = Math.cosh(rapidity);
  let sinh = Math.sinh(rapidity);

  let I = math.identity(3);
  let Kx = math.matrix([[0, 0, 1], 
                        [0, 0, 0], 
                        [1, 0, 0]]);
  let Ky = math.matrix([[0, 0, 0], 
                        [0, 0, 1], 
                        [0, 1, 0]]);
  let K = math.add(math.multiply(n[0], Kx), math.multiply(n[1], Ky));
  let Ksquared = math.multiply(K, K);
  // I + Math.sinh(rapidity) * K + (Math.cosh(rapidity) - 1) * K^2;
  return math.add(math.add(I, 
                                math.multiply(sinh, K)), 
                  math.multiply(cosh - 1, Ksquared));
}