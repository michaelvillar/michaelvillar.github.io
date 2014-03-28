var profileEl = document.body.querySelector("#profile");
var headerEl = document.body.querySelector("header");
var headerDivEls = headerEl.querySelectorAll("div");
var iconEl = headerEl.querySelector("img");
var h1El = headerEl.querySelector("h1");
var h2El = headerEl.querySelector("h2");
var descriptionEls = headerEl.querySelectorAll("p");
var navLinkEls = headerEl.querySelectorAll("nav a");
var navLinkSpanEls = headerEl.querySelectorAll("nav a span");
var statsEl = document.body.querySelector("#stats");
var statsColsEl = statsEl.querySelectorAll(".col");
var viewButton = document.body.querySelector("a#view");
var viewButtonIcon = viewButton.querySelector(".icon");
var viewButtonIconArrow = viewButton.querySelector(".icon .arrow");
var viewButtonLabel = viewButton.querySelector(".label");

(function() {
  var animated = false;
  var animationTimeout;
  var animation = new Dynamics.Animation(viewButtonIconArrow, {
    transform: "translateX(3px) translateY(-3px)"
  }, {
    type: Dynamics.Types.GravityWithForce,
    bounce: 60,
    gravity: 1750,
    complete: function() {
      if(!animated)
        return;
      animationTimeout = setTimeout(function() {
        animation.start();
      }, 500);
    }
  });
  var animateIconArrow = function(animate) {
    if(animate == animated)
      return;
    animated = animate;
    if(animate)
      animation.start();
    else {
      if(animationTimeout)
        clearTimeout(animationTimeout);
    }
  }
  viewButton.addEventListener('mouseover', function() {
    animateIconArrow(true);
  });
  viewButton.addEventListener('mouseout', function() {
    animateIconArrow(false);
  });
})();

var initialState = function() {
  Dynamics.css(profileEl, {
    transform: "translateY(40px) scale(0)",
    opacity: 0
  });
  Dynamics.css(headerEl, {
    transform: "translateY(-152px)"
  });
  Dynamics.css(iconEl, {
    transform: "scale(0)"
  });
  var els = [h1El, h2El];
  for(var i in els) {
    Dynamics.css(els[i], {
      transform: "translateY(-20px)",
      opacity: 0
    });
  }
  Dynamics.css(statsEl, {
    transform: "translateY(-57px)",
    opacity: 0
  });
  for(var i=0; i<statsColsEl.length; i++) {
    Dynamics.css(statsColsEl[i], {
      transform: "translateY(-25px)",
      opacity: 0
    });
  }
  Dynamics.css(viewButton, {
    transform: "translateY(-25px)",
    opacity: 0
  });
  Dynamics.css(viewButtonIcon, {
    transform: "translateX(16px)",
    opacity: 0
  });
  Dynamics.css(viewButtonLabel, {
    transform: "translateX(-8px)"
  });
  for(var i=0; i<descriptionEls.length; i++) {
    Dynamics.css(descriptionEls[i], {
      transform: "translateX(50px)",
      opacity: 0
    });
  }
  for(var i=1; i<navLinkSpanEls.length; i++) {
    Dynamics.css(navLinkSpanEls[i], {
      transform: "scale(.1)",
      opacity: 0
    });
  }
}

var show = function() {
  new Dynamics.Animation(profileEl, {
    transform: "scale(1)",
    opacity: 1
  }, {
    type: Dynamics.Types.Spring,
    frequency: 19,
    friction: 578,
    anticipationStrength: 0,
    anticipationSize: 0,
    duration: 1366
  }).start();
  setTimeout(showElement.bind(this, headerEl), 300);
  setTimeout(showElement.bind(this, iconEl), 300);
  setTimeout(showElement.bind(this, h1El), 500);
  setTimeout(showElement.bind(this, h2El), 550);
  setTimeout(showElement.bind(this, statsEl), 600);
  for(var i=0; i<statsColsEl.length; i++) {
    setTimeout(showElement.bind(this, statsColsEl[i]), 700 + i * 100);
  }
  setTimeout(showElement.bind(this, viewButton), 1000);
  setTimeout(showElement.bind(this, viewButtonIcon), 1000);
  setTimeout(showElement.bind(this, viewButtonLabel), 1000);
};

var showElement = function(el) {
  new Dynamics.Animation(el, {
    transform: "none",
    opacity: 1
  }, {
    type: Dynamics.Types.Spring,
    frequency: 5,
    friction: 200,
    anticipationStrength: 0,
    anticipationSize: 0,
    duration: 600
  }).start();
};

(function() {
  var steps = [
    [iconEl, h1El, h2El],
    [descriptionEls[0], descriptionEls[1]]
  ];
  var current = 0;
  var options = {
    type: Dynamics.Types.Spring,
    frequency: 19,
    friction: 578,
    anticipationStrength: 0,
    anticipationSize: 0,
    duration: 1366
  };
  var linkOptions = {
    type: Dynamics.Types.Spring,
    frequency: 15,
    friction: 300,
    anticipationStrength: 0,
    anticipationSize: 0,
    duration: 1366
  };
  var headerGoTo = function(step) {
    if(current == step)
      return;
    headerDivEls[step].classList.add('active');
    headerDivEls[current].classList.remove('active');

    new Dynamics.Animation(navLinkSpanEls[current], {
      transform: "scale(.1)",
      opacity: 0
    }, linkOptions).start();
    new Dynamics.Animation(navLinkSpanEls[step], {
      transform: "none",
      opacity: 1
    }, linkOptions).start();

    var direction = step > current;
    var delay = 0;
    var elements = steps[current];
    for(var i=0;i<elements.length;i++) {
      var el = elements[i];
      setTimeout(function(el) {
        new Dynamics.Animation(el, {
          transform: (direction ? "translateX(-50px)" : "translateX(50px)"),
          opacity: 0
        }, options).start();
      }.bind(this, el), delay);
      delay += 50;
    }

    var elements = steps[step];
    for(var i=0;i<elements.length;i++) {
      var el = elements[i];
      setTimeout(function(el) {
        new Dynamics.Animation(el, {
          transform: "none",
          opacity: 1
        }, options).start();
      }.bind(this, el), delay);
      delay += 50;
    }

    current = step;
  };

  for(var i=0; i<navLinkEls.length; i++) {
    var link = navLinkEls[i];
    link.addEventListener('click', headerGoTo.bind(this, i));
  }
})();

initialState();
setTimeout(show, 200);
