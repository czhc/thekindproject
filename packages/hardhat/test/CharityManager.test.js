const { expect }  = require('chai');
const { MockProvider } = require('ethereum-waffle');

describe('CharityManager', function(){
  let owner, char1, char2, user;

  before(async function(){
    this.CharityManager = await ethers.getContractFactory('CharityManager');
    this.Charity  = await ethers.getContractFactory('Charity');
    // this.provider = new MockProvider();
  });

  beforeEach(async function(){
    this.manager = await this.CharityManager.deploy();
    await this.manager.deployed();
    [owner, char1, char2, user1] = await ethers.getSigners();

  })

  describe('addCharity', function(){
    describe('creates Charity', function(){
      let char;
      beforeEach(async function(){
        let txn = await this.manager.addCharity('Charity #1');
        console.log('txn.to: ', txn.to);
        char = await this.Charity.attach(txn.to);
        console.log('char: ', await(char.name()));
      })
      it ('with name', async function(){
        console.log('DEBUG char: ', char);
        expect(await char.name()).to.equal('Charity #1');
      })
      it ('with sender wallet', async function(){
        expect(char.wallet).to.equal(owner.address);
      })
      it ('with index', async function(){
        expect(char.index).to.equal(0);
      })
      // it ('increments index', async function(){
      //   await expect(
      //     this.manager.addCharity('Charity #1')
      //     ).to.increase(this.manager.index).by(1);
      // })
    })
    // it('accepts new addresses', async function(){
    //   await this.manager.addHome(char1.address);
    //   expect(await this.manager.charities(char1.address)).to.be.true;
    // })

    // it('rejects existing addresses', async function(){
    //   await this.manager.addHome(char1.address);
    //   await expect(this.manager.addHome(char1.address)).to.be.reverted;
    // })

    // it('requires Owner', async function(){
    //   await expect (this.manager.addHome(char1.address, { from: user1})).to.be.reverted;
    // })

    // it('emits homeAdded', async function(){
    //   await expect (this.manager.addHome(char1.address)).to.emit(this.manager, 'homeAdded');
    // })
    // it('creates new Charity', async function(){

    //   expect(this.manager.charities(0))
    // })

    // it('creates new Charity with msg.sender as owner', async function(){

    // })

    // it ('creates new Charity with index', async function(){

    // })

    // it ('creates new Charity as new', async function(){

    // })

    // it ('emits event charityAdded', async function(){

    // })


    // it('requires Owner', async function(){
    //   // await expect (this.manager.addHome(char1.address, { from: user1})).to.be.reverted;
    // })

    // it('emits homeAdded', async function(){
    //   // await expect (this.manager.addHome(char1.address)).to.emit(this.manager, 'homeAdded');
    // })

  })


  describe('deleteHome', function(){

    // beforeEach(async function(){
    //   await this.manager.addHome(char1.address);
    // })

    // it('removes address', async function(){
    //   await this.manager.deleteHome(char1.address);
    //   expect(await this.manager.charities(char1.address)).to.be.false;
    // })


    // it('requires Owner', async function(){
    //   await expect (this.manager.deleteHome(char1.address, { from: user1})).to.be.reverted;
    // })

    // it('emits homeDeleted', async function(){
    //   await expect (this.manager.deleteHome(char1.address)).to.emit(this.manager, 'homeDeleted');
    // })
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