# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $("#get-preview-button").click ->
    fetch "home/preview",
      method: 'POST',
      headers:
        "Content-Type": "application/json"
      body: JSON.stringify("text": $("#markdownArea").val())
    .then (response) -> response.json()
    .then (data) ->
      $("#previewArea").html(data.html)