defmodule PersonTest do
  use ExUnit.Case

  test "Can insert a person" do
    person = %Friends.Person{}
    assert {:ok, _} = LearnEcto.Repo.insert(person)
  end

  test "can validate a person" do
    person = %Friends.Person{}
    changeset = Friends.Person.changeset(person, %{})

    assert {:error, %{action: :insert, errors: [first_name: _, last_name: _], valid?: false}} =
             LearnEcto.Repo.insert(changeset)
  end
end
