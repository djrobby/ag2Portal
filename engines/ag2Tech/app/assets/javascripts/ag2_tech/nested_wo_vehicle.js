/*
 * Methods to add 'fields' to the Worker order Workers table 
 * Very important!!:
 *  1. remove_fields() & add_fields() are in main nested.js!!
 *  1. Modal window must be named (ie, 'new-worker-fields')
 *  2. Items table must be named (ie. 'workers-table')
 *  3. Each row in Items table must have 'class="fields"'
 *  4. Each field in modal window, to add to the table, must have 'class="field"'
 * >> This global methods are in main nested.js!!
 */

var wo_vehicleFieldsUI = {
    init: function(sel2NoMatches) {
        var validationSettings = {
            errorMessagePosition : 'element'
        };

        $('#addVehicleButton').on('click', function(e) {
            var isValid = $(wo_v_cfg.formId).validate(false, validationSettings);
            if(!isValid) {
                e.stopPropagation();
                return false;
            }
            wo_v_formHandler.appendFields(sel2NoMatches);
            wo_v_formHandler.hideForm();
        });

        $('#cancelVehicleButton').on('click', function(e) {
          wo_v_formHandler.removeFields();
          wo_v_formHandler.hideForm();
        });
    }
};

var wo_v_cfg = {
    formId: '#new-vehicle-fields',
    tableId: '#vehicles-table',
    inputFieldClassSelector: '.field',
    getTBodySelector: function() {
        return this.tableId + ' tbody';
    }
};

var wo_v_formHandler = {
    // Public method for adding a new row to the table.
    appendFields: function (sel2NoMatches) {
        // Get a handle on all the input fields in the form and detach them from
		    // the DOM (we'll attach them later).
        var inputFields = $(wo_v_cfg.formId + ' ' + wo_v_cfg.inputFieldClassSelector);
        inputFields.detach();

        // Build the row and add it to the end of the table.
        wo_v_rowBuilder.addRow(wo_v_cfg.getTBodySelector(), inputFields);

        // Apply select2 to added row selects
        $('select.vsel2').select2('destroy');
        $('select.vsel2').select2({
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
        var inputFields = $(wo_v_cfg.formId + ' ' + wo_v_cfg.inputFieldClassSelector);
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
        // Update and display totals
        $(wo_v_cfg.tableId).trigger('totals');
        // Hide modal
        $(wo_v_cfg.formId).modal('hide');
    }
};

var wo_v_rowBuilder = function() {
    // Private property that define the default <TR> element text.
    var row = $('<tr>', { class: 'fields' });

    // Public property that describes the "Remove" link.
    var link = $('<a>', {
        href: '#',
        onclick: 'remove_fields(this); $("#vehicles-table").trigger("totals"); return false;'
    }).append($('<i>', { class: 'icon-trash' }));

    // A private method for building a <TR> w/the required data.
    var buildRow = function(fields) {
        var newRow = row.clone();
        var newLink = link.clone();

        // fields
        $(fields).map(function() {
            var id = '';
            var css = '';
            var hid = '';
            var txt = '';
            var td;
            // Add only if not select2 link
            if (this.id.indexOf("s2") == -1) {
              // Setup new field(s)
              id = this.id;
              if ($(this).hasClass('fsel2') && id == 'fnt-vehicle') {
                // If it's a not editable select2 select, convert to new text inputs
                hid = '<input class="sub-alfanumeric-text-field sub-disabled-field ' + id + '" type="text" name="' + $(this).attr('name') + '" value="' + $(this).val() + '">';
                txt = '<input class="iconify_item sub-alfanumeric-text-field sub-disabled-field fnt-thing" type="text" value="' + $("option:selected", this).text() + '" readonly>';
                // Add hidden column to row
                td = $('<td/>').append(hid);
                td.appendTo(newRow);
                // Add new column
                td = $('<td/>').append(txt);
              } else {
                // Otherwise, change class
                if ($(this).hasClass('fsel2')) css = css + ' select isel2';
                if ($(this).hasClass('number-text-field')) css = css + ' sub-number-text-field';
                if ($(this).hasClass('sub-disabled-field')) css = css + ' sub-disabled-field';
                if (css === '') css = css + ' sub-alfanumeric-text-field';
                if (css.indexOf("vsel2") == -1) css = css + ' sub-bordered-input';
                css = css + ' string ' + id;
                $(this).removeAttr('class');
                $(this).removeAttr('id');
                $(this).addClass(css);
                // Add new column
                td = $('<td/>').append($(this));
                // ...hiding this if applicable
                if (id === 'fnt-charge-account-v') {
                  td = $('<td style="display:none;"/>').append($(this));
                }
                // If destroy field, add delete link also
                if (id.indexOf("_destroy") != -1) {
                  td = $('<td/>').append($(this), newLink);
                }
              }
              // Add new column(s) to row
              td.appendTo(newRow);
            }
/*
            var id = '';
            var css = '';
            // Add only if not select2 link
            if (this.id.indexOf("s2") == -1) {
              // Apply CSS
              id = this.id;
              if ($(this).hasClass('fsel2')) css = css + ' select vsel2';
              if ($(this).hasClass('number-text-field')) css = css + ' sub-number-text-field';
              if ($(this).hasClass('sub-disabled-field')) css = css + ' sub-disabled-field';
              if (css === '') css = css + ' sub-alfanumeric-text-field';
              if (css.indexOf("vsel2") == -1) css = css + ' sub-bordered-input';
              css = css + ' string ' + id;
              $(this).removeAttr('class');
              $(this).removeAttr('id');
              $(this).addClass(css);
              // Add new column to row
              var td = $('<td/>').append($(this));
              // If destroy field, add delete link also
              if (id.indexOf("_destroy") != -1) {
                var td = $('<td/>').append($(this), newLink);
              }
              td.appendTo(newRow);
            }
*/
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
