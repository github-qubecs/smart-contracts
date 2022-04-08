/**
 *Submitted for verification at BscScan.com on 2022-01-05
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
pragma abicoder v2;

import "./IBEP20.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./Context.sol";
import "./SafeBEP20.sol";
import "./Ownable.sol";
import "./Pausable.sol";
import "./ECDSA.sol";
import "./IBEP1271.sol";

pragma solidity ^0.8.0;

/**
 * @dev Signature verification helper: Provide a single mechanism to verify both private-key (EOA) ECDSA signature and
 * BEP1271 contract sigantures. Using this instead of ECDSA.recover in your contract will make them compatible with
 * smart contract wallets such as Argent and Gnosis.
 *
 * Note: unlike ECDSA signatures, contract signature's are revocable, and the outcome of this function can thus change
 * through time. It could return true at block N and false at block N+1 (or the opposite).
 *
 * _Available since v4.1._
 */
library SignatureChecker {
    
    function isValidSignatureNow(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) internal view returns (bool) {
        (address recovered, ECDSA.RecoverError error) = ECDSA.tryRecover(hash, signature);
        if (error == ECDSA.RecoverError.NoError && recovered == signer) {
            return true;
        }

        (bool success, bytes memory result) = signer.staticcall(
            abi.encodeWithSelector(IBEP1271.isValidSignature.selector, hash, signature)
        );
        return (success && result.length == 32 && abi.decode(result, (bytes4)) == IBEP1271.isValidSignature.selector);
    }
}

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

