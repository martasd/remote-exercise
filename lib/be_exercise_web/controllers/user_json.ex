defmodule BeExerciseWeb.UserJSON do
  alias BeExercise.Payroll
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

  # Show user's name and active salary. If no active salary found, show user's most recently active one.
  defp data(%User{} = user) do
    salary = Payroll.get_user_salary(user)

    %{
      name: user.name,
      salary: show_salary(salary)
    }
  end

  defp show_salary(nil), do: "no salary found"

  defp show_salary(%Salary{} = salary) do
    %{
      amount: salary.amount,
      currency: salary.currency,
      active: salary.active
    }
  end
end
