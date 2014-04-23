svgIndex = 0
random = (a, b) ->
  Math.round(Math.random() * (b - a)) + a

createSVG = (text) ->
  div = document.createElement('div')
  div.innerHTML = text
  div

createCircleSVG = (options = {}) ->
  options.color ?= '#eb4986'
  options.radius ?= 10
  options.radius = Math.ceil(options.radius)
  svgIndex += 1
  circle = createSVG('''
  <svg class="circle" width="''' + options.radius + '''" height="''' + options.radius + '''" version="1.1" xmlns="http://www.w3.org/2000/svg">
    <defs>
      <mask id="mask''' + svgIndex + '''">
        <rect x="0" y="0" width="''' + options.radius + '''" height="''' + options.radius + '''" fill="white"></rect>
        <circle class="inner" cx="''' + options.radius / 2 + '''" cy="''' + options.radius / 2 + '''" r="''' + options.radius / 2 + '''" fill="black"></circle>
      </mask>
    </defs>
    <circle class="outer" cx="''' + options.radius / 2 + '''" cy="''' + options.radius / 2 + '''" r="''' + options.radius / 2 + '''" fill="''' + options.color + '''" mask="url(#mask''' + svgIndex + ''')"></circle>
  </svg>''')
  circle.style.marginLeft = "-#{options.radius / 2}px"
  circle.style.marginTop = "-#{options.radius / 2}px"
  circle

createAnimatedCircle = (position = [], options = {}) =>
  options.delay ?= 0

  circle = createCircleSVG(options)
  circle.style.left = "#{position[0]}px"
  circle.style.top = "#{position[1]}px"
  circle.style.position = "absolute"
  document.body.appendChild(circle)

  innerCircle = circle.querySelector('.inner')
  outerCircle = circle.querySelector('.outer')
  Dynamics.css(outerCircle, {
    transform: "scale(.01)"
  })
  Dynamics.css(innerCircle, {
    transform: "scale(.01)"
  })

  new Dynamics.Animation(outerCircle, {
    transform: "scale(1)"
  }, {
    type: Dynamics.Types.EaseInOut,
    friction: 200,
    duration: 1000 * 1.1
  }).start(delay: options.delay)
  new Dynamics.Animation(innerCircle, {
    transform: "scale(1.01)"
  }, {
    type: Dynamics.Types.EaseInOut,
    friction: 200,
    duration: 1000 * 1.1,
    complete: =>
      circle.parentNode.removeChild(circle)
  }).start(delay: options.delay + 200 * 1.1)

  circle

createGalaxy = (options = {}) =>
  options.radius ?= 30
  count = 10
  innerRadius = options.radius / 15
  center = options.center
  for i in [0...count]
    position = [center[0], center[1]]
    angle = i / count * Math.PI * 2
    delay = 0
    position[0] += Math.cos(angle) * innerRadius
    position[1] += Math.sin(angle) * innerRadius
    circle = createAnimatedCircle(position, delay: delay, radius: options.radius / 3, color: options.color)
    translate = []
    translate[0] = Math.cos(angle) * options.radius
    translate[1] = Math.sin(angle) * options.radius
    translate[1] = Math.round(translate[1])
    new Dynamics.Animation(circle, {
      transform: "translateX(#{translate[0]}px) translateY(#{translate[1]}px)"
    }, {
      type: Dynamics.Types.EaseInOut,
      friction: 200,
      duration: 1200 * 1.2
    }).start(delay: delay)

createRandomGalaxy = =>
  center = [random(200,window.innerWidth - 200), random(200,window.innerHeight - 200)]
  createGalaxy(center: center)
  setTimeout =>
    createGalaxy(center: center, radius: 50, color: '#C9F668')
  , 400

tick = =>
  createRandomGalaxy()

tick()
setInterval tick, 1000
