# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $("#get-preview-button").click ->
    fetch "/preview",
      method: 'post',
      body: JSON.stringify(text: $("#previewArea").html)
      .then (response) -> response.json()
      .then(data) ->
        $("#previewArea").html(data.convertedHtml)