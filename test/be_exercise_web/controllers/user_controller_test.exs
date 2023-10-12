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

    test "lists all users with their salaries ordered by creation time by default", %{conn: conn} do
      user_fixture(%{name: "dean"})
      bill = user_fixture(%{name: "bill"})
      aron = user_fixture(%{name: "aron"})
      carl = user_fixture(%{name: "carl"})

      salary_fixture(bill, %{amount: 100, currency: :gbp})

      salary_fixture(aron, %{amount: 200, currency: :eur})

      salary_fixture(aron, %{
        amount: 300,
        currency: :usd,
        active: false,
        last_active: ~U[2023-10-11 02:30:00Z]
      })

      salary_fixture(carl, %{
        amount: 600,
        currency: :usd,
        active: false,
        last_active: ~U[2023-10-09 02:30:00Z]
      })

      salary_fixture(carl, %{
        amount: 400,
        currency: :usd,
        active: false,
        last_active: ~U[2023-10-11 02:30:00Z]
      })

      # Most recently active salary
      salary_fixture(carl, %{
        amount: 500,
        currency: :eur,
        active: false,
        last_active: ~U[2023-10-12 02:30:00Z]
      })

      conn = get(conn, ~p"/users")

      assert json_response(conn, 200)["data"] ==
               [
                 %{"name" => "dean", "salary" => "no salary found"},
                 %{
                   "name" => "bill",
                   "salary" => %{"active" => true, "amount" => 100, "currency" => "gbp"}
                 },
                 %{
                   "name" => "aron",
                   "salary" => %{"active" => true, "amount" => 200, "currency" => "eur"}
                 },
                 %{
                   "name" => "carl",
                   "salary" => %{"active" => false, "amount" => 500, "currency" => "eur"}
                 }
               ]
    end

    test "lists all users ordered by users' name", %{conn: conn} do
      user_fixture(%{name: "dean"})
      carl = user_fixture(%{name: "carl"})
      aron = user_fixture(%{name: "aron"})
      bill = user_fixture(%{name: "bill"})

      salary_fixture(carl, %{amount: 300, currency: :eur})
      salary_fixture(aron, %{amount: 200, currency: :eur})
      salary_fixture(bill, %{amount: 100, currency: :gbp})

      conn = get(conn, ~p"/users", order_by: ["name"])

      assert json_response(conn, 200)["data"] ==
               [
                 %{
                   "name" => "aron",
                   "salary" => %{"active" => true, "amount" => 200, "currency" => "eur"}
                 },
                 %{
                   "name" => "bill",
                   "salary" => %{"active" => true, "amount" => 100, "currency" => "gbp"}
                 },
                 %{
                   "name" => "carl",
                   "salary" => %{"active" => true, "amount" => 300, "currency" => "eur"}
                 },
                 %{"name" => "dean", "salary" => "no salary found"}
               ]
    end

    test "lists users using pagination", %{conn: conn} do
      aron = user_fixture(%{name: "aron"})
      bill = user_fixture(%{name: "bill"})
      carl = user_fixture(%{name: "carl"})
      dean = user_fixture(%{name: "dean"})
      evan = user_fixture(%{name: "evan"})

      salary_fixture(aron, %{amount: 100, currency: :eur})
      salary_fixture(bill, %{amount: 200, currency: :gbp})
      salary_fixture(carl, %{amount: 300, currency: :eur})
      salary_fixture(dean, %{amount: 400, currency: :jpy})
      salary_fixture(evan, %{amount: 500, currency: :czk})

      conn = get(conn, ~p"/users", page: 1, page_size: 2)

      assert json_response(conn, 200)["data"] ==
               [
                 %{
                   "name" => "aron",
                   "salary" => %{"active" => true, "amount" => 100, "currency" => "eur"}
                 },
                 %{
                   "name" => "bill",
                   "salary" => %{"active" => true, "amount" => 200, "currency" => "gbp"}
                 }
               ]

      conn = get(conn, ~p"/users", page: 2, page_size: 2)

      assert json_response(conn, 200)["data"] ==
               [
                 %{
                   "name" => "carl",
                   "salary" => %{"active" => true, "amount" => 300, "currency" => "eur"}
                 },
                 %{
                   "name" => "dean",
                   "salary" => %{"active" => true, "amount" => 400, "currency" => "jpy"}
                 }
               ]

      conn = get(conn, ~p"/users", page: 3, page_size: 2)

      assert json_response(conn, 200)["data"] ==
               [
                 %{
                   "name" => "evan",
                   "salary" => %{"active" => true, "amount" => 500, "currency" => "czk"}
                 }
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
      _jim = user_fixture(%{name: "jim"})

      salary_fixture(john, %{amount: 100, currency: :gbp})
      salary_fixture(josh, %{amount: 200, currency: :eur})
      salary_fixture(josh, %{amount: 300, currency: :jpy, active: false})
      salary_fixture(jack, %{amount: 400, currency: :eur, active: false})

      conn = post(conn, ~p"/invite-users")
      assert json_response(conn, 200)["data"] == "Invited 2 users."
    end
  end
end
