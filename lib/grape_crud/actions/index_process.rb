require 'process_chain'

module GrapeCRUD
  module Actions
    # Process chain for getting filtered, sorted and paginated records
    # @example get filtered, sorted and paginated records
    #   IndexProcess.new(input: { model_class: Article })
    #               .with_searcher(DefaultSearcher.new(filters: { author: 'max' }))
    #               .filter
    #               .sort('created_at', 'desc')
    #               .paginate(page: 5, per_page: 10)
    class IndexProcess
      include ProcessChain

      # Associate chain with searcher.
      # @parms searcher [Object] searcher object with "results" method
      # @raise [ArgumentError] when searcher has not "results" method
      # @return [GrapeCRUD::Actions::Index] with results.searcher equals
      #   passed searcher
      def with_searcher(searcher)
        unless searcher.respond_to?(:results)
          raise ArgumentError, 'searcher should respond to "results"'
        end

        if_success { return_success searcher: searcher }
      end

      # Apply filters
      # @return [GrapeCRUD::Actions::Index] results.records is filtered records
      def filter
        if_success do
          searcher = results.searcher
          model_class = results.model_class
          return_success records: searcher.results(model_class)
        end
      end

      # Apply sorting
      # @param field [String, Symbol] sorting field
      # @param direction [String, Symbol] sorting direction (asc or desc)
      # @return [GrapeCRUD::Actions::Index] results.records is sorted records
      def sort(field, direction)
        if_success do
          records = results.records
          unless field.nil?
            dir = %w[asc desc].include?(direction.to_s) ? direction : 'desc'
            records = records.order("#{field} #{dir}")
          end
          return_success records: records
        end
      end

      # Apply pagination
      # @param [Hash] opts the options to paginate
      # @option opts [Integer, nil] 'page' page number
      # @option opts [Integer,nil] 'per_page' per page params for pagination
      # @return [GrapeCRUD::Actions::Index] results.records is paginated array
      def paginate(opts)
        if_success do
          records = results.records
          unless opts['page'].nil?
            page = opts['page'].to_i
            per_page = opts['per_page'].nil? ? nil : opts['per_page'].to_i
            records = records.paginate page: page, per_page: per_page
          end
          return_success records: records
        end
      end
    end
  end
end
