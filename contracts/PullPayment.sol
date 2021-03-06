pragma solidity ^0.4.2;

import "./SafeMath.sol";

/*
 * PullPayment
 * Base contract supporting async send for pull payments.
 * Inherit from this contract and use asyncSend instead of send.
 */
contract PullPayment {

  using SafeMath for uint;
  
  mapping(address => uint) public payments;

  event LogRefundETH(address to, uint value);


  /**
  *  Store sent amount as credit to be pulled, called by payer 
  **/
  function asyncSend(address dest, uint amount) internal {
    payments[dest] = payments[dest].add(amount);
  }

  // withdraw accumulated balance, called by payee
  function withdrawPayments() {
    address payee = msg.sender;
    uint payment = payments[payee];
    
    require (payment > 0);
    require (this.balance >= payment);

    payments[payee] = 0;

    require (payee.send(payment));
    
    LogRefundETH(payee,payment);
  }
}
