module Ag2Admin
  class ApplicationController < ::ApplicationController
    mattr_accessor :reset_session_variables_for_filters

    layout 'layouts/application'

    def reset_session_variables_for_filters
      session[:search] = nil
      session[:letter] = nil
      session[:sort] = nil
      session[:direction] = nil
      session[:ifilter] = nil
    end

    def reindex_model(_model)
      _model.singularize.camelize.constantize.index(batch_size: 1000)
      code = I18n.t(:reindex_ok)
    rescue
      code = I18n.t(:reindex_error)
    end

    def reindexable_models
      _array = []
      ActiveRecord::Base.connection.tables.each do |table|
        next if table.match(/\Aschema_migrations\Z/)
        klass = table.singularize.camelize.constantize rescue nil
        if !klass.nil?
          kname = klass.name rescue nil
          kount = klass.count rescue 0
          if !kname.nil? && kount>0
            krcrd = kount > 1 ? I18n.t(:records) : I18n.t(:record)
            krcrd = kname + ' (' + kount.to_s + ' ' + krcrd + ')'
            _array = _array << [krcrd, kname]
          end
        end
      end
      _array
    end
  end
end
