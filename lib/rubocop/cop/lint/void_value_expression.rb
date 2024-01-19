# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      class VoidValueExpression < Base
        def on_return(return_node)
          parent_node = return_node.ancestors
            .take_while { |n| !%i(def defs).include?(n.type) }
            .reject { |n| %i(kwbegin if while begin rescue block).include?(n.type) }
            .first

          #pp parent_node
          return unless parent_node
          return unless parent_node.value_used? || %i{lvasgn send}.include?(parent_node.type)

          add_offense(
            return_node.loc.keyword,
            message: "This return introduces a void value."
          )
        end
      end
    end
  end
end
