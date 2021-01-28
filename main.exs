defmodule TestMacro do
  @admint_context_stack :__admint_context_stack__

  defmacro __using__(_opts) do
    caller = __CALLER__.module

    quote do
      import TestMacro
      unquote(set_admint_context_stack([], caller))
    end
  end

  defmacro admin(do: block) do
    caller = __CALLER__.module
    {file, line} = get_stacktrace(__CALLER__)

    quote do
      unquote(
        check_stack_path(
          [[]],
          "\"admin\" can only be declared as root element",
          file,
          line,
          caller
        )
      )

      unquote(push_admint_context_stack(:admin, caller))
      unquote(block)
      unquote(pop_admint_context_stack(caller))
      unquote(cleanup_admint_context_stack(caller))
    end
  end

  defmacro navigation(_opts \\ [], do: block) do
    caller = __CALLER__.module
    {file, line} = get_stacktrace(__CALLER__)

    quote do
      unquote(
        check_stack_path(
          [[:admin]],
          "\"navigation\" can only be declared as direct child of \"admin\"",
          file,
          line,
          caller
        )
      )

      unquote(push_admint_context_stack(:navigation, caller))
      unquote(block)
      unquote(pop_admint_context_stack(caller))
    end
  end

  defmacro category(name, do: block) do
    caller = __CALLER__.module
    {file, line} = get_stacktrace(__CALLER__)

    quote do
      unquote(
        check_stack_path(
          [[:navigation, :admin]],
          "\"category\" can only be declared as direct child of \"navigation\"",
          file,
          line,
          caller
        )
      )

      nameis = unquote(name)
      IO.puts("adding category #{nameis}")
      unquote(push_admint_context_stack({:category, name}, caller))
      unquote(block)
      IO.puts("ended category #{nameis}")
      unquote(pop_admint_context_stack(caller))
    end
  end

  defmacro page(name, opts \\ []) do
    check_valid_schema(__CALLER__, opts)
    caller = __CALLER__.module
    {file, line} = get_stacktrace(__CALLER__)

    quote do
      unquote(
        check_stack_path(
          [[:navigation, :admin], [:category, :navigation, :admin]],
          "\"page\" can only be declared as direct child of \"navigation\" or \"category\"",
          file,
          line,
          caller
        )
      )

      stack = unquote(get_admint_context_stack(caller))
      nameis = unquote(name)
      IO.puts("adding page #{nameis} into #{inspect(stack)}")
    end
  end

  # ---- Private methods
  defp expand_all(macro, caller \\ __ENV__) do
    macro |> Macro.prewalk(&Macro.expand(&1, caller))
  end

  defp set_admint_context_stack(value \\ [], caller) do
    quote do
      Module.put_attribute(unquote(caller), unquote(@admint_context_stack), unquote(value))
    end
    |> expand_all()
  end

  defp get_admint_context_stack(caller) do
    quote do
      Module.get_attribute(unquote(caller), unquote(@admint_context_stack))
    end
    |> expand_all()
  end

  defp push_admint_context_stack(value, caller) do
    quote do
      stack = unquote(get_admint_context_stack(caller))
      new_stack = [unquote(value) | stack]

      unquote(
        set_admint_context_stack(
          quote do
            new_stack
          end,
          caller
        )
      )
    end
    |> expand_all()
  end

  defp pop_admint_context_stack(caller) do
    quote do
      stack = unquote(get_admint_context_stack(caller))

      with [last | rest] <- stack do
        unquote(
          set_admint_context_stack(
            quote do
              rest
            end,
            caller
          )
        )

        last
      else
        _ -> nil
      end
    end
    |> expand_all()
  end

  defp cleanup_admint_context_stack(caller) do
    quote do
      Module.delete_attribute(unquote(caller), unquote(@admint_context_stack))
    end
    |> expand_all()
  end

  defp check_stack_path(paths, message, file, line, caller) do
    quote do
      stack = unquote(get_admint_context_stack(caller))

      stack_path =
        stack
        |> Enum.map(fn entry ->
          with {id, _} <- entry do
            id
          else
            _ -> entry
          end
        end)

      valid = unquote(paths) |> Enum.reduce(false, fn path, acc -> acc || path == stack_path end)

      if not valid do
        unquote(raise_compiler_error(message, file, line))
      end
    end
    |> expand_all()
  end

  defp get_stacktrace(caller) do
    [{_, _, _, [file: file, line: line]}] = Macro.Env.stacktrace(caller)
    {file, line}
  end

  defp raise_compiler_error(message, file, line) do
    quote do
      raise CompileError, file: unquote(file), line: unquote(line), description: unquote(message)
    end
    |> expand_all()
  end

  defp check_valid_schema(caller, opts) do
    schema = Keyword.get(opts, :schema)

    with {_, _, _module} <- schema do
      true
    else
      nil ->
        true

      _ ->
        [{_, _, _, [file: file, line: line]}] = Macro.Env.stacktrace(caller)

        raise CompileError,
          file: file,
          line: line,
          description: "Expected module with Ecto schema but got #{inspect(schema)}"
    end
  end
end

defmodule Test do
  # use Admint.Definition
  use TestMacro

  admin do
    # header logo: "logo.jpg", title: "My company"

    navigation do
      page(:test_field, schema: Test.My)
      page(:new_page)

      category "My new category" do
        page(:page_inside_category)
        page(:second_page_in_first_category)
      end

      page(:page_after_category)

      category "Second category" do
        page(:first_page_in_second_category)
        page(:new_page_in_second_category)
      end

      page(:last_page_after_second_category)
    end
  end

  def run() do
    IO.puts("End.")
  end
end

# test "CompileError" do
#  assert_raise CompileError, "Some Helpful Info", fn() ->
#    ast = quote do
#      defmodule WillFail do
#         use MustBeValid, false
#      end
#    end
#    Code.eval_quoted(ast, []. __ENV__)
#  end
# end

IO.puts("------ STARTING -------")
Test.run()
