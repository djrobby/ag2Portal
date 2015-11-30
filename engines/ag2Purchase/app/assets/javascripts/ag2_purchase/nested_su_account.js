/*
 * Methods to add 'fields' to the Supplier Bank accounts table 
 * Very important!!:
 *  1. remove_fields() & add_fields() are in main nested.js!!
 *  1. Modal window must be named (ie, 'new-item-fields')
 *  2. Items table must be named (ie. 'items-table')
 *  3. Each row in Items table must have 'class="fields"'
 *  4. Each field in modal window, to add to the table, must have 'class="field"'
 * >> This global methods are in main nested.js!!
 */

var su_accountFieldsUI = {
    init: function(sel2NoMatches) {
        var validationSettings = {
            errorMessagePosition : 'element'
        };

        $('#addAccountButton').on('click', function(e) {
            var isValid = $('#new-account-fields').validate(false, validationSettings);
            if(!isValid) {
                e.stopPropagation();
                return false;
            }
            su_formHandler.appendFields(sel2NoMatches);
            su_formHandler.hideForm();
        });

        $('#cancelAccountButton').on('click', function(e) {
          su_formHandler.removeFields();
          su_formHandler.hideForm();
        });
    }
};

var su_cfg = {
    formId: '#new-account-fields',
    tableId: '#accounts-table',
    inputFieldClassSelector: '.field',
    getTBodySelector: function() {
        return this.tableId + ' tbody';
    }
};

var su_formHandler = {
    // Public method for adding a new row to the table.
    appendFields: function (sel2NoMatches) {
        // Get a handle on all the input fields in the form and detach them from
		    // the DOM (we'll attach them later).
        var inputFields = $(su_cfg.formId + ' ' + su_cfg.inputFieldClassSelector);
        inputFields.detach();

        // Build the row and add it to the end of the table.
        su_rowBuilder.addRow(su_cfg.getTBodySelector(), inputFields);

        // Apply select2 to added row selects
        $('select.wsel2').select2('destroy');
        $('select.wsel2').select2({
          formatNoMatches: function(m) { return sel2NoMatches; },
          dropdownCssClass: 'shrinked',
          dropdownAutoWidth: true,
          containerCssClass: 'sub-select2-field'
        });
    },

    // Public method for remove a new row when cancel button has been clicked.
    removeFields: function () {
        // Get a handle on all the input fields in the form and detach them from
        // the DOM (we'll attach them later).
        var inputFields = $(su_cfg.formId + ' ' + su_cfg.inputFieldClassSelector);
        inputFields.detach();

        // Change value of _destroy field
        $(inputFields).map(function() {
          if (this.id.indexOf("_destroy") != -1) {
            $(this).val("1");
          }
        });
    },

    // Public method for hiding the data entry fields.
    hideForm: function() {
        // Update and display totals NOT HERE!
        //$('#accounts-table').trigger('totals');
        // Hide modal
        $(su_cfg.formId).modal('hide');
    }
};

var su_rowBuilder = function() {
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
            var id = '';
            var css = '';
            // Add only if not select2 link
            if (this.id.indexOf("s2") == -1) {
              // Apply CSS
              id = this.id;
              if ($(this).hasClass('fsel2')) css = css + ' select wsel2';
              if ($(this).hasClass('number-text-field')) css = css + ' sub-number-text-field';
              if ($(this).hasClass('sub-disabled-field')) css = css + ' sub-disabled-field';
              if (css === '') css = css + ' sub-alfanumeric-text-field';
              if (css.indexOf("wsel2") == -1) css = css + ' sub-bordered-input';
              css = css + ' string ' + id;
              $(this).removeAttr('class');
              $(this).removeAttr('id');
              $(this).addClass(css);
              // Add new column to row
              var td = $('<td/>').append($(this));
              // ...hiding this if applicable
              /*
              if (this.id === 'fnt-tax-type') {
                td = $('<td style="display:none;"/>').append($(this));
              }
              */
              // If destroy field, add delete link also
              if (id.indexOf("_destroy") != -1) {
                var td = $('<td/>').append($(this), newLink);
              }
              td.appendTo(newRow);
            }
        });

        return newRow;
    };

    // A public method for building a row and attaching it to the end of a
	// <TBODY> element.
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
