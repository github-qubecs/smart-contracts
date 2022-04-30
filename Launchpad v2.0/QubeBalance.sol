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

interface IQubeBalance {
    function qubeBalance(address walletAddress) external view returns (uint256);
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


    constructor(IBEP20 _qube, QubePresale _qubePresale, IPancakePair _pancakePair, QubeStakeFactory _qubeStakeFactory) {
        qube = _qube;
        qubePresale=_qubePresale;
        pancakePair=_pancakePair;
        qubeStakeFactory=_qubeStakeFactory;
    }    


    function setQube(IBEP20 _qube) public onlyOwner{
        qube=_qube;
    }
    function setQubePresale(QubePresale _qubePresale) public onlyOwner{
        qubePresale=_qubePresale;
    }
    function setQubePancakePair(QubePresale _qubePresale) public onlyOwner{
        pancakePair=_pancakePair;
    }
    function setQubeeStake(QubePresale _qubeStakeFactory) public onlyOwner{
        qubeStakeFactory=_qubeStakeFactory;
    }

    function getQubeBalance(address walletAddress)public returns (uint256){
        qube.balanceOf(walletAddress);
    }
    function getQubePresaleBalance(address walletAddress)public returns (uint256){
        qubePresale.balanceOf(walletAddress);
    }
    function getPancakePairBalance(address walletAddress)public returns (uint256){
        uint112 _qubeBalance;
        uint112 _USDTBalance;
        (_qubeBalance, _USDTBalance) = pancakePair.getReserves();

        uint256 _LP = uint256(_qubeBalance).div(uint256(_USDTBalance));
        uint256 _balanceOf=pancakePair.balanceOf(walletAddress);
        return _LP.mul(_balanceOf);
    }
    function getQubeStakeFactoryBalance(address walletAddress)public{
        uint256 _balance;
        uint256[] tickets = qubeStakeFactory.userTickets(walletAddress);
        for (uint i=0; i<tickets.length; i++){
            userData memory data = qubeStakeFactory.userInfo(i);
            _balance+=userData.stakeAmount;
        }
        return _balance;
    }
    
    function qubeBalance(address walletAddress) public view returns (uint256){
        return getQubeBalance(walletAddress) + getQubePresaleBalance(walletAddress)+getPancakePairBalance(walletAddress)+getQubeStakeFactoryBalance(walletAddress);
    }
}