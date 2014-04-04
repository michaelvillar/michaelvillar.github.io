// Generated by CoffeeScript 1.4.0
(function() {
  var Animation, Animations, Bezier, BrowserSupport, Dynamic, Dynamics, EaseInOut, Gravity, GravityWithForce, Linear, MatrixTools, SelfSpring, Spring, VectorTools, cacheFn, css, stopAnimationsForEl,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Dynamic = (function() {

    Dynamic.properties = {};

    function Dynamic(options) {
      var k, v, _ref;
      this.options = options != null ? options : {};
      this.at = __bind(this.at, this);

      this.next = __bind(this.next, this);

      this.init = __bind(this.init, this);

      _ref = this.options.type.properties;
      for (k in _ref) {
        v = _ref[k];
        if (!(this.options[k] != null) && !v.editable) {
          this.options[k] = v["default"];
        }
      }
    }

    Dynamic.prototype.init = function() {
      return this.t = 0;
    };

    Dynamic.prototype.next = function(step) {
      var r;
      if (this.t > 1) {
        this.t = 1;
      }
      r = this.at(this.t);
      this.t += step;
      return r;
    };

    Dynamic.prototype.at = function(t) {
      return [t, t];
    };

    return Dynamic;

  })();

  Linear = (function(_super) {

    __extends(Linear, _super);

    function Linear() {
      this.at = __bind(this.at, this);

      this.init = __bind(this.init, this);
      return Linear.__super__.constructor.apply(this, arguments);
    }

    Linear.properties = {
      duration: {
        min: 100,
        max: 4000,
        "default": 1000
      }
    };

    Linear.prototype.init = function() {
      return Linear.__super__.init.apply(this, arguments);
    };

    Linear.prototype.at = function(t) {
      return [t, t];
    };

    return Linear;

  })(Dynamic);

  Gravity = (function(_super) {

    __extends(Gravity, _super);

    Gravity.properties = {
      bounce: {
        min: 0,
        max: 80,
        "default": 40
      },
      gravity: {
        min: 1,
        max: 4000,
        "default": 1000
      },
      expectedDuration: {
        editable: false
      }
    };

    function Gravity(options) {
      var _ref;
      this.options = options != null ? options : {};
      this.at = __bind(this.at, this);

      this.curve = __bind(this.curve, this);

      this.init = __bind(this.init, this);

      this.length = __bind(this.length, this);

      this.gravityValue = __bind(this.gravityValue, this);

      this.bounceValue = __bind(this.bounceValue, this);

      this.duration = __bind(this.duration, this);

      this.expectedDuration = __bind(this.expectedDuration, this);

      if ((_ref = this.initialForce) == null) {
        this.initialForce = false;
      }
      this.options.duration = this.duration();
      Gravity.__super__.constructor.call(this, this.options);
    }

    Gravity.prototype.expectedDuration = function() {
      return this.duration();
    };

    Gravity.prototype.duration = function() {
      return Math.round(1000 * 1000 / this.options.gravity * this.length());
    };

    Gravity.prototype.bounceValue = function() {
      var bounce;
      bounce = this.options.bounce / 100;
      bounce = Math.min(bounce, 80);
      return bounce;
    };

    Gravity.prototype.gravityValue = function() {
      return this.options.gravity / 100;
    };

    Gravity.prototype.length = function() {
      var L, b, bounce, curve, gravity;
      bounce = this.bounceValue();
      gravity = this.gravityValue();
      b = Math.sqrt(2 / gravity);
      curve = {
        a: -b,
        b: b,
        H: 1
      };
      if (this.initialForce) {
        curve.a = 0;
        curve.b = curve.b * 2;
      }
      while (curve.H > 0.001) {
        L = curve.b - curve.a;
        curve = {
          a: curve.b,
          b: curve.b + L * bounce,
          H: curve.H * bounce * bounce
        };
      }
      return curve.b;
    };

    Gravity.prototype.init = function() {
      var L, b, bounce, curve, gravity, _results;
      Gravity.__super__.init.apply(this, arguments);
      L = this.length();
      gravity = this.gravityValue();
      gravity = gravity * L * L;
      bounce = this.bounceValue();
      b = Math.sqrt(2 / gravity);
      this.curves = [];
      curve = {
        a: -b,
        b: b,
        H: 1
      };
      if (this.initialForce) {
        curve.a = 0;
        curve.b = curve.b * 2;
      }
      this.curves.push(curve);
      _results = [];
      while (curve.b < 1 && curve.H > 0.001) {
        L = curve.b - curve.a;
        curve = {
          a: curve.b,
          b: curve.b + L * bounce,
          H: curve.H * bounce * bounce
        };
        _results.push(this.curves.push(curve));
      }
      return _results;
    };

    Gravity.prototype.curve = function(a, b, H, t) {
      var L, c, t2;
      L = b - a;
      t2 = (2 / L) * t - 1 - (a * 2 / L);
      c = t2 * t2 * H - H + 1;
      if (this.initialForce) {
        c = 1 - c;
      }
      return c;
    };

    Gravity.prototype.at = function(t) {
      var bounce, curve, gravity, i, v;
      bounce = this.options.bounce / 100;
      gravity = this.options.gravity;
      i = 0;
      curve = this.curves[i];
      while (!(t >= curve.a && t <= curve.b)) {
        i += 1;
        curve = this.curves[i];
        if (!curve) {
          break;
        }
      }
      if (!curve) {
        if (this.initialForce) {
          v = 0;
        } else {
          v = 1;
        }
      } else {
        v = this.curve(curve.a, curve.b, curve.H, t);
      }
      return [t, v];
    };

    return Gravity;

  })(Dynamic);

  GravityWithForce = (function(_super) {

    __extends(GravityWithForce, _super);

    GravityWithForce.prototype.returnsToSelf = true;

    function GravityWithForce(options) {
      this.options = options != null ? options : {};
      this.initialForce = true;
      GravityWithForce.__super__.constructor.call(this, this.options);
    }

    return GravityWithForce;

  })(Gravity);

  Spring = (function(_super) {

    __extends(Spring, _super);

    function Spring() {
      this.at = __bind(this.at, this);
      return Spring.__super__.constructor.apply(this, arguments);
    }

    Spring.properties = {
      frequency: {
        min: 0,
        max: 100,
        "default": 15
      },
      friction: {
        min: 1,
        max: 1000,
        "default": 200
      },
      anticipationStrength: {
        min: 0,
        max: 1000,
        "default": 0
      },
      anticipationSize: {
        min: 0,
        max: 99,
        "default": 0
      },
      duration: {
        min: 100,
        max: 4000,
        "default": 1000
      }
    };

    Spring.prototype.at = function(t) {
      var A, At, a, angle, b, decal, frequency, friction, frictionT, s, v, y0, yS,
        _this = this;
      frequency = Math.max(1, this.options.frequency);
      friction = Math.pow(20, this.options.friction / 100);
      s = this.options.anticipationSize / 100;
      decal = Math.max(0, s);
      frictionT = (t / (1 - s)) - (s / (1 - s));
      if (t < s) {
        A = function(t) {
          var M, a, b, x0, x1;
          M = 0.8;
          x0 = s / (1 - s);
          x1 = 0;
          b = (x0 - (M * x1)) / (x0 - x1);
          a = (M - b) / x0;
          return (a * t * _this.options.anticipationStrength / 100) + b;
        };
        yS = (s / (1 - s)) - (s / (1 - s));
        y0 = (0 / (1 - s)) - (s / (1 - s));
        b = Math.acos(1 / A(yS));
        a = (Math.acos(1 / A(y0)) - b) / (frequency * (-s));
      } else {
        A = function(t) {
          return Math.pow(friction / 10, -t) * (1 - t);
        };
        b = 0;
        a = 1;
      }
      At = A(frictionT);
      angle = frequency * (t - s) * a + b;
      v = 1 - (At * Math.cos(angle));
      return [t, v, At, frictionT, angle];
    };

    return Spring;

  })(Dynamic);

  SelfSpring = (function(_super) {

    __extends(SelfSpring, _super);

    function SelfSpring() {
      this.at = __bind(this.at, this);
      return SelfSpring.__super__.constructor.apply(this, arguments);
    }

    SelfSpring.properties = {
      frequency: {
        min: 0,
        max: 100,
        "default": 15
      },
      friction: {
        min: 1,
        max: 1000,
        "default": 200
      },
      duration: {
        min: 100,
        max: 4000,
        "default": 1000
      }
    };

    SelfSpring.prototype.returnsToSelf = true;

    SelfSpring.prototype.at = function(t) {
      var A, At, At2, Ax, angle, frequency, friction, v,
        _this = this;
      frequency = Math.max(1, this.options.frequency);
      friction = Math.pow(20, this.options.friction / 100);
      A = function(t) {
        return 1 - Math.pow(friction / 10, -t) * (1 - t);
      };
      At = A(t);
      At2 = A(1 - t);
      Ax = (Math.cos(t * 2 * 3.14 - 3.14) / 2) + 0.5;
      Ax = Math.pow(Ax, this.options.friction / 100);
      angle = frequency * t;
      v = Math.cos(angle) * Ax;
      return [t, v, Ax, -Ax];
    };

    return SelfSpring;

  })(Dynamic);

  Bezier = (function(_super) {

    __extends(Bezier, _super);

    Bezier.properties = {
      points: {
        type: 'points',
        "default": [
          {
            "x": 0,
            "y": 0,
            "controlPoints": [
              {
                "x": 0.2,
                "y": 0
              }
            ]
          }, {
            "x": 0.574,
            "y": 1.208,
            "controlPoints": [
              {
                "x": 0.291,
                "y": 1.199
              }, {
                "x": 0.806,
                "y": 1.19
              }
            ]
          }, {
            "x": 1,
            "y": 1,
            "controlPoints": [
              {
                "x": 0.846,
                "y": 1
              }
            ]
          }
        ]
      },
      duration: {
        min: 100,
        max: 4000,
        "default": 1000
      }
    };

    function Bezier(options) {
      this.options = options != null ? options : {};
      this.at = __bind(this.at, this);

      this.yForX = __bind(this.yForX, this);

      this.B = __bind(this.B, this);

      this.B_ = __bind(this.B_, this);

      this.returnsToSelf = this.options.points[this.options.points.length - 1].y === 0;
      Bezier.__super__.constructor.call(this, this.options);
    }

    Bezier.prototype.B_ = function(t, p0, p1, p2, p3) {
      return (Math.pow(1 - t, 3) * p0) + (3 * Math.pow(1 - t, 2) * t * p1) + (3 * (1 - t) * Math.pow(t, 2) * p2) + Math.pow(t, 3) * p3;
    };

    Bezier.prototype.B = function(t, p0, p1, p2, p3) {
      return {
        x: this.B_(t, p0.x, p1.x, p2.x, p3.x),
        y: this.B_(t, p0.y, p1.y, p2.y, p3.y)
      };
    };

    Bezier.prototype.yForX = function(xTarget, Bs) {
      var B, aB, i, lower, percent, upper, x, xTolerance, _i, _len;
      B = null;
      for (_i = 0, _len = Bs.length; _i < _len; _i++) {
        aB = Bs[_i];
        if (xTarget >= aB(0).x && xTarget <= aB(1).x) {
          B = aB;
        }
        if (B !== null) {
          break;
        }
      }
      if (!B) {
        if (this.returnsToSelf) {
          return 0;
        } else {
          return 1;
        }
      }
      xTolerance = 0.0001;
      lower = 0;
      upper = 1;
      percent = (upper + lower) / 2;
      x = B(percent).x;
      i = 0;
      while (Math.abs(xTarget - x) > xTolerance && i < 100) {
        if (xTarget > x) {
          lower = percent;
        } else {
          upper = percent;
        }
        percent = (upper + lower) / 2;
        x = B(percent).x;
        i += 1;
      }
      return B(percent).y;
    };

    Bezier.prototype.at = function(t) {
      var Bs, i, k, points, x, y, _fn,
        _this = this;
      x = t;
      points = this.options.points || Bezier.properties.points["default"];
      Bs = [];
      _fn = function(pointA, pointB) {
        var B;
        B = function(t) {
          return _this.B(t, pointA, pointA.controlPoints[pointA.controlPoints.length - 1], pointB.controlPoints[0], pointB);
        };
        return Bs.push(B);
      };
      for (i in points) {
        k = parseInt(i);
        if (k >= points.length - 1) {
          break;
        }
        _fn(points[k], points[k + 1]);
      }
      y = this.yForX(x, Bs);
      return [x, y];
    };

    return Bezier;

  })(Dynamic);

  EaseInOut = (function(_super) {

    __extends(EaseInOut, _super);

    EaseInOut.properties = {
      friction: {
        min: 1,
        max: 1000,
        "default": 500
      },
      duration: {
        min: 100,
        max: 4000,
        "default": 1000
      }
    };

    function EaseInOut(options) {
      var friction, points;
      this.options = options != null ? options : {};
      this.at = __bind(this.at, this);

      EaseInOut.__super__.constructor.apply(this, arguments);
      friction = this.options.friction || EaseInOut.properties.friction["default"];
      points = [
        {
          "x": 0,
          "y": 0,
          "controlPoints": [
            {
              "x": 1 - (friction / 1000),
              "y": 0
            }
          ]
        }, {
          "x": 1,
          "y": 1,
          "controlPoints": [
            {
              "x": friction / 1000,
              "y": 1
            }
          ]
        }
      ];
      this.bezier = new Bezier({
        type: Bezier,
        duration: this.options.duration,
        points: points
      });
    }

    EaseInOut.prototype.at = function(t) {
      return this.bezier.at(t);
    };

    return EaseInOut;

  })(Dynamic);

  cacheFn = function(func) {
    var cachedMethod, data;
    data = {};
    cachedMethod = function() {
      var k, key, result, _i, _len;
      key = "";
      for (_i = 0, _len = arguments.length; _i < _len; _i++) {
        k = arguments[_i];
        key += k.toString() + ",";
      }
      result = data[key];
      if (!result) {
        data[key] = result = func.apply(this, arguments);
      }
      return result;
    };
    return cachedMethod;
  };

  BrowserSupport = (function() {

    function BrowserSupport() {}

    BrowserSupport.transform = function() {
      return this.withPrefix("transform");
    };

    BrowserSupport.keyframes = function() {
      if (document.body.style.webkitAnimation !== void 0) {
        return "-webkit-keyframes";
      }
      if (document.body.style.mozAnimation !== void 0) {
        return "-moz-keyframes";
      }
      return "keyframes";
    };

    BrowserSupport.withPrefix = function(property) {
      var prefix;
      prefix = this.prefixFor(property);
      if (prefix === 'Moz') {
        return "" + prefix + (property.substring(0, 1).toUpperCase() + property.substring(1));
      }
      if (prefix !== '') {
        return "-" + (prefix.toLowerCase()) + "-" + property;
      }
      return property;
    };

    BrowserSupport.prefixFor = cacheFn(function(property) {
      var k, prefix, prop, propArray, propertyName, _i, _j, _len, _len1, _ref;
      propArray = property.split('-');
      propertyName = "";
      for (_i = 0, _len = propArray.length; _i < _len; _i++) {
        prop = propArray[_i];
        propertyName += prop.substring(0, 1).toUpperCase() + prop.substring(1);
      }
      _ref = ["Webkit", "Moz"];
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        prefix = _ref[_j];
        k = prefix + propertyName;
        if (document.body.style[k] !== void 0) {
          return prefix;
        }
      }
      return '';
    });

    return BrowserSupport;

  })();

  VectorTools = {};

  VectorTools.length = function(vector) {
    var a, e, _i, _len, _ref;
    a = 0;
    _ref = vector.elements;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      e = _ref[_i];
      a += Math.pow(e, 2);
    }
    return Math.sqrt(a);
  };

  VectorTools.normalize = function(vector) {
    var e, i, length, newElements, _ref;
    length = VectorTools.length(vector);
    newElements = [];
    _ref = vector.elements;
    for (i in _ref) {
      e = _ref[i];
      newElements[i] = e / length;
    }
    return Vector.create(newElements);
  };

  VectorTools.combine = function(a, b, ascl, bscl) {
    var result;
    result = [];
    result[0] = (ascl * a.elements[0]) + (bscl * b.elements[0]);
    result[1] = (ascl * a.elements[1]) + (bscl * b.elements[1]);
    result[2] = (ascl * a.elements[2]) + (bscl * b.elements[2]);
    return Vector.create(result);
  };

  MatrixTools = {};

  MatrixTools.decompose = function(matrix) {
    var i, inversePerspectiveMatrix, j, k, pdum3, perspective, perspectiveMatrix, quaternion, rightHandSide, rotate, row, s, scale, skew, t, translate, transposedInversePerspectiveMatrix, type, v, w, x, y, z, _i, _j, _k, _l, _len, _m, _n, _o, _ref;
    translate = [];
    scale = [];
    skew = [];
    quaternion = [];
    perspective = [];
    if (matrix.elements[3][3] === 0) {
      return false;
    }
    for (i = _i = 0; _i <= 3; i = ++_i) {
      for (j = _j = 0; _j <= 3; j = ++_j) {
        matrix.elements[i][j] /= matrix.elements[3][3];
      }
    }
    perspectiveMatrix = matrix.dup();
    for (i = _k = 0; _k <= 2; i = ++_k) {
      perspectiveMatrix.elements[i][3] = 0;
    }
    perspectiveMatrix.elements[3][3] = 1;
    if (matrix.elements[0][3] !== 0 || matrix.elements[1][3] !== 0 || matrix.elements[2][3] !== 0) {
      rightHandSide = Vector.create([matrix.elements[0][3], matrix.elements[1][3], matrix.elements[2][3], matrix.elements[3][3]]);
      inversePerspectiveMatrix = perspectiveMatrix.inverse();
      transposedInversePerspectiveMatrix = inversePerspectiveMatrix.transpose();
      perspective = transposedInversePerspectiveMatrix.multiply(rightHandSide).elements;
      matrix.elements[0][3] = 0;
      matrix.elements[1][3] = 0;
      matrix.elements[2][3] = 0;
      matrix.elements[3][3] = 1;
    } else {
      perspective = [0, 0, 0, 1];
    }
    for (i = _l = 0; _l <= 2; i = ++_l) {
      translate[i] = matrix.elements[3][i];
      matrix.elements[3][i] = 0;
    }
    row = [];
    for (i = _m = 0; _m <= 2; i = ++_m) {
      row[i] = Vector.create([matrix.elements[i][0], matrix.elements[i][1], matrix.elements[i][2]]);
    }
    scale[0] = VectorTools.length(row[0]);
    row[0] = VectorTools.normalize(row[0]);
    skew[0] = row[0].dot(row[1]);
    row[1] = VectorTools.combine(row[1], row[0], 1.0, -skew[0]);
    scale[1] = VectorTools.length(row[1]);
    row[1] = VectorTools.normalize(row[1]);
    skew[0] /= scale[1];
    skew[1] = row[0].dot(row[2]);
    row[2] = VectorTools.combine(row[2], row[0], 1.0, -skew[1]);
    skew[2] = row[1].dot(row[2]);
    row[2] = VectorTools.combine(row[2], row[1], 1.0, -skew[2]);
    scale[2] = VectorTools.length(row[2]);
    row[2] = VectorTools.normalize(row[2]);
    skew[1] /= scale[2];
    skew[2] /= scale[2];
    pdum3 = row[1].cross(row[2]);
    if (row[0].dot(pdum3) < 0) {
      for (i = _n = 0; _n <= 2; i = ++_n) {
        scale[i] *= -1;
        row[i].elements[0] *= -1;
        row[i].elements[1] *= -1;
        row[i].elements[2] *= -1;
      }
    }
    rotate = [];
    rotate[1] = Math.asin(-row[0].elements[2]);
    if (Math.cos(rotate[1]) !== 0) {
      rotate[0] = Math.atan2(row[1].elements[2], row[2].elements[2]);
      rotate[2] = Math.atan2(row[0].elements[1], row[0].elements[0]);
    } else {
      rotate[0] = Math.atan2(-row[2].elements[0], row[1].elements[1]);
      rotate[1] = 0;
    }
    t = row[0].elements[0] + row[1].elements[1] + row[2].elements[2] + 1.0;
    if (t > 1e-4) {
      s = 0.5 / Math.sqrt(t);
      w = 0.25 / s;
      x = (row[2].elements[1] - row[1].elements[2]) * s;
      y = (row[0].elements[2] - row[2].elements[0]) * s;
      z = (row[1].elements[0] - row[0].elements[1]) * s;
    } else if ((row[0].elements[0] > row[1].elements[1]) && (row[0].elements[0] > row[2].elements[2])) {
      s = Math.sqrt(1.0 + row[0].elements[0] - row[1].elements[1] - row[2].elements[2]) * 2.0;
      x = 0.25 * s;
      y = (row[0].elements[1] + row[1].elements[0]) / s;
      z = (row[0].elements[2] + row[2].elements[0]) / s;
      w = (row[2].elements[1] - row[1].elements[2]) / s;
    } else if (row[1].elements[1] > row[2].elements[2]) {
      s = Math.sqrt(1.0 + row[1].elements[1] - row[0].elements[0] - row[2].elements[2]) * 2.0;
      x = (row[0].elements[1] + row[1].elements[0]) / s;
      y = 0.25 * s;
      z = (row[1].elements[2] + row[2].elements[1]) / s;
      w = (row[0].elements[2] - row[2].elements[0]) / s;
    } else {
      s = Math.sqrt(1.0 + row[2].elements[2] - row[0].elements[0] - row[1].elements[1]) * 2.0;
      x = (row[0].elements[2] + row[2].elements[0]) / s;
      y = (row[1].elements[2] + row[2].elements[1]) / s;
      z = 0.25 * s;
      w = (row[1].elements[0] - row[0].elements[1]) / s;
    }
    quaternion[0] = x;
    quaternion[1] = y;
    quaternion[2] = z;
    quaternion[3] = w;
    _ref = [translate, scale, skew, quaternion, perspective, rotate];
    for (_o = 0, _len = _ref.length; _o < _len; _o++) {
      type = _ref[_o];
      for (k in type) {
        v = type[k];
        if (isNaN(v)) {
          type[k] = 0;
        }
      }
    }
    return {
      translate: translate,
      scale: scale,
      skew: skew,
      quaternion: quaternion,
      perspective: perspective,
      rotate: rotate
    };
  };

  MatrixTools.interpolate = function(decomposedA, decomposedB, t) {
    var By, angle, aw, ax, ay, az, bw, bx, bz, cw, cx, cy, cz, decomposed, i, invscale, invth, k, qa, qb, scale, th, _i, _j, _len, _ref, _ref1;
    decomposed = {
      translate: [],
      scale: [],
      skew: [],
      quaternion: [],
      perspective: []
    };
    _ref = ['translate', 'scale', 'skew', 'perspective'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      k = _ref[_i];
      for (i = _j = 0, _ref1 = decomposedA[k].length - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
        decomposed[k][i] = (decomposedB[k][i] - decomposedA[k][i]) * t + decomposedA[k][i];
      }
    }
    qa = decomposedA.quaternion;
    qb = decomposedB.quaternion;
    ax = qa[0];
    ay = qa[1];
    az = qa[2];
    aw = qa[3];
    bx = qb[0];
    By = qb[1];
    bz = qb[2];
    bw = qb[3];
    angle = ax * bx + ay * By + az * bz + aw * bw;
    if (angle < 0.0) {
      ax = -ax;
      ay = -ay;
      az = -az;
      aw = -aw;
      angle = -angle;
    }
    if (angle + 1.0 > .05) {
      if (1.0 - angle >= .05) {
        th = Math.acos(angle);
        invth = 1.0 / Math.sin(th);
        scale = Math.sin(th * (1.0 - t)) * invth;
        invscale = Math.sin(th * t) * invth;
      } else {
        scale = 1.0 - t;
        invscale = t;
      }
    } else {
      bx = -ay;
      By = ax;
      bz = -aw;
      bw = az;
      scale = Math.sin(piDouble * (.5 - t));
      invscale = Math.sin(piDouble * t);
    }
    cx = ax * scale + bx * invscale;
    cy = ay * scale + By * invscale;
    cz = az * scale + bz * invscale;
    cw = aw * scale + bw * invscale;
    decomposed.quaternion[0] = cx;
    decomposed.quaternion[1] = cy;
    decomposed.quaternion[2] = cz;
    decomposed.quaternion[3] = cw;
    return decomposed;
  };

  MatrixTools.recompose = function(decomposedMatrix) {
    var i, j, matrix, perspective, quaternion, rotationMatrix, scale, skew, temp, translate, w, x, y, z, _i, _j, _k, _l;
    translate = decomposedMatrix.translate;
    scale = decomposedMatrix.scale;
    skew = decomposedMatrix.skew;
    quaternion = decomposedMatrix.quaternion;
    perspective = decomposedMatrix.perspective;
    matrix = Matrix.I(4);
    for (i = _i = 0; _i <= 3; i = ++_i) {
      matrix.elements[i][3] = perspective[i];
    }
    x = quaternion[0];
    y = quaternion[1];
    z = quaternion[2];
    w = quaternion[3];
    if (skew[2]) {
      temp = Matrix.I(4);
      temp.elements[2][1] = skew[2];
      matrix = matrix.multiply(temp);
    }
    if (skew[1]) {
      temp = Matrix.I(4);
      temp.elements[2][0] = skew[1];
      matrix = matrix.multiply(temp);
    }
    if (skew[0]) {
      temp = Matrix.I(4);
      temp.elements[1][0] = skew[0];
      matrix = matrix.multiply(temp);
    }
    rotationMatrix = Matrix.I(4);
    rotationMatrix.elements[0][0] = 1 - 2 * (y * y + z * z);
    rotationMatrix.elements[0][1] = 2 * (x * y - z * w);
    rotationMatrix.elements[0][2] = 2 * (x * z + y * w);
    rotationMatrix.elements[1][0] = 2 * (x * y + z * w);
    rotationMatrix.elements[1][1] = 1 - 2 * (x * x + z * z);
    rotationMatrix.elements[1][2] = 2 * (y * z - x * w);
    rotationMatrix.elements[2][0] = 2 * (x * z - y * w);
    rotationMatrix.elements[2][1] = 2 * (y * z + x * w);
    rotationMatrix.elements[2][2] = 1 - 2 * (x * x + y * y);
    matrix = matrix.multiply(rotationMatrix);
    for (i = _j = 0; _j <= 2; i = ++_j) {
      for (j = _k = 0; _k <= 2; j = ++_k) {
        matrix.elements[i][j] *= scale[i];
      }
    }
    for (i = _l = 0; _l <= 2; i = ++_l) {
      matrix.elements[3][i] = translate[i];
    }
    return matrix;
  };

  MatrixTools.matrixToString = function(matrix) {
    var i, j, str, _i, _j;
    str = 'matrix3d(';
    for (i = _i = 0; _i <= 3; i = ++_i) {
      for (j = _j = 0; _j <= 3; j = ++_j) {
        str += matrix.elements[i][j];
        if (!(i === 3 && j === 3)) {
          str += ',';
        }
      }
    }
    str += ')';
    return str;
  };

  MatrixTools.transformStringToMatrixString = cacheFn(function(transform) {
    var matrixEl, result, style;
    matrixEl = document.createElement('div');
    matrixEl.style[BrowserSupport.transform()] = transform;
    document.body.appendChild(matrixEl);
    style = window.getComputedStyle(matrixEl, null);
    result = style.transform || style[BrowserSupport.transform()];
    document.body.removeChild(matrixEl);
    return result;
  });

  Animations = [];

  stopAnimationsForEl = function(el) {
    var animation, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = Animations.length; _i < _len; _i++) {
      animation = Animations[_i];
      if (animation.el === el) {
        _results.push(animation.stop());
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  css = function(el, properties) {
    var k, v, _results;
    _results = [];
    for (k in properties) {
      v = properties[k];
      _results.push(el.style[BrowserSupport.withPrefix(k)] = v);
    }
    return _results;
  };

  Animation = (function() {

    Animation.index = 0;

    function Animation(el, to, options) {
      var redraw;
      this.el = el;
      this.to = to;
      if (options == null) {
        options = {};
      }
      this.apply = __bind(this.apply, this);

      this.frame = __bind(this.frame, this);

      this.stop = __bind(this.stop, this);

      this.start = __bind(this.start, this);

      this.defaultForProperty = __bind(this.defaultForProperty, this);

      this.parseFrames = __bind(this.parseFrames, this);

      this.getFirstFrame = __bind(this.getFirstFrame, this);

      this.convertToMatrix3d = __bind(this.convertToMatrix3d, this);

      this.convertTransformToMatrix = __bind(this.convertTransformToMatrix, this);

      this.dynamic = __bind(this.dynamic, this);

      this.setOptions = __bind(this.setOptions, this);

      if (window['jQuery'] && this.el instanceof jQuery) {
        this.el = this.el[0];
      }
      this.animating = false;
      redraw = this.el.offsetHeight;
      this.frames = this.parseFrames({
        0: this.getFirstFrame(this.to),
        100: this.to
      });
      this.setOptions(options);
      if (this.options.debugName && Dynamics.InteractivePanel) {
        Dynamics.InteractivePanel.addAnimation(this);
      }
      Animations.push(this);
    }

    Animation.prototype.setOptions = function(options) {
      var optionsChanged, _base, _base1, _base2, _base3, _ref, _ref1, _ref2, _ref3, _ref4;
      if (options == null) {
        options = {};
      }
      optionsChanged = (_ref = this.options) != null ? _ref.optionsChanged : void 0;
      this.options = options;
      if ((_ref1 = (_base = this.options).duration) == null) {
        _base.duration = 1000;
      }
      if ((_ref2 = (_base1 = this.options).complete) == null) {
        _base1.complete = null;
      }
      if ((_ref3 = (_base2 = this.options).type) == null) {
        _base2.type = Linear;
      }
      if ((_ref4 = (_base3 = this.options).animated) == null) {
        _base3.animated = true;
      }
      this.returnsToSelf = false || this.dynamic().returnsToSelf;
      this._dynamic = null;
      if (this.options.debugName && Dynamics.Overrides && Dynamics.Overrides["for"](this.options.debugName)) {
        this.options = Dynamics.Overrides.getOverride(this.options, this.options.debugName);
      }
      this.dynamic().init();
      return typeof optionsChanged === "function" ? optionsChanged() : void 0;
    };

    Animation.prototype.dynamic = function() {
      var _ref;
      if ((_ref = this._dynamic) == null) {
        this._dynamic = new this.options.type(this.options);
      }
      return this._dynamic;
    };

    Animation.prototype.convertTransformToMatrix = function(transform) {
      return MatrixTools.transformStringToMatrixString(transform);
    };

    Animation.prototype.convertToMatrix3d = function(transform) {
      var a, b, c, content, d, elements, i, match, matrixElements, tx, ty, _i;
      if (!/matrix/.test(transform)) {
        transform = 'matrix3d(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)';
      } else {
        match = transform.match(/matrix\(([-0-9\.]*), ([-0-9\.]*), ([-0-9\.]*), ([-0-9\.]*), ([-0-9\.]*), ([-0-9\.]*)\)/);
        if (match) {
          a = parseFloat(match[1]);
          b = parseFloat(match[2]);
          c = parseFloat(match[3]);
          d = parseFloat(match[4]);
          tx = parseFloat(match[5]);
          ty = parseFloat(match[6]);
          transform = "matrix3d(" + a + ", " + b + ", 0, 0, " + c + ", " + d + ", 0, 0, 0, 0, 1, 0, " + tx + ", " + ty + ", 0, 1)";
        }
      }
      match = transform.match(/matrix3d\(([^)]*)\)/);
      elements = null;
      if (match) {
        content = match[1];
        elements = content.split(',').map(parseFloat);
      }
      matrixElements = [];
      for (i = _i = 0; _i <= 3; i = ++_i) {
        matrixElements.push(elements.slice(i * 4, i * 4 + 4));
      }
      return Matrix.create(matrixElements);
    };

    Animation.prototype.getFirstFrame = function(properties) {
      var frame, k, style, v;
      frame = {};
      style = window.getComputedStyle(this.el, null);
      for (k in properties) {
        v = this.el.style[BrowserSupport.withPrefix(k)];
        if (!v) {
          v = style[BrowserSupport.withPrefix(k)];
        }
        frame[k] = v;
      }
      return frame;
    };

    Animation.prototype.parseFrames = function(frames) {
      var k, match, newFrames, newProperties, percent, properties, unit, v, vString, value;
      newFrames = {};
      for (percent in frames) {
        properties = frames[percent];
        newProperties = {};
        for (k in properties) {
          v = properties[k];
          if (k !== 'transform') {
            vString = v + "";
            match = vString.match(/([-0-9.]*)(.*)/);
            value = parseFloat(match[1]);
            unit = match[2];
          } else {
            value = MatrixTools.decompose(this.convertToMatrix3d(this.convertTransformToMatrix(v)));
            unit = '';
          }
          newProperties[k] = {
            value: value,
            unit: unit
          };
        }
        newFrames[percent] = newProperties;
      }
      return newFrames;
    };

    Animation.prototype.defaultForProperty = function(property) {
      if (property === 'opacity') {
        return 1;
      }
      return 0;
    };

    Animation.prototype.start = function() {
      stopAnimationsForEl(this.el);
      if (!this.options.animated) {
        this.apply(1, {
          progress: 1
        });
        return;
      }
      this.animating = true;
      this.ts = null;
      if (this.stopped) {
        this.stopped = false;
      }
      return requestAnimationFrame(this.frame);
    };

    Animation.prototype.stop = function() {
      this.animating = false;
      return this.stopped = true;
    };

    Animation.prototype.frame = function(ts) {
      var at, dTs, t, _base;
      if (this.stopped) {
        return;
      }
      t = 0;
      if (this.ts) {
        dTs = ts - this.ts;
        t = dTs / this.options.duration;
      } else {
        this.ts = ts;
      }
      at = this.dynamic().at(t);
      this.apply(at[1], {
        progress: t
      });
      if (t < 1) {
        return requestAnimationFrame(this.frame);
      } else {
        this.animating = false;
        this.dynamic().init();
        return typeof (_base = this.options).complete === "function" ? _base.complete(this) : void 0;
      }
    };

    Animation.prototype.apply = function(t, args) {
      var dValue, frame0, frame1, k, matrix, newValue, oldValue, progress, properties, transform, unit, v, value;
      if (args == null) {
        args = {};
      }
      frame0 = this.frames[0];
      frame1 = this.frames[100];
      progress = args.progress;
      if (progress == null) {
        progress = -1;
      }
      transform = '';
      properties = {};
      for (k in frame1) {
        v = frame1[k];
        value = v.value;
        unit = v.unit;
        newValue = null;
        if (progress >= 1) {
          if (this.returnsToSelf) {
            newValue = frame0[k].value;
          } else {
            newValue = frame1[k].value;
          }
        }
        if (k === 'transform') {
          if (newValue == null) {
            newValue = MatrixTools.interpolate(frame0[k].value, frame1[k].value, t);
          }
          matrix = MatrixTools.recompose(newValue);
          properties['transform'] = MatrixTools.matrixToString(matrix);
        } else {
          if (!newValue) {
            oldValue = null;
            if (frame0[k]) {
              oldValue = frame0[k].value;
            }
            if (oldValue == null) {
              oldValue = this.defaultForProperty(k);
            }
            dValue = value - oldValue;
            newValue = oldValue + (dValue * t);
          }
          properties[k] = newValue;
        }
      }
      return css(this.el, properties);
    };

    return Animation;

  })();

  Dynamics = {
    Animation: Animation,
    Types: {
      Spring: Spring,
      SelfSpring: SelfSpring,
      Gravity: Gravity,
      GravityWithForce: GravityWithForce,
      Linear: Linear,
      Bezier: Bezier,
      EaseInOut: EaseInOut
    },
    css: css
  };

  try {
    if (module) {
      module.exports = Dynamics;
    } else {
      this.Dynamics = Dynamics;
    }
  } catch (e) {
    this.Dynamics = Dynamics;
  }

}).call(this);
