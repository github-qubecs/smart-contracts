// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
pragma abicoder v2;

interface QubeStakeFactory {
    struct userData {
        address user;
        uint256 stakeTime;
        uint256 deadLine;
        uint256 claimTime;
        uint256 stakeAmount;
        uint256 totalRewards;
    }
    function userInfo(uint256 user) external view returns (userData memory);
    function userTickets(address user) external view returns (uint256[] memory);
}