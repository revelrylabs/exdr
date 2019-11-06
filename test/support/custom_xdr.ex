defmodule CustomXDR do
  @moduledoc """
  Module implementing a set of custom type defs by using XDR.Base
  See `XDR.BaseTest` in `base_test.exs`
  """
  use XDR.Base

  define_type("Number", Int)
  define_type("BigFloat", Double)
  define_type("Name", VariableOpaque, 100)
  define_type("StringName", String, 100)
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
    height: build_type(Float),
    address:
      build_type(
        Struct,
        nick_name: "Name",
        street: build_type(VariableOpaque),
        city: build_type(VariableOpaque),
        state: build_type(Opaque, 2),
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
    length: 5
  )

  define_type(
    "SomeNames",
    VariableArray,
    type: "Name",
    max_length: 100
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
