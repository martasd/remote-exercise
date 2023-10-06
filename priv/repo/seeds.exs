# Seed the database with 20_000 users, each with two salaries

alias BeExercise.Payroll

num_users = 20_000
max = 1_000_000
currencies = Ecto.Enum.values(Payroll.Salary, :currency)
now = DateTime.utc_now()

Enum.each(1..num_users, fn _i ->
  name = Faker.Person.first_name()
  user = Payroll.create_user!(%{name: name})

  Payroll.create_salary!(%{
    amount: :rand.uniform(max),
    currency: Enum.random(currencies),
    last_active: DateTime.add(now, -(:rand.uniform(max)))
    user_id: user.id
  })

  Payroll.create_salary!(%{
    amount: :rand.uniform(max),
    currency: Enum.random(currencies),
    last_active: DateTime.add(now, -(:rand.uniform(max)))
    user_id: user.id
  })

end)
