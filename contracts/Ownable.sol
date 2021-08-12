//SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract Ownable{
    address public owner;

    modifier onlyOwner(){
        require(msg.sender == owner);
        _; //Continue execution
    }

    constructor() {
        owner = msg.sender;
    }
}
