defmodule CustomXDR do
  use XDR.Base

  define_type("Number", Int)
  define_type("Name", VariableOpaque, 100)
  define_type("TheMagicNumber", Const, 42)

  define_type(
    "TestScore",
    Struct,
    name: "Name",
    score: "Number",
    grade: build_type(VariableOpaque),
    nothing: build_type(Void)
  )

  define_type(
    "Person",
    Struct,
    age: "Number",
    name: "Name",
    address:
      build_type(
        Struct,
        nick_name: "Name",
        street: build_type(VariableOpaque),
        city: build_type(VariableOpaque),
        state: build_type(VariableOpaque),
        postal_code: build_type(VariableOpaque)
      )
  )

  define_type(
    "Company",
    Struct,
    name: "Name"
  )

  define_type(
    "FiveNames",
    Array,
    type: "Name",
    size: 5
  )

  define_type(
    "SomeNames",
    VariableArray,
    type: "Name",
    max_size: 100
  )

  define_type(
    "AccountType",
    Enum,
    account_type_person: 0,
    account_type_company: 1
  )

  define_type(
    "AccountOwner",
    Union,
    switch_name: :type,
    switch_type: "AccountType",
    switches: [
      account_type_person: :person,
      account_type_company: :company
    ],
    arms: [
      person: "Person",
      company: "Company"
    ]
  )

  define_type(
    "AccountOwnerTwo",
    Union,
    switch_name: :type,
    switch_type: build_type(Int),
    switches: [
      {0, :person},
      {1, :company},
      {2, Void}
    ],
    arms: [
      person: "Person",
      company: "Company"
    ]
  )

  define_type(
    "OptionalAccountOwner",
    Optional,
    "AccountOwner"
  )
end

