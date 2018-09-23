require 'grape_crud/version'

require 'grape_crud/actions/index_process'
require 'grape_crud/class_methods'
require 'grape_crud/default_searcher'

require 'grape-entity'
require 'pundit'
require 'will_paginate'
require 'will_paginate/array'

# CRUD actions for Grape API
module GrapeCRUD
  def self.included(base)
    base.extend ClassMethods

    base.instance_eval do
      helpers Pundit
      helpers do
        def entity_class
          "#{model}Entity".constantize
        end

        def model
          raise NotImplementedError, 'model helper is not implemented'
        end

        def params_key
          model.to_s.underscore
        end

        def permitted_params
          declared(params, include_missing: false)[params_key].to_hash
        end

        def searcher
          DefaultSearcher.new(filters: params[:filter])
        end

        def sorting_direction
          nil
        end

        def sorting_field
          nil
        end
      end
    end
  end
end
