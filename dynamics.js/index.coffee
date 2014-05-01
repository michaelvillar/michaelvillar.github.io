class Tools
  @valuesFromURL = =>
    url = (document.location.toString() || '').split('#')
    values = {}
    if url.length > 1
      query = url[1]
      for arg in query.split(',')
        [k, v] = arg.split('=')
        values[k] = decodeURIComponent(v)
    values

  @saveValues: (args) =>
    argsString = ''
    for k, v of args
      argsString += "," unless argsString == ''
      argsString += "#{k}=#{encodeURIComponent(v)}"

    currentURL = (document.location.toString() || '').split('#')[0]
    document.location = currentURL + "#" + argsString

class App
  constructor: ->
    Dynamics.InteractivePanel.setSize(1000, 1000)
    Dynamics.InteractivePanel.openingAnimation = false

    @firstCircle = true
    @track = document.querySelector('div.track')
    @codeSection = document.querySelector('section.code')
    @demoSection = document.querySelector('section.demo')

    urlOptions = Tools.valuesFromURL()
    urlOptions.points = JSON.parse(urlOptions.points) if urlOptions.points
    defaultOptions = {
      type: 'Spring',
      frequency: 15,
      friction: 200,
      anticipationStrength: 115,
      anticipationSize: 10,
      duration: 1000
    }
    @options = {}
    for k, v of defaultOptions
      @options[k] = v
    for k, v of urlOptions
      @options[k] = v
    @options.type = eval("Dynamics.Types.#{@options.type}") if @options.type

    @createAnimation()
    @update()

  update: =>
    return unless @animation

    # Update code
    @codeSection.innerHTML = @code()

    # Update URL
    options = {}
    for k, v of @animation.options
      continue if k == 'debugName' or v == null or (typeof(v) == 'function' and k != 'type')
      if k == 'type'
        options[k] = v.name
      else if k == 'points'
        options[k] = JSON.stringify(v)
      else
        options[k] = v
    Tools.saveValues(options)

    # Animate
    clearTimeout @animationTimeout if @animationTimeout
    @animationTimeout = setTimeout(@animate, 400)

  animate: =>
    @animation.start()

  createAnimation: =>
    to = { transform: 'translateX(350px)' }
    @createCircle()
    options = {}
    for k, v of @options
      options[k] = v
    options.debugName = 'animation1'
    options.complete = (animation) =>
      # Create a dummy circle to animate the end
      toDestroyCircle = document.createElement('div')
      toDestroyCircle.classList.add('circle')
      transform = 'scale(0)'
      if !animation.dynamic().returnsToSelf
        toDestroyCircle.style.transform = toDestroyCircle.style.MozTransform = toDestroyCircle.style.webkitTransform = 'translateX(350px)'
        transform = "translateX(350px) #{transform}"
      @demoSection.appendChild(toDestroyCircle)
      destroyingAnimation = new Dynamics.Animation(toDestroyCircle, {
        transform: transform
      }, {
        type: Dynamics.Types.Spring,
        frequency: 0,
        friction: 600,
        anticipationStrength: 100,
        anticipationSize: 10,
        duration: 1000,
        complete: =>
          @demoSection.removeChild(toDestroyCircle)
      }).start()

      # Position the circle at the starting point
      @circle.style.transform = @circle.style.MozTransform = @circle.style.webkitTransform = 'scale(0)'
      showingAnimation = new Dynamics.Animation(@circle, {
        transform: 'scale(1)'
      }, {
        type: Dynamics.Types.Spring,
        frequency: 0,
        friction: 600,
        anticipationStrength: 100,
        anticipationSize: 10,
        duration: 1000
      }).start()
    options.optionsChanged = @update
    window.anim = @animation = new Dynamics.Animation(@circle, to, options)

  createCircle: =>
    return if @circle
    @circle = document.createElement('div')
    @circle.classList.add('circle')
    @circle.addEventListener 'click', =>
      @animate()
    @demoSection.appendChild(@circle)

  code: =>
    options = @animation.options
    translateX = if options.type != Dynamics.Types.SelfSpring then 350 else 50
    optionsStr = "&nbsp;&nbsp;<strong>type</strong>: Dynamics.Types.#{options.type.name}"
    for k, v of options
      continue if v == null or typeof(v) == 'function' or k == 'points'
      continue if k == 'debugName'
      continue if k == 'animated'
      continue if k == 'duration' and @animation.dynamic().expectedDuration
      optionsStr += ",\n" if optionsStr != ''
      v = "\"#{v}\"" if k == 'debugName'
      optionsStr += "&nbsp;&nbsp;<strong>#{k}</strong>: #{v}"
    if options.points
      pointsValue = JSON.stringify(options.points)
      optionsStr += ",\n&nbsp;&nbsp;<strong>points</strong>: #{pointsValue}"
    code = '''new <strong>Dynamics.Animation</strong>(document.getElementById("circle"), {
&nbsp;&nbsp;<strong>transform</strong>: "translateX(''' + translateX + '''px)"
}, {

''' + optionsStr + '''

}).start();'''
    code

document.addEventListener "DOMContentLoaded", ->
  app = new App
, false
