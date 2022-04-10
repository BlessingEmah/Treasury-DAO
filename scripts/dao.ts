import { ethers } from "hardhat";


async function main() {
  // We get the contract to deploy
  const DAO = await ethers.getContractFactory("DAO");
  const deployDao = await DAO.deploy( "120", "1");

  await deployDao.deployed();
  console.log("DAO deployed to:", deployDao.address);

 
  //calling the contribute function and passing a payable function
   const value = { value: ethers.utils.parseEther("1000") };
   const value1 = ethers.utils.parseEther("0.1");
  await deployDao.contribute(value)

 const [investor1, investor2, investor3, address4, investor4, investor5] =await ethers.getSigners()
  console.log(
    "The investors are:",
    investor1.address,
    investor2.address,
    investor3.address,
    investor4.address,
    investor5.address

  );

await deployDao.connect(investor2).contribute(value);
await deployDao.connect(investor3).contribute(value);
await deployDao.connect(investor4).contribute(value);
await deployDao.connect(investor5).contribute(value);


await deployDao.connect(investor2).collectShare(value1)
await deployDao.connect(investor3).collectShare(value1);
await deployDao.connect(investor4).collectShare(value1);
await deployDao.connect(investor5).collectShare(value1);
//uncomment the line below to check the shares of an investor.
//console.log("Investors shares is:",await deployDao.connect(investor2).shares(investor2.address))


const value2 = ethers.utils.parseEther("0.1");
await deployDao.connect(investor2).transferShare(value2, investor3.address)
console.log(
"investor2 transferred:",
await deployDao.connect(investor2).shares(investor2.address)
);


const proposalAmount = await ethers.utils.parseEther("0.02")
await deployDao.connect(investor2).createproposalId("Web3 Talent", proposalAmount,address4.address )
console.log("Investors 2 proposal:", await deployDao.proposalId(0));

await deployDao.connect(investor1).vote(0)
await deployDao.connect(investor3).vote(0);
await deployDao.connect(investor4).vote(0);
await deployDao.connect(investor5).vote(0);
console.log("Voted proposal:", await deployDao.proposalId(0));


console.log("contributionEndTime:", await deployDao.contributionEndTime());
console.log("voteTime:", await deployDao.voteTime());
  console.log("approvers:", await deployDao.approvers());

  console.log("Total shares:", await deployDao.totalShares());

  console.log("Approvers:", await deployDao.approvers());
  await deployDao.executeProposal(0);
console.log("EXecuted proposal:", await deployDao.proposalId(0));

console.log("balance before :", await ethers.provider.getBalance(investor1.address))

const withdraw = ethers.utils.parseEther("1000")
await deployDao.withdrawEther(withdraw, investor1.address);

console.log("balance after :", await ethers.provider.getBalance(investor1.address));



// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

}

