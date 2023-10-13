defmodule BeExercise.Payroll.Salary do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias BeExercise.Payroll.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime_usec]
  schema "salaries" do
    field(:amount, :integer)
    field(:currency, Ecto.Enum, values: [:czk, :usd, :eur, :gbp, :jpy])
    field(:active, :boolean)
    field(:last_active, :utc_datetime_usec)

    belongs_to(:user, User)

    timestamps()
  end

  @doc false
  def changeset(salary, attrs) do
    salary
    |> cast(attrs, [:amount, :currency, :active, :last_active, :user_id])
    |> validate_required([:amount, :currency, :active, :user_id])
  end
end
