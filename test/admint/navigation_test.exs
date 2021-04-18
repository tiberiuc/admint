defmodule Admint.Nvigation.Test do
  use ExUnit.Case

  describe "navigation" do
    test "navigation data is returned correctly" do
      defmodule TestNavigationPage do
        use Admint.Definition

        admin do
          navigation do
            page :page1
            page :page2

            category "Category" do
              page :page3
              page :page4
            end
          end
        end
      end

      navigation = Admint.Navigation.get(TestNavigationPage)

      assert [
               {:page, :page1, "Page1", %{}},
               {:page, :page2, "Page2", %{}},
               {:category, _, "Category",
                [{:page, :page3, "Page3", %{}}, {:page, :page4, "Page4", %{}}]}
             ] = navigation
    end

    test "navigation get_index_page_id" do
      defmodule TestNavigationIndexPageId do
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

      index_page_id = Admint.Navigation.get_index_page_id(TestNavigationIndexPageId)

      assert index_page_id == :page1
    end

    test "navigation get_index_page_id when first is a category" do
      defmodule TestNavigationIndexPageIdCateg do
        use Admint.Definition

        admin do
          navigation do
            category "category" do
              page :page3
              page :page4
            end

            page :page1
            page :page2
          end
        end
      end

      index_page_id = Admint.Navigation.get_index_page_id(TestNavigationIndexPageIdCateg)

      assert index_page_id == :page3
    end

    test "navigation get_index_page_id  when first is an empty category" do
      defmodule TestNavigationIndexPageIdEmptyCateg do
        use Admint.Definition

        admin do
          navigation do
            category "category_empty" do
            end

            page :page1
            page :page2

            category "category" do
              page :page3
              page :page4
            end
          end
        end
      end

      index_page_id = Admint.Navigation.get_index_page_id(TestNavigationIndexPageIdEmptyCateg)

      assert index_page_id == :page1
    end

    test "navigation get_page_by_id" do
      defmodule TestNavigationPageById do
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

      page1 = Admint.Navigation.get_page_by_id(TestNavigationPageById, :page1)

      assert {:page, :page1, "Page1", _} = page1

      page3 = Admint.Navigation.get_page_by_id(TestNavigationPageById, :page3)

      assert {:page, :page3, "Page3", _} = page3
    end
  end

  describe "navigation opts " do
    test "custom page title and category title" do
      defmodule TestNavigationCustomTitles do
        use Admint.Definition

        admin do
          navigation do
            page :page1, title: "Custom page title"
            page :page2

            category "Custom category title" do
              page :page3
              page :page4
            end
          end
        end
      end

      page1 = Admint.Navigation.get_page_by_id(TestNavigationCustomTitles, :page1)

      assert {:page, :page1, "Custom page title", _} = page1

      nav = Admint.Navigation.get(TestNavigationCustomTitles)
      [first_page, _, categ] = nav
      {:category, _, categ_title, _} = categ
      {:page, _, page_title, _} = first_page

      assert categ_title == "Custom category title"
      assert page_title == "Custom page title"
    end

    test "page opts" do
      defmodule TestNavigationOpts do
        use Admint.Definition

        admin do
          navigation do
            page :page1, title: "Custom page title", schema: MyApp.Blog
            page :page2

            category "Custom category title" do
              page :page3, schema: MyApp.Post, custom_opt: :test
              page :page4
            end
          end
        end
      end

      page1 = Admint.Navigation.get_page_by_id(TestNavigationOpts, :page1)
      {:page, :page1, "Custom page title", opts} = page1
      assert %{schema: MyApp.Blog, title: "Custom page title"} = opts

      page3 = Admint.Navigation.get_page_by_id(TestNavigationOpts, :page3)
      {:page, :page3, "Page3", opts} = page3
      assert %{schema: MyApp.Post, custom_opt: :test} = opts
    end
  end
end
