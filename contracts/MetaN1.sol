// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import './Operators.sol';

contract MetaN1 is ERC721Enumerable, Operators {
	using SafeMath for uint256;
	using Strings for uint256;

	uint256 private nonce;

	string public baseURI;

	uint256 public supply;

	uint256 public remains;

	uint256 public openTime;

	mapping(uint256 => uint256) public slots;

	mapping(address => bool) public whiteList;

	mapping(address => bool) public isClaimed;

	event WhiteListUpdated(address to, bool isWhite);

	event OpenTimeUpdated(uint256 time);

	event SupplyUpdated(uint256 supply);

	event RemainsUpdated(uint256 remains);

	event BaseURIUpdated(string uri);

	modifier isOpen() {
		require(openTime <= block.timestamp, 'Meta N1: sale is not open');
		_;
	}

	constructor(
		address newOwner,
		address operator,
		string memory _baseURI,
		uint256 _openTime,
		uint256 _supply
	) ERC721('Meta N1', 'meta N') {
		_transferOwnership(newOwner);
		_addOperator(operator);
		_setBaseURI(_baseURI);
		_setOpenTime(_openTime);
		_setSupply(_supply);
		_setRemains(_supply);
		nonce = block.number;
	}

	function mint() external isOpen {
		address to = msg.sender;
		require(whiteList[to], 'Meta N1: caller is not in the white list');
		require(!isClaimed[to], 'Meta N1: token has been claimed');
		_randMint(to);
		isClaimed[to] = true;
	}

	function operatorMint(address to, uint256 amount) external onlyOperator {
		for (uint256 i = 0; i < amount; i++) {
			_randMint(to);
		}
	}

	function updateWhiteList(address[] memory _whiteList, bool isWhite) external onlyOperator {
		_updateWhiteList(_whiteList, isWhite);
	}

	function setOpenTime(uint256 time) external onlyOperator {
		_setOpenTime(time);
	}

	function setBaseURI(string memory _baseURI) external onlyOperator {
		_setBaseURI(_baseURI);
	}

	function _randMint(address to) internal {
		require(remains > 0, 'Meta N1: token sold out');
		nonce++;
		uint256 id = rands();
		if (!_isSlotOccupied(id)) {
			_mint(to, id);
		} else {
			_mint(to, slots[id]);
		}
		if (_isSlotOccupied(remains)) {
			slots[id] = slots[remains];
		} else {
			slots[id] = remains;
		}
		_setRemains(remains.sub(1));
	}

	function rands() internal view returns (uint256) {
		uint256 rand = uint256(keccak256(abi.encodePacked(nonce, blockhash(block.number), msg.sender)));
		return (rand % remains).add(1);
	}

	function _updateWhiteList(address[] memory _whiteList, bool isWhite) internal {
		require(_whiteList.length > 0, 'Meta N1: invalid list length');
		for (uint256 i = 0; i < _whiteList.length; i++) {
			_setWhite(_whiteList[i], isWhite);
		}
	}

	function _setWhite(address to, bool isWhite) internal {
		whiteList[to] = isWhite;
		emit WhiteListUpdated(to, isWhite);
	}

	function _setOpenTime(uint256 time) internal {
		openTime = time;
		emit OpenTimeUpdated(time);
	}

	function _setSupply(uint256 _supply) internal {
		supply = _supply;
		emit SupplyUpdated(_supply);
	}

	function _setRemains(uint256 _remains) internal {
		remains = _remains;
		emit RemainsUpdated(_remains);
	}

	function _setBaseURI(string memory _baseURI) internal {
		baseURI = _baseURI;
		emit BaseURIUpdated(_baseURI);
	}

	function _isSlotOccupied(uint256 id) internal view returns (bool) {
		return slots[id] != 0;
	}

	function tokenURI(uint256 tokenId) public view override returns (string memory) {
		require(_exists(tokenId), 'Meta N1: URI query for nonexistent token');
		return string(abi.encodePacked(baseURI, tokenId.toString(), '.json'));
	}

	function burn(uint256 tokenId) public {
		require(_isApprovedOrOwner(_msgSender(), tokenId), 'Meta N1: caller is not owner nor approved');
		_burn(tokenId);
	}
}
