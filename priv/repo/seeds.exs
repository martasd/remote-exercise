# Seed the database with 20_000 users, each with two salaries

alias BeExercise.Payroll
alias BeExercise.Payroll.User
alias Faker.Person

require Logger

defmodule SeedDatabase do
  @max 1_000_000
  @currencies Ecto.Enum.values(Payroll.Salary, :currency)
  @now DateTime.utc_now()

  def seed_users(num_users) when num_users == 20_000 do
    Logger.info("Seeded the database with 20k users.")
  end

  def seed_users(num_users) do
    name = "#{Person.first_name()} #{Person.last_name()}"

    case Payroll.create_user(%{name: name}) do
      {:ok, %User{} = user} ->
        Payroll.create_salary(%{
          amount: :rand.uniform(@max),
          currency: Enum.random(@currencies),
          active: false,
          last_active: DateTime.add(@now, -:rand.uniform(@max)),
          user_id: user.id
        })

        Payroll.create_salary(%{
          amount: :rand.uniform(@max),
          currency: Enum.random(@currencies),
          active: Enum.random([true, false]),
          last_active: DateTime.add(@now, -:rand.uniform(@max)),
          user_id: user.id
        })

        seed_users(num_users + 1)

      {:error, _} ->
        seed_users(num_users)
    end
  end
end

SeedDatabase.seed_users(0)
