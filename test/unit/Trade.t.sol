// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test, console } from "forge-std/Test.sol";
import { Trade } from "../../src/Trade.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TradeTest is Test {

    Trade trade;

    address quoter = 0x3d4e44Eb1374240CE5F1B871ab261CD16335B76a;
    address router = 0x2626664c2603336E57B271c5C0b26F421741e481;
    address USDT = makeAddr("USDT");
    address WETH = makeAddr("USDT");
    address USER = makeAddr("USER");

    function setUp() public {
        trade = new Trade(quoter, router);
    }

    function test_exactInputSwap() public {
        uint256 amountIn = 5e6;
        uint24 slippage = 5; 

        Trade.SwapExactInputParams memory params = Trade.SwapExactInputParams(USDT, WETH, amountIn, slippage);
        // approving contract
        IERC20(USDT).approve(address(trade), amountIn);
        trade.swapExactInput(params);

        console.log("swapped");
    }

    function testSlippageCalculations() public {
         uint256 slippageTol = (100e18 * (100 - 6)) / 100; 

        console.log(slippageTol);
        // 94000_000_000_000_000_000
        // 94000_000_000_000_000_000
    }
}