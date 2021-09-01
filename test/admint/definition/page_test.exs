defmodule Admint.Definition.PageTest do
  use ExUnit.Case

  describe "page" do
    test "page is defined in navigation space" do
      ast =
        quote do
          defmodule TestNavigationPageWork do
            use Admint, :definition

            admin do
              navigation do
                page :test_page
              end
            end
          end
        end

      Code.eval_quoted(ast, [], __ENV__)

      assert true
    end

    test "page is defined in navigation -> category space" do
      ast =
        quote do
          defmodule TestNavigationCategoryPageWork do
            use Admint, :definition

            admin do
              navigation do
                category "category" do
                  page :test_page
                end
              end
            end
          end
        end

      Code.eval_quoted(ast, [], __ENV__)

      assert true
    end

    test "CompileError when page in wrong space" do
      assert_raise CompileError,
                   ~r/Page can only be declared inside navigation or category/,
                   fn ->
                     defmodule TestAdminCompileErrorPageOutsideNav do
                       use Admint, :definition

                       admin do
                         page :page1

                         navigation do
                         end
                       end
                     end
                   end
    end

    test "CompileError when declare after admin was closed" do
      assert_raise CompileError,
                   ~r/Page can only be declared inside navigation or category/,
                   fn ->
                     defmodule TestAdminCompileErrorOutsidePageDeclaration do
                       use Admint, :definition

                       admin do
                       end

                       page :page1
                     end
                   end
    end

    test "CompileError when page id is not atom" do
      assert_raise CompileError,
                   ~r/Page id must be an atom, got \"page1\"/,
                   fn ->
                     defmodule TestAdminCompileErrorOutsidePageDeclaration do
                       use Admint, :definition

                       admin do
                         navigation do
                           page "page1"
                         end
                       end
                     end
                   end
    end

    test "CompileError when page id is reused" do
      assert_raise CompileError,
                   ~r/Page with the same id ':page1' was already defined here:/,
                   fn ->
                     defmodule TestAdminCompileErrorUniqueId do
                       use Admint, :definition

                       admin do
                         navigation do
                           page :page1
                           page :page2

                           page :page1
                         end
                       end
                     end
                   end
    end

    test "CompileError when page id inside category is reused" do
      assert_raise CompileError,
                   ~r/ Page with the same id ':page1' was already defined here:/,
                   fn ->
                     defmodule TestAdminCompileErrorUniqueId do
                       use Admint, :definition

                       admin do
                         navigation do
                           page :page1
                           page :page2

                           category "category" do
                             page :page1
                           end
                         end
                       end
                     end
                   end
    end
  end
end
