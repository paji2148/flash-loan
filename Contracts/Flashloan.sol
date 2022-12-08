// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IUniswapV2Factory{
   event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Callee {
    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external;
}

interface IUniswapV2Pair {
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function token0() external view returns (address);
    function token1() external view returns (address);
}

interface IUniswapV2Router02 {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface  SwapDex3X{
     function swap3X(uint256 amount, address token1, address token2, address from) external;
}

contract ExampleFlashSwap33 is IUniswapV2Callee {
    address factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    IUniswapV2Router02 public uniswapV2Router;
    address public token1;
    address public token2;
    uint256 public extra;
    address public pairAddress;
    address public dex2;

    constructor(address atoken1, address atoken2, address _dex2){
        token1 = atoken1;
        token2 = atoken2;
        dex2 = _dex2;
        pairAddress = IUniswapV2Factory(factory).getPair(token1, token2);
        IERC20(token1).approve(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 10000000000000000000000000000000000000000);
        IERC20(token2).approve(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 10000000000000000000000000000000000000000);
        IERC20(token1).approve(dex2, 10000000000000000000000000000000000000000);
        IERC20(token2).approve(dex2, 10000000000000000000000000000000000000000);
    }

    receive() external payable {}

    function startFlashLoan(
    uint amount0, 
    uint amount1,
    uint _extra
  ) external {
    extra = _extra;
    IUniswapV2Pair(pairAddress).swap(amount0, amount1, address(this), bytes('not empty'));
  }

    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external override {
        address token0 = IUniswapV2Pair(pairAddress).token0();
        address token1 = IUniswapV2Pair(pairAddress).token1();
        SwapDex3X(dex2).swap3X(amount0, token0, token1, address(this));
        IERC20(token1).transfer(msg.sender, amount0 + extra);
    }
}