defmodule CustomXDR do
  use XDR

  define_type("Number", Int)
  define_type("Name", VariableOpaque, 100)

  define_type(
    "TestScore",
    Struct,
    name: "Name",
    score: "Number",
    grade: build_type(VariableOpaque)
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
end

defmodule XDRUsingTest do
  use ExUnit.Case

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
               grade: %XDR.Type.VariableOpaque{type_name: "VariableOpaque"}
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
        score: 42,
        grade: "F"
      )

    %XDR.Type.Struct{fields: [name: name, score: score, grade: grade]} = test_score
    %XDR.Type.Int{value: 42} = score
    %XDR.Type.VariableOpaque{value: "Jason"} = name
    %XDR.Type.VariableOpaque{value: "F"} = grade
  end

  test "builds a person" do
    {:ok, person} =
      CustomXDR.build_value(
        "Person",
        name: "Jason",
        age: 42,
        address: [
          nick_name: "Home",
          street: "4200 Canal St",
          city: "New Orleans",
          state: "LA",
          postal_code: "70119"
        ]
      )

    city = person.fields[:address].fields[:city].value
    assert city == "New Orleans"

    {:ok, encoding} = CustomXDR.encode(person)
    {:ok, decoded} = CustomXDR.decode("Person", encoding)
    assert decoded == person
  end
end
