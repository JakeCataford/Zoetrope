window.playrange =
  start: 0
  end: 10

VideoController =
  init: ->
    min_handle = document.querySelector(".handle.min")
    max_handle = document.querySelector(".handle.max")
    track_fill = document.querySelector(".track-fill")
    video = document.querySelector("video")
    playhead = document.querySelector(".playhead")

    video.addEventListener "timeupdate", (event) ->
      VideoController.onTimeUpdate(event, playhead, video, min_handle, max_handle)
    , false

    min_handle.addEventListener "dragstart", (event) ->
      VideoController.onHandleDragStart(event, min_handle)
    , false

    max_handle.addEventListener "dragstart", (event) ->
      VideoController.onHandleDragStart(event, max_handle)
    , false

    min_handle.addEventListener "drag", (event) ->
      VideoController.onHandleDrag(event, min_handle)
      VideoController.updateFill(track_fill, min_handle, max_handle)
      VideoController.updatePlayrange(video, min_handle, max_handle)
    , false

    max_handle.addEventListener "drag", (event) ->
      VideoController.onHandleDrag(event, max_handle)
      VideoController.updateFill(track_fill, min_handle, max_handle)
      VideoController.updatePlayrange(video, min_handle, max_handle)
    , false

    min_handle.addEventListener "dragend", (event) ->
      VideoController.onHandleDragEnd(event, min_handle)
    , false

    max_handle.addEventListener "dragend", (event) ->
      VideoController.onHandleDragEnd(event, max_handle)
    , false

  onTimeUpdate: (event, playhead, video, min_handle, max_handle) ->
    playhead.style.left = (video.currentTime/video.duration) * 100 + "%"
    if(video.currentTime > playrange.end)
      video.currentTime = playrange.start

  leftDragBound: ->
    (window.screen.width - 500)/2

  rightDragBound: ->
    (window.screen.width)/2 + 250

  onHandleDragStart: (event, handle) ->
    el = document.querySelector(".nothing")
    el.setAttribute('style', 'position: absolute; display: block; top: 0; left: 0; width: 0; height: 0;' );
    event.dataTransfer.setDragImage(el, 0, 0)
    time = handle.querySelector(".time-display")
    time.classList.remove("bounce-out")
    time.classList.add("bounce-in")

  onHandleDrag: (event, handle) ->
    offset = (event.x - VideoController.leftDragBound() - (handle.offsetWidth/2))
    if (event.x >= VideoController.leftDragBound() && event.x <= VideoController.rightDragBound())
      handle.style.left = offset + "px"

    event.preventDefault()

  updatePlayrange: (video, min_handle, max_handle) ->
    playrange.end = video.duration * (max_handle.offsetLeft/500)
    playrange.start = video.duration * ((min_handle.offsetLeft + min_handle.offsetWidth)/500)

    video.currentTime = playrange.start if video.currentTime < playrange.start
    video.currentTime = playrange.end if video.currentTime > playrange.end

    $("#start_time_form").val(playrange.start)
    $("#end_time_form").val(playrange.end)

    min_handle.querySelector(".time-display").innerHTML = "#{playrange.start.toFixed(2)}s"
    max_handle.querySelector(".time-display").innerHTML = "#{playrange.end.toFixed(2)}s"


  updateFill: (trackfill, min_handle, max_handle) ->
    trackfill.style.left = min_handle.style.left
    amound = (max_handle.offsetLeft - (min_handle.offsetLeft + min_handle.offsetWidth)) + "px"
    trackfill.style.width = amound
    console.log amound

  onHandleDragEnd: (event, handle) ->
    time = handle.querySelector(".time-display")
    time.classList.remove("bounce-in")
    time.classList.add("bounce-out")

ready = ->
  VideoController.init()

$(document).ready(ready)
$(document).on('page:load', ready)
