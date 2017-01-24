# coding: utf-8
require 'active_support/core_ext'
require 'thinreports'

module ThinReportsWithTextRotation
  def self.included(base)
    base.class_eval do
      alias_method_chain :text_box, :text_rotation
    end
  end

  def text_box_with_text_rotation(content, x, y, w, h, attrs = {})
    rotation = !attrs[:single] && content && content.match(%r!/r(?<rate>\d+)$!)

    if rotation
      content = content.delete(rotation.to_s)
      attrs   = attrs.merge :rotate => rotation[:rate].to_i,
                            :rotate_around => :lower_left
    end
    text_box_without_text_rotation(content, x, y, w, h, attrs)
  end
end

ThinReports::Generator::PDF::Document.send :include, ThinReportsWithTextRotation