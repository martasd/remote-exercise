defmodule BeExercise.Repo do
  use Ecto.Repo,
    otp_app: :be_exercise,
    adapter: Ecto.Adapters.Postgres
end
