// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test, console } from "forge-std/Test.sol";
import { YoloTrade } from "../../src/YoloTrade.sol";
import { IUniswapV3Factory } from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import { IQuoterV2 } from "@uniswap/v3-periphery/contracts/interfaces/IQuoterV2.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TradeTest is Test {

    YoloTrade trade;
    IQuoterV2 quoter_v2;
    IUniswapV3Factory poolFactory;

    address quoter = 0x61fFE014bA17989E743c5F6cB21bF9697530B21e;
    address router = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;
    address pool_factory = 0x1F98431c8aD98523631AE4a59f267346ea31F984 ;
    uint256 POOL_FEE = 3000;
    address USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address PEPE = 0x6982508145454Ce325dDbE47a25d4ec3d2311933;
    address DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address USER = 0x36FDBe7005414fA1611330Dc7E18725eD4A75600;

    function setUp() public {
        trade = new YoloTrade(router, quoter);
        poolFactory = IUniswapV3Factory(pool_factory);
        quoter_v2 = IQuoterV2(quoter);

        uint256 userBal = IERC20(USDT).balanceOf(USER);
        console.log("balance of ", USDT, USER);
    }

    function test_exactInputSwap() public {
        uint256 amountIn = 100e6;
        uint24 slippage = 5; 
        // swapping from USDT is not working for some reason
        vm.startPrank(USER);
        YoloTrade.SwapExactInputParams memory params = YoloTrade.SwapExactInputParams(USDC, WBTC, amountIn, slippage);
        // approving contract
        IERC20(USDC).approve(address(trade), amountIn);
        trade.swapExactInput(params);
        vm.stopPrank();

        console.log("swapped");
    }

    function test_exactOutputSwap() public {
        uint256 outAmt = 3e4;
       
        uint24 slippageTol = 2;
        vm.startPrank(USER);
        YoloTrade.SwapExactOutputParams memory params = YoloTrade.SwapExactOutputParams(
            DAI,
            WBTC,
            outAmt,
            slippageTol
        );
         bytes memory path = abi.encodePacked(params.tokenIn, POOL_FEE, params.tokenOut);
        (uint256 maxAmtIn, , , ) = quoter_v2.quoteExactOutput(path, outAmt);
        IERC20(DAI).approve(address(trade), maxAmtIn);
        uint256 inAmt = trade.swapExactOutput(params);
        vm.stopPrank();

        console.log("amountIN", inAmt);
    }

    function test_gettingPool() public {
        vm.prank(USER);
        address poolAddr = poolFactory.getPool(DAI, WBTC, 3000);
        console.log("getting pool", poolAddr);
    }

    function test_checkBalance() public {
       uint256 userBalance =  IERC20(USDT).balanceOf(USER);
       console.log("user balance", userBalance);
    }

    function testSlippageCalculations() public pure{
         uint256 slippageTol = (100e18 * (100 - 6)) / 100; 

        console.log(slippageTol);
     
    }
}