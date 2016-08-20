'use strict';

$( document ).ready(function() {
  // Object for managing page state
  var state = {
    user: {},
    upload_file: null,
    page: 0,
    per_page: 4,
    has_next: false,
    has_prev: false,
    images_loaded: false,
    images: []
  };

  $(".submit", "#register").on("click", do_registration);
  $(".submit", "#login").on("click", do_login);
  $(".submit", "#upload").on("click", do_upload);
  $(".change-panel", "#register").on("click", show_login);
  $(".change-panel", "#login").on("click", show_register);
  $(".change-panel", "#image_list").on("click", show_upload);
  $(".change-panel", "#upload").on("click", show_image_list);
  $(".refresh", "#image_list").on("click", do_load_images);
  $(".upload_file", "#upload").on('change', set_upload_file);
  $(".prev-page", ".pagination").on('click', prev_page);
  $(".next-page", ".pagination").on('click', next_page);

  /**
   * Start with showing the login page. We're not storing sessions
   * locally, so we'll show the login with every page refresh / load
   **/
  show_dialog("login");

  /**
   * Handles the registration form submission.
   */
  function do_registration( evt ) {
    var email = $(".email-fld", "#register"),
        pass = $(".password-fld", "#register"),
        confirm = $(".confirm-fld", "#register"),
        error = $(".error", "#register"),
        email_regex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

    /**
     * Simple error proxy for displaying error labels
     **/
    var do_error = function(err) {
      error.html(err || "&nbsp;");
    }

    if (!email_regex.test(email.val())) {
      email.addClass("highlight");
      do_error("Please supply a valid email address.");
      return;
    }
    email.removeClass("highlight");
    
    if (!pass.val().match(/[A-z]/)) {
      pass.addClass("highlight");
      do_error("Password must contain at least one letter.");
      return;
    }

    if (!pass.val().match(/[A-Z]/)) {
      pass.addClass("highlight");
      do_error("Password must contain at least one capital letter.");
      return;
    }

    if (!pass.val().match(/\d/)) {
      pass.addClass("highlight");
      do_error("Password must contain at least one number.");
      return;
    }

    if (pass.val() != confirm.val()) {
      pass.addClass("highlight");
      confirm.removeClass('valid').addClass('invalid');
      do_error("Password must match password confirmation.");
      return;
    }
    pass.removeClass("highlight");

    $.ajax({
      type: "POST",
      url: "/api/auth/register",
      dataType: 'json',
      async: false,
      data: { user: { email: email.val(), password: pass.val(), confirm: confirm.val() } },
      success: function(data) {
        show_dialog("login");
        alert("Thank you. Please now login.");
      },
      error: function(data) {
        var json = data.responseJSON;
        if (!!json.errors) {
          if (!!json.errors.email) {
            do_error("Email address " + json.errors.email.join(". Email address "));
          } else if (!!json.errors.password) {
            do_error("Password " + json.errors.password. join(". Password "));
          } else {
            do_error("An server error occurred. Please contact an administrator.");
          }
        } else if (!!json.error) {
          do_error(json.error);
        }
      }
    });
    evt.stopPropagation();
    evt.preventDefault();
  }

  /**
   * Handles the login form submission
   **/
  function do_login( evt ) {
    var email = $(".email-fld", "#login"),
        pass = $(".password-fld", "#login"),
        error = $(".error", "#login");

    /**
     * Simple error proxy for displaying error labels
     **/
    var do_error = function(err) {
      error.html(err || "&nbsp;");
    }

    if (email.val().trim() == "") {
      email.addClass("highlight");
      do_error("Please enter your email address.");
      return;
    }
    email.removeClass("highlight");

    if (pass.val() == "") {
      pass.addClass("highlight");
      do_error("Please enter your password.");
      return;
    }
    pass.removeClass("highlight");

    $.ajax({
      type: "POST",
      url: "/api/auth/login",
      dataType: 'json',
      async: false,
      data: { user: { email: email.val(), password: pass.val() } },
      success: function(data) {
        show_dialog("image_list");
        state.user.token = data.data.token;
        load_images();
      },
      error: function(data) {
        var json = data.responseJSON;
        if (!!json.error) {
          do_error(json.error);
        }
      }
    });
    evt.stopPropagation();
    evt.preventDefault();
  }

  /**
   * Proxies the file upload field data
   **/
  function set_upload_file( evt ) {
    state.upload_file = evt.target.files;
  }

  /**
   * Handles the upload form submission
   **/
  function do_upload( evt ) {
    if (!state.user.token) {
      show_login();
      return;
    }
    var error = $(".error", "#upload"),
        file = $(".upload_file", "#upload"),
        name = $(".upload_name", "#upload"),
        desc = $(".upload_description", "#upload");

    /**
     * Simple error proxy for displaying error labels
     **/
    var do_error = function(err) {
      error.html(err || "&nbsp;");
    }

    if (!state.upload_file) {
      file.addClass("highlight");
      do_error("Please select an image to upload.");
      return;
    }
    file.removeClass("highlight");

    if (name.val().trim() == "") {
      name.addClass("highlight");
      do_error("Please enter a name for the image.");
      return;
    }
    name.removeClass("highlight");

    if (desc.val().trim() == "") {
      desc.addClass("highlight");
      do_error("Please enter a description for the image.");
      return;
    }
    desc.removeClass("highlight");

    var fd = new FormData();
    $.each(state.upload_file, function(i, file) {
      fd.append('upload', file);
    });
    fd.append("image[name]", name.val());
    fd.append("image[description]", desc.val());

    $.ajax({
      url: '/api/image',
      type: 'POST',
      data: fd,
      cache: false,
      dataType: 'json',
      headers: { 'authorization': 'Token: ' + state.user.token },
      processData: false,
      contentType: false,
      success: function( data, textStatus, jqXHR ) {
        add_image(data.data.filename, name.val(), desc.val());
        state.upload_file = null;
        state.page = 0;
        load_images();
        show_image_list();
      },
      error: function( data, textStatus, errorThrown ) {
        do_error(jqXHR.responseJSON.data);
      }
    });
    evt.stopPropagation();
    evt.preventDefault();
  }

  /**
   * Event handler for loading images fresh from the server
   **/
  function do_load_images( evt) {
    load_images();
    evt.stopPropagation();
    evt.preventDefault();
  }

  /**
   * Image loading impl
   **/
  function load_images() {
    /**
     * Image requests are paginated. We only want 'per_page' images
     * from offset 'page'.
     **/
    $.ajax({
      url: '/api/image/' + state.page + '/' + state.per_page,
      type: 'GET',
      cache: false,
      dataType: 'json',
      headers: { 'authorization': 'Token: ' + state.user.token },
      success: function( data, textStatus, jqXHR ) {
        var list = data.list;
        clear_images();
        state.has_next = data.has_next;
        state.has_prev = data.has_prev;
        for (var i=0, len=list.length; i<len; i++) {
          if (list[i].filename) {
            add_image(list[i].filename, list[i].thumbnail, list[i].name, list[i].description);
          }
        }
        render_images();
      },
      error: function( jqXHR, textStatus, errorThrown ) {
        console.log('ERRORS: ' + textStatus);
      }
    });
  }

  /**
   * Dialog switching function
   **/
  function show_dialog( dialog ) {
    var items = ["register", "login", "upload", "image_list"];
    for (var i=0, len=items.length; i<len; i++) {
      if (items[i] == dialog) {
        $("#"+items[i]).removeClass("hidden");
      } else {
        $("#"+items[i]).addClass("hidden");
      }
    }
  }

  /**
   * Show login dialog helper function
   **/
  function show_login( evt ) {
    show_dialog("login");
  }

  /**
   * Show register dialog helper function
   **/
  function show_register( evt ) {
    show_dialog("register");
  }

  /**
   * Show upload dialog helper function
   **/
  function show_upload( evt ) {
    show_dialog("upload");
  }

  /**
   * Show image list dialog helper function
   **/
  function show_image_list( evt ) {
    show_dialog("image_list");
  }

  /**
   * Adds an images object to the image buffer. The buffer
   * is reset with each call to load_images.
   **/
  function add_image( filename, thumbnail, name, description ) {
    state.images.push({
      filename: filename, 
      thumbnail: thumbnail, 
      name: name, 
      description: description
    });
  }

  /**
   * Empty the image buffer.
   **/
  function clear_images() {
    state.images = [];
  }

  /**
   * Primary call function to render the images in the image buffer.
   **/
  function render_images() {
    $(".image-container").empty();
    if (state.images.length == 0) {
      render_no_image();
      return;
    }
    for (var i=0,len=state.images.length; i<len; i++) {
      render_image(state.images[i]);
    }
    update_pagination();
  }

  /**
   * Displays "No images uploaded" panel if images buffer is empty.
   **/
  function render_no_image() {
    var node = $("<div/>"),
        label = $("<span/>");
    node.addClass("image-empty");
    label.html("No images available. Please upload an image.");
    node.append(label);
    $(".image-container").append(node);
  }

  /**
   * Render a single image panel to the image_list container
   **/
  function render_image( image ) {
    var node = $("<div/>"),
        img = $("<div/>"),
        name = $("<span/>"),
        desc = $("<span/>");
    node.addClass("image-node");
    img.addClass("image-thumb");
    name.addClass("image-name");
    desc.addClass("image-desc");
    node.append(img).append(name).append(desc);
    
    img.attr('style','background-image: url(' + image.thumbnail + ');');
    name.html(image.name);
    desc.html(image.description);
    $(".image-container").append(node);
  }

  /**
   * Update visibility of the pagination links
   **/
  function update_pagination() {
    $('.next-page').toggle(!!state.has_next)
    $('.prev-page').toggle(!!state.has_prev)
  }

  /**
   * Load images for the previous page offset.
   **/
  function prev_page() {
    if (state.page > 0) {
      state.page--;
      state.images_loaded = false;
      load_images();
    }
  }

  /**
   * Load images for the next page offset.
   **/
  function next_page() {
    if (state.has_next) {
      state.page++;
      state.images_loaded = false;
      load_images();
    }
  }
});