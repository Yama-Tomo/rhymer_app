var app = {};

$(function() {
  app.ele = {};
  app.ele.$form            = $('#main-form');
  app.ele.$textarea        = $('#main-form textarea').get(0);
  app.ele.$rhyme           = $('#rhyme');
  app.ele.$rhyme_success   = $('#rhyme .success');
  app.ele.$rhyme_error     = $('#rhyme .error');
  app.ele.$btn_create      = $('#create');
  app.ele.$btn_random      = $('#random_text');
  app.ele.$btn_clear       = $('#clear_text');
  app.ele.$btn_share       = $('#share');
  app.ele.$share           = $('.share');
  app.ele.$share_url       = $('.share .url');

  app.cache = {};
  app.cache.send_text = null;

  app.ele.$btn_create.click(function() {
    $.ajax({
      url: "./api/v1/rhyme",
      method: "post",
      timeout: 10000,
      cache: false,
      data: app.ele.$form.serialize(),
      dataType: 'json',
      success: function(result, textStatus, xhr) {
        var is_valid = false;

        app.ele.$rhyme_success.empty();
        app.ele.$rhyme_error.hide();

        for(var i = 0; i < result.length; i++) {
          if (result[i][2] < 20) continue;

          is_valid = true;
          app.ele.$rhyme_success.append('<div>♪ ' + result[i][0] + '、 ' + result[i][1] + '</div>');
        }

        if ( ! is_valid) {
          app.ele.$rhyme_error.show();
        }
        app.ele.$rhyme.show();
      },
      error: function(xhr, textStatus, error) {}
    });
  });

  app.ele.$btn_random.click(function() {
    $.ajax({
      url: "./api/v1/random_text",
      method: "get",
      timeout: 10000,
      cache: false,
      dataType: 'json',
      success: function(result, textStatus, xhr) {
        app.ele.$textarea.value = result.result;
      },
      error: function(xhr, textStatus, error) {}
    });
  });

  app.ele.$btn_clear.click(function() {
    app.ele.$textarea.value = "";
  });

  app.ele.$btn_share.click(function() {
    if ( ! app.ele.$rhyme_success.children().length) return;
    if (app.ele.$textarea.value == app.cache.send_text) return;

    $.ajax({
      url: "./api/v1/share",
      method: "post",
      timeout: 10000,
      cache: false,
      data: app.ele.$form.serialize(),
      dataType: 'json',
      success: function(result, textStatus, xhr) {
        app.ele.$share.show();

        app.cache.send_text = app.ele.$textarea.value;

        var url = window.location.href;
        if (url.indexOf('?') != -1) {
            var url = url.substr(0, url.indexOf('?'));
        }

        app.ele.$share_url.text(url + '?id=' + result.id);
      },
      error: function(xhr, textStatus, error) {}
    });
  });




  $('#share input[type=text]').click(function(e) {
    $(e.target).focus();
    $(e.target).select();
  });
});

