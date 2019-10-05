const fs = require('fs');
const path = require('path');
const StellarBase = require('stellar-base');

const pubKeyOne = 'GD6WU64OEP5C4LRBH6NK3MHYIA2ADN6K6II6EXPNVUR3ERBXT4AN4ACD'
const pubKeyTwo = 'GASOCNHNNLYFNMDJYQ3XFMI7BYHIOCFW3GJEOWRPEGK2TDPGTG2E5EDW'
const pubKeyOneRaw = StellarBase.StrKey.decodeEd25519PublicKey(pubKeyOne)
const pubKeyTwoRaw = StellarBase.StrKey.decodeEd25519PublicKey(pubKeyTwo)
const fixturePath = path.join(__dirname, '../../fixtures/stellar');

const address = new StellarBase.Account(pubKeyOne,'2319149195853854');

function writeTransaction(path) {
  const transaction = new StellarBase.TransactionBuilder(address, { fee: 100, networkPassphrase: StellarBase.Networks.TESTNET })
    .addOperation(StellarBase.Operation.payment({
      destination: pubKeyTwo,
      asset: StellarBase.Asset.native(),
      amount: '0.0001'  // 1000 Stroop
    }))
    .setTimeout(StellarBase.TimeoutInfinite)
    .build();

  fs.writeFileSync(path, transaction.toEnvelope().tx().toXDR());
}

// for debugging
function readTransaction(path) {
  const buffer = fs.readFileSync(path);
  const trx = StellarBase.xdr.Transaction.fromXDR(buffer);
  console.log(trx);
}

const trxPath = path.join(fixturePath, './transaction.xdr')
fs.writeFileSync(path.join(fixturePath, 'pubkey_01'), pubKeyOneRaw)
fs.writeFileSync(path.join(fixturePath, 'pubkey_02'), pubKeyTwoRaw)
writeTransaction(trxPath)
