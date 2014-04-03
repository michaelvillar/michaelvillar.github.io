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

(->
  grid = document.querySelector('#grid')

  itemOver = (a) ->
    new Dynamics.Animation(a, {
      transform: "scale(1.18)"
    }, {
      type: Dynamics.Types.Spring,
      frequency: 25,
      duration: 300
    }).start()

  itemOut = (a) ->
    new Dynamics.Animation(a, {
      transform: "none"
    }, {
      type: Dynamics.Types.Spring,
      duration: 1500
    }).start()

  displayItem = (a, index) ->
    Dynamics.css(a, {
      opacity: 0,
      transform: "scale(.01)"
    })
    grid.appendChild(a)
    setTimeout ->
      new Dynamics.Animation(a, {
        transform: "scale(1)",
        opacity: 1
      }, {
        type: Dynamics.Types.Spring,
        friction: 500,
        frequency: 25,
        duration: 2500
      }).start()
    , index * 20

  itemClick = (a) ->
    fade.show()
    logo.show()

  # imgLoaded = (img) ->
  #   img.className = "loaded"

  for i in [1..SOCKS_COUNT]
    a = document.createElement('a')
    a.className = "item"
    img = document.createElement('img')
    img.src = "img/socks/socks-#{i}.jpg"
    a.appendChild(img)

    # img.addEventListener('load', imgLoaded.bind(this, img))

    a.addEventListener('mouseover', itemOver.bind(this, a))
    a.addEventListener('mouseout', itemOut.bind(this, a))
    a.addEventListener('click', itemClick.bind(this, a))

    displayItem(a, i - 1)
)()

(->
  window.addEventListener 'scroll', (e) =>
    logo.updateOffset()
)()
