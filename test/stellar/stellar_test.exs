defmodule StellarXDRTest do
  @moduledoc """
  Test the generated Stellar types
  """
  use ExUnit.Case
  alias Stellar.XDR, as: StellarXDR

  setup_all do
    pubkey_one = File.read!(Path.join(__DIR__, '../fixtures/stellar/pubkey_01'))
    pubkey_two = File.read!(Path.join(__DIR__, './../fixtures/stellar/pubkey_02'))
    trx_encoded = File.read!(Path.join(__DIR__, './../fixtures/stellar/transaction.xdr'))
    %{
      pubkey_one: pubkey_one,
      pubkey_two: pubkey_two,
      trx_encoded: trx_encoded,
    }
  end

  test "can create a transaction", context do
    %{pubkey_one: pubkey_one, pubkey_two: pubkey_two, trx_encoded: trx_encoded} = context
    source_acct = {:public_key_type_ed25519, pubkey_one}
    dest_acct = {:public_key_type_ed25519, pubkey_two}

    assert {:ok, trx} = StellarXDR.build_value("Transaction",
      source_account: source_acct,
      fee: 100,
      seq_num: 2_319_149_195_853_854 + 1,
      time_bounds: nil,
      memo: {:memo_none, nil},
      operations: [
        [
          source_account: nil,
          body: {:payment, [
            destination: dest_acct,
            asset: {:asset_type_native, nil},
            amount: 1000
          ]}
        ]
      ],
      ext: {0, nil}
    )
    {:ok, encoded} = StellarXDR.encode(trx)
    {:ok, decoded} = StellarXDR.decode("Transaction", encoded)
    assert decoded == trx
    assert encoded == trx_encoded
  end
end
