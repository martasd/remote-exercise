defmodule BeExerciseWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use BeExerciseWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: BeExerciseWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  def call(conn, {:params_errors, errors}) do
    conn
    |> put_status(:bad_request)
    |> json(%{params_errors: inspect(errors)})
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: BeExerciseWeb.ErrorJSON)
    |> render(:"404")
  end
end
