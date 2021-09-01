defmodule Admint.DefinitionTest do
  use ExUnit.Case

  describe "Set definition data" do
    test "Default empty admin" do
      defmodule TestNavigationEmptyAdmin do
        use Admint, :definition

        admin do
        end
      end

      definition = TestNavigationEmptyAdmin.__admint_definition__()
      assert %{navigation: [], categories: %{}, pages: %{}} = definition
    end

    test "Empty category" do
      defmodule TestNavigationEmptyCategory do
        use Admint, :definition

        admin do
          navigation do
            category "category1" do
            end
          end
        end
      end

      definition = TestNavigationEmptyCategory.__admint_definition__()

      assert %{
               navigation: [{:category, _, []}],
               categories: _,
               pages: %{}
             } = definition

      {:category, category_id, _} = definition.navigation |> List.first()

      category = definition.categories[category_id]

      assert %{
               __stacktrace__: {_, _},
               id: _,
               opts: %{title: "category1"}
             } = category
    end

    test "Category with page" do
      defmodule TestNavigationCategoryWithPage do
        use Admint, :definition

        admin do
          navigation do
            category "category1" do
              page :page1
            end
          end
        end
      end

      definition = TestNavigationCategoryWithPage.__admint_definition__()

      assert [{:category, _, [page: :page1]}] = definition.navigation

      assert pages: %{page1: %{__stacktrace__: {_, _}, id: :page1, opts: %{}}} = definition.pages
    end

    test "Page inside navigation" do
      defmodule TestNavigationPageOnePage do
        use Admint, :definition

        admin do
          navigation do
            page :page1
          end
        end
      end

      definition = TestNavigationPageOnePage.__admint_definition__()

      assert [page: :page1] = definition.navigation

      assert %{page1: %{__stacktrace__: {_, _}, id: :page1, opts: %{}}} = definition.pages
    end

    test "Multiple pages inside navigation" do
      defmodule TestNavigationPage do
        use Admint, :definition

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

      assert [
               {:page, :page1},
               {:page, :page2},
               {:category, _, [page: :page3, page: :page4]}
             ] = definition.navigation

      assert %{
               page1: %{__stacktrace__: {_, _}, id: :page1, opts: %{}},
               page2: %{__stacktrace__: {_, _}, id: :page2, opts: %{}},
               page3: %{__stacktrace__: {_, _}, id: :page3, opts: %{}},
               page4: %{__stacktrace__: {_, _}, id: :page4, opts: %{}}
             } = definition.pages
    end
  end
end
