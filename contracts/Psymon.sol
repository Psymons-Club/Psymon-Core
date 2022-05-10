//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;



contract PsyMons is ERC721Enumerable,Ownable,ReentrancyGuard{

    //State
    uint constant public MAX_SUPPLY = 901;
    uint constant public PRICE = 1 ether;
    string public PROVENANCE_HASH = "";
    string internal baseURI;

    //Counts
    using Counters for Counters.Counter;
    Counters.Counter private tokenId_;

    //Reflections
    uint public reflectiveAmount;
    mapping(uint=>uint) public reflectiveShare;
    mapping(uint=>uint) public reflectiveRetrieved;
    
    constructor() ERC721("PsyMons","PSY"){
        for(uint i=901;i<1001;i++){
            _safeMint(msg.sender,i);
        }
    }

    //Mint NFTs
    //if max supply has not been reached
    //if full price is paid
    //if presale in not active
    function mint() external payable{
        require(tokenId_.current() < MAX_SUPPLY,"Max supply has been reached");
        require(msg.value >= PRICE,"Full price needs to be paid by the user");
        tokenId_.increment();
        uint currentId = tokenId_.current();
        _safeMint(msg.sender,currentId);
        uint8 reflection_percentage = 10;        
        uint newShare = (msg.value*reflection_percentage)/100;
        reflectiveRetrieved[currentId] = currentId;
        //token ID 1 has 0 rewards for itself
        if(currentId > 1)
        {
            reflectiveAmount += newShare;
            //Rewards are to be split only among first 200 mons
            if(currentId < 200)
            {
                reflectiveShare[currentId] = reflectiveShare[currentId-1] + newShare/(currentId-1);
            }
            else{
                reflectiveShare[currentId] = reflectiveShare[currentId-1] + newShare/(200);
            }
        }
    }

    //Calculate rewards for particular tokenId
    function calculateReward(uint tokenId) public view returns(uint reward){
        require(_exists(tokenId),"Token ID is invalid");
        if(tokenId < 201)
        {
            reward = reflectiveShare[tokenId_.current()] - reflectiveShare[reflectiveRetrieved[tokenId]];
        }
        else{
            reward = 0;
        }
    }

    //Retrieve reflection rewards for particular tokenId
    function retrieveReward(uint tokenId) external nonReentrant{
        require(_exists(tokenId),"Token ID is invalid");
        uint amount = calculateReward(tokenId);
        require(amount > 0,"No reward to retrieve");
        reflectiveAmount -= amount;
        reflectiveRetrieved[tokenId] = tokenId_.current();
        payable(msg.sender).transfer(amount);
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
        uint amount = address(this).balance - reflectiveAmount;
        payable(owner()).transfer(amount);
    }
}