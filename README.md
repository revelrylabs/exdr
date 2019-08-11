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


Ideas for simplifying things:
- Remove the ! functions
- Create a default implementation (this will be most useful if we can mix & match, deriving only _some_ functions)
- Does it make sense to skip steps? We have build_type -> build_value -> encode.... I think we need all of those steps

- We can remove the ! (or the non-!) items from the protocol and then create the other version _only_ at the top level API (XDR proper and anything that _uses_ it)

Ideas for improvement:
- Error struct for richer debugging (filed an issue)

NOTES:
Worked on adapting xdrgen to work with this stuff, and one thing that strikes me
is that maybe the custom type should be a real struct instead of just a binary???
If we could do `build_type(Custom, custom_type_name)` then we could treat it more like the others
(or something like that?)

