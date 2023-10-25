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
    Repo.transaction(fn ->
      User
      |> join(:left, [u], s in assoc(u, :salaries))
      |> where([u, s], s.active)
      |> Repo.stream()
      |> Task.async_stream(fn %User{name: name} ->
        case BEChallengex.send_email(%{name: name}) do
          {:error, msg} ->
            Logger.error("Could not send email to user #{name}. Reason: #{msg}")
            0

          {:ok, _name} ->
            1
        end
      end)
      |> Enum.reduce(0, fn {:ok, num}, acc -> num + acc end)
    end)
  end

  @doc """
  Creates a user.
  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a salary.
  """
  def create_salary(attrs \\ %{}) do
    %Salary{}
    |> Salary.changeset(attrs)
    |> Repo.insert()
  end

  def get_user_salary(%User{} = user) do
    case user.salary do
      %Salary{} = salary ->
        salary

      nil ->
        Salary
        |> where(user_id: ^user.id)
        |> last(:last_active)
        |> Repo.one()
    end
  end
end
