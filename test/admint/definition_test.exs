defmodule Admint.DefinitionTest do
  use ExUnit.Case

  def expand_all(macro, caller \\ __ENV__) do
    macro |> Macro.prewalk(&Macro.expand(&1, caller))
  end

  describe "admin" do
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

    test "CompileError when redeclare admin inside admin" do
      assert_raise CompileError, ~r/"admin" can only be declared as root element/, fn ->
        defmodule TestAdminCompileErrorAdminInsideAdmin do
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
                     defmodule TestAdminCompileErrorDubleDeclaration do
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
                     defmodule TestAdminCompileErrorNavInsideNav do
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
                     defmodule TestAdminCompileErrorOutsideNavigation do
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
            use Admint.Definition

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
                   ~r/"page" can only be declared as direct child of "navigation" or "category"/,
                   fn ->
                     defmodule TestAdminCompileErrorPageOutsideNav do
                       use Admint.Definition

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
                   ~r/admin  was already defined, all configurations must be defined inside "admin"/,
                   fn ->
                     defmodule TestAdminCompileErrorOutsidePageDeclaration do
                       use Admint.Definition

                       admin do
                       end

                       page :page1
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
                   ~r/"category" can only be declared as direct child of "navigation"/,
                   fn ->
                     defmodule TestAdminCompileErrorCategOutsideNav do
                       use Admint.Definition

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
                   ~r/"category" can only be declared as direct child of "navigation"/,
                   fn ->
                     defmodule TestAdminCompileErrorCategInsideCateg do
                       use Admint.Definition

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
                   ~r/admin  was already defined, all configurations must be defined inside "admin"/,
                   fn ->
                     defmodule TestAdminCompileErrorOutsideDef do
                       use Admint.Definition

                       admin do
                       end

                       category "category" do
                       end
                     end
                   end
    end
  end

  describe "Set definition data" do
    test "Default empty admin" do
      defmodule TestNavigationEmptyAdmin do
        use Admint.Definition

        admin do
        end
      end

      definition = TestNavigationEmptyAdmin.__admint_definition__()
      assert %{header: _, navigation: %{entries: _}} = definition
    end

    test "Empty category" do
      defmodule TestNavigationEmptyCategory do
        use Admint.Definition

        admin do
          navigation do
            category "category1" do
            end
          end
        end
      end

      definition = TestNavigationEmptyCategory.__admint_definition__()

      assert %{
               header: _,
               navigation: %{
                 entries: [
                   {_,
                    %{
                      entries: [],
                      id: _,
                      opts: _,
                      type: :category
                    }}
                 ]
               }
             } = definition
    end

    test "Category with page" do
      defmodule TestNavigationCategoryWithPage do
        use Admint.Definition

        admin do
          navigation do
            category "category1" do
              page :page1
            end
          end
        end
      end

      definition = TestNavigationCategoryWithPage.__admint_definition__()

      assert %{
               header: _,
               navigation: %{
                 entries: [
                   {_,
                    %{
                      entries: [page1: %{id: :page1, opts: _, type: :page}],
                      id: _,
                      opts: %{title: "category1"},
                      type: :category
                    }}
                 ]
               }
             } = definition
    end

    test "Page inside navigation" do
      defmodule TestNavigationPageOnePage do
        use Admint.Definition

        admin do
          navigation do
            page :page1
          end
        end
      end

      definition = TestNavigationPageOnePage.__admint_definition__()

      assert %{
               header: _,
               navigation: %{
                 entries: [page1: %{id: :page1, opts: _, type: :page}]
               }
             } = definition
    end

    test "Multiple pages inside navigation" do
      defmodule TestNavigationPage do
        use Admint.Definition

        admin do
          navigation do
            page :page1
            page :page2

            category "category" do
              page :page3
              page :page4
            end
          end
        end
      end

      definition = TestNavigationPage.__admint_definition__()

      assert %{
               header: _,
               navigation: %{
                 entries: [
                   {
                     _,
                     %{
                       id: _,
                       opts: %{title: "category"},
                       type: :category,
                       entries: [
                         page4: %{id: :page4, opts: %{}, type: :page},
                         page3: %{id: :page3, opts: %{}, type: :page}
                       ]
                     }
                   },
                   {
                     :page2,
                     %{id: :page2, opts: %{}, type: :page}
                   },
                   {:page1, %{id: :page1, opts: %{}, type: :page}}
                 ]
               }
             } = definition
    end

    test "CompileError when page id is reused" do
      assert_raise CompileError,
                   ~r/ids must be unique/,
                   fn ->
                     defmodule TestAdminCompileErrorUniqueId do
                       use Admint.Definition

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
                   ~r/ids must be unique/,
                   fn ->
                     defmodule TestAdminCompileErrorUniqueId do
                       use Admint.Definition

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
