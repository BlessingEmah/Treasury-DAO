//SPDX-License-Identifier:MIT;
pragma solidity ^0.8.4;

/* 
DESIGN ARCHITECTURE
I built a treasury DAO which does the following:

For someone to join, they have to contribute to become an Investor.
Their contribution determines their voting shares.
Investors can transfer shares to each other but they need to have a minimum balance.

Only Investors can create proposals
Only Investors can vote on a proposal.

The Dao stores the funds and executes the proposals.
5 ethers = 1 share 
A proposal has a required number of shares for it to be executed.


*/

contract DAO2 {
    struct ProposalInfo {
        uint8 votes; //votes of the proposals
        bool executed;
        uint48 contributionEndTime;
        address proposalAuthor;
        uint256 receivedShares;
        uint256 requiredShares;
        string name;
        mapping(address => bool) Voted;
    }

    uint32 constant contributionTime = 6 days;
    uint256 constant multiplier = 1000;

    uint256 public approvers; // minimum votes required to execute a proposal
    uint24 public voteTime; // //votetime of the proposal
    address public admin; //the dao system
    uint256 public totalShares; // total shares in the smart contract
    uint256 public availableFunds; //ether in the dao system
    uint256 public proposalId;

    mapping(address => bool) public isInvestor;
    mapping(address => uint256) public shares;
    mapping(uint256 => ProposalInfo) public proposals;

    //mapping(address => mapping(uint256 => bool)) public votes;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyInvestors() {
        require(isInvestor[msg.sender] == true, "only investors");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin");
        _;
    }

    function getShares() public view returns (uint256) {
        return (shares[msg.sender]);
    }

    function getS(address _address) public view returns (uint256) {
        return (shares[_address]);
    }

    function contribute() external payable {
        require(msg.value >= 5 ether, "insufficient balance");
        uint256 amount = msg.value / 5 ether;
        uint256 derivedShares = amount * multiplier;
        isInvestor[msg.sender] = true;
        shares[msg.sender] = derivedShares;
        availableFunds += msg.value;   //in the dao

    }

    function transferShare(uint256 amount, address to) external {
        require(shares[msg.sender] >= amount, "not enough shares");
        uint256 _amount = amount * multiplier;
        shares[msg.sender] -= _amount;
        isInvestor[to] = true;
        shares[to] += _amount;
    }

    function createproposalId(string memory name, uint256 requiredShares)
        external
        onlyInvestors
    {
        ProposalInfo storage p = proposals[proposalId];
        p.name = name;
        p.requiredShares = requiredShares;
        p.proposalAuthor = msg.sender;
        p.contributionEndTime = uint48(block.timestamp + contributionTime);
        proposalId++;
    }

    function vote(uint256 Id) external onlyInvestors {
        ProposalInfo storage p = proposals[Id];
        require(
            block.timestamp > p.contributionEndTime,
            "voting time has ended"
        );
        require(!p.Voted[msg.sender], "Investor has voted");
        require(
            p.receivedShares == p.requiredShares,
            "Proposal shares has been met"
        );
        p.votes += 1;
    }

    function executeProposal(uint256 Id) external onlyAdmin {
        ProposalInfo storage p = proposals[Id];
        require(
            block.timestamp <= p.contributionEndTime,
            "cannot execute a proposal before end date"
        );
        require(
            p.executed == false,
            "cannot execute a proposal already executed"
        );
        p.executed = true;
        //require((proposal.votes/ totalShares) * 100 >= approvers, "cannot execute proposal with votes below required approver amount");
        //transferEther(p.amount, p.proposalAddress);
    }

    // function withdrawEther(uint256 amount, address payable to)
    //     external
    //     onlyAdmin
    // {
    //     _transferEther(amount, to);
    // }

    // function _transferEther(uint256 amount, address payable to) internal {
    //     require(amount <= availableFunds, "not enough available funds");
    //     availableFunds -= amount;
    //     to.transfer(amount);
    // }
}

    // the contributiontime has not ended.
    //  check if their shares is greater than the minimum shares.

    // require(
    //     votes[msg.sender][Id] == false,
    //     "investor can only vote once for a proposal"
    // );