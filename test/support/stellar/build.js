const fs = require('fs');
const path = require('path');
const StellarBase = require('stellar-base');

const pubKeyOne = 'GD6WU64OEP5C4LRBH6NK3MHYIA2ADN6K6II6EXPNVUR3ERBXT4AN4ACD'
const pubKeyTwo = 'GASOCNHNNLYFNMDJYQ3XFMI7BYHIOCFW3GJEOWRPEGK2TDPGTG2E5EDW'
const pubKeyOneRaw = StellarBase.StrKey.decodeEd25519PublicKey(pubKeyOne)
const pubKeyTwoRaw = StellarBase.StrKey.decodeEd25519PublicKey(pubKeyTwo)

const address = new StellarBase.Account(pubKeyOne,'2319149195853854');

function writeTransaction() {
  const transaction = new StellarBase.TransactionBuilder(address, { fee: 100, networkPassphrase: StellarBase.Networks.TESTNET })
    // add a payment operation to the transaction
    .addOperation(StellarBase.Operation.payment({
      destination: pubKeyTwo,
      asset: StellarBase.Asset.native(),
      amount: '0.0001'  // 1000 Stroop
    }))
    .setTimeout(StellarBase.TimeoutInfinite)
    .build();

  fs.writeFileSync(
    path.join(__dirname, './transaction.xdr'),
    transaction.toEnvelope().toXDR('base64')
  );
}

function readTransaction(path) {
  const binary = fs.readFileSync(path).toString();
  const trx = new StellarBase.Transaction(binary, StellarBase.Networks.TESTNET);
  console.log(trx);
}

const trxPath = path.join(__dirname, './transaction.xdr')
fs.writeFileSync(path.join(__dirname, 'pubkey_01'), pubKeyOneRaw)
fs.writeFileSync(path.join(__dirname, 'pubkey_02'), pubKeyTwoRaw)
writeTransaction(trxPath)
// readTransaction(trxPath)
