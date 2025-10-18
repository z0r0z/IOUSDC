## dapp

[iousdc.eth.limo](https://iousdc.eth.limo/)

## gas abstraction ("free stablecoin transfers on ethereum")

Transfer authorizations can be played by anyone with the signature and transfer details. These are provided in .txt files by the dapp. 

Refund with ETH PoS yield is possible with a smart contract that relays via `payUSDCWithRefund(address from,address to,uint256 value,uint256 validAfter,uint256 validBefore,bytes32 nonce,bytes signature)`.

Simple (communal) refund contract is deployed on Ethereum at the following address: [0xbd34b384322215C90e00E4BF5e776f615C135903](https://etherscan.io/address/0xbd34b384322215c90e00e4bf5e776f615c135903#code)

This basically holds `wstETH` (anyone can tip the pot via `stakeETHForRefund()` to wrap ETH into `wstETH` for public sponsorship).

When anyone relays USDC auths via refunder contract, the contract estimates the gas cost of the relay, and subsidizes the tx by swapping wstETH for ETH via the liquid UniV3 lowest-fee pool.

Roughly 75% of cost is covered this way (but can be fully subsidized after PoC by introducing faucet-like security guards).
