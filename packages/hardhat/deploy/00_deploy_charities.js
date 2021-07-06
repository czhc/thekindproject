
const { ethers } = require('hardhat');

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const CharityManager = await ethers.getContractFactory('CharityManager');
  console.log('Deploying CharityManager...');
  const manager = await CharityManager.deploy();

  await manager.deployed();
  console.log("CharityManager deployed to: ", manager.address);


};

module.exports.tags = ["Charity"];
