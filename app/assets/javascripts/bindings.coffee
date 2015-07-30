url = window.location

Binding =
  bound_elements: ->
    document.querySelectorAll('*[data-bind]')

  update_bound_elements: (json) ->
    Binding.update_element(element, json) for element in Binding.bound_elements()

  update_element: (element, json) ->
    element.innerHTML = json[element.dataset.bind]

  poll: ->
    $.ajax {
      url: "#{url}.json"
      success: (data, status, jqhxr) ->
        window.location.reload() if data["force_refresh"]
        Binding.update_bound_elements(data)
    }
    setTimeout(Binding.poll, 1000)

  init: ->
    setTimeout(Binding.poll, 1000) if Binding.bound_elements().length > 0

ready = ->
  Binding.init()
  window.Binding = Binding

$(document).ready(ready)
$(document).on('page:load', ready)
