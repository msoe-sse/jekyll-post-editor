Dropzone.autoDiscover = false;

$(function() {
  $('.notice').fadeOut(5000);

  $('#preview-button').click(function() {
    setActiveTab("#preview-button", '#PreviewTabContent');
    let url = new URL(`${window.location.origin}/post/preview`);
    let params = {text: $('#markdownArea').val()};
    Object.keys(params).forEach(key => url.searchParams.append(key, params[key]));
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
    acceptedFiles: 'image/jpeg, image/jpg, image/png, image/gif',
    maxFilesize: 5,
    success: function(file, response) {
      let markdownTextArea = $('#markdownArea');

      let markdownToAdd = `![${file.name}](/assets/img/${file.name})`;
      let currentMarkdown = markdownTextArea.val();
      let caretPos = markdownTextArea[0].selectionStart;

      markdownTextArea.val(currentMarkdown.substring(0, caretPos) + markdownToAdd + currentMarkdown.substring(caretPos));
    }
  });
  
  function setActiveTab(button, tabContent) {
    $('.tabcontent').css('display', 'none');
    $('.tabContainer button.active').removeClass('active');
    $(tabContent).css('display', 'block');
    $(button).addClass('active');
  }

  $('#markdown-button').trigger('click');
});