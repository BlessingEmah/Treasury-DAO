import { expect } from "chai";
import { NOTFOUND } from "dns";
import { ethers } from "hardhat";
import { DAO } from "../contracts/dao.sol"
let DAO:any

describe("Greeter", function () {
  it("Should return the new greeting once it's changed", async function () {
    const Greeter = await ethers.getContractFactory("Greeter");
    const greeter = await Greeter.deploy("Hello, world!");
    await greeter.deployed();

    expect(await greeter.greet()).to.equal("Hello, world!");

    const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    const c = await ethers.getContractFactory("name of file ")
    nft = await c.deploy()
    //@ts-ignore
    await NOTFOUND.deployd();

    // wait until the transaction is mined
    await setGreetingTx.wait();

    expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
