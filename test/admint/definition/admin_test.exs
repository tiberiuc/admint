defmodule Admint.Definition.AdminTest do
  use ExUnit.Case

  describe "admin" do
    @tag tibi: true
    test "admin is defined in root space" do
      ast =
        quote do
          defmodule TestAdminWork do
            use Admint, :definition

            admin do
            end
          end
        end

      Code.eval_quoted(ast, [], __ENV__)

      assert true
    end

    test "CompileError when redeclare admin inside admin" do
      assert_raise CompileError, ~r/Admin can only be declared as root level/, fn ->
        defmodule TestAdminCompileErrorAdminInsideAdmin do
          use Admint, :definition

          admin do
            admin do
            end
          end
        end
      end
    end

    test "CompileError when declare more then one admin" do
      assert_raise CompileError,
                   ~r/Admin can be declared only once/,
                   fn ->
                     defmodule TestAdminCompileErrorDubleDeclaration do
                       use Admint, :definition

                       admin do
                       end

                       admin do
                       end
                     end
                   end
    end
  end
end
