# Backend code exercise

Hi there!

If you're reading this, it means you're now at the coding exercise step of the engineering hiring process. We're really happy that you made it here and super appreciative of your time!

In this exercise you're asked to create a Phoenix application and implement some features on it.

> 💡 The Phoenix application is an API

If you have any questions, don't hesitate to reach out directly to [code_exercise@remote.com](mailto:code_exercise@remote.com).

## Expectations

- It should be production-ready code - the code will show us how you ship things to production and be a mirror of your craft.
  - Just to be extra clear: We don't actually expect you to deploy it somewhere or build a release. It's meant as a statement regarding the quality of the solution.
- Take whatever time you need - we won’t look at start/end dates, you have a life besides this and we respect that! Moreover, if there is something you had to leave incomplete or there is a better solution you would implement but couldn’t due to personal time constraints, please try to walk us through your thought process or any missing parts, using the “Implementation Details” section below.

## What will you build

A phoenix app with 2 endpoints to manage users.

We don’t expect you to implement authentication and authorization but your final solution should assume it will be deployed to production and the data will be consumed by a Single Page Application that runs on customer’s browsers.

To save you some setup time we prepared this repo with a phoenix app that you can use to develop your solution. Alternatively, you can also generate a new phoenix project.

## Requirements

- We should store users and salaries in PostgreSQL database.
- Each user has a name and can have multiple salaries.
- Each salary should have a currency.
- Every field defined above should be required.
- One user should at most have 1 salary active at a given time.
- All endpoints should return JSON.
- A readme file with instructions on how to run the app.

### Seeding the database

- `mix ecto.setup` should create database tables, and seed the database with 20k users, for each user it should create 2 salaries with random amounts/currencies.
- The status of each salary should also be random, allowing for users without any active salary and for users with just 1 active salary.
- Must use 4 or more different currencies. Eg: USD, EUR, JPY and GBP.
- Users’ name can be random or populated from the result of calling list_names/0 defined in the following library: [https://github.com/remotecom/be_challengex](https://github.com/remotecom/be_challengex)

### Tasks

1. 📄 Implement an endpoint to provide a list of users and their salaries
    - Each user should return their `name` and active `salary`.
    - Some users might have been offboarded (offboarding functionality should be considered out of the scope for this exercise) so it’s possible that all salaries that belong to a user are inactive. In those cases, the endpoint is supposed to return the salary that was active most recently.
    - This endpoint should support filtering by partial user name and order by user name.
    - Endpoint: `GET /users`

2. 📬 Implement an endpoint that sends an email to all users with active salaries
    - The action of sending the email must use Remote’s Challenge lib: [https://github.com/remotecom/be_challengex](https://github.com/remotecom/be_challengex)
    - ⚠️ This library doesn’t actually send any email so you don’t necessarily need internet access to work on your challenge.
    - Endpoint: `POST /invite-users`

### When you're done

- You can use the "Implementation Details" section to explain some decisions/shortcomings of your implementation.
- Open a Pull Request in this repo and send the link to [code_exercise@remote.com](mailto:code_exercise@remote.com).
- You can also send some feedback about this exercise. Was it too big/short? Boring? Let us know!

---

## How to run the existing application

You will need the following installed:

- Elixir >= 1.14
- Postgres >= 14.5

Check out the `.tool-versions` file for a concrete version combination we ran the application with. Using [asdf](https://github.com/asdf-vm/asdf) you could install their plugins and them via `asdf install`.

### To start your Phoenix server

- Run `mix setup` to install, setup dependencies and setup the database
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.


## How to execute queries

* List all users

      curl -i "http://localhost:4000/users"

* List all users whose name contains "smith" and order them alphabetically by full name

      curl -i "http://localhost:4000/users?name=smith&order_by[]=name"

* List the first ten users

      curl -i "http://localhost:4000/users?page_size=10&page=1"

* Invite all active users

      curl -i -X POST "http://localhost:4000/invite-users"


## How to test

All tests can be executed by running

      mix test

To run the user controller tests, execute

      mix test test/be_exercise_web/controllers/user_controller_test.exs

## Implementation details

### Schema

From the task description it was clear that we need two schemas: `users` and `salaries`.
* For the salary `amount` field I used integer type to avoid rounding issues caused by floating point arithmetic.
* When a user is offboarded, all her salaries are inactive and we need to be able to return the most recently active one. To do so, I added the timestamp field `last_active`, which I assume is set when an active salary gets deactivated.
* A user `has_many` salaries and thus each salary `belongs_to` a user. Besides that, each user `has_one` salary which is active. An offboarded user's `salary` field is `nil` since all her salaries are inactive.
* To invite a user, we need to uniquely identify a user by her name, so we use unique constraint on the `name` field.

### Seeding the database

I found that BEChallengex contains a list of 646 names. Since I needed to seed the database with 20k unique users, I opted to use `Faker` library which has a longer list of first names and last names which can be combined to form a unique full name. The seeding function `seed_users/1` stops only when 20 000 unique users are created.

### API

#### Listing users with salaries (`GET /users`)

Here we need to check whether a user has an active salary. If so, we return it. Otherwise, we run a query to retrieve the most recently active salary. When a user has no salary at all, we print an informative message.

By default, the endpoint returns all users ordered ascendingly by `inserted_at` timestamp. They can be filtered by partial name and ordered by name. Initially, I implemented my own filtering and ordering. Since we rarely want to query all users in the real world, I used the excellent `Flop` library to enable paginating the query results.  `Flop` supports filtering and sorting as well with intuitive configuration, so I decided to take advantage of it replacing my own implementation, which allows for more flexibility in adding filtering and ordering for additional fields in the future.

To aid the performance of the queries, I've created the following database indexes:
* unique index on users' `name` field
* index on salaries' `user_id` foreign key
* partial unique index on user's active `salary`, which enforces the constraint that at most one active salary can exist for each user

#### Inviting users (`POST /invite-users`)

Since the users table can be very large, I used `Repo.stream/1` to retrieve user records lazily. Furthermore, sending an email can be executed independently for each user, so we can take advantage of Elixir's concurrency here. Compared to sequential approach, using `Task.async_stream/3` sped up the query execution for 19 966 invited users from about 34s to about 5s. 💪
