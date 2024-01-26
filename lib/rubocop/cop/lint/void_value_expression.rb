# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      SKIPPABLE_STATEMENTS = %i[kwbegin if while begin rescue resbody].freeze
      LIMIT_STATEMENTS = %i[def defs block case when].freeze

      class VoidValueExpression < Base
        def on_return(return_node)
          parent_node =
            return_node
            .ancestors
            .take_while { |n| !LIMIT_STATEMENTS.include?(n.type) }
            .reject { |n| SKIPPABLE_STATEMENTS.include?(n.type) }
            .first

          return unless parent_node
          return unless parent_node.value_used? || %i[lvasgn send].include?(parent_node.type)

          add_offense(return_node.loc.keyword, message: 'This return introduces a void value.')
        end
      end
    end
  end
end
