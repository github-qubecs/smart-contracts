/**
 *Submitted for verification at BscScan.com on 2022-01-05
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import "./QubePresale.sol";
import "./IBEP20.sol";
import "./Ownable.sol";
import "./PancakePair.sol";
import "./SafeMath.sol";
import "./QubeStakeFactory.sol";
import "./IERC1155.sol"; 


interface IQubeBalance {
    function qubeBalance(address walletAddress) external view returns (uint256);
    function qubeBalanceWithNFT(address walletAddress) external view returns (uint256);
}

contract QubeBalance is Ownable{
    struct userData {
        address user;
        uint256 stakeTime;
        uint256 deadLine;
        uint256 claimTime;
        uint256 stakeAmount;
        uint256 totalRewards;
    }
    using SafeMath for uint256;

    IBEP20 public qube;
    QubePresale public qubePresale;
    IPancakePair public pancakePair;
    QubeStakeFactory public qubeStakeFactory;
    IERC1155 public silver;
    IERC1155 public gold;
    IERC1155 public diamond;




    constructor() {

    }    


    function setQube(IBEP20 _qube) public onlyOwner{
        qube=_qube;
    }
    function setQubePresale(QubePresale _qubePresale) public onlyOwner{
        qubePresale=_qubePresale;
    }
    function setQubePancakePair(IPancakePair _pancakePair) public onlyOwner{
        pancakePair=_pancakePair;
    }
    function setQubeStake(QubeStakeFactory _qubeStakeFactory) public onlyOwner{
        qubeStakeFactory=_qubeStakeFactory;
    }
    function setSilver(IERC1155 _silver) public onlyOwner{
        silver=_silver;
    }
    function setGold(IERC1155 _gold) public onlyOwner{
        gold=_gold;
    }
    function setDiamond(IERC1155 _diamond) public onlyOwner{
        diamond=_diamond;
    }

    function getQubeBalance(address walletAddress)public view returns (uint256){
        return qube.balanceOf(walletAddress);
    }
    function getQubePresaleBalance(address walletAddress)public view returns (uint256){
        return qubePresale.qubeBalanceOf(walletAddress);
    }
    function getPancakePairBalance(address walletAddress)public view returns (uint256){
        uint112 _qubeBalance;
        uint112 _USDTBalance;
        uint32 _blockTimestampLast;
        (_qubeBalance, _USDTBalance, _blockTimestampLast) = pancakePair.getReserves();

        uint256 _LP = uint256(_qubeBalance).div(uint256(_USDTBalance));
        uint256 _balanceOf=pancakePair.balanceOf(walletAddress);
        return _LP.mul(_balanceOf);
    }
    function getQubeStakeFactoryBalance(address walletAddress)public view returns(uint256){
        uint256 _balance;
        uint256[] memory tickets = qubeStakeFactory.userTickets(walletAddress);

        for (uint i=0; i<tickets.length; i++){
            _balance+= qubeStakeFactory.userInfo(i).stakeAmount;
        }
        return _balance;
    }
    function getNFTBalance(address walletAddress)public view returns (uint256){
        uint256 balance=0;
        for (uint i=0;i<=1100;i++){
            balance+=silver.balanceOf(walletAddress, i);
        }
        for (uint i=0;i<=300;i++){
            balance+=gold.balanceOf(walletAddress, i);
        }
        for (uint i=0;i<=100;i++){
            balance+=diamond.balanceOf(walletAddress, i);
        }
        return balance;
    }
    
    function qubeBalance(address walletAddress) public view returns (uint256){
        return getQubeBalance(walletAddress) + getQubePresaleBalance(walletAddress)+getPancakePairBalance(walletAddress)+getQubeStakeFactoryBalance(walletAddress);
    }
    function qubeBalanceWithNFT(address walletAddress) public view returns (uint256){
        return getQubeBalance(walletAddress) + getQubePresaleBalance(walletAddress)+getPancakePairBalance(walletAddress)+getQubeStakeFactoryBalance(walletAddress)+getNFTBalance(walletAddress);
    }
}