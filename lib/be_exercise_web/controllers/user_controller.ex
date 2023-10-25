defmodule BeExerciseWeb.UserController do
  use BeExerciseWeb, :controller

  alias BeExercise.Payroll

  action_fallback(BeExerciseWeb.FallbackController)

  def index(conn, params) do
    with {:ok, users} <- Payroll.list_users(params) do
      render(conn, :index, users: users)
    end
  end

  def invite(conn, _params) do
    with {:ok, num_invited} <- Payroll.invite_users() do
      json(conn, %{data: "Invited #{num_invited} users."})
    end
  end
end
