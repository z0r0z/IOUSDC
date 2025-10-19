// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract RefundableUSDCPayment {
    uint256 constant REFUND_BASE_GAS         = 60_000;
    uint256 constant MAX_REFUND_GAS_USED     = 150_000;
    uint256 constant MAX_REFUND_BASE_FEE     = 150 gwei;
    uint256 constant MAX_REFUND_PRIORITY_FEE = 3 gwei;

    uint256 constant MAX_REFUND_ETH          = 0.025 ether;
    uint256 constant REFUND_MULTIPLIER_BPS   = 9_500; // 95%
    uint256 constant BPS_DENOM               = 10_000;

    constructor() payable {}

    function stakeETHForRefund() public payable {
        assembly ("memory-safe") {
            pop(call(gas(), WSTETH, selfbalance(), codesize(), 0x00, codesize(), 0x00))
        }
    }

    function payUSDCWithRefund(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        bytes calldata signature
    ) public {
        unchecked {
            uint256 startGas = gasleft();
            USDC.transferWithAuthorization(from, to, value, validAfter, validBefore, nonce, signature);

            uint256 basefee = min(block.basefee, MAX_REFUND_BASE_FEE);
            uint256 gasPrice = min(tx.gasprice, basefee + MAX_REFUND_PRIORITY_FEE);
            uint256 gasUsed = min(startGas - gasleft() + REFUND_BASE_GAS, MAX_REFUND_GAS_USED);

            uint256 refundAmount = gasPrice * gasUsed;

            refundAmount = (refundAmount * REFUND_MULTIPLIER_BPS) / BPS_DENOM;
            refundAmount = min(refundAmount, MAX_REFUND_ETH);

            if (refundAmount == 0) return;

            IV3Swap(POOL).swap(
                address(this),
                true,
                -int256(refundAmount),
                MIN_SQRT_RATIO_PLUS_ONE,
                ""
            );
        }
    }

    error Unauthorized();

    receive() external payable {}

    fallback() external payable {
        unchecked {
            int256 amount0Delta;
            int256 amount1Delta;
            assembly ("memory-safe") {
                amount0Delta := calldataload(0x4)
                amount1Delta := calldataload(0x24)
            }
            require(msg.sender == POOL, Unauthorized());
            assembly ("memory-safe") {
                mstore(0x14, POOL)
                mstore(0x34, amount0Delta)
                mstore(0x00, 0xa9059cbb000000000000000000000000)
                pop(call(gas(), WSTETH, 0, 0x10, 0x44, codesize(), 0x00))
                mstore(0x34, 0)
            }
            uint256 amountOut = uint256(-(amount1Delta));
            assembly ("memory-safe") {
                mstore(0x00, 0x2e1a7d4d)
                mstore(0x20, amountOut)
                pop(call(gas(), WETH, 0, 0x1c, 0x24, codesize(), 0x00))
                pop(call(gas(), origin(), amountOut, codesize(), 0x00, codesize(), 0x00))
            }
        }
    }
}

function min(uint256 a, uint256 b) pure returns (uint256) {
    return a < b ? a : b;
}

IUSDC constant USDC = IUSDC(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

interface IUSDC {
     function transferWithAuthorization(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        bytes memory signature
    ) external;
}

uint160 constant MIN_SQRT_RATIO_PLUS_ONE = 4295128740;
address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
address constant POOL = 0x109830a1AAaD605BbF02a9dFA7B0B92EC2FB7dAa;
address constant WSTETH = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;

interface IV3Swap {
    function swap(address, bool, int256, uint160, bytes calldata)
        external
        returns (int256, int256);
}
