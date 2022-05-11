// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
pragma abicoder v2;
import "./IBEP20.sol";

interface QubeLaunchPadV1 {
    struct userData {
        address userAddress;
        IBEP20 saleToken;
        uint256 idoID;
        uint256 lockedAmount;
        uint256 releasedAmount;
        uint256 lockedDuration;
        uint256 lastClaimed;
        uint256 unlockCount;
        uint256 installmentMonths;
        uint256 distributeROI;        
    }

    function userLockInfo(uint256) external view returns (userData memory);
    function userLockContains(address account,uint256 value) external view returns (bool);
    function userLockLength(address account) external view returns (uint256);
    function userLockAt(address account,uint256 index) external view returns (uint256);
    function userTotalLockIds(address account) external view returns (uint256[] memory);
}