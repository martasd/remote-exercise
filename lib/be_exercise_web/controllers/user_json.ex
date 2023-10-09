defmodule BeExerciseWeb.UserJSON do
  alias BeExercise.Payroll.Salary
  alias BeExercise.Payroll.User

  @doc """
  Renders a list of users.
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      name: user.name,
      salary: show_salary(user.salary)
    }
  end

  defp show_salary(nil), do: "no active salary found"

  defp show_salary(%Salary{} = salary) do
    %{
      amount: salary.amount,
      currency: salary.currency,
      active: salary.active
    }
  end
end
