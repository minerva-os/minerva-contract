pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";
import {
    IWETHGateway
} from "@aave/protocol-v2/contracts/misc/WETHGateway.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Capped.sol";

contract YourContract is ERC20Capped, ChainlinkClient {
    // Stores link of Repo in contract
    string public linkToRepo;

    // Stores amount to be given to Repo maintainer
    address public repoOwner;

    // Stores data on which contributor sponsored how much $$$
    mapping(address => uint256) funds;

    // Stores the usernames of contributors after successful PR merge
    mapping(bytes32 => uint256) contributors;

    bytes32 private userId;
    uint256 private PrCount;

    address private githubOracle;
    bytes32 private userJobId;
    bytes32 private PrJobId;
    string public repoQuery;

    address private alarmOracle;
    bytes32 private alarmJobId;

    uint256 private fee;

    mapping(bytes32 => uint256) public balances;
    
    address payable WETH;

    constructor(
        address _recipient,
        string memory _linkToRepo,
        uint256 _cap,
        string memory _tokenName,
        string memory _tokenSymbol,
        string memory _repoQuery
    ) public ERC20(_tokenName, _tokenSymbol) ERC20Capped(_cap) {
        _mint(_recipient, 100000000000000000000);

        repoOwner = _recipient;

        linkToRepo = _linkToRepo;

        setPublicChainlinkToken();
        githubOracle = 0x9e308Dd6Cb8DFF70a3FDAF9604Af93BBA9f4B57e;
        userJobId = "0d840688ccb64ec38790c1a4e65bba46";
        PrJobId = "4b636dd8bf9342b1bcd148e09f066ba2";

        alarmOracle = 0xAA1DC356dc4B18f30C347798FD5379F3D77ABC5b;
        alarmJobId = "982105d690504c5d9ce374d040c08654";

        fee = 0.1 * 10**18; // 0.1 LINK
        repoQuery = _repoQuery;
        
        WETH = 0xf8aC10E65F2073460aAD5f28E1EABE807DC287CF;
    }

    function deposit(
        address user,
        uint256 amount
    ) public returns (bool) {
        IWETHGateway(WETH).depositETH{value: amount}(user, 0);
        return true;
    }

    function withdraw(
        uint256 amount,
        address user
    ) public returns (bool) {
        IWETHGateway(WETH).withdrawETH(amount, user);
        return true;
    }

    function setPrCheck() public {
        Chainlink.Request memory req =
            buildChainlinkRequest(
                alarmJobId,
                address(this),
                this.fulfillDelay.selector
            );
        req.addUint("until", now + 1 minutes);
        sendChainlinkRequestTo(alarmOracle, req, fee);
    }

    function requestUserId(string memory filter)
        private
        returns (bytes32 requestId)
    {
        Chainlink.Request memory request =
            buildChainlinkRequest(
                userJobId,
                address(this),
                this.fulfillUserId.selector
            );
        request.add("get", "http://localhost:3000");
        request.add("queryParams", repoQuery);
        request.add("path", filter);

        requestId = sendChainlinkRequestTo(githubOracle, request, fee);
    }

    function requestPrData() public returns (bytes32) {
        Chainlink.Request memory request =
            buildChainlinkRequest(
                PrJobId,
                address(this),
                this.fulfillPrData.selector
            );
        request.add("get", "http://localhost:3000");
        request.add("queryParams", repoQuery);
        request.add("path", "count");

        return sendChainlinkRequestTo(githubOracle, request, fee);
    }

    function fulfillUserId(bytes32 _requestId, bytes32 _volume)
        public
        recordChainlinkFulfillment(_requestId)
    {
        userId = _volume;
        // balances[userId] = balances[userId] + 1;

        contributors[userId] += 1;
    }

    function fulfillPrData(bytes32 _requestId, uint256 _volume)
        public
        recordChainlinkFulfillment(_requestId)
    {
        PrCount = _volume;
        for (uint256 i = 0; i < PrCount; i++) {
            string memory filter =
                string(abi.encodePacked("data.", uintToStr(i)));
            requestUserId(filter);
        }
    }

    function fulfillDelay(bytes32 _requestId)
        public
        recordChainlinkFulfillment(_requestId)
    {
        requestPrData();
        setPrCheck();
    }

    function uintToStr(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr);
    }

    // Function called when sponsors contribute $$$.
    function sponsorFundsRepo() public payable {
        require(msg.value >= 0.001 ether);
        funds[msg.sender] = msg.value;

        deposit(
            address(this),
            msg.value
        );

        _mint(msg.sender, 10000000000000000000);
    }

    function getBalance(address _address) public view returns (uint256) {
        return balanceOf(_address);
    }

    // Stores 1 token in the name of the contributor username
    function reserveContributorTokens(bytes32 _userid) public {
        contributors[_userid] += 1;
    }

    function sendContributorTokens(bytes32 _userid, address _address) public {
        require(contributors[_userid] > 0);
        _mint(_address, 1000000000000000000);
    }
    
    fallback() external payable { }
}