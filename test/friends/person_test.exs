defmodule PersonTest do
  use LearnEcto.DataCase
  alias LearnEcto.Repo
  alias Friends.Person

  test "Can insert a person" do
    person = %Friends.Person{}
    assert {:ok, _} = Repo.insert(person)
  end

  test "can validate a person" do
    person = %Person{}
    changeset = Person.changeset(person, %{})

    assert {:error, %{action: :insert, errors: [first_name: _, last_name: _], valid?: false}} =
             Repo.insert(changeset)
  end

  test "can insert a bunch of people" do
    people = [
      %Person{first_name: "Ryan", last_name: "Bigg", age: 28},
      %Person{first_name: "John", last_name: "Smith", age: 27},
      %Person{first_name: "Jane", last_name: "Smith", age: 26}
    ]

    Enum.each(people, fn person -> Repo.insert(person) end)

    assert Person |> Repo.all() |> Enum.count() == 3
  end

  test "can query first" do
    # we need to reset id's to make sure we can select with id 1
    Repo.query("ALTER SEQUENCE people_id_seq RESTART")

    ryan = %Person{first_name: "Ryan", last_name: "Bigg", age: 28}

    people = [
      ryan,
      %Person{first_name: "John", last_name: "Smith", age: 27},
      %Person{first_name: "Jane", last_name: "Smith", age: 26}
    ]

    Enum.each(people, fn person -> Repo.insert(person) end)

    assert Person |> Repo.all() |> Enum.count() == 3

    exptected_query = %Ecto.Query{
      assocs: [],
      distinct: nil,
      from: {"people", Friends.Person},
      group_bys: [],
      havings: [],
      joins: [],
      lock: nil,
      offset: nil,
      prefix: nil,
      preloads: [],
      select: nil,
      sources: nil,
      updates: [],
      wheres: [],
      limit: %Ecto.Query.QueryExpr{
        expr: 1,
        params: []
      },
      order_bys: []
    }

    # two ways of building a query
    assert expected_query = Person |> Ecto.Query.first()
    assert expected_query = Ecto.Query.from(p in Person, order_by: [asc: p.id], limit: 1)

    assert ryan = Person |> Ecto.Query.first() |> Repo.one()

    assert ryan = expected_query |> Repo.one()

    # fetch all
    assert Person |> Repo.all() |> Enum.count() == 3

    # fetch one by id
    assert Person |> Repo.get(1) == ryan

    # fetch by attribute
    assert Person |> Repo.get_by(first_name: "Ryan") == ryan

    # filter results
    assert Person |> Ecto.Query.where(last_name: "Smith") |> Repo.all() |> Enum.count() == 2

    # query syntax version
    # assert Ecto.Query.from(p in Person, where: p.last_name == "Smith")
    #        |> Repo.all()
    #        |> Enum.count() == 2

    last_name = "Smith"
    Person |> Ecto.Query.where(last_name: ^last_name) |> Repo.all()
  end

  test "composing queries" do
    query = Friends.Person |> Ecto.Query.where(last_name: "Smith")

    query = query |> Ecto.Query.where(first_name: "Jane")

    assert %Ecto.Query{wheres: wheres} = query

    assert wheres |> Enum.count() == 2
  end

  test "updating" do
    Repo.query("ALTER SEQUENCE people_id_seq RESTART")

    ryan = %Person{first_name: "Ryan", last_name: "Bigg", age: 28}

    people = [
      ryan,
      %Person{first_name: "John", last_name: "Smith", age: 27},
      %Person{first_name: "Jane", last_name: "Smith", age: 26}
    ]

    Enum.each(people, &Repo.insert/1)

    person = Person |> Ecto.Query.first() |> Repo.one()

    assert person.age == ryan.age

    changeset = Person.changeset(person, %{age: 29})

    assert {:ok, _} = Repo.update(changeset)

    assert person.age == ryan.age

    person = Person |> Ecto.Query.first() |> Repo.one()

    assert person.age == 29
  end

  test "deleting" do
    Repo.query("ALTER SEQUENCE people_id_seq RESTART")
    ryan = %Person{first_name: "Ryan", last_name: "Bigg", age: 28}
    people = [
      ryan,
      %Person{first_name: "John", last_name: "Smith", age: 27},
      %Person{first_name: "Jane", last_name: "Smith", age: 26}
    ]
    Enum.each(people, &Repo.insert/1)
    person = Repo.get(Person, 1)
    Repo.delete(person)
    assert Person |> Repo.all() |> Enum.count() == 2
  end

  test "deleting by struct" do
    # delete is for a single record where we know its pk
    Repo.query("ALTER SEQUENCE people_id_seq RESTART")
    ryan = %Person{first_name: "Ryan", last_name: "Bigg", age: 28}
    people = [
      ryan,
      %Person{first_name: "John", last_name: "Smith", age: 27},
      %Person{first_name: "Jane", last_name: "Smith", age: 26}
    ]
    Enum.each(people, &Repo.insert/1)
    Repo.delete(%Person{id: 1})
    assert Person |> Repo.all() |> Enum.count() == 2
  end
end
