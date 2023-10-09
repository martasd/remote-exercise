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
  @spec list_users(%{name: String.t()} | %{}) :: [%User{}]
  def list_users(filters \\ %{}) do
    User
    |> filter_by_name(filters["name"])
    |> order_by(asc: :name)
    |> preload(:salary)
    |> Repo.all()
  end

  defp filter_by_name(query, nil), do: query

  defp filter_by_name(query, name) do
    # TODO: Sanitize the like query
    from(u in query, where: ilike(u.name, ^"%#{name}%"))
  end

  @doc """
  Invite all users with an active salary by sending an email.
  """
  @spec invite_users() :: {:ok, integer()}
  def invite_users() do
    Repo.transaction(
      fn ->
        User
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
  def create_user!(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert!()
  end

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
    |> Repo.insert!()
  end
end
