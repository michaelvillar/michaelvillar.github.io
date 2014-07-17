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
    cart.close()

  scrollFade = 30

  updateOffset = (options = {}) ->
    options.animated ?= false
    return unless fade.isHidden()
    scrollY = Math.min(window.scrollY, scrollFade)
    offset = scrollY / scrollFade
    dynamic(el).to({
      opacity: 1 - offset,
      translateY: - offset * 10
    }, {
      type: dynamic.EaseInOut,
      duration: 300,
      animated: options.animated
    }).start()
    if offset >= 1
      el.className = "hidden"
    else
      el.className = ""

  show = ->
    dynamic(el).to({
      opacity: 1,
      translateY: 0
    }, {
      type: dynamic.Spring,
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
    { translateY: -48 },
    { translateX: -48, rotate: -90 }
  ]

  dynamic(closeButtonSpan).css(closeButtonSpanStates[1])

  closeButtonEl.addEventListener 'mouseover', =>
    closeButtonSpanVisible = true
    dynamic(closeButtonSpan).to({
      translateX: 0,
      translateY: 0,
      rotate: 0
    }, {
      type: dynamic.Spring,
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
      dynamic(old).to(properties, options).start()
    else
      old.parentNode.removeChild(old)

    closeButtonSpan = closeButtonSpan.cloneNode()
    dynamic(closeButtonSpan).css(closeButtonSpanStates[1])
    closeButtonEl.appendChild(closeButtonSpan)

  closeButtonEl.addEventListener 'mouseout', =>
    hideCloseButton(closeButtonSpanStates[0], {
     type: dynamic.Spring,
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
      dynamic(text).delay(500 + i * 70).to({
        opacity: 1,
        translateY: 0
      }, {
        type: dynamic.Spring,
        frequency: 30,
        friction: 800,
        duration: 2000
      }).start()

  hide = (animated = true, options = {}) ->
    el.style.pointerEvents = 'none'
    hideCloseButton()
    for i in [0..texts.length - 1]
      text = texts[i]
      if text.parentNode.tagName.toLowerCase() == 'h2'
        h = 24
      else
        h = 32
      dynamic(text).to({
        opacity: 0,
        translateY: h
      }, {
        type: dynamic.EaseInOut,
        duration: 200,
        animated: animated,
        complete: options.complete
      }).start()

  hide(false, {
    complete: =>
      el.style.display = ''
  })

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
      dynamic(dot).delay(350).to({
        opacity: 0
      }, {
        type: dynamic.EaseInOut,
        duration: 300
      }).start()
      @hiddenIndexes.push(@current)
    dynamic(dot).to({
      translateY: -10
    }, {
      type: dynamic.GravityWithForce,
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
  cartSection = {
    el: document.querySelector('#cartSection'),
    items: document.querySelector('#cartSection .items'),
    footer: document.querySelector('#cartSection .footer')
  }
  currentCartLabelEl = null
  items = []

  setCartSectionVisibility = (visible, options = {}) ->
    options.animated ?= true
    show = ->
      cartSection.el.style.pointerEvents = 'auto'
      dynamic(cartSection.footer).to({
        translateY: 0
      }, {
        type: dynamic.Spring,
        frequency: 25,
        friction: 1200,
        duration: 3500,
        animated: options.animated,
      }).start()
      dynamic(cartSection.items).delay(if options.animated then 100 else 0).to({
        translateY: 0
        opacity: 1
      }, {
        type: dynamic.Spring,
        frequency: 25,
        friction: 1200,
        duration: 3500,
        animated: options.animated,
        complete: options.complete,
      }).start()

    hide = ->
      cartSection.el.style.pointerEvents = 'none'
      dynamic(cartSection.footer).delay(if options.animated then 200 else 0).to({
        translateY: 260
      }, {
        type: dynamic.EaseInOut,
        duration: 700,
        animated: options.animated,
        complete: options.complete,
      }).start()
      dynamic(cartSection.items).to({
        translateY: 260,
        opacity: 0
      }, {
        type: dynamic.EaseInOut,
        duration: 700,
        animated: options.animated,
      }).start()

    if visible
      show()
    else
      hide()

  setCartSectionVisibility(false, {
    animated: false,
    complete: =>
      cartSection.el.style.display = ''
  })

  setCloseButtonVisibility = (visible, options = {}) ->
    options.animated ?= true
    opacityAnimationOptions = {
      type: dynamic.EaseInOut,
      duration: 200,
      animated: options.animated
    }
    showElement = (el) ->
      dynamic(el).delay(150).to({
        scaleX: 1
      }, {
        type: dynamic.Spring,
        frequency: 25,
        friction: 300,
        duration: 700,
        animated: options.animated,
      }).start()
      dynamic(el).to({
        opacity: 1
      }, opacityAnimationOptions).start()

    hideElement = (el) ->
      dynamic(el).to({
        scaleX: 0.01
      }, {
        type: dynamic.EaseInOut,
        duration: 300,
        animated: options.animated
      }).start()
      dynamic(el).delay(if options.animated then 100).to({
        opacity: 0
      }, opacityAnimationOptions).start()

    if visible
      showElement(closeEl)
      hideElement(cartEl)
    else
      showElement(cartEl)
      hideElement(closeEl)

  setCloseButtonVisibility(false, { animated: false })

  addItem = (item) ->
    if currentCartLabelEl
      dynamic(currentCartLabelEl).to({
        translateY: 6,
        opacity: 0
      }, {
        type: dynamic.EaseInOut,
        duration: 250
      }).start()

    items.push(item)
    currentCartLabelEl = cartLabelEl.cloneNode()
    currentCartLabelEl.innerHTML = items.length
    dynamic(currentCartLabelEl).css({
      translateY: -6,
      opacity: 0
    })
    cartEl.appendChild(currentCartLabelEl)
    cartEl.className = 'filled'
    dynamic(currentCartLabelEl).to({
      translateY: 0
    }, {
      type: dynamic.Gravity,
      bounce: 60,
      gravity: 1300
    }).start()
    dynamic(currentCartLabelEl).to({
      opacity: 1
    }, {
      type: dynamic.EaseInOut,
      duration: 250
    }).start()

  {
    addItem: addItem
    open: ->
      fade.show()
      setCloseButtonVisibility(true)
      setCartSectionVisibility(true)
    close: ->
      setTimeout =>
        fade.hide()
      , 450
      setCloseButtonVisibility(false)
      setCartSectionVisibility(false)
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

    setDisabled: (@disabled) =>

    itemOver: =>
      return if @disabled
      dynamic(@el).to({
        scale: 1.18,
        opacity: 1
      }, {
        type: dynamic.Spring,
        frequency: 25,
        duration: 300
      }).start()

    itemOut: =>
      return if @disabled
      dynamic(@el).to({
        scale: 1
      }, {
        type: dynamic.Spring,
        duration: 1500
      }).start()

    show: =>
      dynamic(@el).css({
        opacity: 0,
        scale: 0.01
      })
      gridEl.appendChild(@el)
      dynamic(@el).delay(@index * 20).to({
        scale: 1,
        opacity: 1
      }, {
        type: dynamic.Spring,
        friction: 500,
        frequency: 25,
        duration: 2500
      }).start()

    absolutePosition: =>
      offset = cumulativeOffset(@el)
      productOffset = cumulativeOffset(productEl)
      {
        top: offset.top - window.scrollY - productOffset.top,
        left: offset.left - window.scrollX - productOffset.left
      }

    itemClick: =>
      return if @disabled
      fade.show()
      logo.show()
      product.show()
      pos = @absolutePosition()
      @clonedEl = @el.cloneNode(true)
      @clonedEl.addEventListener 'click', @close
      dynamic(@clonedEl).css({
        position: 'absolute',
        top: pos.top,
        left: pos.left,
        zIndex: 100,
      })
      productEl.appendChild(@clonedEl)
      @el.classList.add('hidden')
      dynamic(@clonedEl).to({
        translateX: -pos.left + 40,
        translateY: -pos.top + 60
        scale: 2,
        opacity: 1
      }, {
        type: dynamic.Spring,
        friction: 600,
        frequency: 10,
        anticipationSize: 14,
        anticipationStrength: 50,
        duration: 2000
      }).start()
      @clicked?()

    animateClonedEl: (properties = {}, options = {}, noAnimation = true) =>
      setTimeout =>
        dynamic(@clonedEl).css({
          zIndex: 1,
        })
      , 400
      pos = @absolutePosition()
      cloneElPos = cumulativeOffset(@clonedEl)
      cloneElPos.top += window.scrollY
      cloneElPos.left += window.scrollX
      productEl.removeChild(@clonedEl)
      document.body.appendChild(@clonedEl)
      dynamic(@clonedEl).css({
        top: cloneElPos.top,
        left: cloneElPos.left
      })

      options.complete = =>
        unless noAnimation
          dynamic(@el).css({
            scale: 0.01
          })
          dynamic(@el).to({
            scale: 1
          }, {
            type: dynamic.Spring,
            friction: 600,
            frequency: 20,
            anticipationSize: 14,
            anticipationStrength: 50,
            duration: 2000
          }).start()
        @el.classList.remove('hidden')
        document.body.removeChild(@clonedEl)
        @clonedEl = null

      dynamic(@clonedEl).to(properties, options).start()

    close: (callback) =>
      fade.hide()
      logo.updateOffset(animated: true)
      product.hide()
      pos = @absolutePosition()
      @animateClonedEl({
        translateX: - parseInt(@clonedEl.style.left, 10) + pos.left,
        translateY: - parseInt(@clonedEl.style.top, 10) + pos.top,
        scale: 1,
        opacity: 1
      }, {
        type: dynamic.Spring,
        friction: 600,
        frequency: 10,
        duration: 2000
      })
      setTimeout =>
        callback?()
      , 500

    addToCart: =>
      fade.hide()
      logo.updateOffset(animated: true)
      product.hide()

      pos = cumulativeOffset(@el)
      offset = cumulativeOffset(cartEl)
      offset.left += 27
      properties = {
        translateX: offset.left - pos.left - 32,
        translateY: offset.top - pos.top - 48,
        scale: 0.2
      }
      dynamic(@clonedEl).delay(400).to({
        opacity: 0
      }, {
        type: dynamic.EaseInOut,
        duration: 300
      }).start()
      @animateClonedEl(properties, {
        type: dynamic.Spring,
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
    grid.closeCurrentItem ->
      cart.open()
    windowWidth = window.innerWidth
    windowHeight = window.innerHeight
    return
    for i, item of items
      do (item) ->
        item.setDisabled(true)
        offset = cumulativeOffset(item.el)
        delay = Math.abs(offset.left - (windowWidth / 2)) / (windowWidth / 2) +
                offset.top / windowHeight
        delay *= 500
        translateX = offset.left - (windowWidth / 2)
        dynamic(item.el).delay(delay).to({
          translateY: -offset.top + 160,
          translateX: translateX,
          rotate: Math.round(Math.random() * 90 - 45)
        }, {
          type: dynamic.Bezier,
          duration: 450,
          points: [{"x":0,"y":0,"controlPoints":[{"x":0.2,"y":0}]},{"x":1,"y":1,"controlPoints":[{"x":0.843,"y":0.351}]}],
          complete: =>
            item.el.style.visibility = 'hidden'
        }).start()

  closeCartEl.addEventListener 'click', ->
    cart.close()
    windowWidth = window.innerWidth
    windowHeight = window.innerHeight

  closeCurrentItem = (callback) ->
    if currentItem?
      currentItem.close(callback)
    else
      callback()
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
