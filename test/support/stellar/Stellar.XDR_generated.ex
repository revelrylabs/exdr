defmodule Stellar.XDR do
  @moduledoc """
  Automatically generated on 2019-09-22T09:26:14-05:00
  DO NOT EDIT or your changes may be overwritten
  """

  use XDR.Base

  comment ~S"""
  === xdr source ============================================================

      typedef opaque Value<>;

  ===========================================================================
  """
  define_type("Value", VariableOpaque)

  comment ~S"""
  === xdr source ============================================================

      struct SCPBallot
      {
          uint32 counter; // n
          Value value;    // x
      };

  ===========================================================================
  """
  define_type("ScpBallot", Struct,
    counter: "Uint32",
    value: "Value"
  )

  comment ~S"""
  === xdr source ============================================================

      enum SCPStatementType
      {
          SCP_ST_PREPARE = 0,
          SCP_ST_CONFIRM = 1,
          SCP_ST_EXTERNALIZE = 2,
          SCP_ST_NOMINATE = 3
      };

  ===========================================================================
  """
  define_type("ScpStatementType", Enum,
    scp_st_prepare: 0,
    scp_st_confirm: 1,
    scp_st_externalize: 2,
    scp_st_nominate: 3
  )

  comment ~S"""
  === xdr source ============================================================

      struct SCPNomination
      {
          Hash quorumSetHash; // D
          Value votes<>;      // X
          Value accepted<>;   // Y
      };

  ===========================================================================
  """
  define_type("ScpNomination", Struct,
    quorum_set_hash: "Hash",
    votes: build_type(VariableArray, max_length: 2147483647, type: "Value"),
    accepted: build_type(VariableArray, max_length: 2147483647, type: "Value")
  )

  comment ~S"""
  === xdr source ============================================================

      struct
              {
                  Hash quorumSetHash;       // D
                  SCPBallot ballot;         // b
                  SCPBallot* prepared;      // p
                  SCPBallot* preparedPrime; // p'
                  uint32 nC;                // c.n
                  uint32 nH;                // h.n
              }

  ===========================================================================
  """
  define_type("ScpStatementPrepare", Struct,
    quorum_set_hash: "Hash",
    ballot: "ScpBallot",
    prepared: build_type(Optional, "ScpBallot"),
    prepared_prime: build_type(Optional, "ScpBallot"),
    nc: "Uint32",
    nh: "Uint32"
  )

  comment ~S"""
  === xdr source ============================================================

      struct
              {
                  SCPBallot ballot;   // b
                  uint32 nPrepared;   // p.n
                  uint32 nCommit;     // c.n
                  uint32 nH;          // h.n
                  Hash quorumSetHash; // D
              }

  ===========================================================================
  """
  define_type("ScpStatementConfirm", Struct,
    ballot: "ScpBallot",
    n_prepared: "Uint32",
    n_commit: "Uint32",
    nh: "Uint32",
    quorum_set_hash: "Hash"
  )

  comment ~S"""
  === xdr source ============================================================

      struct
              {
                  SCPBallot commit;         // c
                  uint32 nH;                // h.n
                  Hash commitQuorumSetHash; // D used before EXTERNALIZE
              }

  ===========================================================================
  """
  define_type("ScpStatementExternalize", Struct,
    commit: "ScpBallot",
    nh: "Uint32",
    commit_quorum_set_hash: "Hash"
  )

  comment ~S"""
  === xdr source ============================================================

      union switch (SCPStatementType type)
          {
          case SCP_ST_PREPARE:
              struct
              {
                  Hash quorumSetHash;       // D
                  SCPBallot ballot;         // b
                  SCPBallot* prepared;      // p
                  SCPBallot* preparedPrime; // p'
                  uint32 nC;                // c.n
                  uint32 nH;                // h.n
              } prepare;
          case SCP_ST_CONFIRM:
              struct
              {
                  SCPBallot ballot;   // b
                  uint32 nPrepared;   // p.n
                  uint32 nCommit;     // c.n
                  uint32 nH;          // h.n
                  Hash quorumSetHash; // D
              } confirm;
          case SCP_ST_EXTERNALIZE:
              struct
              {
                  SCPBallot commit;         // c
                  uint32 nH;                // h.n
                  Hash commitQuorumSetHash; // D used before EXTERNALIZE
              } externalize;
          case SCP_ST_NOMINATE:
              SCPNomination nominate;
          }

  ===========================================================================
  """
  define_type("ScpStatementPledges", Union,
    switch_type: "ScpStatementType",
    switch_name: :type,
    switches: [
      {:scp_st_prepare, :prepare},
      {:scp_st_confirm, :confirm},
      {:scp_st_externalize, :externalize},
      {:scp_st_nominate, :nominate},
    ],
    arms: [
      prepare: "ScpStatementPrepare",
      confirm: "ScpStatementConfirm",
      externalize: "ScpStatementExternalize",
      nominate: "ScpNomination",
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      struct SCPStatement
      {
          NodeID nodeID;    // v
          uint64 slotIndex; // i

          union switch (SCPStatementType type)
          {
          case SCP_ST_PREPARE:
              struct
              {
                  Hash quorumSetHash;       // D
                  SCPBallot ballot;         // b
                  SCPBallot* prepared;      // p
                  SCPBallot* preparedPrime; // p'
                  uint32 nC;                // c.n
                  uint32 nH;                // h.n
              } prepare;
          case SCP_ST_CONFIRM:
              struct
              {
                  SCPBallot ballot;   // b
                  uint32 nPrepared;   // p.n
                  uint32 nCommit;     // c.n
                  uint32 nH;          // h.n
                  Hash quorumSetHash; // D
              } confirm;
          case SCP_ST_EXTERNALIZE:
              struct
              {
                  SCPBallot commit;         // c
                  uint32 nH;                // h.n
                  Hash commitQuorumSetHash; // D used before EXTERNALIZE
              } externalize;
          case SCP_ST_NOMINATE:
              SCPNomination nominate;
          }
          pledges;
      };

  ===========================================================================
  """
  define_type("ScpStatement", Struct,
    node_id: "NodeId",
    slot_index: "Uint64",
    pledges: "ScpStatementPledges"
  )

  comment ~S"""
  === xdr source ============================================================

      struct SCPEnvelope
      {
          SCPStatement statement;
          Signature signature;
      };

  ===========================================================================
  """
  define_type("ScpEnvelope", Struct,
    statement: "ScpStatement",
    signature: "Signature"
  )

  comment ~S"""
  === xdr source ============================================================

      struct SCPQuorumSet
      {
          uint32 threshold;
          PublicKey validators<>;
          SCPQuorumSet innerSets<>;
      };

  ===========================================================================
  """
  define_type("ScpQuorumSet", Struct,
    threshold: "Uint32",
    validators: build_type(VariableArray, max_length: 2147483647, type: "PublicKey"),
    inner_sets: build_type(VariableArray, max_length: 2147483647, type: "ScpQuorumSet")
  )

  comment ~S"""
  === xdr source ============================================================

      typedef PublicKey AccountID;

  ===========================================================================
  """
  define_type("AccountId", "PublicKey")

  comment ~S"""
  === xdr source ============================================================

      typedef opaque Thresholds[4];

  ===========================================================================
  """
  define_type("Thresholds", Opaque, 4)

  comment ~S"""
  === xdr source ============================================================

      typedef string string32<32>;

  ===========================================================================
  """
  define_type("String32", XDR.Type.String, 32)

  comment ~S"""
  === xdr source ============================================================

      typedef string string64<64>;

  ===========================================================================
  """
  define_type("String64", XDR.Type.String, 64)

  comment ~S"""
  === xdr source ============================================================

      typedef int64 SequenceNumber;

  ===========================================================================
  """
  define_type("SequenceNumber", "Int64")

  comment ~S"""
  === xdr source ============================================================

      typedef opaque DataValue<64>;

  ===========================================================================
  """
  define_type("DataValue", VariableOpaque, 64)

  comment ~S"""
  === xdr source ============================================================

      enum AssetType
      {
          ASSET_TYPE_NATIVE = 0,
          ASSET_TYPE_CREDIT_ALPHANUM4 = 1,
          ASSET_TYPE_CREDIT_ALPHANUM12 = 2
      };

  ===========================================================================
  """
  define_type("AssetType", Enum,
    asset_type_native: 0,
    asset_type_credit_alphanum4: 1,
    asset_type_credit_alphanum12: 2
  )

  comment ~S"""
  === xdr source ============================================================

      struct
          {
              opaque assetCode[4]; // 1 to 4 characters
              AccountID issuer;
          }

  ===========================================================================
  """
  define_type("AssetAlphaNum4", Struct,
    asset_code: build_type(Opaque, 4),
    issuer: "AccountId"
  )

  comment ~S"""
  === xdr source ============================================================

      struct
          {
              opaque assetCode[12]; // 5 to 12 characters
              AccountID issuer;
          }

  ===========================================================================
  """
  define_type("AssetAlphaNum12", Struct,
    asset_code: build_type(Opaque, 12),
    issuer: "AccountId"
  )

  comment ~S"""
  === xdr source ============================================================

      union Asset switch (AssetType type)
      {
      case ASSET_TYPE_NATIVE: // Not credit
          void;

      case ASSET_TYPE_CREDIT_ALPHANUM4:
          struct
          {
              opaque assetCode[4]; // 1 to 4 characters
              AccountID issuer;
          } alphaNum4;

      case ASSET_TYPE_CREDIT_ALPHANUM12:
          struct
          {
              opaque assetCode[12]; // 5 to 12 characters
              AccountID issuer;
          } alphaNum12;

          // add other asset types here in the future
      };

  ===========================================================================
  """
  define_type("Asset", Union,
    switch_type: "AssetType",
    switch_name: :type,
    switches: [
      {:asset_type_native, XDR.Type.Void},
      {:asset_type_credit_alphanum4, :alpha_num4},
      {:asset_type_credit_alphanum12, :alpha_num12},
    ],
    arms: [
      alpha_num4: "AssetAlphaNum4",
      alpha_num12: "AssetAlphaNum12",
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      struct Price
      {
          int32 n; // numerator
          int32 d; // denominator
      };

  ===========================================================================
  """
  define_type("Price", Struct,
    n: "Int32",
    d: "Int32"
  )

  comment ~S"""
  === xdr source ============================================================

      struct Liabilities
      {
          int64 buying;
          int64 selling;
      };

  ===========================================================================
  """
  define_type("Liabilities", Struct,
    buying: "Int64",
    selling: "Int64"
  )

  comment ~S"""
  === xdr source ============================================================

      enum ThresholdIndexes
      {
          THRESHOLD_MASTER_WEIGHT = 0,
          THRESHOLD_LOW = 1,
          THRESHOLD_MED = 2,
          THRESHOLD_HIGH = 3
      };

  ===========================================================================
  """
  define_type("ThresholdIndices", Enum,
    threshold_master_weight: 0,
    threshold_low: 1,
    threshold_med: 2,
    threshold_high: 3
  )

  comment ~S"""
  === xdr source ============================================================

      enum LedgerEntryType
      {
          ACCOUNT = 0,
          TRUSTLINE = 1,
          OFFER = 2,
          DATA = 3
      };

  ===========================================================================
  """
  define_type("LedgerEntryType", Enum,
    account: 0,
    trustline: 1,
    offer: 2,
    datum: 3
  )

  comment ~S"""
  === xdr source ============================================================

      struct Signer
      {
          SignerKey key;
          uint32 weight; // really only need 1byte
      };

  ===========================================================================
  """
  define_type("Signer", Struct,
    key: "SignerKey",
    weight: "Uint32"
  )

  comment ~S"""
  === xdr source ============================================================

      enum AccountFlags
      { // masks for each flag

          // Flags set on issuer accounts
          // TrustLines are created with authorized set to "false" requiring
          // the issuer to set it for each TrustLine
          AUTH_REQUIRED_FLAG = 0x1,
          // If set, the authorized flag in TrustLines can be cleared
          // otherwise, authorization cannot be revoked
          AUTH_REVOCABLE_FLAG = 0x2,
          // Once set, causes all AUTH_* flags to be read-only
          AUTH_IMMUTABLE_FLAG = 0x4
      };

  ===========================================================================
  """
  define_type("AccountFlags", Enum,
    auth_required_flag: 1,
    auth_revocable_flag: 2,
    auth_immutable_flag: 4
  )

  comment ~S"""
  === xdr source ============================================================

      const MASK_ACCOUNT_FLAGS = 0x7;

  ===========================================================================
  """
  define_type("MASK_ACCOUNT_FLAGS", Const, 0x7);

  comment ~S"""
  === xdr source ============================================================

      union switch (int v)
                  {
                  case 0:
                      void;
                  }

  ===========================================================================
  """
  define_type("AccountEntryV1Ext", Union,
    switch_type: build_type(Int),
    switch_name: :v,
    switches: [
      {0, XDR.Type.Void},
    ],
    arms: [
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      struct
              {
                  Liabilities liabilities;

                  union switch (int v)
                  {
                  case 0:
                      void;
                  }
                  ext;
              }

  ===========================================================================
  """
  define_type("AccountEntryV1", Struct,
    liabilities: "Liabilities",
    ext: "AccountEntryV1Ext"
  )

  comment ~S"""
  === xdr source ============================================================

      union switch (int v)
          {
          case 0:
              void;
          case 1:
              struct
              {
                  Liabilities liabilities;

                  union switch (int v)
                  {
                  case 0:
                      void;
                  }
                  ext;
              } v1;
          }

  ===========================================================================
  """
  define_type("AccountEntryExt", Union,
    switch_type: build_type(Int),
    switch_name: :v,
    switches: [
      {0, XDR.Type.Void},
      {1, :v1},
    ],
    arms: [
      v1: "AccountEntryV1",
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      struct AccountEntry
      {
          AccountID accountID;      // master public key for this account
          int64 balance;            // in stroops
          SequenceNumber seqNum;    // last sequence number used for this account
          uint32 numSubEntries;     // number of sub-entries this account has
                                    // drives the reserve
          AccountID* inflationDest; // Account to vote for during inflation
          uint32 flags;             // see AccountFlags

          string32 homeDomain; // can be used for reverse federation and memo lookup

          // fields used for signatures
          // thresholds stores unsigned bytes: [weight of master|low|medium|high]
          Thresholds thresholds;

          Signer signers<20>; // possible signers for this account

          // reserved for future use
          union switch (int v)
          {
          case 0:
              void;
          case 1:
              struct
              {
                  Liabilities liabilities;

                  union switch (int v)
                  {
                  case 0:
                      void;
                  }
                  ext;
              } v1;
          }
          ext;
      };

  ===========================================================================
  """
  define_type("AccountEntry", Struct,
    account_id: "AccountId",
    balance: "Int64",
    seq_num: "SequenceNumber",
    num_sub_entries: "Uint32",
    inflation_dest: build_type(Optional, "AccountId"),
    flags: "Uint32",
    home_domain: "String32",
    thresholds: "Thresholds",
    signers: build_type(VariableArray, max_length: 20, type: "Signer"),
    ext: "AccountEntryExt"
  )

  comment ~S"""
  === xdr source ============================================================

      enum TrustLineFlags
      {
          // issuer has authorized account to perform transactions with its credit
          AUTHORIZED_FLAG = 1
      };

  ===========================================================================
  """
  define_type("TrustLineFlags", Enum,
    authorized_flag: 1
  )

  comment ~S"""
  === xdr source ============================================================

      const MASK_TRUSTLINE_FLAGS = 1;

  ===========================================================================
  """
  define_type("MASK_TRUSTLINE_FLAGS", Const, 1);

  comment ~S"""
  === xdr source ============================================================

      union switch (int v)
                  {
                  case 0:
                      void;
                  }

  ===========================================================================
  """
  define_type("TrustLineEntryV1Ext", Union,
    switch_type: build_type(Int),
    switch_name: :v,
    switches: [
      {0, XDR.Type.Void},
    ],
    arms: [
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      struct
              {
                  Liabilities liabilities;

                  union switch (int v)
                  {
                  case 0:
                      void;
                  }
                  ext;
              }

  ===========================================================================
  """
  define_type("TrustLineEntryV1", Struct,
    liabilities: "Liabilities",
    ext: "TrustLineEntryV1Ext"
  )

  comment ~S"""
  === xdr source ============================================================

      union switch (int v)
          {
          case 0:
              void;
          case 1:
              struct
              {
                  Liabilities liabilities;

                  union switch (int v)
                  {
                  case 0:
                      void;
                  }
                  ext;
              } v1;
          }

  ===========================================================================
  """
  define_type("TrustLineEntryExt", Union,
    switch_type: build_type(Int),
    switch_name: :v,
    switches: [
      {0, XDR.Type.Void},
      {1, :v1},
    ],
    arms: [
      v1: "TrustLineEntryV1",
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      struct TrustLineEntry
      {
          AccountID accountID; // account this trustline belongs to
          Asset asset;         // type of asset (with issuer)
          int64 balance;       // how much of this asset the user has.
                               // Asset defines the unit for this;

          int64 limit;  // balance cannot be above this
          uint32 flags; // see TrustLineFlags

          // reserved for future use
          union switch (int v)
          {
          case 0:
              void;
          case 1:
              struct
              {
                  Liabilities liabilities;

                  union switch (int v)
                  {
                  case 0:
                      void;
                  }
                  ext;
              } v1;
          }
          ext;
      };

  ===========================================================================
  """
  define_type("TrustLineEntry", Struct,
    account_id: "AccountId",
    asset: "Asset",
    balance: "Int64",
    limit: "Int64",
    flags: "Uint32",
    ext: "TrustLineEntryExt"
  )

  comment ~S"""
  === xdr source ============================================================

      enum OfferEntryFlags
      {
          // issuer has authorized account to perform transactions with its credit
          PASSIVE_FLAG = 1
      };

  ===========================================================================
  """
  define_type("OfferEntryFlags", Enum,
    passive_flag: 1
  )

  comment ~S"""
  === xdr source ============================================================

      const MASK_OFFERENTRY_FLAGS = 1;

  ===========================================================================
  """
  define_type("MASK_OFFERENTRY_FLAGS", Const, 1);

  comment ~S"""
  === xdr source ============================================================

      union switch (int v)
          {
          case 0:
              void;
          }

  ===========================================================================
  """
  define_type("OfferEntryExt", Union,
    switch_type: build_type(Int),
    switch_name: :v,
    switches: [
      {0, XDR.Type.Void},
    ],
    arms: [
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      struct OfferEntry
      {
          AccountID sellerID;
          uint64 offerID;
          Asset selling; // A
          Asset buying;  // B
          int64 amount;  // amount of A

          /* price for this offer:
              price of A in terms of B
              price=AmountB/AmountA=priceNumerator/priceDenominator
              price is after fees
          */
          Price price;
          uint32 flags; // see OfferEntryFlags

          // reserved for future use
          union switch (int v)
          {
          case 0:
              void;
          }
          ext;
      };

  ===========================================================================
  """
  define_type("OfferEntry", Struct,
    seller_id: "AccountId",
    offer_id: "Uint64",
    selling: "Asset",
    buying: "Asset",
    amount: "Int64",
    price: "Price",
    flags: "Uint32",
    ext: "OfferEntryExt"
  )

  comment ~S"""
  === xdr source ============================================================

      union switch (int v)
          {
          case 0:
              void;
          }

  ===========================================================================
  """
  define_type("DataEntryExt", Union,
    switch_type: build_type(Int),
    switch_name: :v,
    switches: [
      {0, XDR.Type.Void},
    ],
    arms: [
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      struct DataEntry
      {
          AccountID accountID; // account this data belongs to
          string64 dataName;
          DataValue dataValue;

          // reserved for future use
          union switch (int v)
          {
          case 0:
              void;
          }
          ext;
      };

  ===========================================================================
  """
  define_type("DataEntry", Struct,
    account_id: "AccountId",
    data_name: "String64",
    data_value: "DataValue",
    ext: "DataEntryExt"
  )

  comment ~S"""
  === xdr source ============================================================

      union switch (LedgerEntryType type)
          {
          case ACCOUNT:
              AccountEntry account;
          case TRUSTLINE:
              TrustLineEntry trustLine;
          case OFFER:
              OfferEntry offer;
          case DATA:
              DataEntry data;
          }

  ===========================================================================
  """
  define_type("LedgerEntryData", Union,
    switch_type: "LedgerEntryType",
    switch_name: :type,
    switches: [
      {:account, :account},
      {:trustline, :trust_line},
      {:offer, :offer},
      {:datum, :data},
    ],
    arms: [
      account: "AccountEntry",
      trust_line: "TrustLineEntry",
      offer: "OfferEntry",
      data: "DataEntry",
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      union switch (int v)
          {
          case 0:
              void;
          }

  ===========================================================================
  """
  define_type("LedgerEntryExt", Union,
    switch_type: build_type(Int),
    switch_name: :v,
    switches: [
      {0, XDR.Type.Void},
    ],
    arms: [
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      struct LedgerEntry
      {
          uint32 lastModifiedLedgerSeq; // ledger the LedgerEntry was last changed

          union switch (LedgerEntryType type)
          {
          case ACCOUNT:
              AccountEntry account;
          case TRUSTLINE:
              TrustLineEntry trustLine;
          case OFFER:
              OfferEntry offer;
          case DATA:
              DataEntry data;
          }
          data;

          // reserved for future use
          union switch (int v)
          {
          case 0:
              void;
          }
          ext;
      };

  ===========================================================================
  """
  define_type("LedgerEntry", Struct,
    last_modified_ledger_seq: "Uint32",
    data: "LedgerEntryData",
    ext: "LedgerEntryExt"
  )

  comment ~S"""
  === xdr source ============================================================

      enum EnvelopeType
      {
          ENVELOPE_TYPE_SCP = 1,
          ENVELOPE_TYPE_TX = 2,
          ENVELOPE_TYPE_AUTH = 3
      };

  ===========================================================================
  """
  define_type("EnvelopeType", Enum,
    envelope_type_scp: 1,
    envelope_type_tx: 2,
    envelope_type_auth: 3
  )

  comment ~S"""
  === xdr source ============================================================

      typedef opaque UpgradeType<128>;

  ===========================================================================
  """
  define_type("UpgradeType", VariableOpaque, 128)

  comment ~S"""
  === xdr source ============================================================

      union switch (int v)
          {
          case 0:
              void;
          }

  ===========================================================================
  """
  define_type("StellarValueExt", Union,
    switch_type: build_type(Int),
    switch_name: :v,
    switches: [
      {0, XDR.Type.Void},
    ],
    arms: [
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      struct StellarValue
      {
          Hash txSetHash;   // transaction set to apply to previous ledger
          uint64 closeTime; // network close time

          // upgrades to apply to the previous ledger (usually empty)
          // this is a vector of encoded 'LedgerUpgrade' so that nodes can drop
          // unknown steps during consensus if needed.
          // see notes below on 'LedgerUpgrade' for more detail
          // max size is dictated by number of upgrade types (+ room for future)
          UpgradeType upgrades<6>;

          // reserved for future use
          union switch (int v)
          {
          case 0:
              void;
          }
          ext;
      };

  ===========================================================================
  """
  define_type("StellarValue", Struct,
    tx_set_hash: "Hash",
    close_time: "Uint64",
    upgrades: build_type(VariableArray, max_length: 6, type: "UpgradeType"),
    ext: "StellarValueExt"
  )

  comment ~S"""
  === xdr source ============================================================

      union switch (int v)
          {
          case 0:
              void;
          }

  ===========================================================================
  """
  define_type("LedgerHeaderExt", Union,
    switch_type: build_type(Int),
    switch_name: :v,
    switches: [
      {0, XDR.Type.Void},
    ],
    arms: [
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      struct LedgerHeader
      {
          uint32 ledgerVersion;    // the protocol version of the ledger
          Hash previousLedgerHash; // hash of the previous ledger header
          StellarValue scpValue;   // what consensus agreed to
          Hash txSetResultHash;    // the TransactionResultSet that led to this ledger
          Hash bucketListHash;     // hash of the ledger state

          uint32 ledgerSeq; // sequence number of this ledger

          int64 totalCoins; // total number of stroops in existence.
                            // 10,000,000 stroops in 1 XLM

          int64 feePool;       // fees burned since last inflation run
          uint32 inflationSeq; // inflation sequence number

          uint64 idPool; // last used global ID, used for generating objects

          uint32 baseFee;     // base fee per operation in stroops
          uint32 baseReserve; // account base reserve in stroops

          uint32 maxTxSetSize; // maximum size a transaction set can be

          Hash skipList[4]; // hashes of ledgers in the past. allows you to jump back
                            // in time without walking the chain back ledger by ledger
                            // each slot contains the oldest ledger that is mod of
                            // either 50  5000  50000 or 500000 depending on index
                            // skipList[0] mod(50), skipList[1] mod(5000), etc

          // reserved for future use
          union switch (int v)
          {
          case 0:
              void;
          }
          ext;
      };

  ===========================================================================
  """
  define_type("LedgerHeader", Struct,
    ledger_version: "Uint32",
    previous_ledger_hash: "Hash",
    scp_value: "StellarValue",
    tx_set_result_hash: "Hash",
    bucket_list_hash: "Hash",
    ledger_seq: "Uint32",
    total_coins: "Int64",
    fee_pool: "Int64",
    inflation_seq: "Uint32",
    id_pool: "Uint64",
    base_fee: "Uint32",
    base_reserve: "Uint32",
    max_tx_set_size: "Uint32",
    skip_list: build_type(Array, length: 4, type: "Hash"),
    ext: "LedgerHeaderExt"
  )

  comment ~S"""
  === xdr source ============================================================

      enum LedgerUpgradeType
      {
          LEDGER_UPGRADE_VERSION = 1,
          LEDGER_UPGRADE_BASE_FEE = 2,
          LEDGER_UPGRADE_MAX_TX_SET_SIZE = 3,
          LEDGER_UPGRADE_BASE_RESERVE = 4
      };

  ===========================================================================
  """
  define_type("LedgerUpgradeType", Enum,
    ledger_upgrade_version: 1,
    ledger_upgrade_base_fee: 2,
    ledger_upgrade_max_tx_set_size: 3,
    ledger_upgrade_base_reserve: 4
  )

  comment ~S"""
  === xdr source ============================================================

      union LedgerUpgrade switch (LedgerUpgradeType type)
      {
      case LEDGER_UPGRADE_VERSION:
          uint32 newLedgerVersion; // update ledgerVersion
      case LEDGER_UPGRADE_BASE_FEE:
          uint32 newBaseFee; // update baseFee
      case LEDGER_UPGRADE_MAX_TX_SET_SIZE:
          uint32 newMaxTxSetSize; // update maxTxSetSize
      case LEDGER_UPGRADE_BASE_RESERVE:
          uint32 newBaseReserve; // update baseReserve
      };

  ===========================================================================
  """
  define_type("LedgerUpgrade", Union,
    switch_type: "LedgerUpgradeType",
    switch_name: :type,
    switches: [
      {:ledger_upgrade_version, :new_ledger_version},
      {:ledger_upgrade_base_fee, :new_base_fee},
      {:ledger_upgrade_max_tx_set_size, :new_max_tx_set_size},
      {:ledger_upgrade_base_reserve, :new_base_reserve},
    ],
    arms: [
      new_ledger_version: "Uint32",
      new_base_fee: "Uint32",
      new_max_tx_set_size: "Uint32",
      new_base_reserve: "Uint32",
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      struct
          {
              AccountID accountID;
          }

  ===========================================================================
  """
  define_type("LedgerKeyAccount", Struct,
    account_id: "AccountId"
  )

  comment ~S"""
  === xdr source ============================================================

      struct
          {
              AccountID accountID;
              Asset asset;
          }

  ===========================================================================
  """
  define_type("LedgerKeyTrustLine", Struct,
    account_id: "AccountId",
    asset: "Asset"
  )

  comment ~S"""
  === xdr source ============================================================

      struct
          {
              AccountID sellerID;
              uint64 offerID;
          }

  ===========================================================================
  """
  define_type("LedgerKeyOffer", Struct,
    seller_id: "AccountId",
    offer_id: "Uint64"
  )

  comment ~S"""
  === xdr source ============================================================

      struct
          {
              AccountID accountID;
              string64 dataName;
          }

  ===========================================================================
  """
  define_type("LedgerKeyData", Struct,
    account_id: "AccountId",
    data_name: "String64"
  )

  comment ~S"""
  === xdr source ============================================================

      union LedgerKey switch (LedgerEntryType type)
      {
      case ACCOUNT:
          struct
          {
              AccountID accountID;
          } account;

      case TRUSTLINE:
          struct
          {
              AccountID accountID;
              Asset asset;
          } trustLine;

      case OFFER:
          struct
          {
              AccountID sellerID;
              uint64 offerID;
          } offer;

      case DATA:
          struct
          {
              AccountID accountID;
              string64 dataName;
          } data;
      };

  ===========================================================================
  """
  define_type("LedgerKey", Union,
    switch_type: "LedgerEntryType",
    switch_name: :type,
    switches: [
      {:account, :account},
      {:trustline, :trust_line},
      {:offer, :offer},
      {:datum, :data},
    ],
    arms: [
      account: "LedgerKeyAccount",
      trust_line: "LedgerKeyTrustLine",
      offer: "LedgerKeyOffer",
      data: "LedgerKeyData",
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      enum BucketEntryType
      {
          LIVEENTRY = 0,
          DEADENTRY = 1
      };

  ===========================================================================
  """
  define_type("BucketEntryType", Enum,
    liveentry: 0,
    deadentry: 1
  )

  comment ~S"""
  === xdr source ============================================================

      union BucketEntry switch (BucketEntryType type)
      {
      case LIVEENTRY:
          LedgerEntry liveEntry;

      case DEADENTRY:
          LedgerKey deadEntry;
      };

  ===========================================================================
  """
  define_type("BucketEntry", Union,
    switch_type: "BucketEntryType",
    switch_name: :type,
    switches: [
      {:liveentry, :live_entry},
      {:deadentry, :dead_entry},
    ],
    arms: [
      live_entry: "LedgerEntry",
      dead_entry: "LedgerKey",
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      struct TransactionSet
      {
          Hash previousLedgerHash;
          TransactionEnvelope txs<>;
      };

  ===========================================================================
  """
  define_type("TransactionSet", Struct,
    previous_ledger_hash: "Hash",
    txes: build_type(VariableArray, max_length: 2147483647, type: "TransactionEnvelope")
  )

  comment ~S"""
  === xdr source ============================================================

      struct TransactionResultPair
      {
          Hash transactionHash;
          TransactionResult result; // result for the transaction
      };

  ===========================================================================
  """
  define_type("TransactionResultPair", Struct,
    transaction_hash: "Hash",
    result: "TransactionResult"
  )

  comment ~S"""
  === xdr source ============================================================

      struct TransactionResultSet
      {
          TransactionResultPair results<>;
      };

  ===========================================================================
  """
  define_type("TransactionResultSet", Struct,
    results: build_type(VariableArray, max_length: 2147483647, type: "TransactionResultPair")
  )

  comment ~S"""
  === xdr source ============================================================

      union switch (int v)
          {
          case 0:
              void;
          }

  ===========================================================================
  """
  define_type("TransactionHistoryEntryExt", Union,
    switch_type: build_type(Int),
    switch_name: :v,
    switches: [
      {0, XDR.Type.Void},
    ],
    arms: [
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      struct TransactionHistoryEntry
      {
          uint32 ledgerSeq;
          TransactionSet txSet;

          // reserved for future use
          union switch (int v)
          {
          case 0:
              void;
          }
          ext;
      };

  ===========================================================================
  """
  define_type("TransactionHistoryEntry", Struct,
    ledger_seq: "Uint32",
    tx_set: "TransactionSet",
    ext: "TransactionHistoryEntryExt"
  )

  comment ~S"""
  === xdr source ============================================================

      union switch (int v)
          {
          case 0:
              void;
          }

  ===========================================================================
  """
  define_type("TransactionHistoryResultEntryExt", Union,
    switch_type: build_type(Int),
    switch_name: :v,
    switches: [
      {0, XDR.Type.Void},
    ],
    arms: [
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      struct TransactionHistoryResultEntry
      {
          uint32 ledgerSeq;
          TransactionResultSet txResultSet;

          // reserved for future use
          union switch (int v)
          {
          case 0:
              void;
          }
          ext;
      };

  ===========================================================================
  """
  define_type("TransactionHistoryResultEntry", Struct,
    ledger_seq: "Uint32",
    tx_result_set: "TransactionResultSet",
    ext: "TransactionHistoryResultEntryExt"
  )

  comment ~S"""
  === xdr source ============================================================

      union switch (int v)
          {
          case 0:
              void;
          }

  ===========================================================================
  """
  define_type("LedgerHeaderHistoryEntryExt", Union,
    switch_type: build_type(Int),
    switch_name: :v,
    switches: [
      {0, XDR.Type.Void},
    ],
    arms: [
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      struct LedgerHeaderHistoryEntry
      {
          Hash hash;
          LedgerHeader header;

          // reserved for future use
          union switch (int v)
          {
          case 0:
              void;
          }
          ext;
      };

  ===========================================================================
  """
  define_type("LedgerHeaderHistoryEntry", Struct,
    hash: "Hash",
    header: "LedgerHeader",
    ext: "LedgerHeaderHistoryEntryExt"
  )

  comment ~S"""
  === xdr source ============================================================

      struct LedgerSCPMessages
      {
          uint32 ledgerSeq;
          SCPEnvelope messages<>;
      };

  ===========================================================================
  """
  define_type("LedgerScpMessages", Struct,
    ledger_seq: "Uint32",
    messages: build_type(VariableArray, max_length: 2147483647, type: "ScpEnvelope")
  )

  comment ~S"""
  === xdr source ============================================================

      struct SCPHistoryEntryV0
      {
          SCPQuorumSet quorumSets<>; // additional quorum sets used by ledgerMessages
          LedgerSCPMessages ledgerMessages;
      };

  ===========================================================================
  """
  define_type("ScpHistoryEntryV0", Struct,
    quorum_sets: build_type(VariableArray, max_length: 2147483647, type: "ScpQuorumSet"),
    ledger_messages: "LedgerScpMessages"
  )

  comment ~S"""
  === xdr source ============================================================

      union SCPHistoryEntry switch (int v)
      {
      case 0:
          SCPHistoryEntryV0 v0;
      };

  ===========================================================================
  """
  define_type("ScpHistoryEntry", Union,
    switch_type: build_type(Int),
    switch_name: :v,
    switches: [
      {0, :v0},
    ],
    arms: [
      v0: "ScpHistoryEntryV0",
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      enum LedgerEntryChangeType
      {
          LEDGER_ENTRY_CREATED = 0, // entry was added to the ledger
          LEDGER_ENTRY_UPDATED = 1, // entry was modified in the ledger
          LEDGER_ENTRY_REMOVED = 2, // entry was removed from the ledger
          LEDGER_ENTRY_STATE = 3    // value of the entry
      };

  ===========================================================================
  """
  define_type("LedgerEntryChangeType", Enum,
    ledger_entry_created: 0,
    ledger_entry_updated: 1,
    ledger_entry_removed: 2,
    ledger_entry_state: 3
  )

  comment ~S"""
  === xdr source ============================================================

      union LedgerEntryChange switch (LedgerEntryChangeType type)
      {
      case LEDGER_ENTRY_CREATED:
          LedgerEntry created;
      case LEDGER_ENTRY_UPDATED:
          LedgerEntry updated;
      case LEDGER_ENTRY_REMOVED:
          LedgerKey removed;
      case LEDGER_ENTRY_STATE:
          LedgerEntry state;
      };

  ===========================================================================
  """
  define_type("LedgerEntryChange", Union,
    switch_type: "LedgerEntryChangeType",
    switch_name: :type,
    switches: [
      {:ledger_entry_created, :created},
      {:ledger_entry_updated, :updated},
      {:ledger_entry_removed, :removed},
      {:ledger_entry_state, :state},
    ],
    arms: [
      created: "LedgerEntry",
      updated: "LedgerEntry",
      removed: "LedgerKey",
      state: "LedgerEntry",
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      typedef LedgerEntryChange LedgerEntryChanges<>;

  ===========================================================================
  """
  define_type("LedgerEntryChanges", VariableArray, max_length: 2147483647, type: "LedgerEntryChange")

  comment ~S"""
  === xdr source ============================================================

      struct OperationMeta
      {
          LedgerEntryChanges changes;
      };

  ===========================================================================
  """
  define_type("OperationMeta", Struct,
    changes: "LedgerEntryChanges"
  )

  comment ~S"""
  === xdr source ============================================================

      struct TransactionMetaV1
      {
          LedgerEntryChanges txChanges; // tx level changes if any
          OperationMeta operations<>; // meta for each operation
      };

  ===========================================================================
  """
  define_type("TransactionMetaV1", Struct,
    tx_changes: "LedgerEntryChanges",
    operations: build_type(VariableArray, max_length: 2147483647, type: "OperationMeta")
  )

  comment ~S"""
  === xdr source ============================================================

      union TransactionMeta switch (int v)
      {
      case 0:
          OperationMeta operations<>;
      case 1:
          TransactionMetaV1 v1;
      };

  ===========================================================================
  """
  define_type("TransactionMeta", Union,
    switch_type: build_type(Int),
    switch_name: :v,
    switches: [
      {0, :operations},
      {1, :v1},
    ],
    arms: [
      operations: build_type(VariableArray, max_length: 2147483647, type: "OperationMeta"),
      v1: "TransactionMetaV1",
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      enum ErrorCode
      {
          ERR_MISC = 0, // Unspecific error
          ERR_DATA = 1, // Malformed data
          ERR_CONF = 2, // Misconfiguration error
          ERR_AUTH = 3, // Authentication failure
          ERR_LOAD = 4  // System overloaded
      };

  ===========================================================================
  """
  define_type("ErrorCode", Enum,
    err_misc: 0,
    err_datum: 1,
    err_conf: 2,
    err_auth: 3,
    err_load: 4
  )

  comment ~S"""
  === xdr source ============================================================

      struct Error
      {
          ErrorCode code;
          string msg<100>;
      };

  ===========================================================================
  """
  define_type("Error", Struct,
    code: "ErrorCode",
    msg: build_type(XDR.Type.String, 100)
  )

  comment ~S"""
  === xdr source ============================================================

      struct AuthCert
      {
          Curve25519Public pubkey;
          uint64 expiration;
          Signature sig;
      };

  ===========================================================================
  """
  define_type("AuthCert", Struct,
    pubkey: "Curve25519Public",
    expiration: "Uint64",
    sig: "Signature"
  )

  comment ~S"""
  === xdr source ============================================================

      struct Hello
      {
          uint32 ledgerVersion;
          uint32 overlayVersion;
          uint32 overlayMinVersion;
          Hash networkID;
          string versionStr<100>;
          int listeningPort;
          NodeID peerID;
          AuthCert cert;
          uint256 nonce;
      };

  ===========================================================================
  """
  define_type("Hello", Struct,
    ledger_version: "Uint32",
    overlay_version: "Uint32",
    overlay_min_version: "Uint32",
    network_id: "Hash",
    version_str: build_type(XDR.Type.String, 100),
    listening_port: build_type(Int),
    peer_id: "NodeId",
    cert: "AuthCert",
    nonce: "Uint256"
  )

  comment ~S"""
  === xdr source ============================================================

      struct Auth
      {
          // Empty message, just to confirm
          // establishment of MAC keys.
          int unused;
      };

  ===========================================================================
  """
  define_type("Auth", Struct,
    unused: build_type(Int)
  )

  comment ~S"""
  === xdr source ============================================================

      enum IPAddrType
      {
          IPv4 = 0,
          IPv6 = 1
      };

  ===========================================================================
  """
  define_type("IpAddrType", Enum,
    i_pv4: 0,
    i_pv6: 1
  )

  comment ~S"""
  === xdr source ============================================================

      union switch (IPAddrType type)
          {
          case IPv4:
              opaque ipv4[4];
          case IPv6:
              opaque ipv6[16];
          }

  ===========================================================================
  """
  define_type("PeerAddressIp", Union,
    switch_type: "IpAddrType",
    switch_name: :type,
    switches: [
      {:i_pv4, :ipv4},
      {:i_pv6, :ipv6},
    ],
    arms: [
      ipv4: build_type(Opaque, 4),
      ipv6: build_type(Opaque, 16),
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      struct PeerAddress
      {
          union switch (IPAddrType type)
          {
          case IPv4:
              opaque ipv4[4];
          case IPv6:
              opaque ipv6[16];
          }
          ip;
          uint32 port;
          uint32 numFailures;
      };

  ===========================================================================
  """
  define_type("PeerAddress", Struct,
    ip: "PeerAddressIp",
    port: "Uint32",
    num_failures: "Uint32"
  )

  comment ~S"""
  === xdr source ============================================================

      enum MessageType
      {
          ERROR_MSG = 0,
          AUTH = 2,
          DONT_HAVE = 3,

          GET_PEERS = 4, // gets a list of peers this guy knows about
          PEERS = 5,

          GET_TX_SET = 6, // gets a particular txset by hash
          TX_SET = 7,

          TRANSACTION = 8, // pass on a tx you have heard about

          // SCP
          GET_SCP_QUORUMSET = 9,
          SCP_QUORUMSET = 10,
          SCP_MESSAGE = 11,
          GET_SCP_STATE = 12,

          // new messages
          HELLO = 13
      };

  ===========================================================================
  """
  define_type("MessageType", Enum,
    error_msg: 0,
    auth: 2,
    dont_have: 3,
    get_peer: 4,
    peer: 5,
    get_tx_set: 6,
    tx_set: 7,
    transaction: 8,
    get_scp_quorumset: 9,
    scp_quorumset: 10,
    scp_message: 11,
    get_scp_state: 12,
    hello: 13
  )

  comment ~S"""
  === xdr source ============================================================

      struct DontHave
      {
          MessageType type;
          uint256 reqHash;
      };

  ===========================================================================
  """
  define_type("DontHave", Struct,
    type: "MessageType",
    req_hash: "Uint256"
  )

  comment ~S"""
  === xdr source ============================================================

      union StellarMessage switch (MessageType type)
      {
      case ERROR_MSG:
          Error error;
      case HELLO:
          Hello hello;
      case AUTH:
          Auth auth;
      case DONT_HAVE:
          DontHave dontHave;
      case GET_PEERS:
          void;
      case PEERS:
          PeerAddress peers<100>;

      case GET_TX_SET:
          uint256 txSetHash;
      case TX_SET:
          TransactionSet txSet;

      case TRANSACTION:
          TransactionEnvelope transaction;

      // SCP
      case GET_SCP_QUORUMSET:
          uint256 qSetHash;
      case SCP_QUORUMSET:
          SCPQuorumSet qSet;
      case SCP_MESSAGE:
          StellarMessage envelope;
      case GET_SCP_STATE:
          uint32 getSCPLedgerSeq; // ledger seq requested ; if 0, requests the latest
      };

  ===========================================================================
  """
  define_type("StellarMessage", Union,
    switch_type: "MessageType",
    switch_name: :type,
    switches: [
      {:error_msg, :error},
      {:hello, :hello},
      {:auth, :auth},
      {:dont_have, :dont_have},
      {:get_peer, XDR.Type.Void},
      {:peer, :peers},
      {:get_tx_set, :tx_set_hash},
      {:tx_set, :tx_set},
      {:transaction, :transaction},
      {:get_scp_quorumset, :q_set_hash},
      {:scp_quorumset, :q_set},
      {:scp_message, :envelope},
      {:get_scp_state, :get_scp_ledger_seq},
    ],
    arms: [
      error: "Error",
      hello: "Hello",
      auth: "Auth",
      dont_have: "DontHave",
      peers: build_type(VariableArray, max_length: 100, type: "PeerAddress"),
      tx_set_hash: "Uint256",
      tx_set: "TransactionSet",
      transaction: "TransactionEnvelope",
      q_set_hash: "Uint256",
      q_set: "ScpQuorumSet",
      envelope: "StellarMessage",
      get_scp_ledger_seq: "Uint32",
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      struct
      {
         uint64 sequence;
         StellarMessage message;
         HmacSha256Mac mac;
          }

  ===========================================================================
  """
  define_type("AuthenticatedMessageV0", Struct,
    sequence: "Uint64",
    message: "StellarMessage",
    mac: "HmacSha256Mac"
  )

  comment ~S"""
  === xdr source ============================================================

      union AuthenticatedMessage switch (uint32 v)
      {
      case 0:
          struct
      {
         uint64 sequence;
         StellarMessage message;
         HmacSha256Mac mac;
          } v0;
      };

  ===========================================================================
  """
  define_type("AuthenticatedMessage", Union,
    switch_type: "Uint32",
    switch_name: :v,
    switches: [
      {0, :v0},
    ],
    arms: [
      v0: "AuthenticatedMessageV0",
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      struct DecoratedSignature
      {
          SignatureHint hint;  // last 4 bytes of the public key, used as a hint
          Signature signature; // actual signature
      };

  ===========================================================================
  """
  define_type("DecoratedSignature", Struct,
    hint: "SignatureHint",
    signature: "Signature"
  )

  comment ~S"""
  === xdr source ============================================================

      enum OperationType
      {
          CREATE_ACCOUNT = 0,
          PAYMENT = 1,
          PATH_PAYMENT = 2,
          MANAGE_OFFER = 3,
          CREATE_PASSIVE_OFFER = 4,
          SET_OPTIONS = 5,
          CHANGE_TRUST = 6,
          ALLOW_TRUST = 7,
          ACCOUNT_MERGE = 8,
          INFLATION = 9,
          MANAGE_DATA = 10,
          BUMP_SEQUENCE = 11
      };

  ===========================================================================
  """
  define_type("OperationType", Enum,
    create_account: 0,
    payment: 1,
    path_payment: 2,
    manage_offer: 3,
    create_passive_offer: 4,
    set_option: 5,
    change_trust: 6,
    allow_trust: 7,
    account_merge: 8,
    inflation: 9,
    manage_datum: 10,
    bump_sequence: 11
  )

  comment ~S"""
  === xdr source ============================================================

      struct CreateAccountOp
      {
          AccountID destination; // account to create
          int64 startingBalance; // amount they end up with
      };

  ===========================================================================
  """
  define_type("CreateAccountOp", Struct,
    destination: "AccountId",
    starting_balance: "Int64"
  )

  comment ~S"""
  === xdr source ============================================================

      struct PaymentOp
      {
          AccountID destination; // recipient of the payment
          Asset asset;           // what they end up with
          int64 amount;          // amount they end up with
      };

  ===========================================================================
  """
  define_type("PaymentOp", Struct,
    destination: "AccountId",
    asset: "Asset",
    amount: "Int64"
  )

  comment ~S"""
  === xdr source ============================================================

      struct PathPaymentOp
      {
          Asset sendAsset; // asset we pay with
          int64 sendMax;   // the maximum amount of sendAsset to
                           // send (excluding fees).
                           // The operation will fail if can't be met

          AccountID destination; // recipient of the payment
          Asset destAsset;       // what they end up with
          int64 destAmount;      // amount they end up with

          Asset path<5>; // additional hops it must go through to get there
      };

  ===========================================================================
  """
  define_type("PathPaymentOp", Struct,
    send_asset: "Asset",
    send_max: "Int64",
    destination: "AccountId",
    dest_asset: "Asset",
    dest_amount: "Int64",
    path: build_type(VariableArray, max_length: 5, type: "Asset")
  )

  comment ~S"""
  === xdr source ============================================================

      struct ManageOfferOp
      {
          Asset selling;
          Asset buying;
          int64 amount; // amount being sold. if set to 0, delete the offer
          Price price;  // price of thing being sold in terms of what you are buying

          // 0=create a new offer, otherwise edit an existing offer
          uint64 offerID;
      };

  ===========================================================================
  """
  define_type("ManageOfferOp", Struct,
    selling: "Asset",
    buying: "Asset",
    amount: "Int64",
    price: "Price",
    offer_id: "Uint64"
  )

  comment ~S"""
  === xdr source ============================================================

      struct CreatePassiveOfferOp
      {
          Asset selling; // A
          Asset buying;  // B
          int64 amount;  // amount taker gets. if set to 0, delete the offer
          Price price;   // cost of A in terms of B
      };

  ===========================================================================
  """
  define_type("CreatePassiveOfferOp", Struct,
    selling: "Asset",
    buying: "Asset",
    amount: "Int64",
    price: "Price"
  )

  comment ~S"""
  === xdr source ============================================================

      struct SetOptionsOp
      {
          AccountID* inflationDest; // sets the inflation destination

          uint32* clearFlags; // which flags to clear
          uint32* setFlags;   // which flags to set

          // account threshold manipulation
          uint32* masterWeight; // weight of the master account
          uint32* lowThreshold;
          uint32* medThreshold;
          uint32* highThreshold;

          string32* homeDomain; // sets the home domain

          // Add, update or remove a signer for the account
          // signer is deleted if the weight is 0
          Signer* signer;
      };

  ===========================================================================
  """
  define_type("SetOptionsOp", Struct,
    inflation_dest: build_type(Optional, "AccountId"),
    clear_flags: build_type(Optional, "Uint32"),
    set_flags: build_type(Optional, "Uint32"),
    master_weight: build_type(Optional, "Uint32"),
    low_threshold: build_type(Optional, "Uint32"),
    med_threshold: build_type(Optional, "Uint32"),
    high_threshold: build_type(Optional, "Uint32"),
    home_domain: build_type(Optional, "String32"),
    signer: build_type(Optional, "Signer")
  )

  comment ~S"""
  === xdr source ============================================================

      struct ChangeTrustOp
      {
          Asset line;

          // if limit is set to 0, deletes the trust line
          int64 limit;
      };

  ===========================================================================
  """
  define_type("ChangeTrustOp", Struct,
    line: "Asset",
    limit: "Int64"
  )

  comment ~S"""
  === xdr source ============================================================

      union switch (AssetType type)
          {
          // ASSET_TYPE_NATIVE is not allowed
          case ASSET_TYPE_CREDIT_ALPHANUM4:
              opaque assetCode4[4];

          case ASSET_TYPE_CREDIT_ALPHANUM12:
              opaque assetCode12[12];

              // add other asset types here in the future
          }

  ===========================================================================
  """
  define_type("AllowTrustOpAsset", Union,
    switch_type: "AssetType",
    switch_name: :type,
    switches: [
      {:asset_type_credit_alphanum4, :asset_code4},
      {:asset_type_credit_alphanum12, :asset_code12},
    ],
    arms: [
      asset_code4: build_type(Opaque, 4),
      asset_code12: build_type(Opaque, 12),
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      struct AllowTrustOp
      {
          AccountID trustor;
          union switch (AssetType type)
          {
          // ASSET_TYPE_NATIVE is not allowed
          case ASSET_TYPE_CREDIT_ALPHANUM4:
              opaque assetCode4[4];

          case ASSET_TYPE_CREDIT_ALPHANUM12:
              opaque assetCode12[12];

              // add other asset types here in the future
          }
          asset;

          bool authorize;
      };

  ===========================================================================
  """
  define_type("AllowTrustOp", Struct,
    trustor: "AccountId",
    asset: "AllowTrustOpAsset",
    authorize: build_type(Bool)
  )

  comment ~S"""
  === xdr source ============================================================

      struct ManageDataOp
      {
          string64 dataName;
          DataValue* dataValue; // set to null to clear
      };

  ===========================================================================
  """
  define_type("ManageDataOp", Struct,
    data_name: "String64",
    data_value: build_type(Optional, "DataValue")
  )

  comment ~S"""
  === xdr source ============================================================

      struct BumpSequenceOp
      {
          SequenceNumber bumpTo;
      };

  ===========================================================================
  """
  define_type("BumpSequenceOp", Struct,
    bump_to: "SequenceNumber"
  )

  comment ~S"""
  === xdr source ============================================================

      union switch (OperationType type)
          {
          case CREATE_ACCOUNT:
              CreateAccountOp createAccountOp;
          case PAYMENT:
              PaymentOp paymentOp;
          case PATH_PAYMENT:
              PathPaymentOp pathPaymentOp;
          case MANAGE_OFFER:
              ManageOfferOp manageOfferOp;
          case CREATE_PASSIVE_OFFER:
              CreatePassiveOfferOp createPassiveOfferOp;
          case SET_OPTIONS:
              SetOptionsOp setOptionsOp;
          case CHANGE_TRUST:
              ChangeTrustOp changeTrustOp;
          case ALLOW_TRUST:
              AllowTrustOp allowTrustOp;
          case ACCOUNT_MERGE:
              AccountID destination;
          case INFLATION:
              void;
          case MANAGE_DATA:
              ManageDataOp manageDataOp;
          case BUMP_SEQUENCE:
              BumpSequenceOp bumpSequenceOp;
          }

  ===========================================================================
  """
  define_type("OperationBody", Union,
    switch_type: "OperationType",
    switch_name: :type,
    switches: [
      {:create_account, :create_account_op},
      {:payment, :payment_op},
      {:path_payment, :path_payment_op},
      {:manage_offer, :manage_offer_op},
      {:create_passive_offer, :create_passive_offer_op},
      {:set_option, :set_options_op},
      {:change_trust, :change_trust_op},
      {:allow_trust, :allow_trust_op},
      {:account_merge, :destination},
      {:inflation, XDR.Type.Void},
      {:manage_datum, :manage_data_op},
      {:bump_sequence, :bump_sequence_op},
    ],
    arms: [
      create_account_op: "CreateAccountOp",
      payment_op: "PaymentOp",
      path_payment_op: "PathPaymentOp",
      manage_offer_op: "ManageOfferOp",
      create_passive_offer_op: "CreatePassiveOfferOp",
      set_options_op: "SetOptionsOp",
      change_trust_op: "ChangeTrustOp",
      allow_trust_op: "AllowTrustOp",
      destination: "AccountId",
      manage_data_op: "ManageDataOp",
      bump_sequence_op: "BumpSequenceOp",
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      struct Operation
      {
          // sourceAccount is the account used to run the operation
          // if not set, the runtime defaults to "sourceAccount" specified at
          // the transaction level
          AccountID* sourceAccount;

          union switch (OperationType type)
          {
          case CREATE_ACCOUNT:
              CreateAccountOp createAccountOp;
          case PAYMENT:
              PaymentOp paymentOp;
          case PATH_PAYMENT:
              PathPaymentOp pathPaymentOp;
          case MANAGE_OFFER:
              ManageOfferOp manageOfferOp;
          case CREATE_PASSIVE_OFFER:
              CreatePassiveOfferOp createPassiveOfferOp;
          case SET_OPTIONS:
              SetOptionsOp setOptionsOp;
          case CHANGE_TRUST:
              ChangeTrustOp changeTrustOp;
          case ALLOW_TRUST:
              AllowTrustOp allowTrustOp;
          case ACCOUNT_MERGE:
              AccountID destination;
          case INFLATION:
              void;
          case MANAGE_DATA:
              ManageDataOp manageDataOp;
          case BUMP_SEQUENCE:
              BumpSequenceOp bumpSequenceOp;
          }
          body;
      };

  ===========================================================================
  """
  define_type("Operation", Struct,
    source_account: build_type(Optional, "AccountId"),
    body: "OperationBody"
  )

  comment ~S"""
  === xdr source ============================================================

      enum MemoType
      {
          MEMO_NONE = 0,
          MEMO_TEXT = 1,
          MEMO_ID = 2,
          MEMO_HASH = 3,
          MEMO_RETURN = 4
      };

  ===========================================================================
  """
  define_type("MemoType", Enum,
    memo_none: 0,
    memo_text: 1,
    memo_id: 2,
    memo_hash: 3,
    memo_return: 4
  )

  comment ~S"""
  === xdr source ============================================================

      union Memo switch (MemoType type)
      {
      case MEMO_NONE:
          void;
      case MEMO_TEXT:
          string text<28>;
      case MEMO_ID:
          uint64 id;
      case MEMO_HASH:
          Hash hash; // the hash of what to pull from the content server
      case MEMO_RETURN:
          Hash retHash; // the hash of the tx you are rejecting
      };

  ===========================================================================
  """
  define_type("Memo", Union,
    switch_type: "MemoType",
    switch_name: :type,
    switches: [
      {:memo_none, XDR.Type.Void},
      {:memo_text, :text},
      {:memo_id, :id},
      {:memo_hash, :hash},
      {:memo_return, :ret_hash},
    ],
    arms: [
      text: build_type(XDR.Type.String, 28),
      id: "Uint64",
      hash: "Hash",
      ret_hash: "Hash",
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      struct TimeBounds
      {
          uint64 minTime;
          uint64 maxTime; // 0 here means no maxTime
      };

  ===========================================================================
  """
  define_type("TimeBounds", Struct,
    min_time: "Uint64",
    max_time: "Uint64"
  )

  comment ~S"""
  === xdr source ============================================================

      union switch (int v)
          {
          case 0:
              void;
          }

  ===========================================================================
  """
  define_type("TransactionExt", Union,
    switch_type: build_type(Int),
    switch_name: :v,
    switches: [
      {0, XDR.Type.Void},
    ],
    arms: [
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      struct Transaction
      {
          // account used to run the transaction
          AccountID sourceAccount;

          // the fee the sourceAccount will pay
          uint32 fee;

          // sequence number to consume in the account
          SequenceNumber seqNum;

          // validity range (inclusive) for the last ledger close time
          TimeBounds* timeBounds;

          Memo memo;

          Operation operations<100>;

          // reserved for future use
          union switch (int v)
          {
          case 0:
              void;
          }
          ext;
      };

  ===========================================================================
  """
  define_type("Transaction", Struct,
    source_account: "AccountId",
    fee: "Uint32",
    seq_num: "SequenceNumber",
    time_bounds: build_type(Optional, "TimeBounds"),
    memo: "Memo",
    operations: build_type(VariableArray, max_length: 100, type: "Operation"),
    ext: "TransactionExt"
  )

  comment ~S"""
  === xdr source ============================================================

      union switch (EnvelopeType type)
          {
          case ENVELOPE_TYPE_TX:
              Transaction tx;
              /* All other values of type are invalid */
          }

  ===========================================================================
  """
  define_type("TransactionSignaturePayloadTaggedTransaction", Union,
    switch_type: "EnvelopeType",
    switch_name: :type,
    switches: [
      {:envelope_type_tx, :tx},
    ],
    arms: [
      tx: "Transaction",
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      struct TransactionSignaturePayload
      {
          Hash networkId;
          union switch (EnvelopeType type)
          {
          case ENVELOPE_TYPE_TX:
              Transaction tx;
              /* All other values of type are invalid */
          }
          taggedTransaction;
      };

  ===========================================================================
  """
  define_type("TransactionSignaturePayload", Struct,
    network_id: "Hash",
    tagged_transaction: "TransactionSignaturePayloadTaggedTransaction"
  )

  comment ~S"""
  === xdr source ============================================================

      struct TransactionEnvelope
      {
          Transaction tx;
          /* Each decorated signature is a signature over the SHA256 hash of
           * a TransactionSignaturePayload */
          DecoratedSignature signatures<20>;
      };

  ===========================================================================
  """
  define_type("TransactionEnvelope", Struct,
    tx: "Transaction",
    signatures: build_type(VariableArray, max_length: 20, type: "DecoratedSignature")
  )

  comment ~S"""
  === xdr source ============================================================

      struct ClaimOfferAtom
      {
          // emitted to identify the offer
          AccountID sellerID; // Account that owns the offer
          uint64 offerID;

          // amount and asset taken from the owner
          Asset assetSold;
          int64 amountSold;

          // amount and asset sent to the owner
          Asset assetBought;
          int64 amountBought;
      };

  ===========================================================================
  """
  define_type("ClaimOfferAtom", Struct,
    seller_id: "AccountId",
    offer_id: "Uint64",
    asset_sold: "Asset",
    amount_sold: "Int64",
    asset_bought: "Asset",
    amount_bought: "Int64"
  )

  comment ~S"""
  === xdr source ============================================================

      enum CreateAccountResultCode
      {
          // codes considered as "success" for the operation
          CREATE_ACCOUNT_SUCCESS = 0, // account was created

          // codes considered as "failure" for the operation
          CREATE_ACCOUNT_MALFORMED = -1,   // invalid destination
          CREATE_ACCOUNT_UNDERFUNDED = -2, // not enough funds in source account
          CREATE_ACCOUNT_LOW_RESERVE =
              -3, // would create an account below the min reserve
          CREATE_ACCOUNT_ALREADY_EXIST = -4 // account already exists
      };

  ===========================================================================
  """
  define_type("CreateAccountResultCode", Enum,
    create_account_success: 0,
    create_account_malformed: -1,
    create_account_underfunded: -2,
    create_account_low_reserve: -3,
    create_account_already_exist: -4
  )

  comment ~S"""
  === xdr source ============================================================

      union CreateAccountResult switch (CreateAccountResultCode code)
      {
      case CREATE_ACCOUNT_SUCCESS:
          void;
      default:
          void;
      };

  ===========================================================================
  """
  define_type("CreateAccountResult", Union,
    switch_type: "CreateAccountResultCode",
    switch_name: :code,
    switches: [
      {:create_account_success, XDR.Type.Void},
    ],
    arms: [
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      enum PaymentResultCode
      {
          // codes considered as "success" for the operation
          PAYMENT_SUCCESS = 0, // payment successfuly completed

          // codes considered as "failure" for the operation
          PAYMENT_MALFORMED = -1,          // bad input
          PAYMENT_UNDERFUNDED = -2,        // not enough funds in source account
          PAYMENT_SRC_NO_TRUST = -3,       // no trust line on source account
          PAYMENT_SRC_NOT_AUTHORIZED = -4, // source not authorized to transfer
          PAYMENT_NO_DESTINATION = -5,     // destination account does not exist
          PAYMENT_NO_TRUST = -6,       // destination missing a trust line for asset
          PAYMENT_NOT_AUTHORIZED = -7, // destination not authorized to hold asset
          PAYMENT_LINE_FULL = -8,      // destination would go above their limit
          PAYMENT_NO_ISSUER = -9       // missing issuer on asset
      };

  ===========================================================================
  """
  define_type("PaymentResultCode", Enum,
    payment_success: 0,
    payment_malformed: -1,
    payment_underfunded: -2,
    payment_src_no_trust: -3,
    payment_src_not_authorized: -4,
    payment_no_destination: -5,
    payment_no_trust: -6,
    payment_not_authorized: -7,
    payment_line_full: -8,
    payment_no_issuer: -9
  )

  comment ~S"""
  === xdr source ============================================================

      union PaymentResult switch (PaymentResultCode code)
      {
      case PAYMENT_SUCCESS:
          void;
      default:
          void;
      };

  ===========================================================================
  """
  define_type("PaymentResult", Union,
    switch_type: "PaymentResultCode",
    switch_name: :code,
    switches: [
      {:payment_success, XDR.Type.Void},
    ],
    arms: [
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      enum PathPaymentResultCode
      {
          // codes considered as "success" for the operation
          PATH_PAYMENT_SUCCESS = 0, // success

          // codes considered as "failure" for the operation
          PATH_PAYMENT_MALFORMED = -1,          // bad input
          PATH_PAYMENT_UNDERFUNDED = -2,        // not enough funds in source account
          PATH_PAYMENT_SRC_NO_TRUST = -3,       // no trust line on source account
          PATH_PAYMENT_SRC_NOT_AUTHORIZED = -4, // source not authorized to transfer
          PATH_PAYMENT_NO_DESTINATION = -5,     // destination account does not exist
          PATH_PAYMENT_NO_TRUST = -6,           // dest missing a trust line for asset
          PATH_PAYMENT_NOT_AUTHORIZED = -7,     // dest not authorized to hold asset
          PATH_PAYMENT_LINE_FULL = -8,          // dest would go above their limit
          PATH_PAYMENT_NO_ISSUER = -9,          // missing issuer on one asset
          PATH_PAYMENT_TOO_FEW_OFFERS = -10,    // not enough offers to satisfy path
          PATH_PAYMENT_OFFER_CROSS_SELF = -11,  // would cross one of its own offers
          PATH_PAYMENT_OVER_SENDMAX = -12       // could not satisfy sendmax
      };

  ===========================================================================
  """
  define_type("PathPaymentResultCode", Enum,
    path_payment_success: 0,
    path_payment_malformed: -1,
    path_payment_underfunded: -2,
    path_payment_src_no_trust: -3,
    path_payment_src_not_authorized: -4,
    path_payment_no_destination: -5,
    path_payment_no_trust: -6,
    path_payment_not_authorized: -7,
    path_payment_line_full: -8,
    path_payment_no_issuer: -9,
    path_payment_too_few_offer: -10,
    path_payment_offer_cross_self: -11,
    path_payment_over_sendmax: -12
  )

  comment ~S"""
  === xdr source ============================================================

      struct SimplePaymentResult
      {
          AccountID destination;
          Asset asset;
          int64 amount;
      };

  ===========================================================================
  """
  define_type("SimplePaymentResult", Struct,
    destination: "AccountId",
    asset: "Asset",
    amount: "Int64"
  )

  comment ~S"""
  === xdr source ============================================================

      struct
          {
              ClaimOfferAtom offers<>;
              SimplePaymentResult last;
          }

  ===========================================================================
  """
  define_type("PathPaymentResultSuccess", Struct,
    offers: build_type(VariableArray, max_length: 2147483647, type: "ClaimOfferAtom"),
    last: "SimplePaymentResult"
  )

  comment ~S"""
  === xdr source ============================================================

      union PathPaymentResult switch (PathPaymentResultCode code)
      {
      case PATH_PAYMENT_SUCCESS:
          struct
          {
              ClaimOfferAtom offers<>;
              SimplePaymentResult last;
          } success;
      case PATH_PAYMENT_NO_ISSUER:
          Asset noIssuer; // the asset that caused the error
      default:
          void;
      };

  ===========================================================================
  """
  define_type("PathPaymentResult", Union,
    switch_type: "PathPaymentResultCode",
    switch_name: :code,
    switches: [
      {:path_payment_success, :success},
      {:path_payment_no_issuer, :no_issuer},
    ],
    arms: [
      success: "PathPaymentResultSuccess",
      no_issuer: "Asset",
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      enum ManageOfferResultCode
      {
          // codes considered as "success" for the operation
          MANAGE_OFFER_SUCCESS = 0,

          // codes considered as "failure" for the operation
          MANAGE_OFFER_MALFORMED = -1,     // generated offer would be invalid
          MANAGE_OFFER_SELL_NO_TRUST = -2, // no trust line for what we're selling
          MANAGE_OFFER_BUY_NO_TRUST = -3,  // no trust line for what we're buying
          MANAGE_OFFER_SELL_NOT_AUTHORIZED = -4, // not authorized to sell
          MANAGE_OFFER_BUY_NOT_AUTHORIZED = -5,  // not authorized to buy
          MANAGE_OFFER_LINE_FULL = -6,      // can't receive more of what it's buying
          MANAGE_OFFER_UNDERFUNDED = -7,    // doesn't hold what it's trying to sell
          MANAGE_OFFER_CROSS_SELF = -8,     // would cross an offer from the same user
          MANAGE_OFFER_SELL_NO_ISSUER = -9, // no issuer for what we're selling
          MANAGE_OFFER_BUY_NO_ISSUER = -10, // no issuer for what we're buying

          // update errors
          MANAGE_OFFER_NOT_FOUND = -11, // offerID does not match an existing offer

          MANAGE_OFFER_LOW_RESERVE = -12 // not enough funds to create a new Offer
      };

  ===========================================================================
  """
  define_type("ManageOfferResultCode", Enum,
    manage_offer_success: 0,
    manage_offer_malformed: -1,
    manage_offer_sell_no_trust: -2,
    manage_offer_buy_no_trust: -3,
    manage_offer_sell_not_authorized: -4,
    manage_offer_buy_not_authorized: -5,
    manage_offer_line_full: -6,
    manage_offer_underfunded: -7,
    manage_offer_cross_self: -8,
    manage_offer_sell_no_issuer: -9,
    manage_offer_buy_no_issuer: -10,
    manage_offer_not_found: -11,
    manage_offer_low_reserve: -12
  )

  comment ~S"""
  === xdr source ============================================================

      enum ManageOfferEffect
      {
          MANAGE_OFFER_CREATED = 0,
          MANAGE_OFFER_UPDATED = 1,
          MANAGE_OFFER_DELETED = 2
      };

  ===========================================================================
  """
  define_type("ManageOfferEffect", Enum,
    manage_offer_created: 0,
    manage_offer_updated: 1,
    manage_offer_deleted: 2
  )

  comment ~S"""
  === xdr source ============================================================

      union switch (ManageOfferEffect effect)
          {
          case MANAGE_OFFER_CREATED:
          case MANAGE_OFFER_UPDATED:
              OfferEntry offer;
          default:
              void;
          }

  ===========================================================================
  """
  define_type("ManageOfferSuccessResultOffer", Union,
    switch_type: "ManageOfferEffect",
    switch_name: :effect,
    switches: [
      {:manage_offer_created, :offer},
      {:manage_offer_updated, :offer},
    ],
    arms: [
      offer: "OfferEntry",
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      struct ManageOfferSuccessResult
      {
          // offers that got claimed while creating this offer
          ClaimOfferAtom offersClaimed<>;

          union switch (ManageOfferEffect effect)
          {
          case MANAGE_OFFER_CREATED:
          case MANAGE_OFFER_UPDATED:
              OfferEntry offer;
          default:
              void;
          }
          offer;
      };

  ===========================================================================
  """
  define_type("ManageOfferSuccessResult", Struct,
    offers_claimed: build_type(VariableArray, max_length: 2147483647, type: "ClaimOfferAtom"),
    offer: "ManageOfferSuccessResultOffer"
  )

  comment ~S"""
  === xdr source ============================================================

      union ManageOfferResult switch (ManageOfferResultCode code)
      {
      case MANAGE_OFFER_SUCCESS:
          ManageOfferSuccessResult success;
      default:
          void;
      };

  ===========================================================================
  """
  define_type("ManageOfferResult", Union,
    switch_type: "ManageOfferResultCode",
    switch_name: :code,
    switches: [
      {:manage_offer_success, :success},
    ],
    arms: [
      success: "ManageOfferSuccessResult",
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      enum SetOptionsResultCode
      {
          // codes considered as "success" for the operation
          SET_OPTIONS_SUCCESS = 0,
          // codes considered as "failure" for the operation
          SET_OPTIONS_LOW_RESERVE = -1,      // not enough funds to add a signer
          SET_OPTIONS_TOO_MANY_SIGNERS = -2, // max number of signers already reached
          SET_OPTIONS_BAD_FLAGS = -3,        // invalid combination of clear/set flags
          SET_OPTIONS_INVALID_INFLATION = -4,      // inflation account does not exist
          SET_OPTIONS_CANT_CHANGE = -5,            // can no longer change this option
          SET_OPTIONS_UNKNOWN_FLAG = -6,           // can't set an unknown flag
          SET_OPTIONS_THRESHOLD_OUT_OF_RANGE = -7, // bad value for weight/threshold
          SET_OPTIONS_BAD_SIGNER = -8,             // signer cannot be masterkey
          SET_OPTIONS_INVALID_HOME_DOMAIN = -9     // malformed home domain
      };

  ===========================================================================
  """
  define_type("SetOptionsResultCode", Enum,
    set_options_success: 0,
    set_options_low_reserve: -1,
    set_options_too_many_signer: -2,
    set_options_bad_flag: -3,
    set_options_invalid_inflation: -4,
    set_options_cant_change: -5,
    set_options_unknown_flag: -6,
    set_options_threshold_out_of_range: -7,
    set_options_bad_signer: -8,
    set_options_invalid_home_domain: -9
  )

  comment ~S"""
  === xdr source ============================================================

      union SetOptionsResult switch (SetOptionsResultCode code)
      {
      case SET_OPTIONS_SUCCESS:
          void;
      default:
          void;
      };

  ===========================================================================
  """
  define_type("SetOptionsResult", Union,
    switch_type: "SetOptionsResultCode",
    switch_name: :code,
    switches: [
      {:set_options_success, XDR.Type.Void},
    ],
    arms: [
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      enum ChangeTrustResultCode
      {
          // codes considered as "success" for the operation
          CHANGE_TRUST_SUCCESS = 0,
          // codes considered as "failure" for the operation
          CHANGE_TRUST_MALFORMED = -1,     // bad input
          CHANGE_TRUST_NO_ISSUER = -2,     // could not find issuer
          CHANGE_TRUST_INVALID_LIMIT = -3, // cannot drop limit below balance
                                           // cannot create with a limit of 0
          CHANGE_TRUST_LOW_RESERVE =
              -4, // not enough funds to create a new trust line,
          CHANGE_TRUST_SELF_NOT_ALLOWED = -5 // trusting self is not allowed
      };

  ===========================================================================
  """
  define_type("ChangeTrustResultCode", Enum,
    change_trust_success: 0,
    change_trust_malformed: -1,
    change_trust_no_issuer: -2,
    change_trust_invalid_limit: -3,
    change_trust_low_reserve: -4,
    change_trust_self_not_allowed: -5
  )

  comment ~S"""
  === xdr source ============================================================

      union ChangeTrustResult switch (ChangeTrustResultCode code)
      {
      case CHANGE_TRUST_SUCCESS:
          void;
      default:
          void;
      };

  ===========================================================================
  """
  define_type("ChangeTrustResult", Union,
    switch_type: "ChangeTrustResultCode",
    switch_name: :code,
    switches: [
      {:change_trust_success, XDR.Type.Void},
    ],
    arms: [
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      enum AllowTrustResultCode
      {
          // codes considered as "success" for the operation
          ALLOW_TRUST_SUCCESS = 0,
          // codes considered as "failure" for the operation
          ALLOW_TRUST_MALFORMED = -1,     // asset is not ASSET_TYPE_ALPHANUM
          ALLOW_TRUST_NO_TRUST_LINE = -2, // trustor does not have a trustline
                                          // source account does not require trust
          ALLOW_TRUST_TRUST_NOT_REQUIRED = -3,
          ALLOW_TRUST_CANT_REVOKE = -4,     // source account can't revoke trust,
          ALLOW_TRUST_SELF_NOT_ALLOWED = -5 // trusting self is not allowed
      };

  ===========================================================================
  """
  define_type("AllowTrustResultCode", Enum,
    allow_trust_success: 0,
    allow_trust_malformed: -1,
    allow_trust_no_trust_line: -2,
    allow_trust_trust_not_required: -3,
    allow_trust_cant_revoke: -4,
    allow_trust_self_not_allowed: -5
  )

  comment ~S"""
  === xdr source ============================================================

      union AllowTrustResult switch (AllowTrustResultCode code)
      {
      case ALLOW_TRUST_SUCCESS:
          void;
      default:
          void;
      };

  ===========================================================================
  """
  define_type("AllowTrustResult", Union,
    switch_type: "AllowTrustResultCode",
    switch_name: :code,
    switches: [
      {:allow_trust_success, XDR.Type.Void},
    ],
    arms: [
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      enum AccountMergeResultCode
      {
          // codes considered as "success" for the operation
          ACCOUNT_MERGE_SUCCESS = 0,
          // codes considered as "failure" for the operation
          ACCOUNT_MERGE_MALFORMED = -1,       // can't merge onto itself
          ACCOUNT_MERGE_NO_ACCOUNT = -2,      // destination does not exist
          ACCOUNT_MERGE_IMMUTABLE_SET = -3,   // source account has AUTH_IMMUTABLE set
          ACCOUNT_MERGE_HAS_SUB_ENTRIES = -4, // account has trust lines/offers
          ACCOUNT_MERGE_SEQNUM_TOO_FAR = -5,  // sequence number is over max allowed
          ACCOUNT_MERGE_DEST_FULL = -6        // can't add source balance to
                                              // destination balance
      };

  ===========================================================================
  """
  define_type("AccountMergeResultCode", Enum,
    account_merge_success: 0,
    account_merge_malformed: -1,
    account_merge_no_account: -2,
    account_merge_immutable_set: -3,
    account_merge_has_sub_entry: -4,
    account_merge_seqnum_too_far: -5,
    account_merge_dest_full: -6
  )

  comment ~S"""
  === xdr source ============================================================

      union AccountMergeResult switch (AccountMergeResultCode code)
      {
      case ACCOUNT_MERGE_SUCCESS:
          int64 sourceAccountBalance; // how much got transfered from source account
      default:
          void;
      };

  ===========================================================================
  """
  define_type("AccountMergeResult", Union,
    switch_type: "AccountMergeResultCode",
    switch_name: :code,
    switches: [
      {:account_merge_success, :source_account_balance},
    ],
    arms: [
      source_account_balance: "Int64",
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      enum InflationResultCode
      {
          // codes considered as "success" for the operation
          INFLATION_SUCCESS = 0,
          // codes considered as "failure" for the operation
          INFLATION_NOT_TIME = -1
      };

  ===========================================================================
  """
  define_type("InflationResultCode", Enum,
    inflation_success: 0,
    inflation_not_time: -1
  )

  comment ~S"""
  === xdr source ============================================================

      struct InflationPayout // or use PaymentResultAtom to limit types?
      {
          AccountID destination;
          int64 amount;
      };

  ===========================================================================
  """
  define_type("InflationPayout", Struct,
    destination: "AccountId",
    amount: "Int64"
  )

  comment ~S"""
  === xdr source ============================================================

      union InflationResult switch (InflationResultCode code)
      {
      case INFLATION_SUCCESS:
          InflationPayout payouts<>;
      default:
          void;
      };

  ===========================================================================
  """
  define_type("InflationResult", Union,
    switch_type: "InflationResultCode",
    switch_name: :code,
    switches: [
      {:inflation_success, :payouts},
    ],
    arms: [
      payouts: build_type(VariableArray, max_length: 2147483647, type: "InflationPayout"),
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      enum ManageDataResultCode
      {
          // codes considered as "success" for the operation
          MANAGE_DATA_SUCCESS = 0,
          // codes considered as "failure" for the operation
          MANAGE_DATA_NOT_SUPPORTED_YET =
              -1, // The network hasn't moved to this protocol change yet
          MANAGE_DATA_NAME_NOT_FOUND =
              -2, // Trying to remove a Data Entry that isn't there
          MANAGE_DATA_LOW_RESERVE = -3, // not enough funds to create a new Data Entry
          MANAGE_DATA_INVALID_NAME = -4 // Name not a valid string
      };

  ===========================================================================
  """
  define_type("ManageDataResultCode", Enum,
    manage_data_success: 0,
    manage_data_not_supported_yet: -1,
    manage_data_name_not_found: -2,
    manage_data_low_reserve: -3,
    manage_data_invalid_name: -4
  )

  comment ~S"""
  === xdr source ============================================================

      union ManageDataResult switch (ManageDataResultCode code)
      {
      case MANAGE_DATA_SUCCESS:
          void;
      default:
          void;
      };

  ===========================================================================
  """
  define_type("ManageDataResult", Union,
    switch_type: "ManageDataResultCode",
    switch_name: :code,
    switches: [
      {:manage_data_success, XDR.Type.Void},
    ],
    arms: [
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      enum BumpSequenceResultCode
      {
          // codes considered as "success" for the operation
          BUMP_SEQUENCE_SUCCESS = 0,
          // codes considered as "failure" for the operation
          BUMP_SEQUENCE_BAD_SEQ = -1 // `bumpTo` is not within bounds
      };

  ===========================================================================
  """
  define_type("BumpSequenceResultCode", Enum,
    bump_sequence_success: 0,
    bump_sequence_bad_seq: -1
  )

  comment ~S"""
  === xdr source ============================================================

      union BumpSequenceResult switch (BumpSequenceResultCode code)
      {
      case BUMP_SEQUENCE_SUCCESS:
          void;
      default:
          void;
      };

  ===========================================================================
  """
  define_type("BumpSequenceResult", Union,
    switch_type: "BumpSequenceResultCode",
    switch_name: :code,
    switches: [
      {:bump_sequence_success, XDR.Type.Void},
    ],
    arms: [
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      enum OperationResultCode
      {
          opINNER = 0, // inner object result is valid

          opBAD_AUTH = -1,     // too few valid signatures / wrong network
          opNO_ACCOUNT = -2,   // source account was not found
          opNOT_SUPPORTED = -3 // operation not supported at this time
      };

  ===========================================================================
  """
  define_type("OperationResultCode", Enum,
    op_inner: 0,
    op_bad_auth: -1,
    op_no_account: -2,
    op_not_supported: -3
  )

  comment ~S"""
  === xdr source ============================================================

      union switch (OperationType type)
          {
          case CREATE_ACCOUNT:
              CreateAccountResult createAccountResult;
          case PAYMENT:
              PaymentResult paymentResult;
          case PATH_PAYMENT:
              PathPaymentResult pathPaymentResult;
          case MANAGE_OFFER:
              ManageOfferResult manageOfferResult;
          case CREATE_PASSIVE_OFFER:
              ManageOfferResult createPassiveOfferResult;
          case SET_OPTIONS:
              SetOptionsResult setOptionsResult;
          case CHANGE_TRUST:
              ChangeTrustResult changeTrustResult;
          case ALLOW_TRUST:
              AllowTrustResult allowTrustResult;
          case ACCOUNT_MERGE:
              AccountMergeResult accountMergeResult;
          case INFLATION:
              InflationResult inflationResult;
          case MANAGE_DATA:
              ManageDataResult manageDataResult;
          case BUMP_SEQUENCE:
              BumpSequenceResult bumpSeqResult;
          }

  ===========================================================================
  """
  define_type("OperationResultTr", Union,
    switch_type: "OperationType",
    switch_name: :type,
    switches: [
      {:create_account, :create_account_result},
      {:payment, :payment_result},
      {:path_payment, :path_payment_result},
      {:manage_offer, :manage_offer_result},
      {:create_passive_offer, :create_passive_offer_result},
      {:set_option, :set_options_result},
      {:change_trust, :change_trust_result},
      {:allow_trust, :allow_trust_result},
      {:account_merge, :account_merge_result},
      {:inflation, :inflation_result},
      {:manage_datum, :manage_data_result},
      {:bump_sequence, :bump_seq_result},
    ],
    arms: [
      create_account_result: "CreateAccountResult",
      payment_result: "PaymentResult",
      path_payment_result: "PathPaymentResult",
      manage_offer_result: "ManageOfferResult",
      create_passive_offer_result: "ManageOfferResult",
      set_options_result: "SetOptionsResult",
      change_trust_result: "ChangeTrustResult",
      allow_trust_result: "AllowTrustResult",
      account_merge_result: "AccountMergeResult",
      inflation_result: "InflationResult",
      manage_data_result: "ManageDataResult",
      bump_seq_result: "BumpSequenceResult",
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      union OperationResult switch (OperationResultCode code)
      {
      case opINNER:
          union switch (OperationType type)
          {
          case CREATE_ACCOUNT:
              CreateAccountResult createAccountResult;
          case PAYMENT:
              PaymentResult paymentResult;
          case PATH_PAYMENT:
              PathPaymentResult pathPaymentResult;
          case MANAGE_OFFER:
              ManageOfferResult manageOfferResult;
          case CREATE_PASSIVE_OFFER:
              ManageOfferResult createPassiveOfferResult;
          case SET_OPTIONS:
              SetOptionsResult setOptionsResult;
          case CHANGE_TRUST:
              ChangeTrustResult changeTrustResult;
          case ALLOW_TRUST:
              AllowTrustResult allowTrustResult;
          case ACCOUNT_MERGE:
              AccountMergeResult accountMergeResult;
          case INFLATION:
              InflationResult inflationResult;
          case MANAGE_DATA:
              ManageDataResult manageDataResult;
          case BUMP_SEQUENCE:
              BumpSequenceResult bumpSeqResult;
          }
          tr;
      default:
          void;
      };

  ===========================================================================
  """
  define_type("OperationResult", Union,
    switch_type: "OperationResultCode",
    switch_name: :code,
    switches: [
      {:op_inner, :tr},
    ],
    arms: [
      tr: "OperationResultTr",
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      enum TransactionResultCode
      {
          txSUCCESS = 0, // all operations succeeded

          txFAILED = -1, // one of the operations failed (none were applied)

          txTOO_EARLY = -2,         // ledger closeTime before minTime
          txTOO_LATE = -3,          // ledger closeTime after maxTime
          txMISSING_OPERATION = -4, // no operation was specified
          txBAD_SEQ = -5,           // sequence number does not match source account

          txBAD_AUTH = -6,             // too few valid signatures / wrong network
          txINSUFFICIENT_BALANCE = -7, // fee would bring account below reserve
          txNO_ACCOUNT = -8,           // source account not found
          txINSUFFICIENT_FEE = -9,     // fee is too small
          txBAD_AUTH_EXTRA = -10,      // unused signatures attached to transaction
          txINTERNAL_ERROR = -11       // an unknown error occured
      };

  ===========================================================================
  """
  define_type("TransactionResultCode", Enum,
    tx_success: 0,
    tx_failed: -1,
    tx_too_early: -2,
    tx_too_late: -3,
    tx_missing_operation: -4,
    tx_bad_seq: -5,
    tx_bad_auth: -6,
    tx_insufficient_balance: -7,
    tx_no_account: -8,
    tx_insufficient_fee: -9,
    tx_bad_auth_extra: -10,
    tx_internal_error: -11
  )

  comment ~S"""
  === xdr source ============================================================

      union switch (TransactionResultCode code)
          {
          case txSUCCESS:
          case txFAILED:
              OperationResult results<>;
          default:
              void;
          }

  ===========================================================================
  """
  define_type("TransactionResultResult", Union,
    switch_type: "TransactionResultCode",
    switch_name: :code,
    switches: [
      {:tx_success, :results},
      {:tx_failed, :results},
    ],
    arms: [
      results: build_type(VariableArray, max_length: 2147483647, type: "OperationResult"),
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      union switch (int v)
          {
          case 0:
              void;
          }

  ===========================================================================
  """
  define_type("TransactionResultExt", Union,
    switch_type: build_type(Int),
    switch_name: :v,
    switches: [
      {0, XDR.Type.Void},
    ],
    arms: [
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      struct TransactionResult
      {
          int64 feeCharged; // actual fee charged for the transaction

          union switch (TransactionResultCode code)
          {
          case txSUCCESS:
          case txFAILED:
              OperationResult results<>;
          default:
              void;
          }
          result;

          // reserved for future use
          union switch (int v)
          {
          case 0:
              void;
          }
          ext;
      };

  ===========================================================================
  """
  define_type("TransactionResult", Struct,
    fee_charged: "Int64",
    result: "TransactionResultResult",
    ext: "TransactionResultExt"
  )

  comment ~S"""
  === xdr source ============================================================

      typedef opaque Hash[32];

  ===========================================================================
  """
  define_type("Hash", Opaque, 32)

  comment ~S"""
  === xdr source ============================================================

      typedef opaque uint256[32];

  ===========================================================================
  """
  define_type("Uint256", Opaque, 32)

  comment ~S"""
  === xdr source ============================================================

      typedef unsigned int uint32;

  ===========================================================================
  """
  define_type("Uint32", UnsignedInt)

  comment ~S"""
  === xdr source ============================================================

      typedef int int32;

  ===========================================================================
  """
  define_type("Int32", Int)

  comment ~S"""
  === xdr source ============================================================

      typedef unsigned hyper uint64;

  ===========================================================================
  """
  define_type("Uint64", UnsignedHyperInt)

  comment ~S"""
  === xdr source ============================================================

      typedef hyper int64;

  ===========================================================================
  """
  define_type("Int64", HyperInt)

  comment ~S"""
  === xdr source ============================================================

      enum CryptoKeyType
      {
          KEY_TYPE_ED25519 = 0,
          KEY_TYPE_PRE_AUTH_TX = 1,
          KEY_TYPE_HASH_X = 2
      };

  ===========================================================================
  """
  define_type("CryptoKeyType", Enum,
    key_type_ed25519: 0,
    key_type_pre_auth_tx: 1,
    key_type_hash_x: 2
  )

  comment ~S"""
  === xdr source ============================================================

      enum PublicKeyType
      {
          PUBLIC_KEY_TYPE_ED25519 = KEY_TYPE_ED25519
      };

  ===========================================================================
  """
  define_type("PublicKeyType", Enum,
    public_key_type_ed25519: 0
  )

  comment ~S"""
  === xdr source ============================================================

      enum SignerKeyType
      {
          SIGNER_KEY_TYPE_ED25519 = KEY_TYPE_ED25519,
          SIGNER_KEY_TYPE_PRE_AUTH_TX = KEY_TYPE_PRE_AUTH_TX,
          SIGNER_KEY_TYPE_HASH_X = KEY_TYPE_HASH_X
      };

  ===========================================================================
  """
  define_type("SignerKeyType", Enum,
    signer_key_type_ed25519: 0,
    signer_key_type_pre_auth_tx: 1,
    signer_key_type_hash_x: 2
  )

  comment ~S"""
  === xdr source ============================================================

      union PublicKey switch (PublicKeyType type)
      {
      case PUBLIC_KEY_TYPE_ED25519:
          uint256 ed25519;
      };

  ===========================================================================
  """
  define_type("PublicKey", Union,
    switch_type: "PublicKeyType",
    switch_name: :type,
    switches: [
      {:public_key_type_ed25519, :ed25519},
    ],
    arms: [
      ed25519: "Uint256",
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      union SignerKey switch (SignerKeyType type)
      {
      case SIGNER_KEY_TYPE_ED25519:
          uint256 ed25519;
      case SIGNER_KEY_TYPE_PRE_AUTH_TX:
          /* SHA-256 Hash of TransactionSignaturePayload structure */
          uint256 preAuthTx;
      case SIGNER_KEY_TYPE_HASH_X:
          /* Hash of random 256 bit preimage X */
          uint256 hashX;
      };

  ===========================================================================
  """
  define_type("SignerKey", Union,
    switch_type: "SignerKeyType",
    switch_name: :type,
    switches: [
      {:signer_key_type_ed25519, :ed25519},
      {:signer_key_type_pre_auth_tx, :pre_auth_tx},
      {:signer_key_type_hash_x, :hash_x},
    ],
    arms: [
      ed25519: "Uint256",
      pre_auth_tx: "Uint256",
      hash_x: "Uint256",
    ]
  )

  comment ~S"""
  === xdr source ============================================================

      typedef opaque Signature<64>;

  ===========================================================================
  """
  define_type("Signature", VariableOpaque, 64)

  comment ~S"""
  === xdr source ============================================================

      typedef opaque SignatureHint[4];

  ===========================================================================
  """
  define_type("SignatureHint", Opaque, 4)

  comment ~S"""
  === xdr source ============================================================

      typedef PublicKey NodeID;

  ===========================================================================
  """
  define_type("NodeId", "PublicKey")

  comment ~S"""
  === xdr source ============================================================

      struct Curve25519Secret
      {
              opaque key[32];
      };

  ===========================================================================
  """
  define_type("Curve25519Secret", Struct,
    key: build_type(Opaque, 32)
  )

  comment ~S"""
  === xdr source ============================================================

      struct Curve25519Public
      {
              opaque key[32];
      };

  ===========================================================================
  """
  define_type("Curve25519Public", Struct,
    key: build_type(Opaque, 32)
  )

  comment ~S"""
  === xdr source ============================================================

      struct HmacSha256Key
      {
              opaque key[32];
      };

  ===========================================================================
  """
  define_type("HmacSha256Key", Struct,
    key: build_type(Opaque, 32)
  )

  comment ~S"""
  === xdr source ============================================================

      struct HmacSha256Mac
      {
              opaque mac[32];
      };

  ===========================================================================
  """
  define_type("HmacSha256Mac", Struct,
    mac: build_type(Opaque, 32)
  )

end
