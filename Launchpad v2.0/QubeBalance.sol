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

interface IQubeBalance {
    function qubeBalance(address walletAddress) external view returns (uint256);
}

contract QubeBalance is Ownable{
    using SafeMath for uint256;

    IBEP20 public qube;
    QubePresale public qubePresale;
    IPancakePair public pancakePair;

    constructor(IBEP20 _qube, QubePresale _qubePresale) {
        qube = _qube;
        qubePresale=_qubePresale;
    }    


    function setQube(IBEP20 _qube) public onlyOwner{
        qube=_qube;
    }
    function setQubePresale(QubePresale _qubePresale) public onlyOwner{
        qubePresale=_qubePresale;
    }

    function getPancakePairBalance(address walletAddress)public returns (uint256){
        uint112 _qubeBalance;
        uint112 _USDTBalance;
        (_qubeBalance, _USDTBalance) = pancakePair.getReserves();

        uint256 _LP = uint256(_qubeBalance).div(uint256(_USDTBalance));
        uint256 _balanceOf=pancakePair.balanceOf(walletAddress);
        return _LP.mul(_balanceOf);
    }
    function getQubeBalance(address walletAddress)public{
        qube.balanceOf(walletAddress);
    }
    function getQubePresaleBalance(address walletAddress)public{
        qubePresale.balanceOf(walletAddress);
    }

    function qubeBalance(address walletAddress) public view returns (uint256){
        return getQubeBalance(walletAddress) + qubePresale(walletAddress)+getPancakePairBalance(walletAddress);
    }
}