showEditor = ->
  document.body.classList.add('debug')

  preEl = document.createElement("pre")
  codeEl = document.createElement("code")

  preEl.appendChild(codeEl)
  document.body.appendChild(preEl)

  backEl = document.createElement("a")
  backEl.href = "/"
  backEl.classList.add("back")
  document.body.appendChild(backEl)

  document.head.innerHTML += """
  <link rel="stylesheet" href="macClassicTheme.css">
  """

  script = document.createElement("script")
  script.src = "//cdnjs.cloudflare.com/ajax/libs/highlight.js/8.6/highlight.min.js"
  document.head.appendChild(script)

  script.onload = ->
    code = document.querySelector("#script").textContent.trim()
    code = hljs.highlight("javascript", code).value
    codeEl.innerHTML = code

if window == window.top
  showEditor()
