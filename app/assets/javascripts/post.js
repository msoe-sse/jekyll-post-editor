$(function() {
  $('#preview-button').click(function() {
    setActiveTab("#preview-button", '#PreviewTabContent');
    fetch('post/preview', {
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

  $('#markdown-button').click(function() {
    setActiveTab('#markdown-button', '#MarkdownTabContent');
  });

  function setActiveTab(button, tabContent) {
    $('.tabcontent').css('display', 'none');
    $('#tab-container button.active').removeClass('active');
    $(tabContent).css('display', 'block');
    $(button).addClass('active');
  }

  $('#markdown-button').trigger('click');
});