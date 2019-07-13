$(function() {
  $('.notice').fadeOut(5000);

  $('#preview-button').click(function() {
    setActiveTab("#preview-button", '#PreviewTabContent');
    let url = new URL(`${window.location.origin}/post/preview`);
    let params = {text: $('#markdownArea').val()};
    Object.keys(params).forEach(key => url.searchParams.append(key, params[key]))
    fetch(url)
    .then(resp => resp.json())
    .then(function(data) {
      $('#previewArea').html(data.html);
    })
  });

  $('#markdown-button').click(function() {
    setActiveTab('#markdown-button', '#MarkdownTabContent');
  });

  $('#MarkdownTabContent').dropzone({
    url: '/image/upload',
    success: function(file, response) {
      $('#MarkdownTabContent').val(`![${file.name}](/assets/img/${file.name})`);
    }
  });

  function setActiveTab(button, tabContent) {
    $('.tabcontent').css('display', 'none');
    $('#tab-container button.active').removeClass('active');
    $(tabContent).css('display', 'block');
    $(button).addClass('active');
  }

  $('#markdown-button').trigger('click');
});