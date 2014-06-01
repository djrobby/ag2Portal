/**
 * Drag & drop functions
 */

/*
 * Import files
 */
function dd_import_files(_dd_tag_target, _dd_pre_viewer, _dd_update_attached_path) {
  var dropZone = document.querySelector(_dd_tag_target);
  var contentPane = document.querySelector(_dd_pre_viewer);
  var updateAttachedUrl = _dd_update_attached_path;

  // Event Listener for when the dragged file is over the drop zone.
  dropZone.addEventListener('dragover', function(e) {
    if (e.preventDefault)
      e.preventDefault();
    if (e.stopPropagation)
      e.stopPropagation();

    e.dataTransfer.dropEffect = 'copy';
  });

  // Event Listener for when the dragged file enters the drop zone.
  dropZone.addEventListener('dragenter', function(e) {
    this.className = "over";
  });

  // Event Listener for when the dragged file leaves the drop zone.
  dropZone.addEventListener('dragleave', function(e) {
    this.className = "";
  });

  // Event Listener for when the dragged file dropped in the drop zone.
  dropZone.addEventListener('drop', function(e) {
    if (e.preventDefault)
      e.preventDefault();
    if (e.stopPropagation)
      e.stopPropagation();

    this.className = "";

    var fileList = e.dataTransfer.files;

    if (fileList.length > 0) {
      //readTextFile(fileList[0]);
      readImageFromFile(fileList[0]);
      uploadFile(fileList[0]);
    }
  });

  contentPane.addEventListener('dragover', function(e) {
    if (e.preventDefault)
      e.preventDefault();
    if (e.stopPropagation)
      e.stopPropagation();

    e.dataTransfer.dropEffect = 'copy';
  });

  // Event Listener for when the dragged file enters the drop zone.
  contentPane.addEventListener('dragenter', function(e) {
    dropZone.className = "over";
  });

  // Event Listener for when the dragged file leaves the drop zone.
  contentPane.addEventListener('dragleave', function(e) {
    this.className = "";
  });

  // Event Listener for when the dragged file dropped in the drop zone.
  contentPane.addEventListener('drop', function(e) {
    if (e.preventDefault)
      e.preventDefault();
    if (e.stopPropagation)
      e.stopPropagation();

    this.className = "";

    var fileList = e.dataTransfer.files;

    if (fileList.length > 0) {
      readImageFromFile(fileList[0]);
      uploadFile(fileList[0]);
    }
  });

  /*
   * Load & show image drop on target div
   * Image tag id must be #image_content
   * Image text/Span tag id must be #image_text
   */
  function readImageFromFile(file) {
    var reader = new FileReader();
    reader.onloadend = function(e) {
      if (e.target.readyState == FileReader.DONE) {
        $(dropZone).find("#image_content").attr("src", e.target.result);
        $(dropZone).find("#image_content").show();
        $(dropZone).find("#image_text").html('');
      }
    };
    reader.readAsDataURL(file);
  }

  // Read the contents of a text file.
  function readTextFile(file) {
    var reader = new FileReader();
    reader.onloadend = function(e) {
      if (e.target.readyState == FileReader.DONE) {
        var content = reader.result;
        contentPane.innerHTML = "File: " + file.name + "\n\n" + content;
      }
    };
    reader.readAsBinaryString(file);
  }

  function uploadFile(file) {
    var fd = new FormData();
    if ( typeof fd != "undefined") {
      fd.append("file", file);
      upload();

      function upload() {
        $.ajax({
          url : updateAttachedUrl,
          data : fd,
          processData : false,
          contentType : false,
          type : 'POST',
          success : function(data) {
            //if (data.image != "") readImageFile(data.image);
          }
        });
      }
    }
  }

  function uploadFiles(files) {
    var fd = FormData();
    var position = 0;
    var max = files.length;
    if ( typeof fd != "undefined") {
      function queue() {
        if (max >= 1 && position <= max - 1) {
          fd.append("file", files[position]);
          upload();
        }
      }
      function upload() {
        $.ajax({
          url : '/boxes/hiThere',
          data : fd,
          processData : false,
          contentType : false,
          type : 'POST',
          success : function(data) {
            position = position + 1;
            queue();
          }
        });
      }
      queue();
    }
  }
}

/*
 * Load & show image drop on target div
 * Image tag id must be #image_content
 * Image text/Span tag id must be #image_text
 */
function readImageFromInput(input, div) {
  if (input.files && input.files[0]) {
    var reader = new FileReader();
    reader.onloadend = function(e) {
      if (e.target.readyState == FileReader.DONE) {
        $(div).find("#image_content").attr("src", e.target.result);
        $(div).find("#image_content").show();
        $(div).find("#image_text").html('');
      }
    };
    reader.readAsDataURL(input.files[0]);
  }
}
