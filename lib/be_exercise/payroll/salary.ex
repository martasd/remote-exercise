defmodule BeExercise.Payroll.Salary do
  use Ecto.Schema
  import Ecto.Changeset

  alias BeExercise.Payroll.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "salaries" do
    field(:amount, :integer)
    field(:currency, Ecto.Enum, values: [:czk, :usd, :eur, :gbp, :jpy])
    field(:last_active, :utc_datetime_usec)

    belongs_to(:user, User)

    timestamps()
  end

  @doc false
  def changeset(salary, attrs) do
    salary
    |> cast(attrs, [:amount, :currency, :last_active, :user_id])
    |> validate_required([:amount, :currency, :last_active, :user_id])
  end
end
