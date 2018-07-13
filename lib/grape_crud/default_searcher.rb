module GrapeCRUD
  # Simple filtering implementation
  # @example Returns all records MyModel with name "name" in scope my_scope
  #   DefaultSearcher.new(name: 'name').results(MyModel.my_scope)
  class DefaultSearcher
    # Constructor
    # @param filters [Hash,nil]
    def initialize(filters: nil)
      @filters = filters
    end

    # Returns result of filtering
    # @param base_query. Instance of ActiveRecord::Relation, Mongoid::Criteria,
    #   etc
    def results(base_query)
      return base_query if @filters.nil?
      base_query.where @filters
    end
  end
end
