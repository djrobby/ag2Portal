module ApplicationHelper
  def display_base_errors resource
    return '' if (resource.errors.empty?) or (resource.errors[:base].empty?)
    messages = resource.errors[:base].map { |msg| content_tag(:p, msg) }.join
    html = <<-HTML
    <div class="alert alert-error alert-block">
      <button type="button" class="close" data-dismiss="alert">&#215;</button>
      #{messages}
    </div>
    HTML
    html.html_safe
  end

  def current_translations
    I18n.t(:foo)
    @translations ||= I18n.backend.send(:translations)
    @translations[I18n.locale].with_indifferent_access
  end

  # Sort view table columns
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = (column == sort_column) ? "current #{sort_direction}" : "current"
    direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end
  
  #
  # Nested forms
  #
  # Remove
  def link_to_remove_fields(name, f, options = {})
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)", options)
  end
  
  # Add
  # name:         The name of the link - ie. t("ag2_purchase.purchase_orders.btn_new_item")
  # f:            The parent form - ie. f (usually the form in _form.html.erb)
  # association:  The association data object defined on parent model with accepts_nested_attributes_for (usually items) - ie. :purchase_order_items
  # fields_partial: Partial view name, the one in _item_fields.html.erb - ie. "item_fields" that contains the modal window
  # modal:          Div id (modal window)
  # options: class: "btn btn-warning", title: t("ag2_purchase.purchase_orders.add_item")
  def link_to_add_fields(name, f, association, fields_partial, modal, options = {})
    sel2NoMatch = t("select2.no_matches")
    new_object = f.object.class.reflect_on_association(association).klass.new
    #fields = f.fields_for(association, new_object, :child_index => "new_#{ association }", :onsubmit => "return $(this.)validate();") do |builder|
    #fields = f.fields_for(association, new_object, :child_index => "new_#{ fields_partial }", :onsubmit => "return $(this.)validate();") do |builder|
    fields = f.simple_fields_for(association, new_object, :child_index => "new_#{ fields_partial }", :onsubmit => "return $(this.)validate();") do |builder|
      render(fields_partial, :f => builder)
      #render(association.to_s.singularize + "_fields", :f => builder)
    end
    #link_to_function(name, "add_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", options)
    link_to_function(name, "add_fields(this, \"#{ fields_partial }\", \"#{ modal }\", \"#{ escape_javascript(fields) }\", \"#{ sel2NoMatch }\")", options)
  end
end
