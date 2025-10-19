## dapp

[iousdc.eth.limo](https://iousdc.eth.limo/)

## gas abstraction ("free stablecoin transfers on ethereum")

Transfer authorizations can be played by anyone with the signature and transfer details. These are provided in .txt files by the dapp. 

Refund with ETH PoS yield is possible with a smart contract that relays via `payUSDCWithRefund(address from,address to,uint256 value,uint256 validAfter,uint256 validBefore,bytes32 nonce,bytes signature)`.

Simple (communal) refund contract is deployed on Ethereum at the following address: [0xbd34b384322215C90e00E4BF5e776f615C135903](https://etherscan.io/address/0xbd34b384322215c90e00e4bf5e776f615c135903#code)

This basically holds `wstETH` (anyone can tip the pot via `stakeETHForRefund()` to wrap ETH into `wstETH` for public sponsorship).

When anyone relays USDC auths via refunder contract, the contract estimates the gas cost of the relay, and subsidizes the tx by swapping wstETH for ETH via the liquid UniV3 lowest-fee pool.

## self-sponsor ("you pay their gas with yield")

Similarly, a variant that allows you to sponsor gas for your payment recipient is deployed to ethereum at the following address: [0xFc6E2C8c4866b5e232b6419E47D650EDf5E7fA8c](https://etherscan.io/address/0xfc6e2c8c4866b5e232b6419e47d650edf5e7fa8c#code)

1) Approve 0xFc6E2C8c4866b5e232b6419E47D650EDf5E7fA8c as spender for your wstETH (you should hold a couple bucks worth)

- [https://etherscan.io/token/0x7f39c581f595b53c5cb19bd0b3f8da6c935e2ca0#writeContract#F1](https://etherscan.io/token/0x7f39c581f595b53c5cb19bd0b3f8da6c935e2ca0#writeContract#F1)

2) You, your recipient, or a relayer (anyone) can then process the payment and receive refund. Use the same params as the community pot variant (above) and call:

```solidity
function payUSDCWithRefund(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        bytes calldata signature
    ) public {
```

And use the params provided by the IOUSDC.eth.limo .txt file relates to slip payments:


<img width="660" height="374" alt="Screenshot 2025-10-19 at 3 50 26 PM" src="https://github.com/user-attachments/assets/26378304-c455-49ed-a082-f63ce4bb285d" />
