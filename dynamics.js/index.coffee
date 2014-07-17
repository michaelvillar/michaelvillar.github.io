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
      anticipationStrength: 200,
      anticipationSize: 25,
      duration: 1000
    }
    @options = {}
    for k, v of defaultOptions
      @options[k] = v
    for k, v of urlOptions
      @options[k] = v
    @options.type = eval("dynamic.#{@options.type}") if @options.type

    @createAnimation()
    @update(@options)

  update: (options) =>
    return unless @circle

    # Update code
    @codeSection.innerHTML = @code(options)

    # Update URL
    urlOptions = {}
    for k, v of (options ? @to.options)
      continue if k == 'debugName' or v == null or (typeof(v) == 'function' and k != 'type')
      if k == 'type'
        urlOptions[k] = v.name
      else if k == 'points'
        urlOptions[k] = JSON.stringify(v)
      else
        urlOptions[k] = v
    Tools.saveValues(urlOptions)

    # Change track size
    options = Dynamics.Overrides.getOverride(@to.options, @to.options.debugName)
    if @translateX(options.type) == 350
      @track.classList.remove('tiny')
    else
      @track.classList.add('tiny')

    # Animate
    clearTimeout @animationTimeout if @animationTimeout
    @animationTimeout = setTimeout(@animate, 400)

  animate: =>
    options = Dynamics.Overrides.getOverride(@to.options, @to.options.debugName)
    @circle.to({
      transform: "translateX(#{@translateX(options.type)}px)"
    }, @to.options).start()

  createAnimation: =>
    @createCircle()
    options = {}
    for k, v of @options
      options[k] = v
    options.debugName = 'animation1'
    options.complete = @onComplete
    options.optionsChanged = @update
    @to = { options: options }

  createCircle: =>
    return if @circle
    circle = document.createElement('div')
    circle.classList.add('circle')
    circle.addEventListener 'click', =>
      @animate()
    @demoSection.appendChild(circle)
    @circle = dynamic(circle)

  code: (options) =>
    options ?= @to.options
    translateX = @translateX(options.type)
    optionsStr = "&nbsp;&nbsp;<strong>type</strong>: dynamic.#{options.type.name}"
    for k, v of options
      continue if v == null or typeof(v) == 'function' or k == 'points'
      continue if k == 'debugName'
      continue if k == 'animated'
      # continue if k == 'duration' and @to.dynamic().expectedDuration
      optionsStr += ",\n" if optionsStr != ''
      v = "\"#{v}\"" if k == 'debugName'
      optionsStr += "&nbsp;&nbsp;<strong>#{k}</strong>: #{v}"
    if options.points
      pointsValue = JSON.stringify(options.points)
      optionsStr += ",\n&nbsp;&nbsp;<strong>points</strong>: #{pointsValue}"
    code = '''dynamic(document.getElementById("circle")).to({
&nbsp;&nbsp;<strong>transform</strong>: "translateX(''' + translateX + '''px)"
}, {

''' + optionsStr + '''

}).start();'''
    code

  # Private
  endTranslateX: (type) ->
    if type in [dynamic.SelfSpring, dynamic.GravityWithForce]
      0
    else
      350

  translateX: (type) ->
    if type in [dynamic.SelfSpring]
      50
    else
      350

  # Events
  onComplete: (element, to, options) =>
    # Create a dummy circle to animate the end
    toDestroyCircle = document.createElement('div')
    toDestroyCircle.classList.add('circle')
    transform = 'scale(0)'
    dynamic(toDestroyCircle).css({
      transform: "translateX(#{@endTranslateX(options.type)}px)"
    })
    transform = "translateX(#{@endTranslateX(options.type)}px) #{transform}"
    @demoSection.appendChild(toDestroyCircle)
    dynamic(toDestroyCircle).to({
      transform: transform
    }, {
      type: dynamic.Spring,
      frequency: 0,
      friction: 600,
      anticipationStrength: 100,
      anticipationSize: 10,
      duration: 1000,
      complete: =>
        @demoSection.removeChild(toDestroyCircle)
    }).start()

    # Position the circle at the starting point
    @circle.css({ transform: 'scale(0)' })
    @circle.to({
      transform: 'scale(1)'
    }, {
      type: dynamic.Spring,
      frequency: 0,
      friction: 600,
      anticipationStrength: 100,
      anticipationSize: 10,
      duration: 1000
    }).start()

document.addEventListener "DOMContentLoaded", ->
  app = new App
, false
