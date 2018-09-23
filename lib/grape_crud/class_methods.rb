module GrapeCRUD
  # :nodoc:
  module ClassMethods
    # Adds GET '/' andpoint to your resource
    # @param [Hash] options the options to paginate
    # @option authorize [true,false] pass true if you need authorization.
    #  (Pundit)
    # @example
    #  class ArticlesAPI < Grape::API
    #    include GrapeCRUD
    #    resource :articles do
    #      desc 'Returns list of filtered, sorted and paginated articles'
    #      add_index_action
    #    end
    #  end
    def add_index_action(options = {})
      get '/' do
        items = Actions::IndexProcess.new(input: { model_class: model })
                                     .with_searcher(searcher)
                                     .filter
                                     .sort(sorting_field, sorting_direction)
                                     .paginate(page: params['page'],
                                               per_page: params['per_page'])
                                     .results
        authorize items, :index? if options[:authorize]
        present items, with: entity_class
        present_pagination items if params['page'].present?
      end
    end

    # Adds GET '/:id' endpoint to your resource
    # @param [Hash] options the options to paginate
    # @option authorize [true,false] pass true if you need authorization.
    #  (Pundit)
    # @example
    #  class ArticlesAPI < Grape::API
    #    include GrapeCRUD
    #    resource :articles do
    #      desc 'Returns article by id'
    #      add_show_action
    #    end
    #  end
    def add_show_action(options = {})
      get '/:id' do
        item = model.find params[:id]
        authorize item, :show? if options[:authorize]
        present item, with: entity_class
      end
    end

    # Add POST '/' to your resource
    # @param [Hash] options the options to paginate
    # @option authorize [true,false] pass true if you need authorization.
    #  (Pundit)
    # @example
    #  class ArticlesAPI < Grape::API
    #    include GrapeCRUD
    #    resource :articles do
    #      desc 'Creates new article'
    #      params do
    #        requires :article, type: Hash do
    #          requires :name, type: String
    #        end
    #      end
    #      add_create_action
    #    end
    #  end
    def add_create_action(options = {})
      post '/' do
        item = model.new permitted_params
        authorize item, :create? if options[:authorize]
        if item.save
          present item, with: entity_class
        else
          error!({ errors: item.errors.messages }, 422)
        end
      end
    end
  end
end
