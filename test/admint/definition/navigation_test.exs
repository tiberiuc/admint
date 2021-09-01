defmodule Admint.Definition.NavigationTest do
  use ExUnit.Case

  describe "navigation" do
    test "navigation is defined in admin space" do
      ast =
        quote do
          defmodule TestNavigationWork do
            use Admint, :definition

            admin do
              navigation do
              end
            end
          end
        end

      Code.eval_quoted(ast, [], __ENV__)

      assert true
    end

    test "CompileError when navigation in wrong space" do
      assert_raise CompileError,
                   ~r/Navigation must be declared only inside admin/,
                   fn ->
                     defmodule TestAdminCompileErrorNavInsideNav do
                       use Admint, :definition

                       admin do
                         navigation do
                           navigation do
                           end
                         end
                       end
                     end
                   end
    end

    test "CompileError when declare after admin was closed" do
      assert_raise CompileError,
                   ~r/Navigation must be declared only inside admin/,
                   fn ->
                     defmodule TestAdminCompileErrorOutsideNavigation do
                       use Admint, :definition

                       admin do
                       end

                       navigation do
                       end
                     end
                   end
    end
  end
end
