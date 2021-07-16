# Admint

Admin for Phoenix based application using LiveView

## Installation

Phoenix v1.5 comes with built-in support for LiveView apps. You can create a new application with:

```
mix phx.new my_app --live
```

Then add `admint` to the list of dependencies in `mix.exs`:

```
def deps do
  [
    {:admint, git: "https://github.com/admint_elixir/admint"}
  ]
```

Configure `admint` in `config/config.exs`

```
# Config Admint
config :admint,
  ecto_repo: MyApp.Repo,
  router: MyAppWeb.Router
```

Add admint endpoints for static files in `endpoint.ex`

```
use Admint, :endpoint
```

Add routing for admint in `router.ex`

```
use Admint, :router

.....

admint "/my_admin", MyAppWeb.MyAdmin do
  pipe_through :browser
end
```

Create a module `MyAppWeb.MyAdmin` with definitions for your admin

```
defmodule MyAppWeb.MyAdmin do
  use Admint.Definition

  admin do
    navigation do
      page :dashboard, title: "My dashboard", render: MyAppWeb.Dashboard


      category "Blog" do
        page :posts, tile: "Blog posts", schema: MyApp.Blog.Post
        page :comments, schema MyApp.Blog.Comment
      end

      page :users, schema: MyApp.User
    end
  end
end

```

If you're using `mix format`, make sure you add `:admint` to the ` import_deps` configuration in your `.formatter.exs` file:

```
[
  import_deps: [:ecto, :phoenix, :admint],
  ...
]
```

## License

Copyright (c) 2021, Tiberiu Craciun.

Surface source code is licensed under the [MIT License](LICENSE.md).
