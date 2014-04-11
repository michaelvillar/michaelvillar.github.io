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

product = (->
  el = document.querySelector('#product')
  texts = el.querySelectorAll('h2 > span, p > span, button')
  closeButtonEl = el.querySelector('a.close')
  closeButtonSpan = closeButtonEl.querySelector('span')
  closeButtonSpanVisible = false
  button = el.querySelector('button')

  closeButtonSpanStates = [
    'translateY(-48px)',
    'translateX(-48px) rotate(-90deg)'
  ]

  Dynamics.css(closeButtonSpan, {
    transform: closeButtonSpanStates[1]
  })

  closeButtonEl.addEventListener 'mouseover', =>
    closeButtonSpanVisible = true
    new Dynamics.Animation(closeButtonSpan, {
      transform: 'none'
    }, {
      type: Dynamics.Types.Spring,
      frequency: 20,
      friction: 800,
      duration: 2000
    }).start()

  hideCloseButton = (properties = null, options = null) ->
    return unless closeButtonSpanVisible
    closeButtonSpanVisible = false
    old = closeButtonSpan
    if properties?
      options.complete = ->
        old.parentNode.removeChild(old)
      new Dynamics.Animation(old, properties, options).start()
    else
      old.parentNode.removeChild(old)

    closeButtonSpan = closeButtonSpan.cloneNode()
    Dynamics.css(closeButtonSpan, {
      transform: closeButtonSpanStates[1]
    })
    closeButtonEl.appendChild(closeButtonSpan)

  closeButtonEl.addEventListener 'mouseout', =>
    hideCloseButton({
      transform: closeButtonSpanStates[0]
    }, {
     type: Dynamics.Types.Spring,
     frequency: 0,
     friction: 490,
     anticipationStrength: 98,
     anticipationSize: 53,
     duration: 500
    })

  show = ->
    el.style.pointerEvents = 'auto'
    for i in [0..texts.length - 1]
      text = texts[i]
      setTimeout ((text) =>
        new Dynamics.Animation(text, {
          opacity: 1,
          transform: 'none'
        }, {
          type: Dynamics.Types.Spring,
          frequency: 30,
          friction: 800,
          duration: 2000
        }).start()
      ).bind(this, text), 500 + i * 70

  hide = (animated = true) ->
    el.style.pointerEvents = 'none'
    hideCloseButton()
    for i in [0..texts.length - 1]
      text = texts[i]
      if text.parentNode.tagName.toLowerCase() == 'h2'
        h = 24
      else
        h = 18
      new Dynamics.Animation(text, {
        opacity: 0,
        transform: "translateY(#{h}px)"
      }, {
        type: Dynamics.Types.EaseInOut,
        duration: 200,
        animated: animated
      }).start()

  hide(false)

  {
    show: show,
    hide: hide,
    closeButtonEl: closeButtonEl,
    button: button
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
      new Dynamics.Animation(dot, {
        opacity: 0
      }, {
        type: Dynamics.Types.EaseInOut,
        duration: 300
      }).start({
        delay: 350
      })
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

cart = (->
  cartEl = document.querySelector('header a#cart')
  closeEl = document.querySelector('header a#closeCart')
  cartLabelEl = cartEl.querySelector('.label')
  currentCartLabelEl = null
  items = []

  setCloseButtonVisibility = (visible, options = {}) ->
    options.animated ?= true
    opacityAnimationOptions = {
      type: Dynamics.Types.EaseInOut,
      duration: 200,
      animated: options.animated
    }
    showElement = (el) ->
      new Dynamics.Animation(el, {
        transform: "none"
      }, {
        type: Dynamics.Types.Spring,
        frequency: 25,
        friction: 300,
        duration: 700,
        animated: options.animated,
      }).start({ delay: 150 })
      new Dynamics.Animation(el, {
        opacity: 1
      }, opacityAnimationOptions).start()

    hideElement = (el) ->
      new Dynamics.Animation(el, {
        transform: "scaleX(.01)"
      }, {
        type: Dynamics.Types.EaseInOut,
        duration: 300,
        animated: options.animated
      }).start()
      new Dynamics.Animation(el, {
        opacity: 0
      }, opacityAnimationOptions).start({ delay: if options.animated then 100 })

    if visible
      showElement(closeEl)
      hideElement(cartEl)
    else
      showElement(cartEl)
      hideElement(closeEl)

  setCloseButtonVisibility(false, { animated: false })

  addItem = (item) ->
    if currentCartLabelEl
      new Dynamics.Animation(currentCartLabelEl, {
        transform: 'translateY(6px)',
        opacity: 0
      }, {
        type: Dynamics.Types.EaseInOut,
        duration: 250
      }).start()

    items.push(item)
    currentCartLabelEl = cartLabelEl.cloneNode()
    currentCartLabelEl.innerHTML = items.length
    Dynamics.css(currentCartLabelEl, {
      transform: 'translateY(-6px)',
      opacity: 0
    })
    cartEl.appendChild(currentCartLabelEl)
    cartEl.className = 'filled'
    new Dynamics.Animation(currentCartLabelEl, {
      transform: "none"
    }, {
      type: Dynamics.Types.Gravity,
      bounce: 60,
      gravity: 1300
    }).start()
    new Dynamics.Animation(currentCartLabelEl, {
      opacity: 1
    }, {
      type: Dynamics.Types.EaseInOut,
      duration: 250
    }).start()

  {
    addItem: addItem,
    setCloseButtonVisibility: setCloseButtonVisibility
  }
)()

grid = (->
  gridEl = document.querySelector('#grid')
  productEl = document.querySelector('#product')
  cartEl = document.querySelector('header a#cart')
  closeCartEl = document.querySelector('header a#closeCart')

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
      new Dynamics.Animation(@el, {
        transform: "scale(1)",
        opacity: 1
      }, {
        type: Dynamics.Types.Spring,
        friction: 500,
        frequency: 25,
        duration: 2500
      }).start({
        delay: @index * 20
      })

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
      product.show()
      pos = @absolutePosition()
      @clonedEl = @el.cloneNode(true)
      @clonedEl.addEventListener 'click', @close
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
        anticipationSize: 14,
        anticipationStrength: 50,
        duration: 2000
      }).start()
      @clicked?()

    animateClonedEl: (properties = {}, options = {}, noAnimation = true) =>
      setTimeout =>
        Dynamics.css(@clonedEl, {
          zIndex: 1,
        })
      , 400
      pos = @absolutePosition()
      cloneElPos = cumulativeOffset(@clonedEl)
      cloneElPos.top += window.scrollY
      cloneElPos.left += window.scrollX
      productEl.removeChild(@clonedEl)
      document.body.appendChild(@clonedEl)
      Dynamics.css(@clonedEl, {
        top: cloneElPos.top,
        left: cloneElPos.left
      })

      options.complete = =>
        unless noAnimation
          Dynamics.css(@el, {
            transform: 'scale(.01)'
          })
          new Dynamics.Animation(@el, {
            transform: 'none'
          }, {
            type: Dynamics.Types.Spring,
            friction: 600,
            frequency: 20,
            anticipationSize: 14,
            anticipationStrength: 50,
            duration: 2000
          }).start()
        @el.classList.remove('hidden')
        document.body.removeChild(@clonedEl)
        @clonedEl = null

      new Dynamics.Animation(@clonedEl, properties, options).start()

    close: =>
      fade.hide()
      logo.updateOffset(animated: true)
      product.hide()

      pos = @absolutePosition()
      transform = "translateX(#{- parseInt(@clonedEl.style.left, 10) + pos.left}px) translateY(#{- parseInt(@clonedEl.style.top, 10) + pos.top}px)"
      @animateClonedEl({
        transform: transform,
        opacity: 1
      }, {
        type: Dynamics.Types.Spring,
        friction: 600,
        frequency: 10,
        duration: 2000
      })

    addToCart: =>
      fade.hide()
      logo.updateOffset(animated: true)
      product.hide()

      pos = cumulativeOffset(@el)
      offset = cumulativeOffset(cartEl)
      offset.left += 27
      transform = "translateX(#{offset.left - pos.left - 32}px) translateY(#{offset.top - pos.top - 48}px) scale(.2)"
      console.log(pos, offset)
      console.log(transform)
      new Dynamics.Animation(@clonedEl, {
        opacity: 0
      }, {
        type: Dynamics.Types.EaseInOut,
        duration: 300
      }).start({
        delay: 400
      })
      @animateClonedEl({
        transform: transform
      }, {
        type: Dynamics.Types.Spring,
        frequency: 3,
        friction: 200,
        anticipationStrength: 67,
        anticipationSize: 44,
        duration: 700
      }, false)

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

  cartEl.addEventListener 'click', ->
    cart.setCloseButtonVisibility(true)
    windowWidth = window.innerWidth
    windowHeight = window.innerHeight
    for i, item of items
      offset = cumulativeOffset(item.el)
      delay = Math.abs(offset.left - (windowWidth / 2)) / (windowWidth / 2) +
              offset.top / windowHeight
      delay *= 500
      translateX = offset.left - (windowWidth / 2)
      new Dynamics.Animation(item.el, {
        transform: "translateY(-#{offset.top + 160}px) translateX(#{translateX}px) rotate(#{Math.round(Math.random() * 90 - 45)}deg)"
      }, {
        type: Dynamics.Types.Bezier,
        duration: 450,
        points: [{"x":0,"y":0,"controlPoints":[{"x":0.2,"y":0}]},{"x":1,"y":1,"controlPoints":[{"x":0.843,"y":0.351}]}]
      }).start({
        delay: delay
      })

  closeCartEl.addEventListener 'click', ->
    cart.setCloseButtonVisibility(false)

  closeCurrentItem = ->
    if currentItem?
      currentItem.close()
    currentItem = null

  addToCartCurrentItem = ->
    if currentItem?
      setTimeout cart.addItem.bind(cart, currentItem), 500
      currentItem.addToCart()
    currentItem = null

  {
    closeCurrentItem: closeCurrentItem,
    addToCartCurrentItem: addToCartCurrentItem
  }
)()

(->
  window.addEventListener 'scroll', logo.updateOffset
  window.addEventListener 'keyup', (e) =>
    if e.keyCode == 27
      # escape
      grid.closeCurrentItem()

  product.closeButtonEl.addEventListener 'click', grid.closeCurrentItem
  product.button.addEventListener 'click', grid.addToCartCurrentItem
)()
