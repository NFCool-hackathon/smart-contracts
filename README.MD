# NFCool Smart Contracts

## About / Synopsis

Smart Contracts designed to link real-world items to blockchain, providing two main solutions:
- Authenticity (through NFC verification)
- Ownership (through Phone Verification using Chainlink Services)

### ERC1155 derived

`NFCool.sol` is a ERC1155 based smart contract, implementing a **unit** aspect. 
On the ERC1155 standard, we can only track user balances, which do not allow us to know who own a specific token, which would be a little bit annoying to represent real-wold items.

To fix this problem, we implemented a new mapping, allowing us to track units of our tokens:
`mapping(uint256 => mapping(uint256 => TokenUnitData)) private _tokenUnitData;`

### ACCESS Roles

- **Admin**: can grant and revoke roles
- **Minter**: can mint tokens (amount = 0) 
- **Supplier**: can mint units (amount = 1)
- **Seller**: can set the status of a unit to `sold`

## Installation

* ``npm install``

## Usage

### Features

* Mint a token (amount  = 0)
* Mint a unit (amount = 1)
* Track unit instead of only tracking balances
* Update unit status values following the current workflow:  
`minted` -> `sold` -> `owned` -> `stolen` 

### Contracts

- `NFCool.sol`: main contract, implementing the token unit system, and status workflow
- `ERC1155Access.sol`: implementing the roles 
- `PhoneVerification.sol`: implementing the chainlink interactions through a request function and a fulfill function

### Build

    truffle compile

### Testing

For unit testing:
``truffle test``

For terminal testing: ``truffle develop``

### Deploy 

1. Deploy the `PhoneVerification.sol` contract
2. Deploy the `NFCool.sol` contract using the `PhoneVerification.sol` contract address in parameter
3. Call the `PhoneVerification.sol` function `setCallerContract` with the `NFCool.sol` contract address as parameter
