defmodule AdmintWeb.Demo.Admin do
  use Admint.Definition

  admin do
    navigation do
      page :dashboard

      page :first_page
      page :second_page

      category :general  do
        page :members
        page :plugins
      end

      category :transactions do
      end

      page :payments
    end
  end

end
