defmodule Admint.Test do
  use Admint.Definition

  # admin do
  #   # header logo: "logo.jpg", title: "My company"

  #   navigation do
  #     page(:test_field, schema: Test.My)
  #     page(:new_page)

  #     category "My new category" do
  #       page(:page_inside_category)
  #       page(:second_page_in_first_category)
  #     end

  #     page(:page_after_category)

  #     category "Second category" do
  #       page(:first_page_in_second_category)
  #       page(:new_page_in_second_category)
  #     end

  #     page(:last_page_after_second_category)
  #   end
  # end

  def run() do
    IO.puts("End.")

    Code.eval_string(
      """
                defmodule TestAdmin do
                  use Admint.Definition

                  admin do
                  end
                end
      """,
      __ENV__
    )
  end
end
