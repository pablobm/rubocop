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

  it 'registers an offense when a return appears as rvalue of an assignment' do
    expect_offense(<<~RUBY)
      def void_assignment
        a = return 1
            ^^^^^^ This return introduces a void value.
      end
    RUBY
  end

  it 'registers an offense when a return appears as rvalue of an op-assignment' do
    expect_offense(<<~RUBY)
      def opassign_with_return
        n += return n + 1
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

  context 'begin block' do
    it 'registers an offense when a return introduces a void value' do
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

    it 'does not register an offense when a return does not introduce a void value' do
      expect_no_offenses(<<~RUBY)
        def perfectly_normal_method
          begin
            return 1
          end
        end
      RUBY
    end
  end

  context 'block' do
    it 'does not register an offense when a return does not introduce a void value' do
      expect_no_offenses(<<~RUBY)
        def return_within_block
          items.each do |item|
            return item
          end
        end
      RUBY
    end

    it 'does not register an offense when the block returns but the method also returns a value' do
      expect_no_offenses(<<~RUBY)
        def return_within_block_and_query_method
          a = list.fetch(1) { return }
        end
      RUBY
    end

    it 'registers an offense when a return introduces a void value into an assignment' do
      expect_offense(<<~RUBY)
        with_block {
          a = return 1
              ^^^^^^ This return introduces a void value.
        }
      RUBY
    end

    it 'registers an offense when a return introduces a void value into an expression' do
      expect_offense(<<~RUBY)
        def bad_return_in_block
          items.each do |item|
            return do_something(item) and 1
            ^^^^^^ This return introduces a void value.
          end
        end
      RUBY
    end
  end

  context 'conditional' do
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

    it 'registers an offense when a return introduces a void value into an expression' do
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

    it 'registers an offense when a return introduces a void value into an assignment' do
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
  end

  context 'case statement' do
    it 'does not register an offense when a return appears in a case branch' do
      expect_no_offenses(<<~RUBY)
        def case_when_return
          case foo
          when 1
            return
          end
        end
      RUBY
    end

    it 'does not register an offense when a return appears in a rescue-able case statement' do
      expect_no_offenses(<<~RUBY)
        def case_with_rescue
          case foo
          when 1
            return
          end
        rescue SomeException
          handle_issue
        end
      RUBY
    end

    it 'registers an offense when a return introduces a void value into an expression' do
      expect_offense(<<~RUBY)
        def case_expression
          1 +
            case foo
            when 1
              return 1
              ^^^^^^ This return introduces a void value.
            else
              2
            end
          end
      RUBY
    end

    it 'registers an offense when a return introduces a void value into an assignment' do
      expect_offense(<<~RUBY)
        def case_assignment
          bar =
            case foo
            when 1
              return 1
              ^^^^^^ This return introduces a void value.
            else
              2
            end
          end
      RUBY
    end
  end

  context 'method definition' do
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
  end

  context 'singleton method definition' do
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
  end

  # Not detected by MRI. Detected by JRuby
  it 'registers an offense when a return introduces a void conditional within a begin block' do
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
  it 'registers an offense when a return introduces a void conditional within a begin block and there is still code after that' do
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
end
