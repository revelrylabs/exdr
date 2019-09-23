defmodule StellarXDRTest do
  @moduledoc """
  Test the generated Stellar types
  """
  use ExUnit.Case
  alias Stellar.XDR, as: StellarXDR

  setup_all do
    pubkey_one = File.read!(Path.join(__DIR__, '../support/stellar/pubkey_01'))
    pubkey_two = File.read!(Path.join(__DIR__, './../support/stellar/pubkey_02'))
    %{
      pubkey_one: pubkey_one,
      pubkey_two: pubkey_two
    }
  end

  test "can create a transaction", %{pubkey_one: pubkey_one, pubkey_two: pubkey_two} do
    source_acct = {:public_key_type_ed25519, pubkey_one}
    dest_acct = {:public_key_type_ed25519, pubkey_two}

    assert {:ok, trx} = StellarXDR.build_value("Transaction",
      source_account: source_acct,
      fee: 100,
      seq_num: 2_319_149_195_853_854,
      time_bounds: nil,
      memo: {:memo_none, nil},
      operations: [
        [
          source_account: source_acct,
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
  end
end
