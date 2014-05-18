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
    init: function(sel2NoMatches) {
        var validationSettings = {
            errorMessagePosition : 'element'
        };

        $('#addButton').on('click', function(e) {
            var isValid = $('#new-item-fields').validate(false, validationSettings);
            if(!isValid) {
                e.stopPropagation();
                return false;
            }
            po_formHandler.appendFields(sel2NoMatches);
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
    appendFields: function (sel2NoMatches) {
        // Get a handle on all the input fields in the form and detach them from
		    // the DOM (we'll attach them later).
        var inputFields = $(po_cfg.formId + ' ' + po_cfg.inputFieldClassSelector);
        inputFields.detach();

        // Build the row and add it to the end of the table.
        po_rowBuilder.addRow(po_cfg.getTBodySelector(), inputFields);

        // Apply select2 to added row selects
        $('select.isel2').select2('destroy');
        $('select.isel2').select2({
          formatNoMatches: function(m) { return sel2NoMatches; },
          dropdownCssClass: 'shrinked',
          dropdownAutoWidth: true,
          containerCssClass: 'sub-select2-field'
        });
    },

    // Public method for hiding the data entry fields.
    hideForm: function() {
        // Update and display totals
        $('#items-table').trigger('totals');
        // Hide modal
        $(po_cfg.formId).modal('hide');
    }
};

var po_rowBuilder = function() {
    // Private property that define the default <TR> element text.
    var row = $('<tr>', { class: 'fields' });

    // Public property that describes the "Remove" link.
    var link = $('<a>', {
        href: '#',
        onclick: 'remove_fields(this); $("#items-table").trigger("totals"); return false;'
    }).append($('<i>', { class: 'icon-trash' }));

    // A private method for building a <TR> w/the required data.
    var buildRow = function(fields) {
        var newRow = row.clone();
        var newLink = link.clone();

        // fields
        $(fields).map(function() {
            //var divs = '<div class="control-group string required purchase_order_purchase_order_items_description"><div class="controls"><input class="string required sub-alfanumeric-text-field fnt-description" id="purchase_order_purchase_order_items_attributes_0_description" name="fnt-description" onkeyup="caps(this)" size="50" type="text" value="toto" /></div></div>';
            var css = '';
            // Add only if not select2 link
            if (this.id.indexOf("s2") == -1) {
              // Apply CSS
              css = this.id;
              if ($(this).hasClass('fsel2')) css = css + ' select isel2';
              if ($(this).hasClass('number-text-field')) css = css + ' sub-number-text-field';
              if ($(this).hasClass('sub-disabled-field')) css = css + ' sub-disabled-field';
              if (css === this.id) css = css + ' sub-alfanumeric-text-field';
              if (css.indexOf("isel2") == -1) css = css + ' sub-bordered-input';
              css = css + ' string';
              $(this).removeAttr('class');
              $(this).addClass(css);
              // Add new column to row
              var td = $('<td/>').append($(this));
              if (this.id === 'fnt-code' || this.id === 'fnt-delivery-date' ||
                this.id === 'fnt-work-order' || this.id === 'fnt-project' ||
                this.id === 'fnt-charge-account' || this.id === 'fnt-store' ||
                this.id === 'fnt-tax-type') {
                td = $('<td style="display:none;"/>').append($(this));
              }
              // If destroy field, add delete link also
              if (this.id.indexOf("_destroy") != -1) {
                var td = $('<td/>').append($(this), newLink);
              }
              td.appendTo(newRow);
            }
        });
        // link
        //var td = $('<td/>').append(newLink);
        //td.appendTo(newRow);

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
