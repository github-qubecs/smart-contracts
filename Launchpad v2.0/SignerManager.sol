// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
pragma abicoder v2;

import "./Ownable.sol";

/// @title Fallback Manager - A contract that manages fallback calls made to this contract
/// @author Richard Meissner - <richard@gnosis.pm>
contract SignerManager is Ownable  {
    event ChangedSigner(address signer);
    // keccak256("owner.signer.address")
    bytes32 internal constant SIGNER_STORAGE_SLOT = 0x975ab5f8337fe05074119ae2318a39673b00662f832900cb67ec977634a27381;

    /// @dev Set a signer that checks transactions before execution
    /// @param signer The address of the signer to be used or the 0 address to disable the signer
    function setSigner(address signer) external onlyOwner {
        setSignerInternal(signer);
    }
        
    function setSignerInternal(address signer) internal {
        bytes32 slot = SIGNER_STORAGE_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, signer)
        }
        emit ChangedSigner(signer);
    }

    function getSignerInternal() internal view returns (address signer) {
        bytes32 slot = SIGNER_STORAGE_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            signer := sload(slot)
        }
    }
    
    function getSigner(bytes32 slot) public view returns (address signer){
        if(slot == SIGNER_STORAGE_SLOT && _msgSender() == owner()){
            // solhint-disable-next-line no-inline-assembly
            assembly {
                signer := sload(slot)
            }
        }else {
            return address(0);
        }
    }
}