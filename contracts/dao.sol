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

*/

contract DAO {

    struct ProposalInfo{
        uint id;
        uint votes; //votes of the proposals
        uint contributionEndTime;
        uint amount;
        address payable proposalAddress;
        bool executed;
        string name;
    }
   
uint public totalShares;  // total shares in the smart contract
uint public availableFunds; //in ethers
uint public contributionEndTime ;
uint public contributionTime = 5 days;
uint public nextProposalId;
uint public voteTime; // //votetime of the proposal
uint public approvers;// minimum votes required to execute a proposal
address public admin; //the dao system

mapping(address => bool) public isInvestor;
mapping(address => uint) public shares;
mapping(uint => ProposalInfo)  public proposalId;
mapping(address => mapping(uint => bool) )public votes;
 
                                                                                                                                                                                          
constructor(
    uint _voteTime,
    uint _approvers) {
    require(_approvers > 0 && _approvers < 100,"approver limit");
    contributionEndTime = block.timestamp + contributionTime;
    voteTime = _voteTime;
    approvers = _approvers;
    admin = msg.sender;
} 

modifier onlyInvestors() {
    require(isInvestor[msg.sender] ==true, "only investors");
    _;
}

modifier onlyAdmin() {
    require(msg.sender == admin, "only admin");
    _;
}


function contribute() external payable {
    require(block.timestamp < contributionEndTime, "Contribution has ended");
    isInvestor[msg.sender] = true;
    shares[msg.sender] += msg.value;
    totalShares += msg.value;
    availableFunds += msg.value;
}

function collectShare(uint amount) external returns(bool){
    require(shares[msg.sender] >= amount, "not enough shares" );
    require(availableFunds >= amount, "not enough availablefunds");
    shares[msg.sender] -= amount;
    availableFunds -= amount;
    (bool status, ) =(msg.sender).call{value:amount}(""); 
    return status;
}

function transferShare(uint amount, address to) external { 
     require(shares[msg.sender] >= amount, "not enough shares" );
    shares[msg.sender] -= amount;
    isInvestor[to] = true;  
    shares[to] += amount;
}
   
   
function createproposalId( string memory name, uint amount, address payable proposalAddress) external onlyInvestors() {
    require(availableFunds >= amount, "amount too big");
    proposalId[nextProposalId] = ProposalInfo(
        nextProposalId,
        0, // number of votes
        block.timestamp + voteTime, //enddate of the voting time
        amount,
        proposalAddress,
        false,
        name
    );
    availableFunds -= amount;
    nextProposalId++; 
}

function vote(uint Id) external onlyInvestors(){
    ProposalInfo storage proposal = proposalId[Id];
    require(votes[msg.sender][Id] == false, "investor can only vote once for a proposal");
    require(block.timestamp <= proposal.contributionEndTime, "can only vote until proposal end");
    votes[msg.sender][Id]= true;
    proposal.votes += shares[msg.sender];
}

function executeProposal(uint Id) external onlyAdmin() {
     ProposalInfo storage proposal = proposalId[Id];
     require(block.timestamp <= proposal.contributionEndTime, "cannot execute a proposal before end date" ); 
     require(proposal.executed == false, "cannot execute a proposal already executed ");
     //require((proposal.votes/ totalShares) * 100 >= approvers, "cannot execute proposal with votes below required approver amount");
    _transferEther(proposal.amount, proposal.proposalAddress);
    proposal.executed = true;
}

function withdrawEther(uint amount, address payable to)external onlyAdmin() {
    _transferEther(amount, to);
}


function _transferEther(uint amount, address payable to) internal  {
    require(amount <= availableFunds, "not enough available funds");
    availableFunds -= amount;
    to.transfer(amount);  
}

// function viewStruct(uint id) public view returns(ProposalInfo memory){
//     return proposalId[id];
// }


}