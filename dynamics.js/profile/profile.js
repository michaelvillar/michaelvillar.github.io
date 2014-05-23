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
  var animating = false;
  var animationTimeout;
  var arrow = dynamic(viewButtonIconArrow);
  var animateArrow = function() {
    if(arrow.isAnimating())
      return;
    arrow.to({
      translateX: 3,
      translateY: -3
    }, {
      type: dynamic.GravityWithForce,
      bounce: 60,
      gravity: 1750,
      complete: function() {
        if(!animated)
          return;
        animationTimeout = setTimeout(function() {
          animateArrow();
        }, 500);
      }
    }).start();
  }
  var animateIconArrow = function(animate) {
    if(animate == animated)
      return;
    animated = animate;
    if(animate)
      animateArrow()
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
  dynamic(profileEl).css({
    translateY: 40,
    scale: 0,
    opacity: 0
  });
  dynamic(headerEl).css({
    translateY: -152
  });
  dynamic(iconEl).css({
    scale: 0
  });
  var els = [h1El, h2El];
  for(var i in els) {
    dynamic(els[i]).css({
      translateY: -20,
      opacity: 0
    });
  }
  dynamic(statsEl).css({
    translateY: -57,
    opacity: 0
  });
  for(var i=0; i<statsColsEl.length; i++) {
    dynamic(statsColsEl[i]).css({
      translateY: -25,
      opacity: 0
    });
  }
  dynamic(viewButton).css({
    translateY: -25,
    opacity: 0
  });
  dynamic(viewButtonIcon).css({
    translateX: 16,
    opacity: 0
  });
  dynamic(viewButtonLabel).css({
    translateX: -8
  });
  for(var i=0; i<descriptionEls.length; i++) {
    dynamic(descriptionEls[i]).css({
      translateX: 50,
      opacity: 0
    });
  }
  for(var i=1; i<navLinkSpanEls.length; i++) {
    dynamic(navLinkSpanEls[i]).css({
      scale: 0.1,
      opacity: 0
    });
  }
}

var show = function() {
  dynamic(profileEl).to({
    scale: 1,
    translateY: 0,
    opacity: 1
  }, {
    type: dynamic.Spring,
    frequency: 19,
    friction: 578,
    anticipationStrength: 0,
    anticipationSize: 0,
    duration: 1366
  }).start();
  showElement(headerEl, 300);
  showElement(iconEl, 300);
  showElement(h1El, 500);
  showElement(h2El, 550);
  showElement(statsEl, 600);
  for(var i=0; i<statsColsEl.length; i++) {
    showElement(statsColsEl[i], 700 + i * 100);
  }
  showElement(viewButton, 1000);
  showElement(viewButtonIcon, 1000);
  showElement(viewButtonLabel, 1000);
};

var showElement = function(el, delay) {
  dynamic(el).delay(delay).to({
    translateY: 0,
    translateX: 0,
    scale: 1,
    opacity: 1
  }, {
    type: dynamic.Spring,
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
    type: dynamic.Spring,
    frequency: 19,
    friction: 578,
    anticipationStrength: 0,
    anticipationSize: 0,
    duration: 1366
  };
  var linkOptions = {
    type: dynamic.Spring,
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

    dynamic(navLinkSpanEls[current]).to({
      scale: 0.1,
      opacity: 0
    }, linkOptions).start();
    dynamic(navLinkSpanEls[step]).to({
      scale: 1,
      opacity: 1
    }, linkOptions).start();

    var direction = step > current;
    var delay = 0;
    var elements = steps[current];
    for(var i=0;i<elements.length;i++) {
      var el = elements[i];
      dynamic(el).delay(delay).to({
        translateX: (direction ? -50 : 50),
        opacity: 0
      }, options).start();
      delay += 50;
    }

    var elements = steps[step];
    for(var i=0;i<elements.length;i++) {
      var el = elements[i];
      dynamic(el).delay(delay).to({
        translateX: 0,
        opacity: 1
      }, options).start();
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
