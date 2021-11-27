# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def parse_query_results(query)
    query_results = ActiveRecord::Base.connection.execute(query).values

    if query_results.empty?
      []
    else
      query_results[0][0] && JSON
        .parse(query_results[0][0])
        .map { |result| result.deep_transform_keys { |key| key.to_s.camelize(:lower) } }
    end
  end
end
