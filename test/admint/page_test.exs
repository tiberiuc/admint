defmodule Admint.PageTest do
  use ExUnit.Case

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

    opts = Admint.Page.get_opts(TestNavigationOpts, :page1)
    assert %{schema: MyApp.Blog, title: "Custom page title"} = opts

    opts = Admint.Page.get_opts(TestNavigationOpts, :page3)
    assert %{schema: MyApp.Post, custom_opt: :test} = opts
  end
end
