defmodule BeExerciseWeb.PageController do
  use BeExerciseWeb, :controller

  def ping(conn, _params) do
    render(conn, :ping)
  end
end
