defmodule BeExerciseWeb.Router do
  use BeExerciseWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", BeExerciseWeb do
    pipe_through(:api)

    get("/users", UserController, :index)
    post("/invite-users", UserController, :invite)
  end
end
