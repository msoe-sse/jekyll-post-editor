$(function() {
  $('#get-preview-button').click(function() {
    fetch('preview', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({'text': $('#markdownArea').val()})
    })
    .then(resp => resp.json())
    .then(function(data) {
      $('#previewArea').html(data.html);
    })
  });
});