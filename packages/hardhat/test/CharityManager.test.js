const { expect }  = require('chai');

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
        let charityAdd =  await this.manager.charityMap(0);
        this.charity = await this.CharityFactory.attach(charityAdd);
      })
      it('with given name', async()=>{
        expect(await this.charity.name()).to.equal('Charity #1');
      })
      it('with msg origin as Charity owner ', async() =>{
        expect(await this.charity.getOwner()).to.equal(char1.address);
      })
      it('with index', async() => {
        expect(await this.charity.index()).to.equal(0);
      })
      it('pushes charity address to list', async()=>{
        let list = await this.manager.getCharityList();
        expect(list.length).to.equal(1);
        expect(list).to.include(this.charity.address.toString());
      })
      it('increments manager.index', async()=>{
        expect(await this.manager.index()).to.equal(1);
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
      let charityAdd =  await this.manager.charityMap(0);
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


  })

})