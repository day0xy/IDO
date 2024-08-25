// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TestTokenIDO {
    IERC20 public token;
    address public owner;
    bool public isPresaleActive = false;
    // Total amount of tokens for this presale
    uint256 public totalPresaleAmount;

    // Presale price
    uint256 constant PRESALE_PRICE = 0.001 ether;
    // Expected fundraising target
    uint256 constant RAISE_LIMIT = 100 ether;
    // Maximum fundraising cap
    uint256 constant RAISE_CAP = 200 ether;
    // Minimum purchase amount
    uint256 constant MIN_BUY = 0.01 ether;
    // Maximum purchase amount
    uint256 constant MAX_BUY = 0.1 ether;
    // Presale time
    uint256 public startTime;
    uint256 public endTime;
    // Total amount raised
    uint256 public totalRaised = 0;

    mapping(address => uint256) public funded;
    mapping(address => bool) public claimedRefund;

    event PresaleStarted();
    event Presale(address indexed user, uint256 amount);
    event TokensClaimed(address indexed user, uint256 tokens);
    event RefundClaimed(address indexed user, uint256 amount);

    constructor(
        address _token,
        uint256 _totalPresaleAmount,
        uint256 _startTime,
        uint256 _endTime,
        address _owner
    ) {
        owner = _owner;
        token = IERC20(_token);
        require(token.totalSupply() > 0, "invalid token");
        require(_totalPresaleAmount > 0, "invalid total presale amount");
        require(
            _totalPresaleAmount <= token.totalSupply(),
            "total presale amount exceeds total supply"
        );
        totalPresaleAmount = _totalPresaleAmount;
        startTime = _startTime;
        endTime = _endTime;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    modifier onlyPresaleActive() {
        require(isPresaleActive, "presale not active");
        _;
    }

    modifier whenPresaleEnded() {
        require(block.timestamp > endTime, "presale not ended");
        _;
    }

    function startPresale() external onlyOwner {
        require(!isPresaleActive, "presale already active");
        isPresaleActive = true;
        emit PresaleStarted();
    }

    // During presale, users send ETH to exchange for tokens
    function presale() external payable onlyPresaleActive {
        require(msg.value >= MIN_BUY, "below min buy");
        require(msg.value <= MAX_BUY, "above max buy");
        // Prevent exceeding the cap amount
        require(totalRaised + msg.value <= RAISE_CAP, "exceeds raise cap");
        require(block.timestamp >= startTime, "presale not started");
        require(block.timestamp <= endTime, "presale ended");

        // Track the amount of ETH sent by the user
        funded[msg.sender] += msg.value;
        totalRaised += msg.value;
        token.transfer(msg.sender, msg.value / PRESALE_PRICE);

        emit Presale(msg.sender, msg.value);
    }

    // After the presale ends, if the fundraising target is met, users can claim tokens
    function claimTokens() external whenPresaleEnded {
        require(totalRaised >= RAISE_LIMIT, "raise limit not met");
        uint256 amount = funded[msg.sender];
        require(amount > 0, "no tokens to claim");

        funded[msg.sender] = 0;
        // Calculate tokens based on the user's investment
        // Tokens = total presale tokens * (user's ETH contribution / total raised ETH)
        uint256 tokens = totalPresaleAmount *
            (funded[msg.sender] / totalRaised);

        // Send tokens to the user
        token.transfer(msg.sender, tokens);
        emit TokensClaimed(msg.sender, tokens);
    }

    // After the presale ends, if fundraising did not meet RAISE_LIMIT, users can request a refund
    function claimRefund() external whenPresaleEnded {
        require(totalRaised < RAISE_LIMIT, "raise limit met");
        require(!claimedRefund[msg.sender], "refund already claimed");

        uint256 amount = funded[msg.sender];
        require(amount > 0, "no refund available");

        claimedRefund[msg.sender] = true;
        funded[msg.sender] = 0;

        // Refund the amount to the user
        payable(msg.sender).transfer(amount);
        emit RefundClaimed(msg.sender, amount);
    }

    // After the presale ends, if the fundraising meets RAISE_LIMIT, the owner can withdraw funds
    function withdrawFunds() external onlyOwner whenPresaleEnded {
        require(totalRaised >= RAISE_LIMIT, "raise limit not met");
        payable(owner).transfer(address(this).balance);
    }

    function totalRaised_() external view returns (uint256) {
        return totalRaised;
    }
}
