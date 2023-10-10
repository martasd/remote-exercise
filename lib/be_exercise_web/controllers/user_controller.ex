defmodule BeExerciseWeb.UserController do
  use BeExerciseWeb, :controller

  alias BeExercise.Payroll
  alias BeExercise.Payroll.User

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

  def show(conn, %{"id" => id}) do
    user = Payroll.get_user!(id)
    render(conn, :show, user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Payroll.get_user!(id)

    with {:ok, %User{} = user} <- Payroll.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Payroll.get_user!(id)

    with {:ok, %User{}} <- Payroll.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
