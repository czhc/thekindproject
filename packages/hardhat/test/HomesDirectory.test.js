const { expect }  = require('chai');
const { MockProvider } = require('ethereum-waffle');

describe('HomesDirectory', function(){
  let owner, home1, home2, user;
  before(async function(){
    this.HomesDirectory = await ethers.getContractFactory('HomesDirectory');
    // this.provider = new MockProvider();
  });

  beforeEach(async function(){
    this.homeDir = await this.HomesDirectory.deploy();
    await this.homeDir.deployed();
    [owner, home1, home2, user1] = await ethers.getSigners();

  })

  describe('addHome', function(){
    it('accepts new addresses', async function(){
      await this.homeDir.addHome(home1.address);
      expect(await this.homeDir.homes(home1.address)).to.be.true;
    })

    it('rejects existing addresses', async function(){
      await this.homeDir.addHome(home1.address);
      await expect(this.homeDir.addHome(home1.address)).to.be.reverted;
    })

    it('requires Owner', async function(){
      await expect (this.homeDir.addHome(home1.address, { from: user1})).to.be.reverted;
    })

    it('emits homeAdded', async function(){
      await expect (this.homeDir.addHome(home1.address)).to.emit(this.homeDir, 'homeAdded');
    })
  })


  describe('updateHome', function(){

    beforeEach(async function(){
      await this.homeDir.addHome(home1.address)
    })

    it('accepts changed addresses', async function(){
      await this.homeDir.updateHome(home1.address, home2.address);
      expect(await this.homeDir.homes(home1.address)).to.be.false;
      expect(await this.homeDir.homes(home2.address)).to.be.true;
    })

    it('rejects non-existing address in directory', async function(){
      await this.homeDir.updateHome(home1.address, home2.address);
      await expect(this.homeDir.updateHome(home1.address, home2.address)).to.be.reverted;
    })

    it('requires Owner', async function(){
      await expect (this.homeDir.updateHome(home1.address, home2.address, { from: user1})).to.be.reverted;
    })

    it('emits homeUpated', async function(){
      await expect (this.homeDir.updateHome(home1.address, home2.address)).to.emit(this.homeDir, 'homeUpdated');
    })
  })


  describe('deleteHome', function(){

    beforeEach(async function(){
      await this.homeDir.addHome(home1.address);
    })

    it('removes address', async function(){
      await this.homeDir.deleteHome(home1.address);
      expect(await this.homeDir.homes(home1.address)).to.be.false;
    })


    it('requires Owner', async function(){
      await expect (this.homeDir.deleteHome(home1.address, { from: user1})).to.be.reverted;
    })

    it('emits homeDeleted', async function(){
      await expect (this.homeDir.deleteHome(home1.address)).to.emit(this.homeDir, 'homeDeleted');
    })
  })

  // it('retrieve returns a value previously stored', async function(){
  //   await this.box.setValue(42);
  //   expect(await this.box.getValue()).to.equal(42);
  // })

  // it('emits event ValueChanged', async function(){
  //   await expect(this.box.setValue(42)).to.emit(this.box, 'ValueChanged');
  // })

  // it('reverts when unauthorized', async function(){
  //   const [owner, addr1] = await ethers.getSigners();
  //   await expect(this.box.setValue(100, { from: addr1 })).to.be.reverted;
  // })
})