// OpenZeppelin Contracts v4.3.2 (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// OpenZeppelin Contracts v4.4.0 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a pBEPentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract QubeLaunchPad is Ownable,Pausable,SignerManager,ReentrancyGuard{
    
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;
    using Address for address payable;
    using SignatureChecker for address;
    using EnumerableSet for EnumerableSet.UintSet;

    uint256 public monthDuration = 2592000;
    uint256 public internalLockTickets; 
    uint256 public minimumVestingPeriod = 0;
    uint256 public maximumVestingPeriod = 12;
    bytes32 public constant SIGNATURE_PERMIT_TYPEHASH = keccak256("bytes signature,address user,uint256 amount,uint256 tier,uint256 slot,uint256 deadline");
    
    address public distributor; 

    struct dataStore{
        IBEP20 saleToken;
        IBEP20 quoteToken;
        uint256 currentTier;
        uint256 normalSaleStartTier;
        uint256 totalSaleAmountIn;
        uint256 totalSaleAmountOut;
        uint256[] startTime;
        uint256[] endTime;
        uint256[] salePrice;
        uint256[] quotePrice;
        uint256[] saleAmountIn;
        uint256[] saleAmountOut;        
        uint256[] minimumRequire;
        uint256[] maximumRequire;
        uint256 minimumEligibleQuoteForTx;
        uint256[] minimumEligibleQubeForTx;
        bool tierStatus;
        bool signOff;
        bool delegateState;
    }

    struct vestingStore{
        uint256[] vestingMonths;
        uint256[] instantRoi;
        uint256[] installmentRoi;     
        uint256[] distributeROI;
        bool isLockEnabled;
    }

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

    dataStore[] private reserveInfo;
    vestingStore[] private vestingInfo;
   
    mapping (address => EnumerableSet.UintSet) private userLockIdInfo;
    mapping (uint256 => userData) public userLockInfo;
    mapping (bytes => bool) public isSigned;
    mapping (uint256 => uint256) public totalDelegates;
    mapping (uint256 => mapping (address => uint256)) public userDelegate;

    event _initICO(address indexed saleToken,address indexed quoteToken,uint256 idoId,uint256 time);
    event _ico(address indexed user,uint256 idoId,uint256 stakeId,uint256 amountOut,uint256 receivedToken,uint256 lockedToken,uint256 time);
    event _claim(address indexed user,uint256 idoId,uint256 stakeId,uint256 receivedToken,uint256 unlockCount,uint256 time);

    IBEP20 public qube;   
    
    receive() external payable {}
    
    constructor(IBEP20 _qube,address signer) {
        setSignerInternal(signer);
        qube = _qube;

        distributor = msg.sender;
    }    

    function pause() public onlyOwner{
      _pause();
    }

    function unpause() public onlyOwner{
      _unpause();
    }

    function setDistributor(address account) public onlyOwner {
        require(account != address(0), "Address can't be zero");

        distributor = account;
    }

    function vestingPeriodUpdate(uint256 minimum,uint256 maximum) public onlyOwner{
        minimumVestingPeriod = minimum;
        maximumVestingPeriod = maximum;
    }
    
    function bnbEmergencySafe(uint256 amount) public onlyOwner {
       (payable(owner())).sendValue(amount);
    }
    
    function tokenEmergencySafe(IBEP20 token,uint256 amount) public onlyOwner {
       token.safeTransfer(owner(),amount);
    }

    function monthDurationUpdate(uint256 time) public onlyOwner{
        monthDuration = time;
    }
    
    struct inputStore{
        IBEP20 saleToken;
        IBEP20 quoteToken;
        uint256[] startTime;
        uint256[] endTime;
        uint256[] salePrice;
        uint256[] quotePrice;
        uint256[] saleAmountIn;
        uint256[] vestingMonths;
        uint256[] instantRoi;
        uint256[] installmentRoi;
        uint256[] minimumRequire;//Minimum requirement per tier
        uint256[] maximumRequire;//Maximum allowed per tier
        uint256 minimumEligibleQuoteForTx;
        uint256[] minimumEligibleQubeForTx;//Qube stake requirement for each tier
        bool isLockEnabled;
        bool delegateState;
    }
    
    function initICO(inputStore memory vars) public onlyOwner {
        uint256 lastTierTime = block.timestamp;
        uint256 saleAmountIn;
        for(uint256 i;i<vars.startTime.length;i++){
            require(vars.startTime[i] >= lastTierTime,"startTime is invalid");
            require(vars.startTime[i] <= vars.endTime[i], "endtime is invalid");
            require(minimumVestingPeriod <= vars.vestingMonths[i] && vars.vestingMonths[i] <= maximumVestingPeriod, "Vesting Months Invalid");
            require(vars.instantRoi[i].add(vars.installmentRoi[i]) <= 100, "invalid roi");
            saleAmountIn = saleAmountIn.add(vars.saleAmountIn[i]);
            lastTierTime = vars.endTime[i];
        }

        reserveInfo.push(dataStore({
            saleToken: vars.saleToken,
            quoteToken: vars.quoteToken,
            currentTier: 0,
            normalSaleStartTier: vars.startTime.length - 2,
            totalSaleAmountIn: saleAmountIn,
            totalSaleAmountOut: 0,
            startTime: vars.startTime,
            endTime: vars.endTime,
            salePrice: vars.salePrice,
            quotePrice: vars.quotePrice,
            saleAmountIn: vars.saleAmountIn,
            saleAmountOut: new uint256[](vars.saleAmountIn.length),
            minimumRequire: vars.minimumRequire, 
            maximumRequire: vars.maximumRequire,
            minimumEligibleQuoteForTx: vars.minimumEligibleQuoteForTx,
            minimumEligibleQubeForTx: vars.minimumEligibleQubeForTx,
            tierStatus: false,
            signOff: true,
            delegateState: vars.delegateState
        }));

        vestingInfo.push(vestingStore({
            vestingMonths: vars.vestingMonths,
            instantRoi: vars.instantRoi,
            installmentRoi: vars.installmentRoi,   
            distributeROI: new uint256[](vars.vestingMonths.length),
            isLockEnabled: vars.isLockEnabled
        }));
        
        if(!vars.delegateState) {
            IBEP20(vars.saleToken).safeTransferFrom(_msgSender(),address(this),saleAmountIn);
        }
        
        emit _initICO(
            address(vars.saleToken),
            address(vars.quoteToken),
            reserveInfo.length - 1,
            block.timestamp
        );
    }

    function minimumQubeAmount(uint256 reserveInfoID, uint256 tierID) public view returns (uint256){
        dataStore storage vars = reserveInfo[reserveInfoID];
        return vars.minimumEligibleQubeForTx[tierID];
    }
    function minimumPurchaseAmount(uint256 reserveInfoID, uint256 tierID) public view returns (uint256){
        dataStore storage vars = reserveInfo[reserveInfoID];
        return vars.minimumRequire[tierID];
    }
    function maximumPurchaseAmount(uint256 reserveInfoID, uint256 tierID) public view returns (uint256){
        dataStore storage vars = reserveInfo[reserveInfoID];
        return vars.maximumRequire[tierID];
    }

    function qubeBalance(address walletAddress) public view returns (uint256){
        return qube.balanceOf(walletAddress);
    }

    function saleCurrencyBalance(address walletAddress, uint256 reserveInfoID) public view returns (uint256){
        dataStore storage vars = reserveInfo[reserveInfoID];
        IBEP20 quoteToken = vars.quoteToken;
        return quoteToken.balanceOf(walletAddress);
    }

    function isEligibleWallet(address walletAddress, uint256 reserveInfoID, uint256 tierID) public view returns (bool){
        dataStore storage vars = reserveInfo[reserveInfoID]; //sale details and variables
        bool minimumCubeCheck = false; 
        bool minimumPurchaseCheck = false;
        uint256 decimal = vars.quoteToken.decimals();
        uint256 price = getPrice(vars.salePrice[vars.currentTier],vars.quotePrice[vars.currentTier],decimal);
        if(qubeBalance(walletAddress)>=minimumQubeAmount(reserveInfoID, tierID)){
            minimumCubeCheck=true;
        }
        if(vars.quoteToken.balanceOf(walletAddress)>=price){
            minimumPurchaseCheck=true;
        }
        return minimumCubeCheck && minimumPurchaseCheck;
    }

    function setStateStore(
        uint256 _id,
        bool _tierStatus,
        bool _signOff,
        bool _delegateState
    ) public onlyOwner {
        reserveInfo[_id].tierStatus = _tierStatus;
        reserveInfo[_id].signOff = _signOff;
        reserveInfo[_id].delegateState = _delegateState;
    }

    function setTime( 
        uint256 _id,
        uint256[] memory _startTime,
        uint256[] memory _endTime
    ) public onlyOwner {
        reserveInfo[_id].startTime = _startTime;
        reserveInfo[_id].endTime = _endTime;
    }

    function setSalePrice(
        uint256 _id,
        uint256[] memory _salePrice,
        uint256[] memory _quotePrice
    ) public onlyOwner {
        reserveInfo[_id].salePrice = _salePrice;
        reserveInfo[_id].quotePrice = _quotePrice;
    }

    function setVestingStore(
        uint256 _id,
        uint256[] memory _vestingMonths,
        uint256[] memory _instantRoi,
        uint256[] memory _installmentRoi,
        bool _isLockEnabled
    ) public onlyOwner {
        vestingInfo[_id].vestingMonths = _vestingMonths;
        vestingInfo[_id].instantRoi = _instantRoi;
        vestingInfo[_id].installmentRoi = _installmentRoi;
        vestingInfo[_id].isLockEnabled = _isLockEnabled;
    }    

    function setOtherStore(
        uint256 _id,
        uint256[] memory _minimumRequire,
        uint256[] memory _maximumRequire,
        uint256 _minimumEligibleQuoteForTx,
        uint256[] memory _minimumEligibleQubeForTx
    ) public onlyOwner {
        reserveInfo[_id].minimumRequire = _minimumRequire;
        reserveInfo[_id].maximumRequire = _maximumRequire;
        reserveInfo[_id].minimumEligibleQuoteForTx = _minimumEligibleQuoteForTx;
        reserveInfo[_id].minimumEligibleQubeForTx = _minimumEligibleQubeForTx;
    }

    function setCurrentTier(
        uint256 _id,
        uint256 _currentTier
    ) public onlyOwner {
        reserveInfo[_id].currentTier = _currentTier;
    }
  
    
    function getPrice(uint256 salePrice,uint256 quotePrice,uint256 decimal) public pure returns (uint256) {
       return (10 ** decimal) * salePrice / quotePrice;
    }
    
    struct singParams{
        bytes signature;
        address user;
        uint256 amount;
        uint256 tier;
        uint256 slot;
        uint256 deadline;
    }
    
    function signDecodeParams(bytes memory params) public pure returns (singParams memory) {
    (
        bytes memory signature,
        address user,
        uint256 amount,
        uint256 tier,
        uint256 slot,
        uint256 deadline
    ) =
      abi.decode(
        params,
        (bytes,address, uint256,uint256, uint256, uint256)
    );

    return
      singParams(
        signature,
        user,
        amount,
        tier,
        slot,
        deadline
      );
    }

    function signVerify(singParams memory sign) internal {
        require(sign.user == msg.sender, "invalid user");
        require(block.timestamp < sign.deadline, "Time Expired");
        require(!isSigned[sign.signature], "already sign used");
            
        bytes32 hash_ = keccak256(abi.encodePacked(
                SIGNATURE_PERMIT_TYPEHASH,
                address(this),
                sign.user,                
                sign.amount,
                sign.tier,
                sign.slot,
                sign.deadline
        ));
            
        require(signValidition(ECDSA.toEthSignedMessageHash(hash_),sign.signature), "Sign Error");
        isSigned[sign.signature] = true;       
    }
    
    function buy(uint256 id,uint256 amount,bytes memory signStore) public payable nonReentrant {
        dataStore storage vars = reserveInfo[id];
        vestingStore storage vesting = vestingInfo[id];
        address user = _msgSender();
        uint256 getAmountOut;
        while(vars.endTime[vars.currentTier] < block.timestamp && !vars.tierStatus){
            if(vars.currentTier != vars.startTime.length) {
                vars.currentTier++;
                
                if(vars.startTime[vars.normalSaleStartTier + 1] <= block.timestamp){
                    vars.tierStatus = true;
                    vars.currentTier = vars.normalSaleStartTier + 1;
                } 
            }
            
            if(!vars.signOff && vars.endTime[vars.normalSaleStartTier] <= block.timestamp) {
                vars.signOff = true;
            }
        }
        require(vars.startTime[vars.currentTier] <= block.timestamp && vars.endTime[vars.currentTier] >= block.timestamp, "Time expired");
        
        if(!vars.signOff){
            signVerify(signDecodeParams(signStore));
        }
        
        if(address(vars.quoteToken) == address(0)){
           uint256 getAmountIn = msg.value;
           require(getAmountIn >= vars.minimumRequire[vars.currentTier] && getAmountIn <= vars.maximumRequire[vars.currentTier], "invalid amount passed");
           if(getAmountIn >= vars.minimumEligibleQuoteForTx){
               require(qube.balanceOf(user) >= vars.minimumEligibleQubeForTx[vars.currentTier], "Not eligible to buy");
           }
           
           getAmountOut = getAmountIn.mul(getPrice(vars.salePrice[vars.currentTier],vars.quotePrice[vars.currentTier],18)).div(1e18);    
        }else {
           require(amount >= vars.minimumRequire[vars.currentTier] && amount <= vars.maximumRequire[vars.currentTier], "invalid amount passed");
           if(amount == vars.minimumEligibleQuoteForTx){
               require(qube.balanceOf(user) >= vars.minimumEligibleQubeForTx[vars.currentTier],"Not eligible to buy");
           }
           
           vars.quoteToken.safeTransferFrom(user,address(this),amount);
           
           uint256 decimal = vars.quoteToken.decimals();
         
           getAmountOut = amount.mul(getPrice(vars.salePrice[vars.currentTier],vars.quotePrice[vars.currentTier],decimal)).div(10 ** decimal);
        }

        for(uint256 i=0;i<=vars.currentTier;i++){
            if(i != 0){
                vars.saleAmountIn[i] = vars.saleAmountIn[i].add(vars.saleAmountIn[i-1].sub(vars.saleAmountOut[i-1]));
                vars.saleAmountOut[i-1] = vars.saleAmountIn[i-1];
            }
        }
        vars.saleAmountOut[vars.currentTier] = vars.saleAmountOut[vars.currentTier].add(getAmountOut);
        require(vars.saleAmountOut[vars.currentTier] <= vars.saleAmountIn[vars.currentTier], "Reserved amount exceed");
        
        if(vesting.isLockEnabled){
            internalLockTickets++;
            if(vars.delegateState) {
                totalDelegates[id] = totalDelegates[id].add(getAmountOut.mul(vesting.instantRoi[vars.currentTier]).div(1e2));
                userDelegate[id][user] = userDelegate[id][user].add(getAmountOut.mul(vesting.instantRoi[vars.currentTier]).div(1e2));
            } else {
                vars.saleToken.safeTransfer(user,getAmountOut.mul(vesting.instantRoi[vars.currentTier]).div(1e2));
            }
            userLockIdInfo[user].add(internalLockTickets);
            userLockInfo[internalLockTickets] = userData({
                userAddress: user,
                saleToken: vars.saleToken,
                idoID: id,
                lockedAmount: getAmountOut.mul(vesting.installmentRoi[vars.currentTier]).div(1e2),
                releasedAmount: 0,
                lockedDuration: block.timestamp,
                lastClaimed: block.timestamp,
                unlockCount: 0,
                installmentMonths: vesting.vestingMonths[vars.currentTier],
                distributeROI: uint256(1e4).div(vesting.vestingMonths[vars.currentTier])     
            });

            emit _ico(
                user,
                id,
                internalLockTickets,
                getAmountOut,
                getAmountOut.mul(vesting.instantRoi[vars.currentTier]).div(1e2),
                getAmountOut.mul(vesting.installmentRoi[vars.currentTier]).div(1e2),
                block.timestamp
            );
        }else {
            if(vars.delegateState) {
                totalDelegates[id] = totalDelegates[id].add(getAmountOut);
                userDelegate[id][user] = userDelegate[id][user].add(getAmountOut);
            } else {
                vars.saleToken.safeTransfer(user,getAmountOut);
            }

            emit _ico(
                user,
                id,
                internalLockTickets,
                getAmountOut,
                getAmountOut,
                0,
                block.timestamp
            );
        }

    }

    function deposit(uint256 id,uint256 amount) public {
        require(_msgSender() == distributor, "distributor only accessible");
        require(totalDelegates[id] == amount, "amount must be equal");

        reserveInfo[id].saleToken.safeTransferFrom(distributor,address(this),amount);
        totalDelegates[id] = 0;
    }

    function redeem(uint256 id) public nonReentrant {
        require(totalDelegates[id] == 0, "funds not available");
        require(userDelegate[id][_msgSender()] > 0, "death balance");
       
        reserveInfo[id].saleToken.safeTransfer(msg.sender,userDelegate[id][_msgSender()]);
        userDelegate[id][_msgSender()] = 0;
    }

    function claim(uint256 lockId) public whenNotPaused nonReentrant {
        require(userLockContains(msg.sender,lockId), "unable to access");
        
        userData storage store = userLockInfo[lockId];
        
        require(store.lockedDuration.add(monthDuration) < block.timestamp, "unable to claim now");
        require(store.releasedAmount != store.lockedAmount, "amount exceed");
        
        uint256 reward = store.lockedAmount * (store.distributeROI) / (1e4);
        uint given = store.unlockCount;
        while(store.lockedDuration.add(monthDuration) < block.timestamp) {
            if(store.unlockCount == store.installmentMonths){
                userLockIdInfo[store.userAddress].remove(lockId);
                break;
            }
            store.lockedDuration = store.lockedDuration.add(monthDuration);            
            store.unlockCount = store.unlockCount + 1;         
        }        
        store.lastClaimed = block.timestamp;
        uint256 amountOut = reward * (store.unlockCount - given);
        store.releasedAmount = store.releasedAmount.add(amountOut);
        store.saleToken.safeTransfer(store.userAddress,amountOut);

        emit _claim(
            msg.sender,
            store.idoID,
            lockId,
            amountOut,
            store.unlockCount,
            block.timestamp
        );
    }
    
    function signValidition(bytes32 hash,bytes memory signature) public view returns (bool) {
        return getSignerInternal().isValidSignatureNow(hash,signature);
    }
    
    function getTokenOut(uint256 id,uint256 amount) public view returns (uint256){
        dataStore memory vars = reserveInfo[id]; 

        while(vars.endTime[vars.currentTier] < block.timestamp && !vars.tierStatus){
            if(vars.currentTier != vars.startTime.length) {
                vars.currentTier++;                
                if(vars.startTime[vars.normalSaleStartTier + 1] <= block.timestamp){
                    vars.tierStatus = true;
                    vars.currentTier = vars.normalSaleStartTier + 1;
                }
            }
        }
        
        if(!(vars.startTime[vars.currentTier] <= block.timestamp && vars.endTime[vars.currentTier] >= block.timestamp && amount >= vars.minimumRequire[vars.currentTier] && amount <= vars.maximumRequire[vars.currentTier])){
            return 0;
        }
        
        if(address(vars.quoteToken) == address(0)){
            return amount.mul(getPrice(vars.salePrice[vars.currentTier],vars.quotePrice[vars.currentTier],18)).div(1e18);
        }
        
        if(address(vars.quoteToken) != address(0)){
            uint256 decimal = vars.quoteToken.decimals();
            return amount.mul(getPrice(vars.salePrice[vars.currentTier],vars.quotePrice[vars.currentTier],decimal)).div(10 ** decimal);
        } else{
            return 0;
        }
    }

    function userLockContains(address account,uint256 value) public view returns (bool) {
        return userLockIdInfo[account].contains(value);
    }

    function userLockLength(address account) public view returns (uint256) {
        return userLockIdInfo[account].length();
    }

    function userLockAt(address account,uint256 index) public view returns (uint256) {
        return userLockIdInfo[account].at(index);
    }

    function userTotalLockIds(address account) public view returns (uint256[] memory) {
        return userLockIdInfo[account].values();
    }

    function reserveDetails(uint256 id) public view returns (dataStore memory) {
        dataStore memory vars = reserveInfo[id];

        while(vars.endTime[vars.currentTier] < block.timestamp && !vars.tierStatus){
            if(vars.currentTier != vars.startTime.length) {
                vars.currentTier++;
                
                if(vars.startTime[vars.normalSaleStartTier + 1] <= block.timestamp){
                    vars.tierStatus = true;
                    vars.currentTier = vars.normalSaleStartTier + 1;
                } 
            }
            
            if(!vars.signOff && vars.endTime[vars.normalSaleStartTier] <= block.timestamp) {
                vars.signOff = true;
            }
        }
        for(uint256 i=0;i<=vars.currentTier;i++){
            if(i != 0){
                vars.saleAmountIn[i] = vars.saleAmountIn[i].add(vars.saleAmountIn[i-1].sub(vars.saleAmountOut[i-1]));
                vars.saleAmountOut[i-1] = vars.saleAmountIn[i-1];
            }
        }
        return vars;
    }

    function vestingDetils(uint256 id) public view returns (vestingStore memory) {
        vestingStore memory vesting = vestingInfo[id];
        for(uint256 i; i<vesting.vestingMonths.length; i++){
            vesting.distributeROI[i] = uint256(1e4).div(vesting.vestingMonths[i]);
        }
        return (vesting);
    }

    function reserveLength() public view returns (uint256) {
        return reserveInfo.length;
    }
}
