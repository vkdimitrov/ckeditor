//= require ckeditor/filebrowser/javascripts/jquery.tmpl.min.js
//= require ckeditor/filebrowser/javascripts/fileuploader.js
//= require ckeditor/filebrowser/javascripts/jquery.endless-scroll.js
//= require ckeditor/filebrowser/javascripts/rails.js
//= require ckeditor/filebrowser/javascripts/application.js

document.addEventListener("DOMContentLoaded", function(event) {
  $('#query').on('input', function() {
    $.get( "/ckeditor/pictures?query="+$(this).val() , function( data ) {
      $( ".fileupload-list" ).html($(data).find(".fileupload-list"));
    });
  });
});