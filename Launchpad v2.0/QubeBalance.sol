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
import "./IERC1155.sol"; 


interface IQubeBalance {
    function qubeBalance(address walletAddress) external view returns (uint256);
    function qubeBalanceWithNFT(address walletAddress) external view returns (uint256);
}

interface IQubeStake{
    /*struct userData {
        address user;
        uint256 stakeTime;
        uint256 deadLine;
        uint256 claimTime;
        uint256 stakeAmount;
        uint256 totalRewards;
    }
    mapping (uint256 => userData) public userInfo;*/
    function userInfo(uint256 index) external view returns (address user, uint256 stakeTime, uint256 deadLine, uint256 claimTime, uint256 stakeAmount, uint256 totalRewards);
    function userTickets(address user) external view returns (uint256[] memory);
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

    struct userNFTData{
        uint256[] IDs;
        uint256 rank;
    }

    using SafeMath for uint256;

    IBEP20 public qube;
    QubePresale public qubePresale;
    IPancakePair public pancakePair;
    IQubeStake public qubeStake;
    IERC1155 public silver;
    IERC1155 public gold;
    IERC1155 public diamond;
    mapping (address=>userNFTData) public userNFT;



    constructor() {

    }    

    function setQubeStake(IQubeStake _qubeStake) public onlyOwner{
        qubeStake=_qubeStake;
    }

    function removeNFT(address _user, uint256 _ID) public{
        require(msg.sender==_user || msg.sender==owner());
        if (!(userNFT[_user].IDs[userNFT[_user].IDs.length - 1]==_ID)){
            userNFT[_user].IDs[_ID] = userNFT[_user].IDs[userNFT[_user].IDs.length - 1];
        }
        userNFT[_user].IDs.pop();
    }
    function addNFT(address _user, uint256 _ID) public{
        require(msg.sender==_user || msg.sender==owner());
        userNFT[_user].IDs.push(_ID);
    }
    function changeNFTRank(address _user, uint256 _rank) public{
        require(msg.sender==_user || msg.sender==owner());
        userNFT[_user].rank=_rank;
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
    function getQubeStakeBalance(address walletAddress)public view returns(uint256){
        uint256 _balance;
        address _user;
        uint256 _stakeTime;
        uint256 _deadLine;
        uint256 _claimTime;
        uint256 _stakeAmount;
        uint256 _totalRewards;
        uint256[] memory tickets = qubeStake.userTickets(walletAddress);

        for (uint i=0; i<tickets.length; i++){
            //userData storage userStore = qubeStake.userInfo[i];
            (_user, _stakeTime, _deadLine, _claimTime, _stakeAmount, _totalRewards) = qubeStake.userInfo(i);
            _balance+= _stakeAmount;
        }
        return _balance;
    }
    function getNFTBalance(address walletAddress)public view returns (uint256){
        uint256 balance=0;
        
        for (uint i=0;i<userNFT[walletAddress].IDs.length;i++){
            uint256 currentID=userNFT[walletAddress].IDs[i];
            balance+=silver.balanceOf(walletAddress, currentID);
            balance+=gold.balanceOf(walletAddress, currentID);
            balance+=diamond.balanceOf(walletAddress, currentID);
        }
        return balance;
    }

    function getNFTBalanceFromAllNFTs(address walletAddress)public view returns (uint256){
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
        return getQubeBalance(walletAddress) + getQubePresaleBalance(walletAddress)+getPancakePairBalance(walletAddress)+getQubeStakeBalance(walletAddress);
    }
    function qubeBalanceWithNFT(address walletAddress) public view returns (uint256){
        return getQubeBalance(walletAddress) + getQubePresaleBalance(walletAddress)+getPancakePairBalance(walletAddress)+getQubeStakeBalance(walletAddress)+getNFTBalance(walletAddress);
    }
    function qubeBalanceWithNFTFromAllNFTs(address walletAddress) public view returns (uint256){
        return getQubeBalance(walletAddress) + getQubePresaleBalance(walletAddress)+getPancakePairBalance(walletAddress)+getQubeStakeBalance(walletAddress)+getNFTBalanceFromAllNFTs(walletAddress);
    }
}