defmodule Admint.Definition.CategoryTest do
  use ExUnit.Case

  describe "category" do
    test "category is defined in navigation space" do
      ast =
        quote do
          defmodule TestNavigationCategoryWork do
            use Admint, :definition

            admin do
              navigation do
                category "category" do
                end
              end
            end
          end
        end

      Code.eval_quoted(ast, [], __ENV__)

      assert true
    end

    test "CompileError when category in wrong space" do
      assert_raise CompileError,
                   ~r/Category can only be declared only inside navigation/,
                   fn ->
                     defmodule TestAdminCompileErrorCategOutsideNav do
                       use Admint, :definition

                       admin do
                         category "category" do
                         end

                         navigation do
                         end
                       end
                     end
                   end
    end

    test "CompileError when category is inside category" do
      assert_raise CompileError,
                   ~r/Category can only be declared only inside navigation/,
                   fn ->
                     defmodule TestAdminCompileErrorCategInsideCateg do
                       use Admint, :definition

                       admin do
                         navigation do
                           category "category" do
                             category "inside category" do
                             end
                           end
                         end
                       end
                     end
                   end
    end

    test "CompileError when declare after admin was closed" do
      assert_raise CompileError,
                   ~r/Category can only be declared only inside navigation/,
                   fn ->
                     defmodule TestAdminCompileErrorOutsideDef do
                       use Admint, :definition

                       admin do
                       end

                       category "category" do
                       end
                     end
                   end
    end

    test "CompileError when title is not string" do
      assert_raise CompileError,
                   ~r/ Category should have a title as string, got :category/,
                   fn ->
                     defmodule TestAdminCompileErrorOutsideDef do
                       use Admint, :definition

                       admin do
                         category :category do
                         end
                       end
                     end
                   end
    end
  end
end
