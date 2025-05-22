const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("AccessControl", function () {
  let AccessControl, accessControl, owner, addr1, addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    AccessControl = await ethers.getContractFactory("AccessControl");
    accessControl = await upgrades.deployProxy(AccessControl, [])
    await accessControl.waitForDeployment();
  });

  describe("initialize", function () {
    it("should set the deployer as admin", async function () {
      expect(await accessControl.isAdmin(owner.address)).to.be.true;
    });
  });

  describe("isAdmin", function () {
    it("should return false for non-admin", async function () {
      expect(await accessControl.isAdmin(addr1.address)).to.be.false;
    });

    it("should return true for admin", async function () {
      await accessControl.manageRole(addr1.address, true);
      expect(await accessControl.isAdmin(addr1.address)).to.be.true;
    });
  });

  describe("manageRole", function () {
    it("should allow admin to grant admin role", async function () {
      await accessControl.manageRole(addr1.address, true);
      expect(await accessControl.isAdmin(addr1.address)).to.be.true;
    });

    it("should allow admin to revoke admin role", async function () {
      await accessControl.manageRole(addr1.address, true);
      await accessControl.manageRole(addr1.address, false);
      expect(await accessControl.isAdmin(addr1.address)).to.be.false;
    });

    it("should revert if non-admin tries to manage roles", async function () {
      await expect(
        accessControl.connect(addr1).manageRole(addr2.address, true)
      ).to.be.revertedWith("AccessControl: Only admin");
    });

    it("should revert if revoking role fails", async function () {
      await expect(
        accessControl.manageRole(addr1.address, false)
      ).to.be.revertedWith("AccessControl: failed to revoke DEFAULT_ADMIN_ROLE");
    });
  });

  describe("upgrade proxy", function () {
    it("should allow upgrade if called by admin", async function () {
      const AccessControlV2 = await ethers.getContractFactory("AccessControl");
       await upgrades.upgradeProxy(
       await accessControl.getAddress(),
        AccessControlV2
      );
    });

    it("should revert if called by non-admin", async function () {
      await expect(
        accessControl.connect(addr1).upgradeToAndCall(owner.address,"0x")
      ).to.be.revertedWith("AccessControl: Only admin can upgrade");
    });
  });
});