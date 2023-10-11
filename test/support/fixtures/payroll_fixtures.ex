defmodule BeExercise.PayrollFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BeExercise.Payroll` context.
  """
  alias BeExercise.Payroll

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        name: "John Doe"
      })
      |> Payroll.create_user()

    user
  end

  @doc """
  Generate a salary.
  """
  def salary_fixture(user, attrs \\ %{}) do
    {:ok, salary} =
      attrs
      |> Enum.into(%{
        amount: 42,
        currency: :czk,
        active: true,
        user_id: user.id
      })
      |> Payroll.create_salary()

    salary
  end
end
