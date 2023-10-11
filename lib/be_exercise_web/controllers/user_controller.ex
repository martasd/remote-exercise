defmodule BeExerciseWeb.UserController do
  use BeExerciseWeb, :controller

  alias BeExercise.Payroll

  action_fallback(BeExerciseWeb.FallbackController)

  def index(conn, params) do
    users = Payroll.list_users(params)
    render(conn, :index, users: users)
  end

  def invite(conn, _params) do
    with {:ok, num_invited} <- Payroll.invite_users() do
      json(conn, %{data: "Invited #{num_invited} users."})
    end
  end
end
