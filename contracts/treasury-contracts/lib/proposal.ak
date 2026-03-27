use aiken/cbor
use aiken/primitive/bytearray
use cardano/transaction.{OutputReference}
use sundae/multisig.{AllOf, AnyOf, AtLeast, MultisigScript, Signature}
use types.{
  TreasuryConfiguration, TreasuryPermissions, VendorConfiguration,
  VendorPermissions,
}

// Seed UTxO
fn seed_utxo() -> OutputReference {
  OutputReference {
    transaction_id: #"f527414edcb7e9f8c44aa9e7ea08000716251c81287ed731b6ed155a0035c04a",
    output_index: 0,
  }
}

// Proposer / Vendor entity (Hlabs - Michele Nuzzi)
fn hlabs() -> MultisigScript {
  Signature {
    key_hash: #"7f0e0f6fb80bbfada6e78876ebdf151b87d93630fd844cebd4e641de",
  }
}

// Oversight board entities

fn santiago_carmuega() -> MultisigScript {
  Signature {
    key_hash: #"946a76ec4564f793d643cb13ff900f2ec578bcd521addab275af5ebb",
  }
}

fn chris_gianelloni() -> MultisigScript {
  Signature {
    key_hash: #"058a5ab0c66647dcce82d7244f80bfea41ba76c7c9ccaf86a41b00fe",
  }
}

fn lucas_rosa() -> MultisigScript {
  Signature {
    key_hash: #"ccc4a58ebc9aa058cd0dee6f84e4de39e23574a054e405b0ca467a88",
  }
}

// Groups

fn oversight_board() -> List<MultisigScript> {
  [santiago_carmuega(), chris_gianelloni(), lucas_rosa()]
}

// Treasury Permissions

fn reorganize() -> MultisigScript {
  hlabs()
}

fn sweep_treasury() -> MultisigScript {
  AllOf {
    scripts: [hlabs(), AnyOf { scripts: oversight_board() }],
  }
}

fn fund() -> MultisigScript {
  AtLeast { required: 2, scripts: oversight_board() }
}

fn disburse() -> MultisigScript {
  AllOf {
    scripts: [hlabs(), AnyOf { scripts: oversight_board() }],
  }
}

// Vendor Permissions

fn pause() -> MultisigScript {
  AnyOf { scripts: oversight_board() }
}

fn resume() -> MultisigScript {
  AtLeast { required: 2, scripts: oversight_board() }
}

fn modify() -> MultisigScript {
  AllOf {
    scripts: [hlabs(), AtLeast { required: 2, scripts: oversight_board() }],
  }
}

// Configuration

pub fn registry_token() {
  #"ce87368e260c74aeb6c271cbb4bece2e6ed94405d946725e97d2e7ba"
}

pub fn treasury_expiration() {
  1893456000000
}

pub fn payout_upperbound() {
  1896134400000
}

pub fn vendor_expiration() {
  1898812800000
}

pub fn treasury_configuration() -> TreasuryConfiguration {
  TreasuryConfiguration {
    registry_token: registry_token(),
    permissions: TreasuryPermissions {
      reorganize: reorganize(),
      sweep: sweep_treasury(),
      fund: fund(),
      disburse: disburse(),
    },
    expiration: treasury_expiration(),
    payout_upperbound: payout_upperbound(),
  }
}

pub fn vendor_configuration() -> VendorConfiguration {
  VendorConfiguration {
    registry_token: registry_token(),
    permissions: VendorPermissions {
      pause: pause(),
      resume: resume(),
      modify: modify(),
    },
    expiration: vendor_expiration(),
  }
}

// Display tests — trace CBOR hex for extraction

test display_seed_utxo() {
  trace bytearray.to_hex(cbor.serialise(seed_utxo()))
  True
}

test display_treasury_config() {
  trace bytearray.to_hex(cbor.serialise(treasury_configuration()))
  True
}

test display_vendor_config() {
  trace bytearray.to_hex(cbor.serialise(vendor_configuration()))
  True
}
