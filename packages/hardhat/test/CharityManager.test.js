const { expect }  = require('chai');
const { smockit } = require('@eth-optimism/smock');

describe('CharityManager', function(){
  let owner, char1, char2, user;

  before (async() => {
    [owner, char1, char2, user1] = await ethers.getSigners();
    this.ManagerFactory = await ethers.getContractFactory('CharityManager');
    this.CharityFactory = await ethers.getContractFactory('Charity');
  })

  beforeEach(async()=>{
    this.manager = await this.ManagerFactory.deploy();
    await this.manager.deployed();
  })

  describe('createCharity', async()=>{
    describe('with attributes', async()=>{
      beforeEach(async()=>{
        await this.manager.connect(char1).createCharity('Charity #1');
        let charityAdd =  await this.manager.charityMap(1);
        this.charity = await this.CharityFactory.attach(charityAdd);
      })
      it ('does not start from reserved index 0', async()=>{
        let cNull = await this.manager.charityMap(0);
        expect(cNull.address).to.equal(undefined);
      })
      it('with given name', async()=>{
        expect(await this.charity.name()).to.equal('Charity #1');
      })
      it('with msg origin as Charity owner ', async() =>{
        expect(await this.charity.getOwner()).to.equal(char1.address);
      })
      it('with index', async() => {
        expect(await this.charity.index()).to.equal(1);
      })
      it('pushes charity address to list', async()=>{
        let list = await this.manager.getCharityList();
        expect(list.length).to.equal(1);
        expect(list).to.include(this.charity.address.toString());
      })
      it('increments manager.index', async()=>{
        expect(await this.manager.index()).to.equal(2);
      })
      it('emits CharityCreated', async()=> {
        await expect(this.manager.createCharity('foo'))
          .to.emit(this.manager, 'CharityCreated');
      })
    })

  })




  describe('verifyCharity', async()=>{
    beforeEach(async()=>{
      await this.manager.connect(char1).createCharity('Charity #1');
      let charityAdd =  await this.manager.charityMap(1);
      this.charity = await this.CharityFactory.attach(charityAdd);
    })

    it('should allow manager owner', async()=>{
      await expect(
        this.manager.connect(owner)
          .verifyCharity(this.charity.address)
      ).to.not.be.reverted;
    })

    it('should not allow charity owner', async()=>{
      await expect(
        this.manager.connect(char1)
          .verifyCharity(this.charity.address)
      ).to.be.reverted;
    })

    // tests for Charity.verify() in Charity suite

    it('emits CharityVerified', async()=> {
      await expect(
        this.manager
          .verifyCharity(this.charity.address)
        ).to
        .emit(this.manager, 'CharityStatusChanged')
        .withArgs(this.charity.address, 1); //1 = Verified
    })


    it('asserts charity is Verified', async() =>{
      // mocks verifyCharity to test silent errors on Charity.verify()
      const mockCharity = await smockit(this.charity);
      mockCharity.smocked.status.will.return.with(0);

      await expect(
         this.manager.verifyCharity(mockCharity.address)
        ).to.be.reverted; //from assert(_c.status())
    })
  })


  describe('donateTo', async()=> {
    beforeEach(async()=>{
      await this.manager.connect(char1).createCharity('Charity #1');
      let charityAdd =  await this.manager.charityMap(1);
      this.charity = await this.CharityFactory.attach(charityAdd);
      await this.manager.verifyCharity(this.charity.address);
    })

    it('reverts on non-Charity address', async() => {
      await expect(
        this.manager.donateTo(
          ethers.constants.AddressZero,
          { value: 100 }
          )
        ).to.be.revertedWith('Charity does not exist')
    })

    it('emits DonationReceived', async() => {
      await expect(
        this.manager
          .connect(user1)
          .donateTo(this.charity.address, { value: 101})
        ).to
        .emit(this.manager, 'DonationReceived')
        .withArgs(user1.address, this.charity.address, 101);
    })

    /**
     * TODO: add test to mock Charity call/receive and assert manager reverts donateTo
     * STATUS: pending confirmation from smock team
     * ISSUE: https://github.com/ethereum-optimism/optimism/issues/1245
     *
    it('reverts on unsuccessful transfer', async() => {
      // mocks Charity.receive to return a false scenario
      const mockManager = await smockit(this.manager);
      const mockCharity = await smockit(this.charity);

      console.log('mockCharity: ', mockCharity);
      console.log('mockCharity.status: ', await mockCharity.status());

      mockManager.smocked.charityExists.will.return.with(true);
      // smocked does not stub call or receive yet
      mockCharity.smocked.status.will.return.with(0);

      await expect(
         mockManager
           .connect(owner)
           .donateTo(mockCharity.address, {value: 102})
        ).to.be.revertedWith('Failed to send funds') //from assert(_c.status())
    })
    **/
  })
})