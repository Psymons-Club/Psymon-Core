//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Psymon is ERC721Enumerable,Ownable,ReentrancyGuard{

    uint constant public MAX_SUPPLY = 3801;
    uint constant public PRICE = 1e8;

    string public PROVENANCE_HASH = "";
    string internal baseURI;

    uint public whitelistSold;
    uint public whitelistLimit;

    uint tokenId_;

    uint[] purchaseCode = [1,3,5,10];

    //Reflections
    uint public reflectiveAmount;
    mapping(uint=>uint) public reflectiveShare;
    mapping(uint=>uint) public reflectiveRetrieved;
    
    constructor() ERC721("PsyMons","PSYMON"){
        for(uint i=3801;i<4001;i++){
            _safeMint(msg.sender,i);
        }
    }

    function mint(uint code) external payable{
        require(tokenId_ < MAX_SUPPLY,"Max supply has been reached");
        require(msg.value >= PRICE*purchaseCode[code],"Full price needs to be paid by the user");
        for(uint i=0;i<purchaseCode[code];i++){
            tokenId_++;
            _safeMint(msg.sender,tokenId_);
        }
    }

    function _baseURI() internal view virtual override returns (string memory){
        return baseURI;
    }

    //Owner modifiable base URI (to switch between api and folder hash)
    function setBaseURI(string memory newBaseURI) external onlyOwner(){
        baseURI = newBaseURI;
    }

    //Owner function for retrieving non reward balance
    function retrieveBalance() external onlyOwner nonReentrant{
        uint amount = address(this).balance;
        payable(owner()).transfer(amount);
    }
}