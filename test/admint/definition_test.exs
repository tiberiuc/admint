defmodule Admint.DefinitionTest do
  use ExUnit.Case

  def expand_all(macro, caller \\ __ENV__) do
    macro |> Macro.prewalk(&Macro.expand(&1, caller))
  end

  describe "admin" do
    @tag tibi: true
    test "admin is defined in root space" do
      ast =
        quote do
          defmodule TestAdminWork do
            use Admint.Definition

            admin do
            end
          end
        end

      Code.eval_quoted(ast, [], __ENV__)

      assert true
    end

    @tag tibi: false
    test "CompileError when redeclare admin inside admin" do
      assert_raise CompileError, ~r/"admin" can only be declared as root element/, fn ->
        defmodule TestAdminCompileError do
          use Admint.Definition

          admin do
            admin do
            end
          end
        end
      end
    end

    test "CompileError when declare more then one admin" do
      assert_raise CompileError,
                   ~r/admin  was already defined, all configurations must be defined inside "admin"/,
                   fn ->
                     defmodule TestAdminCompileError do
                       use Admint.Definition

                       admin do
                       end

                       admin do
                       end
                     end
                   end
    end
  end

  describe "navigation" do
    test "navigation is defined in admin space" do
      ast =
        quote do
          defmodule TestNavigationWork do
            use Admint.Definition

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
                   ~r/"navigation" can only be declared as direct child of "admin"/,
                   fn ->
                     defmodule TestAdminCompileError do
                       use Admint.Definition

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
                   ~r/admin  was already defined, all configurations must be defined inside "admin"/,
                   fn ->
                     defmodule TestAdminCompileError do
                       use Admint.Definition

                       admin do
                       end

                       navigation do
                       end
                     end
                   end
    end
  end

  describe "page" do
    test "page is defined in navigation space" do
      ast =
        quote do
          defmodule TestNavigationPageWork do
            use Admint.Definition

            admin do
              navigation do
                page :test_page do
                end
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
            use Admint.Definition

            admin do
              navigation do
                category :category do
                  page :test_page do
                  end
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
                   ~r/"page" can only be declared as direct child of "navigation" or "category"/,
                   fn ->
                     defmodule TestAdminCompileError do
                       use Admint.Definition

                       admin do
                         page do
                         end

                         navigation do
                         end
                       end
                     end
                   end
    end

    test "CompileError when declare after admin was closed" do
      assert_raise CompileError,
                   ~r/admin  was already defined, all configurations must be defined inside "admin"/,
                   fn ->
                     defmodule TestAdminCompileError do
                       use Admint.Definition

                       admin do
                       end

                       page do
                       end
                     end
                   end
    end
  end

  describe "category" do
    test "category is defined in navigation space" do
      ast =
        quote do
          defmodule TestNavigationCategoryWork do
            use Admint.Definition

            admin do
              navigation do
                category :category do
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
                   ~r/"category" can only be declared as direct child of "navigation"/,
                   fn ->
                     defmodule TestAdminCompileError do
                       use Admint.Definition

                       admin do
                         category :category do
                         end

                         navigation do
                         end
                       end
                     end
                   end
    end

    test "CompileError when category is inside category" do
      assert_raise CompileError,
                   ~r/"category" can only be declared as direct child of "navigation"/,
                   fn ->
                     defmodule TestAdminCompileError do
                       use Admint.Definition

                       admin do
                         navigation do
                           category :category do
                             category :inside_category do
                             end
                           end
                         end
                       end
                     end
                   end
    end

    test "CompileError when declare after admin was closed" do
      assert_raise CompileError,
                   ~r/admin  was already defined, all configurations must be defined inside "admin"/,
                   fn ->
                     defmodule TestAdminCompileError do
                       use Admint.Definition

                       admin do
                       end

                       category :category do
                       end
                     end
                   end
    end
  end
end
