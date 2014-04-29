/*
 * Main methods to remove or add 'fields' for the Items table 
 * Very important!!:
 *  1. Modal window must be named 'new-item-fields'
 *  2. Items table must be named 'items-table'
 *  3. Each row in Items table must have 'class="fields"'
 *  4. Each field in modal window must have 'class="field"'
 * >> If a master form have more then one items table, this code must be replicated at the proper folder & file name!!
 */
// Remove current item from the DOM
function remove_fields(link) {
    $(link).prev("input[type=hidden]").val("1");
    $(link).closest(".fields").hide();
}
// Display modal to add new item
function add_fields(link, association, content, sel2NoMatches) {
    var new_id = new Date().getTime();
    var regex = new RegExp("new_" + association, "g");
    $(link).parent().after(content.replace(regex, new_id));
    $('#new-item-fields').modal('show');
    // Special datepicker
    $('.idatepicker').datepicker({
      format : 'dd/mm/yyyy',
      weekStart : 1
    }).on('changeDate', function(e){
    	$('.idatepicker').datepicker('hide');
    });
    // Special select2
    $('select.isel2').select2({
      formatNoMatches: function(m) { return sel2NoMatches; }
    });
}

// Set up the UI/UX for the master screens.  This object sets up all the functionality we need to:
//  1.  Bind to the "click" event of the "#addButton" on the modal form.
//  2.  Append data from the modal form to the Items table.
//  3.  Hide the modal form when the user is done entering data.
//
// If any other events need to be wired up, the init function would be the place to put them.
var itemFieldsUI = {
    init: function() {
        // Configuration for the jQuery validator plugin:
        // Set the error messages to appear under the element that has the error. By default, the
        // errors appear in the all-too-familiar bulleted-list.
        // Other configuration options can be seen here:  https://github.com/victorjonsson/jQuery-Form-Validator
        var validationSettings = {
            errorMessagePosition : 'element'
        };

        // Run validation on an input element when it loses focus.
        //$('#new-item-fields').validateOnBlur();

        $('#addButton').on('click', function(e) {
            // If the form validation on our Items modal "form" fails, stop everything and prompt the user
            // to fix the issues.
            var isValid = $('#new-item-fields').validate(false, validationSettings);
            if(!isValid) {
                e.stopPropagation();
                return false;
            }
            formHandler.appendFields();
            formHandler.hideForm();
            //alert('Added');
        });
    }
};

// Configuration for the Add/Edit master screen's functionality:
//  formId:  The ID of the <FORM> that contains the input fields that need to be captured and appended to the table of Items.
//  tableId:  The ID of the <TABLE> that represents the Items assigned to master.
//  inputFieldClassSelector:  The CSS class that is assigned to all the data entry/input fields that need to be collected
//      for appending to th Items table (and ultimately for saving to the database).
//  getTBodySelector:  A VERY simple method that concatenates the cfg.tableId and " tbody" to build the selector we need
//      to identify the <TABLE> where we'll be appending rows.
var cfg = {
    formId: '#new-item-fields',
    tableId: '#items-table',
    inputFieldClassSelector: '.field',
    getTBodySelector: function() {
        return this.tableId + ' tbody';
    }
};

// Provides functionality to append new rows to the Items table and hide the modal form for adding new Items.
// NOTE:  The "appendFields" function depends on the rowBuilder to handle building the HTML for the new row.
var formHandler = {
    // Public method for adding a new row to the table.
    appendFields: function () {
        // Get a handle on all the input fields in the form and detach them from the DOM (we'll attach them later).
        var inputFields = $(cfg.formId + ' ' + cfg.inputFieldClassSelector);
        inputFields.detach();

        // Build the row and add it to the end of the table.
        rowBuilder.addRow(cfg.getTBodySelector(), inputFields);

        // Add the "Remove" link to the last cell.
        rowBuilder.link.clone().appendTo($('tr:last td:last'));
    },

    // Public method for hiding the data entry fields.
    hideForm: function() {
        $(cfg.formId).modal('hide');
    }
};

// Provides functionality for building the HTML that represents a new <TR> for the Items table.
var rowBuilder = function() {
    // Private property that define the default <TR> element text.
    var row = $('<tr>', { class: 'fields' });

    // Public property that describes the "Remove" link.
    var link = $('<a>', {
        href: '#',
        onclick: 'remove_fields(this); return false;',
        title: 'Delete this Item.'
    }).append($('<i>', { class: 'icon-trash' }));

    // A private method for building a <TR> w/the required data.
    var buildRow = function(fields) {
        var newRow = row.clone();

        $(fields).map(function() {
            $(this).removeAttr('class');
            var td = $('<td/>').append($(this));
            td.appendTo(newRow);
        });

        return newRow;
    };

    // A public method for building a row and attaching it to the end of a <TBODY> element.
    var attachRow = function(tableBody, fields) {
        var row = buildRow(fields);
        $(row).appendTo($(tableBody));
    };

    // Only expose public methods/properties.
    return {
        addRow: attachRow,
        link: link
    };
}();
