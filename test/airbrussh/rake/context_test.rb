require "minitest_helper"
require "airbrussh/rake/context"

class Airbrussh::Rake::ContextTest < Minitest::Test
  include RakeTaskDefinition

  def setup
    @config = Airbrussh::Configuration.new
  end

  def teardown
    Airbrussh::Rake::Context.current_task_name = nil
  end

  def test_current_task_name_is_nil_when_disabled
    @config.monkey_patch_rake = false
    context = Airbrussh::Rake::Context.new(@config)
    define_and_execute_rake_task("one") do
      assert_nil(context.current_task_name)
    end
  end

  def test_current_task_name
    @config.monkey_patch_rake = true
    context = Airbrussh::Rake::Context.new(@config)

    assert_nil(context.current_task_name)

    define_and_execute_rake_task("one") do
      assert_equal("one", context.current_task_name)
    end

    define_and_execute_rake_task("two") do
      assert_equal("two", context.current_task_name)
    end
  end

  def test_register_new_command_is_true_for_first_execution_per_rake_task
    @config.monkey_patch_rake = true
    context = Airbrussh::Rake::Context.new(@config)
    define_and_execute_rake_task("one") do
      assert context.register_new_command(:command_one)
      refute context.register_new_command(:command_one)
      assert context.register_new_command(:command_two)
      refute context.register_new_command(:command_two)
    end

    define_and_execute_rake_task("two") do
      assert context.register_new_command(:command_one)
      refute context.register_new_command(:command_one)
      assert context.register_new_command(:command_two)
      refute context.register_new_command(:command_two)
    end
  end

  def test_decorate_command
    @config.monkey_patch_rake = true
    context = Airbrussh::Rake::Context.new(@config)

    define_and_execute_rake_task("one") do
      context.register_new_command(:command_one)
      command_one = context.decorate_command(:command_one)
      context.register_new_command(:command_two)
      command_two = context.decorate_command(:command_two)

      assert_equal(0, command_one.position)
      assert_equal(1, command_two.position)
    end

    define_and_execute_rake_task("two") do
      context.register_new_command(:command_three)
      command_three = context.decorate_command(:command_three)
      context.register_new_command(:command_four)
      command_four = context.decorate_command(:command_four)

      assert_equal(0, command_three.position)
      assert_equal(1, command_four.position)
    end
  end
end
