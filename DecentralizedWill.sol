// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract DecentralizedWill {
    struct Will {
        address beneficiary;
        uint lastCheckIn;
        uint inactivityPeriod;
        uint amount;
        bool claimed;
    }

    // mappings from the Will owner to the will data
    mapping(address => Will) public wills;

    // Set or update a will (you can only add money to the will)
    function setWill(address beneficiary, uint inactivityPeriod) external payable {
        require(beneficiary != address(0), "Invalid beneficiary");
        require(msg.value > 0, "Must send ETH");

        Will storage will = wills[msg.sender];

        require(!will.claimed, "Will already claimed");

        will.beneficiary = beneficiary;
        will.inactivityPeriod = inactivityPeriod;
        will.lastCheckIn = block.timestamp;
        will.amount += msg.value; // in wei
    }

    // Send a heartbeat to keep your will alive
    function heartbeat() external {
        require(wills[msg.sender].beneficiary != address(0), "No will exists for sender");
        require(!wills[msg.sender].claimed, "Will already claimed");
        wills[msg.sender].lastCheckIn = block.timestamp;
    }

    // Claim inheritance if owner is inactive
    function claim(address owner) external {
        Will storage will = wills[owner];

        require(!will.claimed, "Already claimed");
        require(will.beneficiary != address(0), "No will set");
        require(msg.sender == will.beneficiary, "You are not the beneficiary");
        require(block.timestamp >= will.lastCheckIn + will.inactivityPeriod, "Owner is still active");

        uint amount = will.amount;

        will.claimed = true;
        will.amount = 0;

        payable(will.beneficiary).transfer(amount);
    }

    function isClaimable(address _owner) external view returns (bool) {
        Will memory will = wills[_owner];
        return (
            !will.claimed &&
            will.beneficiary != address(0) &&
            block.timestamp >= will.lastCheckIn + will.inactivityPeriod
        );
    }

    // Allow owners to send more ETH to their will after setup (this can also be done with setWill)
    receive() external payable {
        Will storage will = wills[msg.sender];
        require(will.beneficiary != address(0), "No will exists");
        require(!will.claimed, "Will already claimed");

        will.amount += msg.value;
    }
}
