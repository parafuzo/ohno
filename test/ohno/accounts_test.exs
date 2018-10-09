defmodule Ohno.AccountsTest do
  use Ohno.DataCase, async: true

  alias Ohno.Accounts
  alias Ohno.Accounts.GithubUser

  describe to_string(Accounts) do
    setup do
      read_file_event!("push_commit")
    end

    test "add user from params", ~m{sender} do
      {:ok, %GithubUser{} = user} = Accounts.user_from_sender(sender)
      assert user.node_id == jq!(sender, ".node_id")
      assert user.login == jq!(sender, ".login")
      assert user.html_url == jq!(sender, ".html_url")
      assert user.avatar_url == jq!(sender, ".avatar_url")
    end

    test "update user if exist", ~m{sender} do
      {:ok, %GithubUser{} = user} = Accounts.user_from_sender(sender)

      new_login = Faker.Internet.user_name()
      {:ok, %GithubUser{} = updated} = sender
        |> Map.put("login", new_login)
        |> Accounts.user_from_sender

      assert user.id == updated.id
      assert updated.login == new_login
    end

    test "fail to create a user with invalid params" do
      error = {:sender, {"invalid sender to create user", sender: %{}}}
      {:error, ^error} = Accounts.user_from_sender(%{})
    end
  end
end
