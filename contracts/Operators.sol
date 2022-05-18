// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';

abstract contract Operators is Ownable {

	mapping(address => bool) public operators;

	event AddOperator(address to);

	event RemoveOperator(address to);

	modifier onlyOperator() {
		require(isOperator(msg.sender), 'Operators: caller is not the operator');
		_;
	}

	function addOperator(address to) external onlyOwner {
		_addOperator(to);
	}

	function removeOperator(address to) external onlyOwner {
		_removeOperator(to);
	}

	function _addOperator(address to) internal {
		require(!isOperator(to), 'Operators: existent operator');
		operators[to] = true;

		emit AddOperator(to);
	}

	function _removeOperator(address to) internal {
		require(isOperator(to), 'Operators: nonexistent operator');
		delete operators[to];

		emit RemoveOperator(to);
	}

	function isOperator(address to) public view returns(bool) {
		return operators[to];
	}


}
