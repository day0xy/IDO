# IDO Contract

This contract implements a Token Pre-sale (IDO) with the following functionalities:

## Features

1. **Start Pre-sale**:
   - Enable pre-sale for any given ERC20 token.
   - Set the pre-sale price, fundraising target in ETH, over-funding limit, and pre-sale duration.
2. **User Participation**:
   - Any user can participate in the pre-sale by paying ETH.
3. **Refund Mechanism**:
   - If the fundraising target is not met by the end of the pre-sale, users are able to claim a refund.
4. **Token Distribution**:
   - If the pre-sale is successful, users can claim their tokens.
   - The project owner can withdraw the raised ETH.

## Usage

- Deploy the contract with the necessary parameters.
- Users can interact to participate in the pre-sale.
- Ensure proper handling of refunds and token distribution post pre-sale.

## Requirements

- Solidity version: [Specify version]
- ERC20 Token contract: [Link or specify requirements]

## License

This project is licensed under the MIT License.