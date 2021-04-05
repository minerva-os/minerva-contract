// FOR REMIX

pragma solidity ^0.8.0;

// Please note Open Zeppelin 3.x is being used here

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/ERC20Capped.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Capped.sol";

// import "hardhat/console.sol";

contract YourContract is ERC20Capped {
    // Stores link of Repo in contract
    string public linkToRepo;

    // Stores amount to be given to Repo maintainer
    address public repoOwner;

    // Stores data on which contributor sponsored how much $$$
    mapping(address => uint256) funds;

    // Stores the usernames of contributors after successful PR merge
    mapping(string => uint256) contributors;

    // Please add the arguments while deploying contracts. For now, Token Name is static.
    constructor(
        address _recipient,
        string memory _linkToRepo,
        uint256 _cap
    ) public ERC20("MyToken", "MYT") ERC20Capped(_cap) {
        // _mint(_owner, 1000000000000000000000);

        // For Remix
        ERC20._mint(_recipient, 100000000000000000000);

        // For hardhat
        // _mint(_recipient, 100000000000000000000);

        repoOwner = _recipient;

        linkToRepo = _linkToRepo;
    }

    // Function called when sponsors contribute $$$.
    function sponsorFundsRepo() public payable {
        require(msg.value >= 0.001 ether);
        funds[msg.sender] = msg.value;

        // sendSponsorFunds(msg.sender);
        // transferFrom(address(this), msg.sender, 10000000000000000000);
        _mint(msg.sender, 10000000000000000000);
    }

    function getBalance(address _address) public view returns (uint256) {
        return balanceOf(_address);
    }

    // Stores 1 token in the name of the contributor username
    function reserveContributorTokens(string memory _username) public {
        contributors[_username] += 1;
    }

    function sendContributorTokens(string memory _username, address _address)
        public
    {
        require(contributors[_username] > 0);
        _mint(_address, 1000000000000000000);
    }
}
