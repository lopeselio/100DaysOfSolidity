// SPDX-License-Identifier: MIT 

pragma solidity >=0.7.0 <0.9.0;

contract Escrow {
    
    // VARIABLES
    enum State { NOT_INITIATED, AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE }
    
    State public currState;
    bool public isBuyerIn;
    bool public isSellerIn;
    
    uint public price;
    address public buyer;
    address payable public seller;
    
    // MODIFIERS
    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only buyer can call this function");
        _;
    }
    
    modifier escrowNotStarted() {
        require(currState == State.NOT_INITIATED);
        _;
    }
    
    // FUNCTIONS
    constructor(address _buyer, address payable _seller, uint _price){
        buyer = _buyer;
        seller = _seller;
        price = _price * (1 ether);
        
    }
    
    function initContract() escrowNotStarted public {
        if(msg.sender == buyer) {
            isBuyerIn = true;
        }
        if(msg.sender == seller) {
            isSellerIn = true;
        }
        if(isBuyerIn && isSellerIn) {
            currState = State.AWAITING_PAYMENT;
        }
        
    }
    
    function deposit() onlyBuyer public payable {
        require(currState == State.AWAITING_PAYMENT, "Already Paid");
        require(msg.value == price, "Wrong deposit amount");
        currState = State.AWAITING_DELIVERY;
        
    }
    
    function confirmDelivery() onlyBuyer payable public {
        require(currState == State.AWAITING_DELIVERY, "Connot confirm delivery");
        seller.transfer(price);
        currState = State.COMPLETE;
    }
    
    function withdraw() onlyBuyer payable public {
        require (currState == State.AWAITING_DELIVERY, "Cannot withdraw at this stage");
        payable(msg.sender).transfer(price);
        currState = State.COMPLETE;
        
    }
}
