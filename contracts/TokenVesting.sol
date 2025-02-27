// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title TokenVesting
 * @dev A token holder contract that can release its token balance gradually like a
 * typical vesting scheme, with a cliff and vesting period.
 */
contract TokenVesting is Ownable(msg.sender) {
    using SafeERC20 for IERC20;

    // Vesting schedule structure
    struct VestingSchedule {
        uint256 totalAmount;     // Total amount of tokens to be vested
        uint256 startTime;       // Start time of the vesting period
        uint256 cliffDuration;   // Duration of the cliff period in seconds
        uint256 duration;        // Duration of the vesting period in seconds
        uint256 releasedAmount; // Amount of tokens already released
        bool revocable;         // Whether the vesting is revocable
        bool revoked;           // Whether the vesting has been revoked
    }

    // Token address => beneficiary address => vesting schedule
    mapping(address => mapping(address => VestingSchedule)) public vestingSchedules;

    // Events
    event TokensVested(address token, address beneficiary, uint256 amount);
    event VestingCreated(address token, address beneficiary, uint256 amount);
    event VestingRevoked(address token, address beneficiary);

    /**
     * @notice Creates a vesting schedule for a beneficiary
     * @param token Address of the ERC20 token
     * @param beneficiary Address of the beneficiary
     * @param amount Total amount of tokens to be vested
     * @param cliffDuration Duration of the cliff period in seconds
     * @param duration Total duration of the vesting period in seconds
     * @param revocable Whether the vesting is revocable by the owner
     */
    function createVestingSchedule(
        address token,
        address beneficiary,
        uint256 amount,
        uint256 cliffDuration,
        uint256 duration,
        bool revocable
    ) external onlyOwner {
        require(token != address(0), "Token address cannot be 0");
        require(beneficiary != address(0), "Beneficiary address cannot be 0");
        require(amount > 0, "Amount must be > 0");
        require(duration > 0, "Duration must be > 0");
        require(duration >= cliffDuration, "Duration must be >= cliff");
        
        // Check if there's no existing schedule
        require(vestingSchedules[token][beneficiary].totalAmount == 0, "Schedule exists");

        // Transfer tokens to this contract
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        uint256 startTime = block.timestamp;
        
        vestingSchedules[token][beneficiary] = VestingSchedule({
            totalAmount: amount,
            startTime: startTime,
            cliffDuration: cliffDuration,
            duration: duration,
            releasedAmount: 0,
            revocable: revocable,
            revoked: false
        });

        emit VestingCreated(token, beneficiary, amount);
    }

    /**
     * @notice Releases vested tokens for a beneficiary
     * @param token Address of the ERC20 token
     */
    function release(address token) external {
        VestingSchedule storage schedule = vestingSchedules[token][msg.sender];
        require(schedule.totalAmount > 0, "No vesting schedule");
        require(!schedule.revoked, "Vesting revoked");

        uint256 releasable = _computeReleasableAmount(schedule);
        require(releasable > 0, "No tokens to release");

        schedule.releasedAmount += releasable;
        IERC20(token).safeTransfer(msg.sender, releasable);

        emit TokensVested(token, msg.sender, releasable);
    }

    /**
     * @notice Revokes the vesting schedule for a beneficiary
     * @param token Address of the ERC20 token
     * @param beneficiary Address of the beneficiary
     */
    function revoke(address token, address beneficiary) external onlyOwner {
        VestingSchedule storage schedule = vestingSchedules[token][beneficiary];
        require(schedule.totalAmount > 0, "No vesting schedule");
        require(schedule.revocable, "Not revocable");
        require(!schedule.revoked, "Already revoked");

        uint256 releasable = _computeReleasableAmount(schedule);
        
        // Release vested tokens
        if (releasable > 0) {
            schedule.releasedAmount += releasable;
            IERC20(token).safeTransfer(beneficiary, releasable);
            emit TokensVested(token, beneficiary, releasable);
        }

        // Return unvested tokens to owner
        uint256 unreleased = schedule.totalAmount - schedule.releasedAmount;
        if (unreleased > 0) {
            IERC20(token).safeTransfer(owner(), unreleased);
        }

        schedule.revoked = true;
        emit VestingRevoked(token, beneficiary);
    }

    /**
     * @notice Computes the releasable amount of tokens for a vesting schedule
     * @param token Address of the ERC20 token
     * @param beneficiary Address of the beneficiary
     * @return Amount of releasable tokens
     */
    function computeReleasableAmount(address token, address beneficiary)
        public
        view
        returns (uint256)
    {
        VestingSchedule memory schedule = vestingSchedules[token][beneficiary];
        return _computeReleasableAmount(schedule);
    }

    /**
     * @notice Internal function to compute the releasable amount of tokens for a vesting schedule
     * @param schedule VestingSchedule struct
     * @return Amount of releasable tokens
     */
    function _computeReleasableAmount(VestingSchedule memory schedule)
        private
        view
        returns (uint256)
    {
        // Check if cliff has passed
        if (block.timestamp < schedule.startTime + schedule.cliffDuration) {
            return 0;
        }

        // If over duration, all tokens vested
        if (block.timestamp >= schedule.startTime + schedule.duration) {
            return schedule.totalAmount - schedule.releasedAmount;
        }

        // Linear vesting
        uint256 timeFromStart = block.timestamp - schedule.startTime;
        uint256 vestedAmount = (schedule.totalAmount * timeFromStart) / schedule.duration;
        return vestedAmount - schedule.releasedAmount;
    }

    /**
     * @notice Returns the vesting schedule for a beneficiary
     * @param token Address of the ERC20 token
     * @param beneficiary Address of the beneficiary
     */
    function getVestingSchedule(address token, address beneficiary)
        external
        view
        returns (
            uint256 totalAmount,
            uint256 startTime,
            uint256 cliffDuration,
            uint256 duration,
            uint256 releasedAmount,
            bool revocable,
            bool revoked
        )
    {
        VestingSchedule memory schedule = vestingSchedules[token][beneficiary];
        return (
            schedule.totalAmount,
            schedule.startTime,
            schedule.cliffDuration,
            schedule.duration,
            schedule.releasedAmount,
            schedule.revocable,
            schedule.revoked
        );
    }
} 