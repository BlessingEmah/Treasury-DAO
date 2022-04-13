//SPDX-License-Identifier:MIT;
pragma solidity ^0.8.4;

/* 
    DESIGN ARCHITECTURE

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
        mapping(address => bool) voted;
    }

    uint32 constant CONTRIBUTION_TIME = 6 days;
    uint256 constant MULTIPLIER = 1000;

    uint256 public immutable approvers; // minimum votes required to execute a proposal
    address public immutable admin; //the dao system
    uint256 public totalShares; // total shares in the smart contract
    uint256 public availableFunds; //ether in the dao system
    uint256 public proposalCount;

    mapping(address => bool) public isInvestor;
    mapping(address => uint256) public shares;
    mapping(uint256 => ProposalInfo) public proposals;

    //mapping(address => mapping(uint256 => bool)) public votes;

    constructor(uint _approvers) {
        admin = msg.sender;
        approvers = _approvers;
    }

    modifier onlyInvestor() {
        require(isInvestor[msg.sender], "only investors");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin");
        _;
    }

    function contribute() external payable {
        require(msg.value >= 5 ether, "insufficient balance");
        uint256 amount = msg.value / 5 ether;
        uint256 derivedShares = amount * MULTIPLIER;
        shares[msg.sender] = derivedShares;
        totalShares += derivedShares;
        availableFunds += msg.value;
        isInvestor[msg.sender] = true; 
    }

    function transferShare(uint256 amount, address to) external onlyInvestor {
        require(to != address(0), "Address is invalid");
        require(amount > 0, "amount is invalid");
        require(shares[msg.sender] >= amount, "not enough shares");
        shares[msg.sender] -= amount;
        isInvestor[to] = true;
        shares[to] += amount;
        if(shares[msg.sender] == 0){
            isInvestor[msg.sender] = false;
        }
    }

    function createproposalId(string memory _name, uint256 _requiredShares)
        external
        onlyInvestor
    {
        proposalCount++;
        ProposalInfo storage proposal = proposals[proposalCount];
        proposal.name = _name;
        proposal.requiredShares = _requiredShares;
        proposal.proposalAuthor = msg.sender;
        proposal.contributionEndTime = uint48(block.timestamp + CONTRIBUTION_TIME);
    }

    function vote(uint256 _id) external onlyInvestor {
        ProposalInfo storage proposal = proposals[_id];
        require(
            !proposal.executed,
            "Proposal has already been executed"
        );
        require(
            !(block.timestamp > proposal.contributionEndTime),
            "voting time has ended"
        );
        require(!proposal.voted[msg.sender], "Investor has already voted");
        require(
            !(proposal.receivedShares >= proposal.requiredShares),
            "Proposal shares has already been met"
        );
        proposal.voted[msg.sender] = true;
        proposal.receivedShares += shares[msg.sender];
        proposal.votes += 1;
    }

    function executeProposal(uint256 _id) external onlyAdmin {
        ProposalInfo storage proposal = proposals[_id];
        require(
            (block.timestamp <= proposal.contributionEndTime),
            "Contribution time elapsed"
        );
        require(
            proposal.votes >= approvers,
            "Number of approvers invalid"
        );
        require(
            !proposal.executed,
            "Proposal already executed"
        );
        require(
            proposal.receivedShares >= proposal.requiredShares,
            "Shares threshold not reached"
        );
        proposal.executed = true;
    }
}
