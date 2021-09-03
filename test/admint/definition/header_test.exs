defmodule Admint.Definition.HeaderTest do
  use ExUnit.Case

  describe "header" do
    test "header is defined in admin space" do
      ast =
        quote do
          defmodule TestheaderWork do
            use Admint, :definition

            admin do
              header()
            end
          end
        end

      Code.eval_quoted(ast, [], __ENV__)

      assert true
    end

    test "CompileError when header in wrong space" do
      assert_raise CompileError,
                   ~r/Header must be declared only inside admin/,
                   fn ->
                     defmodule TestAdminCompileErrorNavInsideNav do
                       use Admint, :definition

                       admin do
                         navigation do
                           header()
                         end
                       end
                     end
                   end
    end

    test "CompileError when declare after admin was closed" do
      assert_raise CompileError,
                   ~r/Header must be declared only inside admin/,
                   fn ->
                     defmodule TestAdminCompileErrorOutsideheader do
                       use Admint, :definition

                       admin do
                       end

                       header do
                       end
                     end
                   end
    end
  end
end
