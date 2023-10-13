defmodule BeExercise.Payroll do
  @moduledoc """
  The Payroll context.
  """
  import Ecto.Query, warn: false

  alias BeExercise.Payroll.Salary
  alias BeExercise.Payroll.User
  alias BeExercise.Repo

  require Logger

  @doc """
  Returns the list of users ordered by name. Supports partial filtering by name.
  """
  @spec list_users(%{name: String.t()} | %{}) ::
          {:ok, [User.t()]} | {:params_errors, [{atom(), term()}]}
  def list_users(params) do
    user_query = preload(User, :salary)
    params = parse_params(params)

    case Flop.validate_and_run(user_query, params, for: BeExercise.Payroll.User) do
      {:ok, {users, _meta}} ->
        {:ok, users}

      {:error, meta} ->
        {:params_errors, meta.errors}
    end
  end

  # Parse the name filter from params
  defp parse_params(params) do
    case Map.pop(params, "name") do
      {nil, params} ->
        params

      {name, params} ->
        Map.put(params, "filters", [%{"field" => "name", "op" => "ilike", "value" => name}])
    end
  end

  @doc """
  Invite all users with an active salary by sending an email.
  """
  @spec invite_users() :: {:ok, integer()}
  def invite_users() do
    Repo.transaction(
      fn ->
        User
        |> join(:left, [u], s in assoc(u, :salaries))
        |> where([u, s], s.active)
        |> Repo.stream()
        |> Enum.reduce(0, fn %User{name: name}, num_invited ->
          case BEChallengex.send_email(%{name: name}) do
            {:error, msg} ->
              Logger.error("Could not send email to user #{name}. Reason: #{msg}")
              num_invited

            {:ok, _name} ->
              num_invited + 1
          end
        end)
      end,
      timeout: :infinity
    )
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.
  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Creates a salary.
  """
  def create_salary(attrs \\ %{}) do
    %Salary{}
    |> Salary.changeset(attrs)
    |> Repo.insert()
  end
end
