defmodule PersonTest do
  use ExUnit.Case
  test "Can insert a person" do
    person = %Friends.Person{}
    assert {:ok, _} = LearnEcto.Repo.insert(person)
  end
end
