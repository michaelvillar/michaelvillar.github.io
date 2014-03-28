var profileEl = document.body.querySelector("#profile");
var headerEl = document.body.querySelector("header");
var iconEl = headerEl.querySelector("img");
var h1El = headerEl.querySelector("h1");
var h2El = headerEl.querySelector("h2");
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
    bounce: 47,
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

initialState();
setTimeout(show, 200);
