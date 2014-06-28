// Generated by CoffeeScript 1.4.0
(function() {
  var App, Tools,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Tools = (function() {
    var _this = this;

    function Tools() {}

    Tools.valuesFromURL = function() {
      var arg, k, query, url, v, values, _i, _len, _ref, _ref1;
      url = (document.location.toString() || '').split('#');
      values = {};
      if (url.length > 1) {
        query = url[1];
        _ref = query.split(',');
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          arg = _ref[_i];
          _ref1 = arg.split('='), k = _ref1[0], v = _ref1[1];
          values[k] = decodeURIComponent(v);
        }
      }
      return values;
    };

    Tools.saveValues = function(args) {
      var argsString, currentURL, k, v;
      argsString = '';
      for (k in args) {
        v = args[k];
        if (argsString !== '') {
          argsString += ",";
        }
        argsString += "" + k + "=" + (encodeURIComponent(v));
      }
      currentURL = (document.location.toString() || '').split('#')[0];
      return document.location = currentURL + "#" + argsString;
    };

    return Tools;

  }).call(this);

  App = (function() {

    function App() {
      this.code = __bind(this.code, this);

      this.createCircle = __bind(this.createCircle, this);

      this.createAnimation = __bind(this.createAnimation, this);

      this.animate = __bind(this.animate, this);

      this.update = __bind(this.update, this);

      var defaultOptions, k, urlOptions, v;
      Dynamics.InteractivePanel.setSize(1000, 1000);
      Dynamics.InteractivePanel.openingAnimation = false;
      this.firstCircle = true;
      this.track = document.querySelector('div.track');
      this.codeSection = document.querySelector('section.code');
      this.demoSection = document.querySelector('section.demo');
      urlOptions = Tools.valuesFromURL();
      if (urlOptions.points) {
        urlOptions.points = JSON.parse(urlOptions.points);
      }
      defaultOptions = {
        type: 'Spring',
        frequency: 15,
        friction: 200,
        anticipationStrength: 115,
        anticipationSize: 10,
        duration: 1000
      };
      this.options = {};
      for (k in defaultOptions) {
        v = defaultOptions[k];
        this.options[k] = v;
      }
      for (k in urlOptions) {
        v = urlOptions[k];
        this.options[k] = v;
      }
      if (this.options.type) {
        this.options.type = eval("dynamic." + this.options.type);
      }
      this.createAnimation();
      this.update();
    }

    App.prototype.update = function(options) {
      var k, urlOptions, v, _ref;
      if (!this.circle) {
        return;
      }
      this.codeSection.innerHTML = this.code(options);
      urlOptions = {};
      _ref = options != null ? options : this.to.options;
      for (k in _ref) {
        v = _ref[k];
        if (k === 'debugName' || v === null || (typeof v === 'function' && k !== 'type')) {
          continue;
        }
        if (k === 'type') {
          urlOptions[k] = v.name;
        } else if (k === 'points') {
          urlOptions[k] = JSON.stringify(v);
        } else {
          urlOptions[k] = v;
        }
      }
      Tools.saveValues(urlOptions);
      if (this.animationTimeout) {
        clearTimeout(this.animationTimeout);
      }
      return this.animationTimeout = setTimeout(this.animate, 400);
    };

    App.prototype.animate = function() {
      return this.circle.to(this.to.to, this.to.options).start();
    };

    App.prototype.createAnimation = function() {
      var k, options, to, v, _ref,
        _this = this;
      to = {
        transform: 'translateX(350px)'
      };
      this.createCircle();
      options = {};
      _ref = this.options;
      for (k in _ref) {
        v = _ref[k];
        options[k] = v;
      }
      options.debugName = 'animation1';
      options.complete = function(animation) {
        var toDestroyCircle, transform;
        toDestroyCircle = document.createElement('div');
        toDestroyCircle.classList.add('circle');
        transform = 'scale(0)';
        if (true) {
          toDestroyCircle.style.transform = toDestroyCircle.style.MozTransform = toDestroyCircle.style.webkitTransform = 'translateX(350px)';
          transform = "translateX(350px) " + transform;
        }
        _this.demoSection.appendChild(toDestroyCircle);
        dynamic(toDestroyCircle).to({
          transform: transform
        }, {
          type: dynamic.Spring,
          frequency: 0,
          friction: 600,
          anticipationStrength: 100,
          anticipationSize: 10,
          duration: 1000,
          complete: function() {
            return _this.demoSection.removeChild(toDestroyCircle);
          }
        }).start();
        _this.circle.css({
          transform: 'scale(0)'
        });
        return _this.circle.to({
          transform: 'scale(1)'
        }, {
          type: dynamic.Spring,
          frequency: 0,
          friction: 600,
          anticipationStrength: 100,
          anticipationSize: 10,
          duration: 1000
        }).start();
      };
      options.optionsChanged = this.update;
      return this.to = {
        to: to,
        options: options
      };
    };

    App.prototype.createCircle = function() {
      var circle,
        _this = this;
      if (this.circle) {
        return;
      }
      circle = document.createElement('div');
      circle.classList.add('circle');
      circle.addEventListener('click', function() {
        return _this.animate();
      });
      this.demoSection.appendChild(circle);
      return this.circle = dynamic(circle);
    };

    App.prototype.code = function(options) {
      var code, k, optionsStr, pointsValue, translateX, v;
      if (options == null) {
        options = this.to.options;
      }
      translateX = options.type !== dynamic.SelfSpring ? 350 : 50;
      optionsStr = "&nbsp;&nbsp;<strong>type</strong>: dynamic." + options.type.name;
      for (k in options) {
        v = options[k];
        if (v === null || typeof v === 'function' || k === 'points') {
          continue;
        }
        if (k === 'debugName') {
          continue;
        }
        if (k === 'animated') {
          continue;
        }
        if (optionsStr !== '') {
          optionsStr += ",\n";
        }
        if (k === 'debugName') {
          v = "\"" + v + "\"";
        }
        optionsStr += "&nbsp;&nbsp;<strong>" + k + "</strong>: " + v;
      }
      if (options.points) {
        pointsValue = JSON.stringify(options.points);
        optionsStr += ",\n&nbsp;&nbsp;<strong>points</strong>: " + pointsValue;
      }
      code = 'dynamic(document.getElementById("circle")).to({\n&nbsp;&nbsp;<strong>transform</strong>: "translateX(' + translateX + 'px)"\n}, {\n' + optionsStr + '\n}).start();';
      return code;
    };

    return App;

  })();

  document.addEventListener("DOMContentLoaded", function() {
    var app;
    return app = new App;
  }, false);

}).call(this);
