/*
 * Methods to add 'fields' to the Purchase Items table 
 * Very important!!:
 *  1. remove_fields() & add_fields() are in main nested.js!!
 *  1. Modal window must be named (ie, 'new-item-fields')
 *  2. Items table must be named (ie. 'items-table')
 *  3. Each row in Items table must have 'class="fields"'
 *  4. Each field in modal window, to add to the table, must have 'class="field"'
 * >> This global methods are in main nested.js!!
 */

var po_itemFieldsUI = {
    init: function() {
        // Configuration for the jQuery validator plugin:
        // Set the error messages to appear under the element that has the error. By default, the
        // errors appear in the all-too-familiar bulleted-list.
        // Other configuration options can be seen here:  https://github.com/victorjonsson/jQuery-Form-Validator
        var validationSettings = {
            errorMessagePosition : 'element'
        };

        $('#addButton').on('click', function(e) {
            // If the form validation on our Items modal "form" fails, stop everything and prompt the user
            // to fix the issues.
            var isValid = $('#new-item-fields').validate(false, validationSettings);
            if(!isValid) {
                e.stopPropagation();
                return false;
            }
            po_formHandler.appendFields();
            po_formHandler.hideForm();
        });
    }
};

var po_cfg = {
    formId: '#new-item-fields',
    tableId: '#items-table',
    inputFieldClassSelector: '.field',
    getTBodySelector: function() {
        return this.tableId + ' tbody';
    }
};

var po_formHandler = {
    // Public method for adding a new row to the table.
    appendFields: function () {
        // Get a handle on all the input fields in the form and detach them from the DOM (we'll attach them later).
        var inputFields = $(po_cfg.formId + ' ' + po_cfg.inputFieldClassSelector);
        inputFields.detach();

        // Build the row and add it to the end of the table.
        po_rowBuilder.addRow(po_cfg.getTBodySelector(), inputFields);

        // Add the "Remove" link to the last cell.
        //po_rowBuilder.link.clone().appendTo($('tr:last td:last'));
    },

    // Public method for hiding the data entry fields.
    hideForm: function() {
        $(po_cfg.formId).modal('hide');
    }
};

var po_rowBuilder = function() {
    // Private property that define the default <TR> element text.
    var row = $('<tr>', { class: 'fields' });

    // Public property that describes the "Remove" link.
    var link = $('<a>', {
        href: '#',
        onclick: 'remove_fields(this); return false;'
    }).append($('<i>', { class: 'icon-trash' }));

    // A private method for building a <TR> w/the required data.
    var buildRow = function(fields) {
        var newRow = row.clone();
        var newLink = link.clone();

        // fields
        $(fields).map(function() {
            //alert(this.id);
            $(this).removeAttr('class');
            $(this).addClass("sub-number-text-field");
            var css = '';
            // Add only if not select2 link
            if (this.id.indexOf("s2") == -1) {
              css = this.id;
              if ($(this).hasClass('fsel2')) css = css + ' isel2 sub-select2-field';
              if ($(this).hasClass('number-text-field')) css = css + ' sub-number-text-field';
              if ($(this).hasClass('sub-disabled-field')) css = css + ' sub-disabled-field';
              if (css == $(this).id) css = css + ' sub-alfanumeric-text-field';
              $(this).removeAttr('class');
              $(this).addClass(css);
              var td = $('<td/>').append($(this));
              td.appendTo(newRow);
            }
        });
        // link
        var td = $('<td/>').append(newLink);
        td.appendTo(newRow);

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