defmodule XDRUsingTest do
  use ExUnit.Case

  @address_value [
    nick_name: "Home",
    street: "4200 Canal St",
    city: "New Orleans",
    state: "LA",
    postal_code: "70119"
  ]

  test "registers types properly" do
    assert %{"Number" => %XDR.Type.Int{}} = CustomXDR.custom_types()
    assert %{"Name" => %XDR.Type.VariableOpaque{max_len: 100}} = CustomXDR.custom_types()
    assert CustomXDR.resolve_type!("Number") == %XDR.Type.Int{type_name: "Number"}

    assert CustomXDR.resolve_type!("Name") == %XDR.Type.VariableOpaque{
             max_len: 100,
             type_name: "Name"
           }
  end

  test "resolves a test score" do
    assert CustomXDR.resolve_type!("TestScore") == %XDR.Type.Struct{
             fields: [
               name: %XDR.Type.VariableOpaque{max_len: 100, type_name: "Name"},
               score: %XDR.Type.Int{type_name: "Number"},
               grade: %XDR.Type.VariableOpaque{type_name: "VariableOpaque"},
               nothing: %XDR.Type.Void{type_name: "Void"}
             ],
             type_name: "TestScore"
           }
  end

  test "resolves a person" do
    {:ok, person_type} = CustomXDR.resolve_type("Person")
    address = person_type.fields[:address]
    %XDR.Type.VariableOpaque{type_name: "VariableOpaque"} = address.fields[:city]
  end

  test "builds a test score" do
    test_score =
      CustomXDR.build_value!(
        "TestScore",
        name: "Jason",
        score: CustomXDR.const("TheMagicNumber"),
        grade: "F",
        nothing: nil
      )

    assert %XDR.Type.Struct{fields: [name: name, score: score, grade: grade, nothing: nothing]} =
             test_score

    assert %XDR.Type.Int{value: 42} = score
    assert %XDR.Type.VariableOpaque{value: "Jason"} = name
    assert %XDR.Type.VariableOpaque{value: "F"} = grade
    assert %XDR.Type.Void{} = nothing
  end

  test "builds a person" do
    {:ok, person} =
      CustomXDR.build_value(
        "Person",
        name: "Jason",
        age: 42,
        address: @address_value
      )

    city = person.fields[:address].fields[:city].value
    assert city == "New Orleans"

    {:ok, encoding} = CustomXDR.encode(person)
    {:ok, decoded} = CustomXDR.decode("Person", encoding)
    assert decoded == person

    # NOTE: this checks that the fields stay in the order
    # given in the "person" definition (age then name)
    # even though the values are provided in a different order in build_value
    assert [
             age: 42,
             name: "Jason",
             address: @address_value
           ] = CustomXDR.extract_value!(person)
  end

  test "builds an account" do
    owner_company =
      CustomXDR.build_value!(
        "AccountOwner",
        {:account_type_company, name: "Myloft & Hey"}
      )

    encoded_owner = CustomXDR.encode!(owner_company)
    encoded_switch = XDR.Type.Int.encode(1)

    encoded_name =
      "Name"
      |> CustomXDR.build_value!("Myloft & Hey")
      |> CustomXDR.encode!()

    assert encoded_owner == encoded_switch <> encoded_name
    assert owner_company == CustomXDR.decode!("AccountOwner", encoded_owner)
  end

  test "builds an account with int switch" do
    owner_company =
      CustomXDR.build_value!(
        "AccountOwnerTwo",
        {1, name: "Myloft and Hey"}
      )

    encoded_owner = CustomXDR.encode!(owner_company)
    encoded_switch = XDR.Type.Int.encode(1)

    encoded_name =
      "Name"
      |> CustomXDR.build_value!("Myloft and Hey")
      |> CustomXDR.encode!()

    assert encoded_owner == encoded_switch <> encoded_name
    assert owner_company == CustomXDR.decode!("AccountOwnerTwo", encoded_owner)
    assert rem(byte_size(encoded_owner), 4) == 0
  end

  test "builds an account with void arm" do
    owner_company =
      CustomXDR.build_value!(
        "AccountOwnerTwo",
        {2, nil}
      )

    encoded_owner = CustomXDR.encode!(owner_company)
    encoded_switch = XDR.Type.Int.encode(2)
    encoded_name = ""

    assert encoded_owner == encoded_switch <> encoded_name
    assert owner_company == CustomXDR.decode!("AccountOwnerTwo", encoded_owner)
    assert rem(byte_size(encoded_owner), 4) == 0
  end

  test "builds an optional account owner w/o a value" do
    non_owner =
      CustomXDR.build_value!(
        "OptionalAccountOwner",
        {false, nil}
      )

    encoded_non_owner = CustomXDR.encode!(non_owner)
    assert encoded_non_owner == <<0, 0, 0, 0>>
    assert non_owner == CustomXDR.decode!("OptionalAccountOwner", encoded_non_owner)
  end

  test "builds an optional account owner with a value" do
    owner =
      CustomXDR.build_value!(
        "OptionalAccountOwner",
        {true, {:account_type_company, name: "Myloft & Hey"}}
      )

    encoded = CustomXDR.encode!(owner)
    encoded_bool = XDR.Type.Int.encode(1)
    encoded_switch = XDR.Type.Int.encode(1)

    encoded_name =
      "Name"
      |> CustomXDR.build_value!("Myloft & Hey")
      |> CustomXDR.encode!()

    assert encoded == encoded_bool <> encoded_switch <> encoded_name
    assert owner == CustomXDR.decode!("OptionalAccountOwner", encoded)
  end

  test "defines fixed arrays" do
    name_list = ~w(Marvin Arthur Ford Trillian Zaphod)
    names = CustomXDR.build_value!("FiveNames", name_list)
    encoded = CustomXDR.encode!(names)
    assert <<0, 0, 0, 6>> <> "Marvin" <> rest = encoded
    assert names == CustomXDR.decode!("FiveNames", encoded)
    assert CustomXDR.extract_value!(names) == name_list
  end

  test "defines variable-length arrays" do
    name_list = ~w(Marvin Arthur Ford Trillian Zaphod)
    names = CustomXDR.build_value!("SomeNames", name_list)
    encoded = CustomXDR.encode!(names)
    assert <<0, 0, 0, 5>> <> <<0, 0, 0, 6>> <> "Marvin" <> rest = encoded
    assert names == CustomXDR.decode!("SomeNames", encoded)
    assert CustomXDR.extract_value!(names) == name_list
  end

  test "reports errors properly with ad hoc types" do
    {:error, error} =
      CustomXDR.build_value(
        "Person",
        name: "Jason",
        age: 42,
        address: Keyword.put(@address_value, :city, 123)
      )

    assert error.path == "address.city"
    assert error.message == "value must be a binary"
    assert error.type == "VariableOpaque"
  end

  test "reports errors properly with named custom types" do
    {:error, error} =
      CustomXDR.build_value(
        "Person",
        name: "Jason",
        age: 42,
        address: Keyword.put(@address_value, :nick_name, 123)
      )

    assert error.path == "address.nick_name"
    assert error.message == "value must be a binary"
    assert error.type == "Name"
  end
end
