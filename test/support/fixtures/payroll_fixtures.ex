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
    case attrs
         |> Enum.into(%{
           name: "John Doe"
         })
         |> Payroll.create_user() do
      {:ok, user} -> user
      {:error, reason} -> raise "Failed to create user fixture: #{inspect(reason)}"
    end
  end

  @doc """
  Generate a salary.
  """
  def salary_fixture(user, attrs \\ %{}) do
    case attrs
         |> Enum.into(%{
           amount: 42,
           currency: :czk,
           active: true,
           user_id: user.id
         })
         |> Payroll.create_salary() do
      {:ok, salary} -> salary
      {:error, reason} -> raise "Failed to create salary fixture: #{inspect(reason)}"
    end
  end
end
