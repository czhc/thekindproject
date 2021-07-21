// 0x17a8A1e046B2a7D07f9B38577FD14E81515df086


const { ethers } = require('hardhat');

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const CharityManager = await ethers.getContractFactory('Charity');
  console.log('Deploying Charity');
  const charity = await Charity.deploy();

  await charity.deployed();
  console.log("CharityManager deployed to: ", manager.address);

};

module.exports.tags = ["Charity"];
