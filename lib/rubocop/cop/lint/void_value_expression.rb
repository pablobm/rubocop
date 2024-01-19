# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # TODO: Write cop description and example of bad / good code. For every
      # `SupportedStyle` and unique configuration, there needs to be examples.
      # Examples must have valid Ruby syntax. Do not use upticks.
      #
      # @safety
      #   Delete this section if the cop is not unsafe (`Safe: false` or
      #   `SafeAutoCorrect: false`), or use it to explain how the cop is
      #   unsafe.
      #
      # @example EnforcedStyle: bar (default)
      #   # Description of the `bar` style.
      #
      #   # bad
      #   bad_bar_method
      #
      #   # bad
      #   bad_bar_method(args)
      #
      #   # good
      #   good_bar_method
      #
      #   # good
      #   good_bar_method(args)
      #
      # @example EnforcedStyle: foo
      #   # Description of the `foo` style.
      #
      #   # bad
      #   bad_foo_method
      #
      #   # bad
      #   bad_foo_method(args)
      #
      #   # good
      #   good_foo_method
      #
      #   # good
      #   good_foo_method(args)
      #
      class VoidValueExpression < Base
        def on_next(node)
          on_void_node(node, block_limit: true)
        end

        def on_break(node)
          on_void_node(node, block_limit: true)
        end

        def on_return(node)
          on_void_node(node)
        end

        private

        def on_void_node(void_node, block_limit: false)
          pp void_node.ancestors.last
          pp [void_node, *void_node.ancestors].map { |n| [n.type, :value_used?, n.value_used?] }

          limits = %i(def defs)
          if block_limit
            limits << :block
          end

          parent_node = void_node.ancestors
            .take_while { |n| !limits.include?(n.type) }
            .reject { |n| %i(kwbegin if while begin rescue block).include?(n.type) }
            .first

          #pp parent_node
          return unless parent_node
          return unless parent_node.value_used? || %i{lvasgn send}.include?(parent_node.type)

          add_offense(
            void_node.loc.keyword,
            message: "This #{void_node.type} introduces a void value."
          )
        end
      end
    end
  end
end
