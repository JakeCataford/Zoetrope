RevealOnClick =
  reveal: (element) ->
    element.style.display = 'block'

  onclick: (element) ->
    element.classList.remove('bounce')
    element.classList.add('bounce')
    target = document.querySelector(element.dataset.reveal)
    RevealOnClick.reveal(target) if target?

  init: ->
    buttons_that_reveal_elements = document.querySelectorAll("*[data-reveal]")
    console.log buttons_that_reveal_elements
    button.addEventListener("mouseup", ->
      RevealOnClick.onclick(button)
    ) for button in buttons_that_reveal_elements

HideOnClick =
  reveal: (element) ->
    element.style.display = 'none'

  onclick: (element) ->
    target = document.querySelector(element.dataset.hide)
    HideOnClick.reveal(target) if target?

  init: ->
    buttons_that_hide_elements = document.querySelectorAll("*[data-hide]")
    console.log buttons_that_hide_elements
    button.addEventListener("mouseup", ->
      HideOnClick.onclick(button)
    ) for button in buttons_that_hide_elements


ready = ->
  RevealOnClick.init()
  HideOnClick.init()

$(document).ready(ready)
$(document).on('page:load', ready)
