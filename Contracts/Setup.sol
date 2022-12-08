
// SPDX-License-Identifier: UNLICENCED

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract QuicksilverToken is ERC20 {
    constructor(string memory name, string memory symbol, address mintTo) ERC20(name, symbol) {
        _mint(mintTo, 100000000000000000000000000000000000);
    }
}

interface UniswapInterface{
   function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
}

contract SwapDex3X {

    receive() external payable {}

    function swap3X(uint256 amount, address token1, address token2, address from) external {
        IERC20(token1).transferFrom(from, address(this), amount);
        IERC20(token2).transfer(msg.sender, amount * 3);
    }

}

contract FlashloanTarget {
    address immutable factory;
    QuicksilverToken public QuicksilverA;
    QuicksilverToken public QuicksilverB;
    SwapDex3X public Swap3X;

    constructor() {
        QuicksilverA = new QuicksilverToken("QuicksilverA", "1", address(this));
        QuicksilverB = new QuicksilverToken("QuicksilverA", "2", address(this));
        Swap3X = new SwapDex3X();
        QuicksilverA.transfer(address(Swap3X), 1000000000000000000000000000);
        QuicksilverB.transfer(address(Swap3X), 1000000000000000000000000000);
        factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;

        QuicksilverA.approve(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 10000000000000000000000000000000000000000);
        QuicksilverB.approve(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 10000000000000000000000000000000000000000);
      
        // add liquidity
        UniswapInterface(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D).addLiquidity(address(QuicksilverA), address(QuicksilverB),
        1000000000000000000000000, 1000000000000000000000000, 0, 0, 0x693F42Ae42b495f6a560674e9D47F38beBfa7F0C, block.timestamp);
    }

    receive() external payable {}

}