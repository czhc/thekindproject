
const { ethers } = require('hardhat');

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const HomesDirectory = await ethers.getContractFactory('HomesDirectory');
  console.log('Deploying HomesDirectory...');
  const homes = await HomesDirectory.deploy();
  await homes.deployed();
  console.log("HomesDirectory deployed to: ", homes.address);
};

module.exports.tags = ["Homes"];
