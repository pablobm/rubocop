# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::VoidValueExpression, :config do
  it 'registers an offense when a return appears where an expression is expected' do
    expect_offense(<<~RUBY)
      def void_expression
        return a and b
        ^^^^^^ This return introduces a void value.
      end
    RUBY
  end

  it 'registers an offense when a return appears in an assignment' do
    expect_offense(<<~RUBY)
      def void_assignment
        a = return 1
            ^^^^^^ This return introduces a void value.
      end
    RUBY
  end

  it 'registers an offense when a return appears in an assignment within a loop' do
    expect_offense(<<~RUBY)
      def void_assignment_within_while
        while running?
          a = return 1
              ^^^^^^ This return introduces a void value.
        end
      end
    RUBY
  end

  it 'does not register an offense when a return appears at the top level of a method' do
    expect_no_offenses(<<~RUBY)
      def perfectly_normal_method
        return 1
      end
    RUBY
  end

  it 'registers an offense when a return causes a begin block to resolve to void where an expression is expected' do
    expect_offense(<<~RUBY)
      def void_assignment_within_begin
        a =
          begin
            return 1
            ^^^^^^ This return introduces a void value.
          end
      end
    RUBY
  end

  it 'does not register an offense when a return appears at the top level of a begin block' do
    expect_no_offenses(<<~RUBY)
      def perfectly_normal_method
        begin
          return 1
        end
      end
    RUBY
  end

  it 'does not register an offense when a return appears in a block' do
    expect_no_offenses(<<~RUBY)
      def return_within_block
        items.each do |item|
          return item if item.returnable?
        end
      end
    RUBY
  end

  # I don't think this is avoidable.
  pending 'does not register an offense when a return appears in a metaprogrammed method' do
    expect_no_offenses(<<~RUBY)
      def metaprogrammed_module
        my_module = Module.new {
          define_method method_name do
            return 1
          end
        }
      end
    RUBY
  end

  it 'does not register an offense when a return appears in a conditional branch' do
    expect_no_offenses(<<~RUBY)
      def conditional_guard
        return if foo
      end
    RUBY
  end

  it 'does not register an offense when a return appears in a rescue-able conditional branch' do
    expect_no_offenses(<<~RUBY)
      def conditional_guard_with_rescue
        return if foo
      rescue SomeException
        handle_issue
      end
    RUBY
  end

  it 'registers an offense when a return causes a conditional to resolve to void where an expression is expected' do
    expect_offense(<<~RUBY)
      def conditional_expression
        1 +
          if foo
            2
          else
            return 1
            ^^^^^^ This return introduces a void value.
          end
        end
    RUBY
  end

  it 'registers an offense when a return appears in a conditional used by an assignment' do
    expect_offense(<<~RUBY)
      def conditional_assignment
        bar =
          if foo
            2
          else
            return 1
            ^^^^^^ This return introduces a void value.
          end
        end
    RUBY
  end

  it 'does not register an offense when a method definition is part of an expression' do
    expect_no_offenses(<<~RUBY)
      private def secret
        return 123
      end
    RUBY
  end

  it 'does not register an offense when a method definition is part of an assignment' do
    expect_no_offenses(<<~RUBY)
      method_name = def secret
        return 123
      end
    RUBY
  end

  it 'does not register an offense when a singleton method definition is part of an expression' do
    expect_no_offenses(<<~RUBY)
      private def foo.secret
        return 123
      end
    RUBY
  end

  it 'does not register an offense when a singleton method definition is part of an assignment' do
    expect_no_offenses(<<~RUBY)
      method_name = def foo.secret
        return 123
      end
    RUBY
  end

  it 'registers an offense when a return appears in an assignment within a block' do
    expect_offense(<<~RUBY)
      with_block {
        a = return 1
            ^^^^^^ This return introduces a void value.
      }
    RUBY
  end

  it 'registers an offense when a next appears in an expression' do
    expect_offense(<<~RUBY)
      def expression_with_next
        n = 0
        while n < 1
          n += 1
          1 + next
              ^^^^ This next introduces a void value.
        end
      end
    RUBY
  end

  it 'registers an offense when a next appears in an assignment' do
    expect_offense(<<~RUBY)
      def assignment_with_next
        n = 0
        while n < 1
          n += 1
          x = next 1
              ^^^^ This next introduces a void value.
        end
      end
    RUBY
  end

  it 'opassign' do
    expect_offense(<<~RUBY)
      def assignment_with_next
        n = 0
        while n < 1
          n += next n + 1
               ^^^^ This next introduces a void value.
        end
      end
    RUBY
  end

  it 'does not register an offense when a next is used correctly' do
    expect_no_offenses(<<~RUBY)
      def correct_next
        items.each do |item|
          next if item.skippable?
          do_something(item)
        end
      end
    RUBY
  end

  it 'registers an offense when a return is used where an expression is expected within a block' do
    expect_offense(<<~RUBY)
      def bad_return_in_block
        items.each do |item|
          return do_something(item) and 1
          ^^^^^^ This return introduces a void value.
        end
      end
    RUBY
  end

  it 'registers an offense when a break appears in an expression' do
    expect_offense(<<~RUBY)
      def expression_with_break
        n = 0
        while n < 1
          n += 1
          1 + break
              ^^^^^ This break introduces a void value.
        end
      end
    RUBY
  end

  it 'registers an offense when a break appears in an assignment' do
    expect_offense(<<~RUBY)
      def assignment_with_break
        n = 0
        while n < 1
          n += 1
          1 + break
              ^^^^^ This break introduces a void value.
        end
      end
    RUBY
  end

  it 'does not register an offense when a break is used correctly' do
    expect_no_offenses(<<~RUBY)
      def correct_break
        items.each do |item|
          do_something(item)
          break if item.last?
        end
      end
    RUBY
  end

  # Not detected by MRI or JRuby
  it 'registers an offense when there is still code after a bad return within a begin block' do
    expect_offense(<<~RUBY)
      def void_assignment_with_if_plus_code
        a =
          begin
            return 1
            ^^^^^^ This return introduces a void value.

            puts "AFTER"
          end
      end
    RUBY
  end

  # Not detected by MRI. Detected by JRuby
  it 'registers an offense when a return causes a void conditional within a begin block' do
    expect_offense(<<~RUBY)
      def void_assignment_with_if_plus_code
        a =
          begin
            if true
              return 1
              ^^^^^^ This return introduces a void value.
            end
          end
      end
    RUBY
  end

  # Not detected by MRI or JRuby
  it 'registers an offense when a return causes a void conditional within a begin block and there is still code after that' do
    expect_offense(<<~RUBY)
      def void_assignment_with_if_plus_code
        a =
          begin
            if true
              return 1
              ^^^^^^ This return introduces a void value.
            end

            puts "AFTER"
          end
      end
    RUBY
  end
end
