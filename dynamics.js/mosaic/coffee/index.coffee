(->
  DURATION_R = 1.4
  canvas = document.querySelector('canvas')
  ctx = canvas.getContext("2d")
  pixelRatio = window.devicePixelRatio || 1
  canvasWidth = parseInt(canvas.width, 10)
  canvasHeight = parseInt(canvas.height, 10)
  canvas.width = canvasWidth * pixelRatio
  canvas.height = canvasHeight * pixelRatio
  canvas.style.width = canvasWidth + "px"
  canvas.style.height = canvasHeight + "px"

  randomBetween = (a, b) ->
    Math.round(a + Math.random() * (b - a))

  pastelColor = ->
    r = randomBetween(80, 255)
    g = randomBetween(Math.max(80, 255 - r), 255)
    b = randomBetween(Math.max(80, 255 - Math.max(r, g)), 255)
    [r, g, b]

  objectIndex = 0
  class Vertice
    constructor: ([@x, @y]) ->
      @[0] = @x
      @[1] = @y

    animateFrom: ([x, y]) ->
      return if @animating
      @animating = true

      y = 0 if @[1] == 0
      from = [x, y]
      to = [@[0], @[1]]
      @[0] = x
      @[1] = y

      tween = new Dynamics.Tween(
        type: Dynamics.Types.Spring
        duration: 1000 * DURATION_R
        friction: 400
        change: (t, value) =>
          @[0] = from[0] + (value * (to[0] - from[0]))
          @[1] = from[1] + (value * (to[1] - from[1]))
      ).start()

  class Triangle
    constructor: (@a, @b, @c) ->
      @alpha = 1
      @color = pastelColor()
      @index = objectIndex
      objectIndex += 1

    draw: (ctx) =>
      @fill(ctx, "white")
      @fill(ctx, "rgba(#{@color[0]},#{@color[1]},#{@color[2]},#{0.16 * @alpha})")

    fill: (ctx, color) =>
      ctx.beginPath()
      ctx.fillStyle = color
      ctx.moveTo(@a[0] * pixelRatio, @a[1] * pixelRatio);
      ctx.lineTo(@b[0] * pixelRatio, @b[1] * pixelRatio)
      ctx.lineTo(@c[0] * pixelRatio, @c[1] * pixelRatio)
      ctx.fill()

    show: =>
      fromPoint = @b
      point = @a
      if @b[0] > point[0]
        point = @b
        fromPoint = @a
      if @c[0] > point[0]
        point = @c

      for p in [@a, @b, @c]
        p.animateFrom([p[0] - 100, p[1]]) if p[0] != 0

      # @alpha = 1
      tween = new Dynamics.Tween(
        type: Dynamics.Types.EaseInOut
        duration: 100 * DURATION_R
        change: (t, value) =>
          @alpha = value
      ).start()
      # point.animateFrom(fromPoint)

    leftX: =>
      Math.min(@a[0], @b[0], @c[0])

  options = {
    cellsize: 27,
    cellpadding: 40
  }
  cellsX = Math.ceil(canvasWidth / options.cellsize - 1)
  cellsY = Math.ceil(canvasHeight / options.cellsize - 1)
  cellsizeX = canvasWidth / cellsX
  cellsizeY = canvasHeight / cellsY

  triangles = []
  vertices = []
  for col in [0..cellsX]
    for row in [0..cellsY]
      if col == 0
        x = 0
      else if col == cellsX
        x = canvasWidth
      else
        x = col * cellsizeX + Math.random() * options.cellpadding

      if row == 0
        y = 0
      else if row == cellsY
        y = canvasHeight
      else
        y = row * cellsizeY + Math.random() * options.cellpadding

      vertices.push([x, y])

  delaunayTriangles = Delaunay.triangulate(vertices);
  verticesObjects = []
  for vertice in vertices
    verticesObjects.push(new Vertice(vertice))
  i = 0
  while i < delaunayTriangles.length
    triangle = new Triangle(verticesObjects[delaunayTriangles[i]], verticesObjects[delaunayTriangles[i+1]], verticesObjects[delaunayTriangles[i+2]])
    triangle.alpha = 0
    triangles.push(triangle)
    i += 3

  draw = ->
    ctx.clearRect(0, 0, canvasWidth * pixelRatio, canvasHeight * pixelRatio)
    for triangle in triangles
      triangle.draw(ctx)
    requestAnimationFrame draw

  i = triangles.length
  for triangle in triangles
    i -= 1
    do (triangle, i) ->
      setTimeout ->
        triangle.show()
      , i * 2 * DURATION_R

  draw()
  requestAnimationFrame draw
)()
