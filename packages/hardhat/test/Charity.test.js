const { expect } = require('chai');
const { smockit } = require('@eth-optimism/smock');
const { getEventResponse } = require('./utils');

describe('Charity', function(){
  let owner, char1, donor, user1, address, charity;

  before (async() => {
    [owner, char1, donor, user1] = await ethers.getSigners();
    this.ManagerFactory = await ethers.getContractFactory('CharityManager');
    this.CharityFactory = await ethers.getContractFactory('Charity');
    this.manager = await this.ManagerFactory.deploy();
    await this.manager.deployed();

    let address = await getEventResponse(
                    await this.manager
                            .connect(char1)
                            .createCharity('Charity #1'),
                    'cAddress'
                  )
    this.charity = await this.CharityFactory.attach(address);
    await this.manager.verifyCharity(address);
    await this.manager.connect(donor).donateTo(address, { value: 1000});
  })

  describe ('withdraw', async() =>{
    it('requires owner', async() =>{
      await expect(
          this.charity.connect(user1)
            .withdraw(100)
        ).to.be.revertedWith('Unauthorized');
    })

    it('requires sufficient balance', async()=>{
      await expect(
          this.charity
            .withdraw(100)
        ).to.be.revertedWith('Unauthorized');

    })

    it('does not allow manager owner', async() =>{
      await expect(
          this.charity.connect(owner)
            .withdraw(100)
        ).to.be.revertedWith('Unauthorized');
    })

    it('decrements balance', async()=>{
      await this.charity.connect(char1).withdraw(100)
      expect(await this.charity.balance()).to.equal('900');
    })

    it('emits FundWithdraw event', async()=>{
      await expect(
        this.charity.connect(char1).withdraw(100)
       ).to.emit(
         this.charity, 'FundWithdrawn'
       ).withArgs(
         char1.address, 100
       )
    })
  })

  describe ('receive', async()=> {
    it ('requires Charity to be Verified', async () => {
      newCharityAdd = await getEventResponse(
                      await this.manager
                              .connect(char1)
                              .createCharity('Charity #2'),
                      'cAddress'
                    )

      txn = donor.sendTransaction({
              to: newCharityAdd,
              value: 100}
            )

      await expect(txn).to.be.revertedWith('Charity is not Verified');

    })

    it ('increments balance', async() =>{
      before = (await this.charity.balance()).toNumber();

      await donor.sendTransaction({
              to: this.charity.address,
              value: 100}
            )

      expect(
        (await this.charity.balance()).toNumber()
      ).to
      .equal(before+100);

    })

    it ('emits FundReceived event', async() =>{
      await expect(
        donor.sendTransaction({
              to: this.charity.address,
              value: 100}
            )
       ).to
      .emit(this.charity, 'FundReceived')
      .withArgs(donor.address, 100)
    })

  })
})