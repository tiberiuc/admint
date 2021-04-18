defmodule AdmintWeb.Demo.Admin do
  use Admint.Definition

  admin do
    navigation do
      page :dashboard, title: "My dashboard", schema: Admint.Demo.Schema

      page :first_page, title: "My first page"
      page :custom_page, render: AdmintWeb.Demo.CustomPage

      category "Custom category title" do
        page :members
        page :plugins
      end

      category "Transactions" do
      end

      page :payments
    end
  end
end
