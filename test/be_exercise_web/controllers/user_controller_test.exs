defmodule BeExerciseWeb.UserControllerTest do
  use BeExerciseWeb.ConnCase

  import BeExercise.PayrollFixtures

  setup %{conn: conn} do
    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")

    {:ok, conn: conn}
  end

  describe "index" do
    test "returns no data when there are no users", %{conn: conn} do
      conn = get(conn, ~p"/users")
      assert json_response(conn, 200)["data"] == []
    end

    test "lists all created users with their active salaries ordered by name", %{conn: conn} do
      abe = user_fixture(%{name: "abe"})
      bill = user_fixture(%{name: "bill"})
      carl = user_fixture(%{name: "carl"})
      user_fixture(%{name: "dean"})

      salary_fixture(abe, %{amount: 100, currency: :gbp})

      salary_fixture(bill, %{amount: 200, currency: :eur})

      salary_fixture(bill, %{
        amount: 300,
        currency: :usd,
        active: false,
        last_active: ~U[2023-10-11 02:30:00Z]
      })

      salary_fixture(carl, %{
        amount: 400,
        currency: :usd,
        active: false,
        last_active: ~U[2023-10-11 02:30:00Z]
      })

      salary_fixture(carl, %{
        amount: 500,
        currency: :eur,
        active: false,
        last_active: ~U[2023-10-12 02:30:00Z]
      })

      conn = get(conn, ~p"/users")

      assert json_response(conn, 200)["data"] ==
               [
                 %{
                   "name" => "abe",
                   "salary" => %{"active" => true, "amount" => 100, "currency" => "gbp"}
                 },
                 %{
                   "name" => "bill",
                   "salary" => %{"active" => true, "amount" => 200, "currency" => "eur"}
                 },
                 %{
                   "name" => "carl",
                   "salary" => %{"active" => false, "amount" => 500, "currency" => "eur"}
                 },
                 %{"name" => "dean", "salary" => "no salary found"}
               ]
    end

    test "filters users by partial name", %{conn: conn} do
      john = user_fixture(%{name: "john"})
      josh = user_fixture(%{name: "josh"})
      jack = user_fixture(%{name: "jack"})

      salary_fixture(john, %{amount: 100, currency: :gbp})
      salary_fixture(josh, %{amount: 200, currency: :eur})
      salary_fixture(jack, %{amount: 300, currency: :eur})

      conn = get(conn, ~p"/users", name: "jo")

      assert json_response(conn, 200)["data"] ==
               [
                 %{
                   "name" => "john",
                   "salary" => %{"active" => true, "amount" => 100, "currency" => "gbp"}
                 },
                 %{
                   "name" => "josh",
                   "salary" => %{"active" => true, "amount" => 200, "currency" => "eur"}
                 }
               ]
    end
  end

  describe "invite" do
    test "does not send any email if there are no users", %{conn: conn} do
      conn = post(conn, ~p"/invite-users")
      assert json_response(conn, 200)["data"] == "Invited 0 users."
    end

    test "sends email only to users with active salaries", %{conn: conn} do
      john = user_fixture(%{name: "john"})
      josh = user_fixture(%{name: "josh"})
      jack = user_fixture(%{name: "jack"})

      salary_fixture(john, %{amount: 100, currency: :gbp})
      salary_fixture(josh, %{amount: 200, currency: :eur})
      salary_fixture(jack, %{amount: 300, currency: :eur, active: false})

      conn = post(conn, ~p"/invite-users")
      assert json_response(conn, 200)["data"] == "Invited 2 users."
    end
  end
end
