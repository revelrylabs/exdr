# XDR

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `xdr` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:xdr, "~> 0.1.0"}
  ]
end
```


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/xdr](https://hexdocs.pm/xdr).


CURRENT STATUS:
* looks like union is working, though I may want to go back and refactor b/c we're storing
  types and values in separate places right now, while the underlying structs can accommodate
  both type and value in one place. maybe rename
    switches -> switch_options
    switch_type and switch_value -> switch
    remove value and store it in the correct arm
