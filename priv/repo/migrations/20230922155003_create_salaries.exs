defmodule BeExercise.Repo.Migrations.CreateSalaries do
  use Ecto.Migration

  def change do
    create table(:salaries, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:amount, :integer)
      add(:currency, :string)
      add(:active, :boolean)
      add(:last_active, :utc_datetime_usec)
      add(:user_id, references(:users, on_delete: :delete_all, type: :binary_id))

      timestamps()
    end

    create(index(:salaries, [:user_id]))

    create(
      unique_index(:salaries, [:user_id],
        where: "active = TRUE",
        name: "active_salary_user_id_index"
      )
    )
  end
end
