defmodule CustomXDR do
  use XDR

  define_type("Number", :int)
  define_type("Name", :variable_opaque, 100)

  define_type(
    "TestScore",
    :struct,
    name: "Name",
    score: "Number",
    grade: build_type(:variable_opaque)
  )

  define_type(
    "Person",
    :struct,
    age: "Number",
    name: "Name",
    address:
      build_type(
        :struct,
        nick_name: "Name",
        street: build_type(:variable_opaque),
        city: build_type(:variable_opaque),
        state: build_type(:variable_opaque),
        postal_code: build_type(:variable_opaque)
      )
  )

  def get_types do
    @custom_types
  end
end

defmodule XDRUsingTest do
  use ExUnit.Case

  test "registers types properly" do
    assert %{"Number" => %XDR.Type.Int{}} = CustomXDR.get_types()
    assert %{"Name" => %XDR.Type.VariableOpaque{max_len: 100}} = CustomXDR.get_types()
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
    person_type = CustomXDR.resolve_type!("Person")
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
    person =
      CustomXDR.build_value!(
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
  end
end
