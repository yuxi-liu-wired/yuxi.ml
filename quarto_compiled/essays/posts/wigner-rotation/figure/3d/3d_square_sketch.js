export function squareSketch(canvasId1, canvasId2, canvasId3) {

  // Shared variables
  let vx = 0;
  let vy = 0;
  const max3Velocity = 0.8;

  let circleDiameter = 2;
  let dotDiameter = 0.1;
  let circleColor = hexToRgb("#ffffff");

  let lightConeColor = hexToRgb("#7887ab");
  let spaceCircleColor = hexToRgb("#7887ab");
  let spaceCircleDotColor = [255, 0, 0];
  const leftSketchBackgroundColor = [0, 0, 0];

  const boxHeight = 2;

  const scaleFactor = 100;
  const fontSize = 3;
  const canvasSize = 300;
  const largeCanvasSize = 600;

  // X Sketch: Unit circle with draggable dot on the x-axis
  let xSketch = function (p) {
    let dot = { x: 0, y: 0 };
    let dragging = false;

    p.setup = function () {
      p.createCanvas(canvasSize, canvasSize);
      p.noStroke();  
    };

    p.draw = function () {
      p.background(0);
      p.translate(p.width / 2, p.height / 2);
      p.scale(scaleFactor);

      p.fill(circleColor);
      p.ellipse(0, 0, circleDiameter, circleDiameter); // the disk of 3-velocities
      p.fill(0, 0, 0);
      p.ellipse(dot.x, dot.y, dotDiameter, dotDiameter); // 3-velocity (v_x, 0)

      p.push();
      p.translate(-0.8, 0.5);
      p.scale(fontSize/scaleFactor);
      p.fill(spaceCircleColor);
      p.text('modify Vₓ', 0., 0.);
      p.pop();

      if (dragging) {
        let [mouseXTransformed, mouseYTransformed] = getMouseXY(p);
        let bound = (circleDiameter/2) * max3Velocity;
        dot.x = Math.max(-bound, Math.min(mouseXTransformed, bound));
        dot.y = 0;
        vx = dot.x;
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

  // Y Sketch: Unit circle with draggable dot on the y-axis
  let ySketch = function (p) {
    let checkboxTrail;
    let dot = { x: 0, y: 0 };
    let dragging = false;

    p.setup = function () {
      p.createCanvas(canvasSize, canvasSize);
      p.noStroke();  
    };

    p.draw = function () {
      p.background(0);
      p.translate(p.width / 2, p.height / 2);
      p.scale(scaleFactor);

      p.fill(circleColor);
      p.ellipse(0, 0, circleDiameter, circleDiameter); // the disk of 3-velocities
      p.fill(0, 0, 0);
      p.ellipse(dot.x, dot.y, dotDiameter, dotDiameter); // 3-velocity (0, v_y)

      p.push();
      p.translate(-0.8, 0.5);
      p.scale(fontSize/scaleFactor);
      p.fill(spaceCircleColor);
      p.text('modify Vᵧ', 0., 0.);
      p.pop();

      if (dragging) {
        let [mouseXTransformed, mouseYTransformed] = getMouseXY(p);
        let bound = (circleDiameter/2) * max3Velocity;
        dot.x = 0;
        dot.y = Math.max(-bound, Math.min(mouseYTransformed, bound));
        vy = dot.y;
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

  // Right Sketch: spacetime diagram
  let rightSketch = function (p) {
    p.setup = function () {
      p.createCanvas(largeCanvasSize, largeCanvasSize, p.WEBGL);
      p.ortho(-largeCanvasSize/2, largeCanvasSize/2, -largeCanvasSize/2, largeCanvasSize/2, -largeCanvasSize, 2*largeCanvasSize);
      p.camera(-1, -1, -1, 
        0, 0, 0, 
        0, 0, 1);
  };

    p.draw = function () {
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
      p.fill(255, 255, 255, 127); // RGBA: White with 50% transparency
      p.noStroke();
      p.plane(4, 4);
      p.pop();

      // Plot that should be affected by the Lorentz transform.
      p.push();
      p.fill(lightConeColor);
      let transformX = velocityToLorentzTransform([vx, 0]);
      let transformY = velocityToLorentzTransform([0, vy]);
      p.applyMatrix(...getTransformMatrixArray(transformX));
      p.applyMatrix(...getTransformMatrixArray(transformY));
      p.translate(0.5, -0.5, 0)

      // Draw a rectangle [0, 1]×[0, 1]×[-boxHeight, boxHeight]
      p.box(1, 1, boxHeight);
      p.pop();

    };
  };
  new p5(xSketch, canvasId1);
  new p5(ySketch, canvasId2);
  new p5(rightSketch, canvasId3);

  function getTransformMatrixArray(transform){
    return [transform.get([0, 0]), transform.get([0, 1]), transform.get([0, 2]), 0,
                            transform.get([1, 0]), transform.get([1, 1]), transform.get([1, 2]), 0,
                            transform.get([2, 0]), transform.get([2, 1]), transform.get([2, 2]), 0,
                            0, 0, 0, 1];
  }
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
};