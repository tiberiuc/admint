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

      assert %{
               __stacktrace__: {_, _},
               config: %{},
               header: %Admint.Header{__stacktrace__: {_, _}, config: %{}},
               navigation: %Admint.Navigation{__stacktrace__: {_, _}, entries: [], config: %{}},
               categories: %{},
               pages: %{}
             } = definition
    end

    test "Default empty header" do
      defmodule TestHeaderEmptyAdmin do
        use Admint, :definition

        admin do
          header()
        end
      end

      definition = TestHeaderEmptyAdmin.__admint_definition__()

      assert %{
               __stacktrace__: {_, _},
               config: %{},
               header: %Admint.Header{__stacktrace__: {_, _}, config: %{}},
               navigation: %Admint.Navigation{__stacktrace__: {_, _}, entries: [], config: %{}},
               categories: %{},
               pages: %{}
             } = definition
    end

    test "Header/admin and navigation with config" do
      defmodule TestAHNWithconfigAdmin do
        use Admint, :definition

        admin page: MyApp.PageModule do
          header()

          navigation do
          end
        end
      end

      definition = TestAHNWithconfigAdmin.__admint_definition__()

      assert %{
               __stacktrace__: {_, _},
               config: %{},
               header: %Admint.Header{__stacktrace__: {_, _}, config: %{}},
               navigation: %Admint.Navigation{
                 __stacktrace__: {_, _},
                 entries: [],
                 config: %{}
               },
               categories: %{},
               pages: %{}
             } = definition
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
               navigation: %Admint.Navigation{
                 __stacktrace__: {_, _},
                 config: %{},
                 entries: [{:category, _, []}]
               },
               categories: _,
               pages: %{}
             } = definition

      {:category, category_id, _} = definition.navigation.entries |> List.first()

      category = definition.categories[category_id]

      assert %Admint.Category{
               __stacktrace__: {_, _},
               id: _,
               config: %{title: "category1"}
             } = category
    end

    test "Category with page" do
      defmodule TestNavigationCategoryWithPage do
        use Admint, :definition

        admin do
          navigation do
            category "category1" do
              page :page1, schema: MyApp.Schema
            end
          end
        end
      end

      definition = TestNavigationCategoryWithPage.__admint_definition__()

      assert [{:category, _, [page: :page1]}] = definition.navigation.entries

      assert pages: %{page1: %Admint.Page{__stacktrace__: {_, _}, config: %{}}} = definition.pages
    end

    test "Page inside navigation" do
      defmodule TestNavigationPageOnePage do
        use Admint, :definition

        admin do
          navigation do
            page :page1, schema: MyApp.Schema
          end
        end
      end

      definition = TestNavigationPageOnePage.__admint_definition__()

      assert [page: :page1] = definition.navigation.entries

      assert %{page1: %Admint.Page{__stacktrace__: {_, _}, config: %{}}} = definition.pages
    end

    test "Multiple pages inside navigation" do
      defmodule TestNavigationPage do
        use Admint, :definition

        admin do
          navigation do
            page :page1, schema: MyApp.Schema

            page :page2, schema: MyApp.Schema

            category "category" do
              page :page3, schema: MyApp.Schema

              page :page4, schema: MyApp.Schema
            end
          end
        end
      end

      definition = TestNavigationPage.__admint_definition__()

      assert [
               {:page, :page1},
               {:page, :page2},
               {:category, _, [page: :page3, page: :page4]}
             ] = definition.navigation.entries

      assert %{
               page1: %Admint.Page{
                 __stacktrace__: {_, _},
                 config: %{}
               },
               page2: %Admint.Page{
                 __stacktrace__: {_, _},
                 config: %{}
               },
               page3: %Admint.Page{
                 __stacktrace__: {_, _},
                 config: %{}
               },
               page4: %Admint.Page{
                 __stacktrace__: {_, _},
                 config: %{}
               }
             } = definition.pages

      assert %{
               id: :page1,
               module: Admint.Page,
               render: nil,
               schema: MyApp.Schema,
               index_page: Admint.Web.Page.IndexLive,
               view_page: Admint.Web.Page.ViewLive,
               edit_page: Admint.Web.Page.EditLive,
               title: "Page1"
             } = definition.pages.page1.config
    end
  end
end
