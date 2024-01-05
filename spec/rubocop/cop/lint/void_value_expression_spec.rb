# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::VoidValueExpression, :config do
  it 'registers an offense when a returns appears within an expression' do
    expect_offense(<<~RUBY)
      def void_expression
        return a and b
        ^^^^^^ This return invalidates the expression.
      end
    RUBY
  end

  it 'registers an offense when a returns appears within an assignment' do
    expect_offense(<<~RUBY)
      def void_assignment
        a = return 1
            ^^^^^^ This return invalidates the expression.
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

  it 'registers an offense when a return appears within a begin block in an assignment' do
    expect_offense(<<~RUBY)
      def void_assignment_with_begin
        a =
          begin
            return 1
            ^^^^^^ This return invalidates the expression.
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
      def return_in_block
        items.each do |item|
          return item if item.returnable?
        end
      end
    RUBY
  end

  it 'does not register an offense when a return appears in an "if" guard clause' do
    expect_no_offenses(<<~RUBY)
      def if_guard
        return if foo
      end
    RUBY
  end

  it 'does not register an offense when a return appears in an "if" guard clause' do
    expect_no_offenses(<<~RUBY)
      def if_guard_with_rescue
        return if foo
      rescue SomeException
        handle_issue
      end
    RUBY
  end

  it 'does not register an offense when a return appears in an "unless" guard clause' do
    expect_no_offenses(<<~RUBY)
      def unless_guard
        return unless foo
      end
    RUBY
  end

  it 'does not register an offense when a return appears at the top of an "else" branch' do
    expect_no_offenses(<<~RUBY)
      def else_branch
        if foo
          bar
        else
          return 1
        end
      end
    RUBY
  end

  it 'registers an offense when a return appears in an if/else used by an expression' do
    expect_offense(<<~RUBY)
      def expression_with_if
        1 +
          if foo
            2
          else
            return 1
            ^^^^^^ This return invalidates the expression.
          end
        end
    RUBY
  end

  it 'registers an offense when a return appears in an if/else used by an assignment' do
    expect_offense(<<~RUBY)
      def assignment_with_if
        bar =
          if foo
            2
          else
            return 1
            ^^^^^^ This return invalidates the expression.
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

  it 'does not register an offense when a method definition is part of an assignment' do
    expect_no_offenses(<<~RUBY)
      method_name = def foo.secret
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

  it 'does not register an offense when a method definition is part of an assignment' do
    expect_no_offenses(<<~RUBY)
      method_name = def foo.secret
        return 123
      end
    RUBY
  end

  it 'registers an offense when a return appears in an assignment in a block' do
    expect_offense(<<~RUBY)
      with_block {
        a = return 1
            ^^^^^^ This return invalidates the expression.
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
              ^^^^ This next invalidates the expression.
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
          1 + next
              ^^^^ This next invalidates the expression.
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

  it 'registers an offense when a return is incorrectly used within a block' do
    expect_offense(<<~RUBY)
      def bad_return_in_block
        items.each do |item|
          return do_something(item) and 1
          ^^^^^^ This return invalidates the expression.
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
              ^^^^^ This break invalidates the expression.
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
              ^^^^^ This break invalidates the expression.
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

  it 'registers an offense when there is still code after a bad return' do
    expect_offense(<<~RUBY)
      def void_assignment_with_if_plus_code
        a =
          begin
            if true
              return 1
              ^^^^^^ This return invalidates the expression.
            end

            puts "AFTER"
          end
      end
    RUBY
  end
end
