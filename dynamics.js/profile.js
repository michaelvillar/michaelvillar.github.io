var profileEl = document.body.querySelector("#profile");
var headerEl = document.body.querySelector("header");
var iconEl = headerEl.querySelector("img");
var h1El = headerEl.querySelector("h1");
var h2El = headerEl.querySelector("h2");
var statsEl = document.body.querySelector("#stats");
var statsColsEl = statsEl.querySelectorAll(".col");
var followButton = document.body.querySelector("button#follow");
var followButtonIcon = followButton.querySelector(".icon");
var followButtonLabel = followButton.querySelector(".label");

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
  Dynamics.css(followButton, {
    transform: "translateY(-25px)",
    opacity: 0
  });
  Dynamics.css(followButtonIcon, {
    transform: "translateX(16px)",
    opacity: 0
  });
  Dynamics.css(followButtonLabel, {
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
  setTimeout(showElement.bind(this, followButton), 1000);
  setTimeout(showElement.bind(this, followButtonIcon), 1600);
  setTimeout(showElement.bind(this, followButtonLabel), 1600);
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

window.addEventListener('click', function() {
  initialState();
  setTimeout(show, 200);
});
