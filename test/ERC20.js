const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("ERC20", function () {
  let ERC20, erc20, AccessControl, accessControl;
  let owner, admin, nonAdmin;

  beforeEach(async function () {
    [owner, admin, nonAdmin] = await ethers.getSigners();

    AccessControl = await ethers.getContractFactory("AccessControl");
    accessControl = await upgrades.deployProxy(AccessControl, []);
    await accessControl.waitForDeployment();

    await accessControl.manageRole(admin.address, true);

    ERC20 = await ethers.getContractFactory("ERC20");
    erc20 = await upgrades.deployProxy(ERC20, ["TestToken", "TT", await accessControl.getAddress()]);
    await erc20.waitForDeployment();
  });

  describe("initialize", function () {
    it("should set name and symbol correctly", async function () {
      expect(await erc20.name()).to.equal("TestToken");
      expect(await erc20.symbol()).to.equal("TT");
    });
  });

  describe("mint", function () {
    it("should allow admin to mint tokens", async function () {
      await erc20.connect(admin).mint(nonAdmin.address, 1000);
      expect(await erc20.balanceOf(nonAdmin.address)).to.equal(1000);
    });

    it("should revert if non-admin tries to mint", async function () {
      await expect(
        erc20.connect(nonAdmin).mint(nonAdmin.address, 1000)
      ).to.be.revertedWith("ERC20: Only admin can mint");
    });
  });

  describe("burn", function () {
    beforeEach(async function () {
      // Admin mints tokens to nonAdmin before attempting burn
      await erc20.connect(admin).mint(nonAdmin.address, 500);
    });

    it("should allow admin to burn tokens", async function () {
      await erc20.connect(admin).burn(nonAdmin.address, 200);
      expect(await erc20.balanceOf(nonAdmin.address)).to.equal(300);
    });

    it("should revert if non-admin tries to burn", async function () {
      await expect(
        erc20.connect(nonAdmin).burn(nonAdmin.address, 100)
      ).to.be.revertedWith("ERC20: Only admin can burn");
    });
  });

  describe("upgrade proxy", function () {
    it("should allow upgrade if called by admin", async function () {
      const ERC20V2 = await ethers.getContractFactory("ERC20");
      await upgrades.upgradeProxy(await erc20.getAddress(), ERC20V2);
    });

    it("should revert upgrade if called by non-admin", async function () {
    const erc20V2 = await erc20.getAddress()
      await expect(
        erc20.connect(nonAdmin).upgradeToAndCall(erc20V2, "0x")
      ).to.be.revertedWith("ERC20: Only admin can upgrade");
    });
  });
});