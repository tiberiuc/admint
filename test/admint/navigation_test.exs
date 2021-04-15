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

            category :category do
              page :page3
              page :page4
            end
          end
        end
      end

      navigation = Admint.Navigation.get(TestNavigationPage)

      assert navigation == [
               {:page, :page1, "Page1", []},
               {:page, :page2, "Page2", []},
               {:category, :category, "Category",
                [{:page, :page3, "Page3", []}, {:page, :page4, "Page4", []}]}
             ]
    end
  end
end
