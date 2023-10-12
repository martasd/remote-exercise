defmodule BeExercise.Payroll.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias BeExercise.Payroll.Salary

  @derive {
    Flop.Schema,
    filterable: [:name],
    sortable: [:name, :inserted_at],
    pagination_types: [:page],
    default_order: %{
      order_by: [:inserted_at],
      order_directions: [:asc]
    }
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime_usec]
  schema "users" do
    field(:name, :string)

    has_one(:salary, Salary, where: [active: true])
    has_many(:salaries, Salary)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint([:name])
  end
end
