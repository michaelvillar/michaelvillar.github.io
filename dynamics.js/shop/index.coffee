SOCKS_COUNT = 34

fade = (->
  el = document.querySelector('#fade')
  el.style.display = 'none'

  hideTimeout = null
  hidden = true

  show = ->
    hidden = false
    el.style.display = 'block'
    clearTimeout(hideTimeout) if hideTimeout
    hideTimeout = null
    setTimeout =>
      el.className = 'visible'

  hide = ->
    hidden = true
    el.className = ''
    hideTimeout = setTimeout ->
      el.style.display = 'none'
    , 450

  {
    show: show,
    hide: hide,
    isHidden: ->
      hidden
  }
)()

logo = (->
  el = document.querySelector('#logo')
  el.addEventListener 'click', ->
    fade.hide()
    updateOffset(animated: true)

  scrollFade = 30

  updateOffset = (options = {}) ->
    options.animated ?= false
    return unless fade.isHidden()
    scrollY = Math.min(window.scrollY, scrollFade)
    offset = scrollY / scrollFade
    new Dynamics.Animation(el, {
      opacity: 1 - offset,
      transform: "translateY(#{(- offset * 10)}px)"
    }, {
      type: Dynamics.Types.EaseInOut,
      duration: 300,
      animated: options.animated
    }).start()
    if offset >= 1
      el.className = "hidden"
    else
      el.className = ""

  show = ->
    new Dynamics.Animation(el, {
      opacity: 1,
      transform: "none"
    }, {
      type: Dynamics.Types.Spring,
      duration: 500
    }).start()
    el.className = ""

  {
    show: show,
    updateOffset: updateOffset
  }
)()

class Loading
  constructor: (el) ->
    @el = el
    @dots = @el.querySelectorAll('span')
    @current = 0
    @animated = false
    @hiddenIndexes = []

  start: =>
    return if @animated
    @animated = true
    @tick()
    @interval = setInterval(@tick, 500)

  tick: =>
    dot = @dots[@current]
    if @stopping
      setTimeout =>
        new Dynamics.Animation(dot, {
          opacity: 0
        }, {
          type: Dynamics.Types.EaseInOut,
          duration: 300
        }).start()
      , 350
      @hiddenIndexes.push(@current)
    new Dynamics.Animation(dot, {
      transform: "translateY(-10px)"
    }, {
      type: Dynamics.Types.GravityWithForce,
      bounce: 60,
      gravity: 1300
    }).start()
    @current += 1
    if @current > 2
      @current = 0
    if @hiddenIndexes.indexOf(@current) != -1
      clearInterval(@interval) if @interval
      @hiddenIndexes = []

  stop: =>
    return unless @animated
    @stopping = true
    @animated = false

loading = new Loading(document.querySelector('header .loading'))
loading.start()

(->
  grid = document.querySelector('#grid')

  class Item
    constructor: (i) ->
      @index = i

      @el = document.createElement('a')
      @el.className = "item"
      @img = document.createElement('img')
      @el.appendChild(@img)

      @img.addEventListener('load', @imgLoaded)

      @el.addEventListener('mouseover', @itemOver)
      @el.addEventListener('mouseout', @itemOut)
      @el.addEventListener('click', @itemClick)

    load: =>
      @img.src = "http://michaelvillar.github.io/dynamics.js/shop/img/socks/socks-#{@index}.jpg"

    itemOver: =>
      new Dynamics.Animation(@el, {
        transform: "scale(1.18)"
      }, {
        type: Dynamics.Types.Spring,
        frequency: 25,
        duration: 300
      }).start()

    itemOut: =>
      new Dynamics.Animation(@el, {
        transform: "none"
      }, {
        type: Dynamics.Types.Spring,
        duration: 1500
      }).start()

    show: =>
      Dynamics.css(@el, {
        opacity: 0,
        transform: "scale(.01)"
      })
      grid.appendChild(@el)
      setTimeout =>
        new Dynamics.Animation(@el, {
          transform: "scale(1)",
          opacity: 1
        }, {
          type: Dynamics.Types.Spring,
          friction: 500,
          frequency: 25,
          duration: 2500
        }).start()
      , @index * 20

    itemClick: =>
      fade.show()
      logo.show()

    imgLoaded: =>
      @img.className = "loaded"
      @loaded?()

  items = []
  loadedCount = 0
  showItems = ->
    loading.stop()
    for item in items
      item.show()
  itemLoaded = ->
    loadedCount += 1
    if loadedCount >= items.length
      showItems()

  for i in [1..SOCKS_COUNT]
    item = new Item(i)
    item.loaded = itemLoaded
    items.push(item)
  for item in items
    item.load()

)()

(->
  window.addEventListener 'scroll', (e) =>
    logo.updateOffset()
)()
