defmodule Admint.DefinitionTest do
  use ExUnit.Case
  doctest Admint.Definition

  def expand_all(macro, caller \\ __ENV__) do
    macro |> Macro.prewalk(&Macro.expand(&1, caller))
  end

  describe "admin" do
    test "admin is defined in root space" do
      ast =
        Code.eval_string("""
                  defmodule TestAdmin do
                    use Admint.Definition

                    admin do
                    end
                  end
        """)

      # |> expand_all()

      IO.inspect(ast)

      # Code.eval_quoted(ast, [], file: "test", line: 1)

      assert true
    end

    # test "CompileError when redeclare admin" do
    #   assert_raise CompileError, "Some Helpful Info", fn ->
    #     defmodule TestAdmin2 do
    #       use Admint.Definition

    #       admin do
    #         admin do
    #         end
    #       end
    #     end
    #   end
    # end
  end
end
