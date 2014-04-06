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

cumulativeOffset = (el) ->
  top = 0
  left = 0
  while el
    top += el.offsetTop || 0
    left += el.offsetLeft || 0
    el = el.offsetParent

  {
    top: top,
    left: left
  }

logo = (->
  el = document.querySelector('#logo')
  el.addEventListener 'click', ->
    grid.closeCurrentItem()

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

grid = (->
  gridEl = document.querySelector('#grid')
  productEl = document.querySelector('#product')

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
      @img.src = "./img/socks/socks-#{@index}.jpg"

    itemOver: =>
      new Dynamics.Animation(@el, {
        transform: "scale(1.18)",
        opacity: 1
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
      gridEl.appendChild(@el)
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

    absolutePosition: =>
      offset = cumulativeOffset(@el)
      productOffset = cumulativeOffset(productEl)
      {
        top: offset.top - window.scrollY - productOffset.top,
        left: offset.left - window.scrollX - productOffset.left
      }

    itemClick: =>
      fade.show()
      logo.show()
      pos = @absolutePosition()
      @clonedEl = @el.cloneNode(true)
      Dynamics.css(@clonedEl, {
        position: 'absolute',
        top: pos.top,
        left: pos.left,
        zIndex: 100,
      })
      productEl.appendChild(@clonedEl)
      @el.classList.add('hidden')
      new Dynamics.Animation(@clonedEl, {
        transform: "translateX(#{-pos.left + 40}px) translateY(#{-pos.top + 60}px) scale(2)",
        opacity: 1
      }, {
        type: Dynamics.Types.Spring,
        friction: 600,
        frequency: 10,
        duration: 2000
      }).start()
      @clicked?()

    close: =>
      fade.hide()
      logo.updateOffset(animated: true)
      setTimeout =>
        Dynamics.css(@clonedEl, {
          zIndex: 1,
        })
      , 400

      pos = @absolutePosition()
      transform = "translateX(#{- parseInt(@clonedEl.style.left, 10) + pos.left}px) translateY(#{- parseInt(@clonedEl.style.top, 10) + pos.top}px)"
      cloneElPos = cumulativeOffset(@clonedEl)
      cloneElPos.top += window.scrollY
      cloneElPos.left += window.scrollX
      productEl.removeChild(@clonedEl)
      document.body.appendChild(@clonedEl)
      Dynamics.css(@clonedEl, {
        top: cloneElPos.top,
        left: cloneElPos.left
      })

      new Dynamics.Animation(@clonedEl, {
        transform: transform,
        opacity: 1
      }, {
        type: Dynamics.Types.Spring,
        friction: 600,
        frequency: 10,
        duration: 2000,
        complete: =>
          @el.classList.remove('hidden')
          document.body.removeChild(@clonedEl)
          @clonedEl = null
      }).start()


    imgLoaded: =>
      @img.className = "loaded"
      @loaded?()

  items = []
  loadedCount = 0
  currentItem = null
  showItems = ->
    loading.stop()
    for item in items
      item.show()
  itemLoaded = ->
    loadedCount += 1
    if loadedCount >= items.length
      showItems()
  itemClicked = ->
    currentItem = @

  for i in [1..SOCKS_COUNT]
    item = new Item(i)
    item.loaded = itemLoaded
    item.clicked = itemClicked
    items.push(item)
  for item in items
    item.load()

  closeCurrentItem = ->
    if currentItem?
      currentItem.close()
    currentItem = null

  {
    closeCurrentItem: closeCurrentItem
  }
)()

(->
  window.addEventListener 'scroll', (e) =>
    logo.updateOffset()

  window.addEventListener 'keyup', (e) =>
    if e.keyCode == 27
      # escape
      grid.closeCurrentItem()
)()
